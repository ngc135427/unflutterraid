import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:http/http.dart' as http;

class UnraidApiException implements Exception {
  const UnraidApiException(this.message);

  final String message;

  @override
  String toString() => message;
}

class UnraidApiClient {
  UnraidApiClient({
    required String baseUrl,
    required String apiKey,
    http.Client? httpClient,
  })  : baseUrl = _normalizeBaseUrl(baseUrl),
        apiKey = apiKey.trim(),
        _httpClient = httpClient ?? http.Client();

  final String baseUrl;
  final String apiKey;
  final http.Client _httpClient;

  static const _clientOrigin = 'unflutterraid';

  Uri get _graphqlUri => Uri.parse('$baseUrl/graphql');

  Map<String, String> get _authHeaders => {
        'Origin': _clientOrigin,
        'x-api-key': apiKey,
      };

  Future<void> checkConnection() async {
    final data = await _request(_servicesCheckQuery);
    final services = _asList(data['services']);
    final hasUnraidApi = services.any((service) {
      final serviceMap = _asMap(service);
      return serviceMap['name']?.toString() == 'unraid-api';
    });
    if (!hasUnraidApi) {
      throw const UnraidApiException(
        '未找到 unraid-api 服务，请确认 Unraid Connect/API 插件已启用',
      );
    }
    await _request(_loginCheckQuery);
  }

  Future<UnraidDashboard> fetchDashboard() async {
    final data = await _request(_dashboardQuery);
    return UnraidDashboard.fromJson(data);
  }

  void close() {
    _httpClient.close();
  }

  Future<void> runManagementAction({
    required ManagementItemType type,
    required String id,
    required ManagementAction action,
  }) async {
    final mutation = switch (type) {
      ManagementItemType.docker => _dockerActionMutation(action),
      ManagementItemType.vm => _vmActionMutation(action),
      ManagementItemType.share => throw const UnraidApiException('共享项目不支持该操作'),
    };

    await _request(
      mutation,
      variables: {'id': id},
    );
  }

  Future<List<UnraidFileEntry>> fetchDirectory(String path) async {
    final uri = Uri.parse('$baseUrl/webGui/include/Browse.php').replace(
      queryParameters: {
        'dir': path,
        'path': 'Browse',
      },
    );

    late http.Response response;
    try {
      response = await _httpClient
          .get(uri, headers: _authHeaders)
          .timeout(const Duration(seconds: 12));
    } on TimeoutException {
      throw const UnraidApiException('读取目录超时');
    } on Object catch (error) {
      throw UnraidApiException('无法读取目录：$error');
    }

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw UnraidApiException('目录接口返回 HTTP ${response.statusCode}');
    }

    return _parseBrowseHtml(response.body);
  }

  Future<Uint8List> fetchFileBytes(String path) async {
    final uri = _fileUri(path);
    late http.Response response;
    try {
      response = await _httpClient
          .get(uri, headers: _authHeaders)
          .timeout(const Duration(seconds: 20));
    } on TimeoutException {
      throw const UnraidApiException('加载图片超时');
    } on Object catch (error) {
      throw UnraidApiException('无法加载图片：$error');
    }

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw UnraidApiException('图片接口返回 HTTP ${response.statusCode}');
    }
    return response.bodyBytes;
  }

  Uri _fileUri(String path) {
    final encodedPath = path
        .split('/')
        .map((segment) => Uri.encodeComponent(segment))
        .join('/');
    return Uri.parse(baseUrl).resolve(encodedPath);
  }

  Future<Map<String, dynamic>> _request(
    String query, {
    Map<String, dynamic>? variables,
  }) async {
    late http.Response response;
    try {
      response = await _httpClient
          .post(
            _graphqlUri,
            headers: {
              'content-type': 'application/json',
              'accept': 'application/json',
              ..._authHeaders,
            },
            body: jsonEncode({
              'query': query,
              if (variables != null) 'variables': variables,
            }),
          )
          .timeout(const Duration(seconds: 12));
    } on TimeoutException {
      throw const UnraidApiException('连接服务器超时');
    } on Object catch (error) {
      throw UnraidApiException('无法连接服务器：$error');
    }

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw UnraidApiException('服务器返回 HTTP ${response.statusCode}');
    }

    final decoded = jsonDecode(response.body);
    if (decoded is! Map<String, dynamic>) {
      throw const UnraidApiException('服务器返回了无效数据');
    }

    final errors = decoded['errors'];
    if (errors is List && errors.isNotEmpty) {
      final first = errors.first;
      final message = first is Map<String, dynamic>
          ? first['message']?.toString()
          : first.toString();
      throw UnraidApiException(message ?? 'GraphQL 请求失败');
    }

    final data = decoded['data'];
    if (data is! Map<String, dynamic>) {
      throw const UnraidApiException('响应中缺少 data 字段');
    }
    return data;
  }

  static String _normalizeBaseUrl(String value) {
    final trimmed = value.trim();
    final withoutTrailingSlash = trimmed.endsWith('/')
        ? trimmed.substring(0, trimmed.length - 1)
        : trimmed;
    return withoutTrailingSlash;
  }
}

enum ManagementItemType { docker, vm, share }

enum ManagementAction { start, stop, restart }

class UnraidDashboard {
  const UnraidDashboard({
    required this.serverName,
    required this.serverDescription,
    required this.model,
    required this.registration,
    required this.uptime,
    required this.dockerItems,
    required this.vmItems,
    required this.shareItems,
  });

  final String serverName;
  final String serverDescription;
  final String model;
  final String registration;
  final String uptime;
  final List<UnraidManagementItem> dockerItems;
  final List<UnraidManagementItem> vmItems;
  final List<UnraidManagementItem> shareItems;

  factory UnraidDashboard.fromJson(Map<String, dynamic> json) {
    final server = _asMap(json['server']);
    final info = _asMap(json['info']);
    final os = _asMap(info['os']);
    final system = _asMap(info['system']);
    final registration = _asMap(json['registration']);
    final docker = _asMap(json['docker']);
    final vms = _asMap(json['vms']);

    return UnraidDashboard(
      serverName: _firstText([
        server['name'],
        os['hostname'],
        'Unraid',
      ]),
      serverDescription: _firstText([
        server['comment'],
        system['model'],
        os['distro'],
        'Media server',
      ]),
      model: _firstText([
        system['model'],
        system['manufacturer'],
        'Custom',
      ]),
      registration: _firstText([
        registration['type'],
        registration['state'],
        '未知',
      ]),
      uptime: _formatUptime(os['uptime']),
      dockerItems: _asList(docker['containers'])
          .map(UnraidManagementItem.fromDocker)
          .toList(),
      vmItems:
          _asList(vms['domains']).map(UnraidManagementItem.fromVm).toList(),
      shareItems:
          _asList(json['shares']).map(UnraidManagementItem.fromShare).toList(),
    );
  }
}

class UnraidManagementItem {
  const UnraidManagementItem({
    required this.id,
    required this.title,
    required this.status,
    required this.description,
    required this.type,
  });

  final String id;
  final String title;
  final String status;
  final String description;
  final ManagementItemType type;

  factory UnraidManagementItem.fromDocker(Object? value) {
    final json = _asMap(value);
    final names = _asList(json['names']);
    final name = names.isEmpty ? null : names.first;
    return UnraidManagementItem(
      id: json['id']?.toString() ?? '',
      title: _cleanDockerName(name?.toString()) ??
          _firstText([json['image'], '未命名容器']),
      status: _formatStatus(json['state'] ?? json['status']),
      description: _firstText([
        json['status'],
        json['image'],
        json['webUiUrl'],
        'Docker 容器',
      ]),
      type: ManagementItemType.docker,
    );
  }

  factory UnraidManagementItem.fromVm(Object? value) {
    final json = _asMap(value);
    return UnraidManagementItem(
      id: json['id']?.toString() ?? '',
      title: _firstText([json['name'], '未命名虚拟机']),
      status: _formatStatus(json['state']),
      description: '虚拟机',
      type: ManagementItemType.vm,
    );
  }

  factory UnraidManagementItem.fromShare(Object? value) {
    final json = _asMap(value);
    return UnraidManagementItem(
      id: json['id']?.toString() ?? '',
      title: _firstText([json['name'], json['nameOrig'], '未命名共享']),
      status: json['cache'] == true ? '缓存' : '阵列',
      description: _firstText([
        json['comment'],
        _formatShareSize(json['used'], json['size']),
        '共享目录',
      ]),
      type: ManagementItemType.share,
    );
  }
}

class UnraidFileEntry {
  const UnraidFileEntry({
    required this.name,
    required this.path,
    required this.isDirectory,
    required this.size,
    required this.modified,
  });

  final String name;
  final String path;
  final bool isDirectory;
  final String size;
  final String modified;

  bool get isImage {
    final ext = name.split('.').last.toLowerCase();
    return const {
      'avif',
      'bmp',
      'gif',
      'ico',
      'jpeg',
      'jpg',
      'png',
      'tif',
      'tiff',
      'webp',
    }.contains(ext);
  }
}

const _loginCheckQuery = '''
query LoginCheck {
  me {
    id
    name
  }
}
''';

const _servicesCheckQuery = '''
query ServicesCheck {
  services {
    id
    name
    version
  }
}
''';

const _dashboardQuery = '''
query Dashboard {
  server {
    id
    name
    comment
    status
    localurl
    remoteurl
    lanip
    wanip
  }
  registration {
    type
    state
  }
  info {
    os {
      hostname
      distro
      release
      uptime
    }
    system {
      manufacturer
      model
    }
  }
  docker {
    containers {
      id
      names
      image
      state
      status
      webUiUrl
      autoStart
    }
  }
  vms {
    domains {
      id
      name
      state
    }
  }
  shares {
    id
    name
    nameOrig
    comment
    cache
    used
    size
  }
}
''';

String _dockerActionMutation(ManagementAction action) {
  final field = switch (action) {
    ManagementAction.start => 'start',
    ManagementAction.stop => 'stop',
    ManagementAction.restart => 'restart',
  };
  if (action == ManagementAction.restart) {
    return '''
mutation RestartDocker(\$id: PrefixedID!) {
  stop: docker {
    stop(id: \$id) {
      id
    }
  }
  start: docker {
    start(id: \$id) {
      id
    }
  }
}
''';
  }
  return '''
mutation DockerAction(\$id: PrefixedID!) {
  docker {
    $field(id: \$id) {
      id
    }
  }
}
''';
}

String _vmActionMutation(ManagementAction action) {
  final field = switch (action) {
    ManagementAction.start => 'start',
    ManagementAction.stop => 'stop',
    ManagementAction.restart => 'reboot',
  };
  return '''
mutation VmAction(\$id: PrefixedID!) {
  vm {
    $field(id: \$id)
  }
}
''';
}

Map<String, dynamic> _asMap(Object? value) {
  return value is Map<String, dynamic> ? value : const {};
}

List<Object?> _asList(Object? value) {
  return value is List ? value : const [];
}

String _firstText(List<Object?> values) {
  for (final value in values) {
    final text = value?.toString().trim();
    if (text != null && text.isNotEmpty) {
      return text;
    }
  }
  return '';
}

String? _cleanDockerName(String? value) {
  final trimmed = value?.trim();
  if (trimmed == null || trimmed.isEmpty) {
    return null;
  }
  return trimmed.startsWith('/') ? trimmed.substring(1) : trimmed;
}

String _formatStatus(Object? value) {
  final raw = value?.toString().trim();
  return switch (raw) {
    'RUNNING' => '运行中',
    'PAUSED' => '已暂停',
    'EXITED' => '已停止',
    'IDLE' => '空闲',
    'SHUTDOWN' || 'SHUTOFF' => '已关闭',
    'CRASHED' => '异常',
    'PMSUSPENDED' => '休眠',
    null || '' => '未知',
    _ => raw,
  };
}

String _formatShareSize(Object? used, Object? total) {
  final usedText = _formatKilobytes(used);
  final totalText = _formatKilobytes(total);
  if (usedText == null && totalText == null) {
    return '共享目录';
  }
  if (usedText == null) {
    return '总计 $totalText';
  }
  if (totalText == null) {
    return '已用 $usedText';
  }
  return '已用 $usedText / $totalText';
}

String? _formatKilobytes(Object? value) {
  final number = int.tryParse(value?.toString() ?? '');
  if (number == null) {
    return null;
  }
  final bytes = number * 1024;
  const units = ['B', 'KB', 'MB', 'GB', 'TB', 'PB'];
  var amount = bytes.toDouble();
  var unit = 0;
  while (amount >= 1024 && unit < units.length - 1) {
    amount /= 1024;
    unit += 1;
  }
  return '${amount.toStringAsFixed(amount >= 10 ? 0 : 1)} ${units[unit]}';
}

String _formatUptime(Object? value) {
  final raw = value?.toString();
  if (raw == null || raw.isEmpty) {
    return '未知';
  }
  final bootTime = DateTime.tryParse(raw);
  if (bootTime == null) {
    return raw;
  }
  final elapsed = DateTime.now().difference(bootTime);
  if (elapsed.inDays > 0) {
    return '${elapsed.inDays} 天';
  }
  if (elapsed.inHours > 0) {
    return '${elapsed.inHours} 小时';
  }
  return '${elapsed.inMinutes} 分钟';
}

List<UnraidFileEntry> _parseBrowseHtml(String html) {
  final rows = RegExp(
    r'<tr[^>]*>(.*?)</tr>',
    caseSensitive: false,
    dotAll: true,
  ).allMatches(html);

  return rows
      .map((match) => _parseBrowseRow(match.group(1) ?? ''))
      .whereType<UnraidFileEntry>()
      .toList();
}

UnraidFileEntry? _parseBrowseRow(String row) {
  final link = RegExp(
    r'<a[^>]+href="([^"]+)"[^>]*>(.*?)</a>',
    caseSensitive: false,
    dotAll: true,
  ).firstMatch(row);
  if (link == null) {
    return null;
  }

  final href = _decodeHtml(link.group(1) ?? '').trim();
  final name = _stripHtml(link.group(2) ?? '').trim();
  if (name.isEmpty || name == 'Parent Directory') {
    return null;
  }

  final isDirectory = href.contains('?dir=');
  final path = isDirectory ? _pathFromBrowseHref(href) : href;
  if (path.isEmpty) {
    return null;
  }

  final cells = RegExp(
    r'<td[^>]*>(.*?)</td>',
    caseSensitive: false,
    dotAll: true,
  ).allMatches(row).map((match) => _stripHtml(match.group(1) ?? '')).toList();

  return UnraidFileEntry(
    name: name,
    path: path,
    isDirectory: isDirectory,
    size: cells.length > 5 ? cells[5] : '',
    modified: cells.length > 6 ? cells[6] : '',
  );
}

String _pathFromBrowseHref(String href) {
  final uri = Uri.tryParse(href);
  final dir = uri?.queryParameters['dir'];
  if (dir == null || dir.isEmpty) {
    return '';
  }
  return Uri.decodeComponent(dir);
}

String _stripHtml(String value) {
  return _decodeHtml(value.replaceAll(RegExp(r'<[^>]*>'), '').trim());
}

String _decodeHtml(String value) {
  return value
      .replaceAll('&amp;', '&')
      .replaceAll('&lt;', '<')
      .replaceAll('&gt;', '>')
      .replaceAll('&quot;', '"')
      .replaceAll('&#039;', "'")
      .replaceAll('&nbsp;', ' ');
}
