import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
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
    final data = await _request(_dashboardQuery, allowPartialData: true);
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
    if (kIsWeb) {
      throw const UnraidApiException(
        '浏览器会拦截 Unraid WebGUI 文件接口的跨域请求。请使用 Android/Windows 客户端浏览共享目录，或为 Web 版本配置同源代理。',
      );
    }

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
    if (kIsWeb) {
      throw const UnraidApiException(
        '浏览器会拦截 Unraid WebGUI 文件接口的跨域请求。请使用 Android/Windows 客户端预览文件，或为 Web 版本配置同源代理。',
      );
    }

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
    bool allowPartialData = false,
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

    final decoded = _decodeGraphqlResponse(response.body);
    if (response.statusCode < 200 || response.statusCode >= 300) {
      final message = _firstGraphqlErrorMessage(decoded);
      throw UnraidApiException(
        message ?? '服务器返回 HTTP ${response.statusCode}',
      );
    }

    if (decoded is! Map<String, dynamic>) {
      throw const UnraidApiException('服务器返回了无效数据');
    }

    final data = decoded['data'];
    final errors = decoded['errors'];
    if (errors is List && errors.isNotEmpty) {
      final message = _firstGraphqlErrorMessage(decoded);
      if (!allowPartialData || data is! Map<String, dynamic>) {
        throw UnraidApiException(message ?? 'GraphQL 请求失败');
      }
    }

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
    required this.version,
    required this.status,
    required this.lanIp,
    required this.uptime,
    required this.cpuSummary,
    required this.cpuPercent,
    required this.baseboardSummary,
    required this.memoryUsage,
    required this.memoryPercent,
    required this.arrayState,
    required this.arrayUsage,
    required this.arrayPercent,
    required this.dockerItems,
    required this.vmItems,
    required this.shareItems,
  });

  final String serverName;
  final String serverDescription;
  final String model;
  final String version;
  final String status;
  final String lanIp;
  final String uptime;
  final String cpuSummary;
  final double cpuPercent;
  final String baseboardSummary;
  final String memoryUsage;
  final double memoryPercent;
  final String arrayState;
  final String arrayUsage;
  final double arrayPercent;
  final List<UnraidManagementItem> dockerItems;
  final List<UnraidManagementItem> vmItems;
  final List<UnraidManagementItem> shareItems;

  factory UnraidDashboard.fromJson(Map<String, dynamic> json) {
    final server = _asMap(json['server']);
    final vars = _asMap(json['vars']);
    final info = _asMap(json['info']);
    final os = _asMap(info['os']);
    final cpu = _asMap(info['cpu']);
    final baseboard = _asMap(info['baseboard']);
    final metrics = _asMap(json['metrics']);
    final cpuMetrics = _asMap(metrics['cpu']);
    final memory = _asMap(metrics['memory']);
    final array = _asMap(json['array']);
    final arrayCapacity = _asMap(_asMap(array['capacity'])['kilobytes']);
    final docker = _asMap(json['docker']);
    final vms = json['vms'];

    final memoryTotal = _asDouble(memory['total']);
    final memoryAvailable = _asDouble(memory['available']);
    final memoryUsed = _firstNumber([
      memory['used'],
      memoryTotal == null || memoryAvailable == null
          ? null
          : memoryTotal - memoryAvailable,
    ]);
    final arrayTotalKb = _asDouble(arrayCapacity['total']);
    final arrayUsedKb = _asDouble(arrayCapacity['used']);

    return UnraidDashboard(
      serverName: _firstText([
        server['name'],
        os['hostname'],
        'Unraid',
      ]),
      serverDescription: _firstText([
        server['comment'],
        os['distro'],
        cpu['brand'],
        'Media server',
      ]),
      model: _firstText([
        baseboard['model'],
        baseboard['manufacturer'],
        cpu['brand'],
        'Custom',
      ]),
      version: _firstText([
        vars['version'],
        os['release'],
        '未知',
      ]),
      status: _formatStatus(server['status']),
      lanIp: _firstText([server['lanip'], '未知']),
      uptime: _formatUptime(os['uptime']),
      cpuSummary: _formatCpuSummary(cpu),
      cpuPercent: _percent(cpuMetrics['percentTotal'], 100),
      baseboardSummary: _formatBaseboardSummary(baseboard),
      memoryUsage: _formatBytesUsage(memoryUsed, memoryTotal),
      memoryPercent: _percent(memoryUsed, memoryTotal),
      arrayState: _formatStatus(array['state']),
      arrayUsage: _formatKilobytesUsage(arrayUsedKb, arrayTotalKb),
      arrayPercent: _percent(arrayUsedKb, arrayTotalKb),
      dockerItems: _asList(docker['containers'])
          .map(UnraidManagementItem.fromDocker)
          .toList(),
      vmItems: _vmList(vms).map(UnraidManagementItem.fromVm).toList(),
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
    final labels = _asMap(json['labels']);
    return UnraidManagementItem(
      id: json['id']?.toString() ?? '',
      title: _cleanDockerName(name?.toString()) ??
          _firstText([json['image'], '未命名容器']),
      status: _formatStatus(json['state'] ?? json['status']),
      description: _firstText([
        json['status'],
        json['image'],
        labels['net.unraid.docker.webui'],
        'Docker 容器',
      ]),
      type: ManagementItemType.docker,
    );
  }

  factory UnraidManagementItem.fromVm(Object? value) {
    final json = _asMap(value);
    final domain = _asMap(json['domain']);
    return UnraidManagementItem(
      id: _firstText([domain['id'], json['id']]),
      title: _firstText([domain['name'], json['name'], '未命名虚拟机']),
      status: _formatStatus(domain['state'] ?? json['state']),
      description: '虚拟机',
      type: ManagementItemType.vm,
    );
  }

  factory UnraidManagementItem.fromShare(Object? value) {
    final json = _asMap(value);
    return UnraidManagementItem(
      id: _firstText([json['id'], json['name'], json['nameOrig']]),
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
    guid
    name
    status
    localurl
    remoteurl
    lanip
    wanip
  }
  vars {
    version
  }
  info {
    cpu {
      id
      manufacturer
      brand
      vendor
      threads
      cores
      socket
    }
    baseboard {
      id
      manufacturer
      model
    }
    os {
      hostname
      distro
      release
      uptime
    }
  }
  metrics {
    cpu {
      id
      percentTotal
    }
    memory {
      id
      total
      used
      free
      available
      percentTotal
    }
  }
  array {
    id
    state
    capacity {
      kilobytes {
        free
        used
        total
      }
    }
  }
  docker {
    containers {
      id
      names
      image
      state
      status
      labels
      autoStart
    }
  }
  vms {
    id
    domain {
      id
      uuid
      name
      state
    }
  }
  shares {
    name
    nameOrig
    comment
    free
    used
    size
    cache
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

List<Object?> _vmList(Object? value) {
  if (value is List) {
    return value;
  }
  if (value is Map<String, dynamic>) {
    final domain = value['domain'];
    if (domain is List) {
      return domain.map((item) => {'domain': item}).toList();
    }
    if (domain is Map<String, dynamic>) {
      return [value];
    }
    return _asList(value['domains']);
  }
  return const [];
}

Object? _decodeGraphqlResponse(String body) {
  try {
    return jsonDecode(body);
  } on FormatException {
    return null;
  }
}

String? _firstGraphqlErrorMessage(Object? decoded) {
  if (decoded is! Map<String, dynamic>) {
    return null;
  }
  final errors = decoded['errors'];
  if (errors is! List || errors.isEmpty) {
    return null;
  }
  final first = errors.first;
  if (first is Map<String, dynamic>) {
    final message = first['message']?.toString().trim();
    return message == null || message.isEmpty ? null : message;
  }
  final message = first?.toString().trim();
  return message == null || message.isEmpty ? null : message;
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

double? _asDouble(Object? value) {
  if (value is num) {
    return value.toDouble();
  }
  return double.tryParse(value?.toString() ?? '');
}

double? _firstNumber(List<Object?> values) {
  for (final value in values) {
    final number = _asDouble(value);
    if (number != null) {
      return number;
    }
  }
  return null;
}

double _percent(Object? used, Object? total) {
  final usedNumber = _asDouble(used);
  final totalNumber = _asDouble(total);
  if (usedNumber == null || totalNumber == null || totalNumber <= 0) {
    return 0;
  }
  return (usedNumber / totalNumber).clamp(0, 1).toDouble();
}

String _formatCpuSummary(Map<String, dynamic> cpu) {
  final brand = _firstText([cpu['brand'], cpu['manufacturer'], '未知 CPU']);
  final cores = _firstText([cpu['cores']]);
  final threads = _firstText([cpu['threads']]);
  final specs = [
    if (cores.isNotEmpty) '$cores 核',
    if (threads.isNotEmpty) '$threads 线程',
  ];
  if (specs.isEmpty) {
    return brand;
  }
  return '$brand · ${specs.join(' / ')}';
}

String _formatBaseboardSummary(Map<String, dynamic> baseboard) {
  return _firstText([
    [
      baseboard['manufacturer'],
      baseboard['model'],
    ].where((value) => _firstText([value]).isNotEmpty).join(' '),
    '未知主板',
  ]);
}

String _formatBytesUsage(Object? used, Object? total) {
  final usedText = _formatBytes(used);
  final totalText = _formatBytes(total);
  if (usedText == null && totalText == null) {
    return '未知';
  }
  if (usedText == null) {
    return '总计 $totalText';
  }
  if (totalText == null) {
    return '已用 $usedText';
  }
  return '$usedText / $totalText';
}

String _formatKilobytesUsage(Object? used, Object? total) {
  final usedText = _formatKilobytes(used);
  final totalText = _formatKilobytes(total);
  if (usedText == null && totalText == null) {
    return '未知';
  }
  if (usedText == null) {
    return '总计 $totalText';
  }
  if (totalText == null) {
    return '已用 $usedText';
  }
  return '$usedText / $totalText';
}

String? _formatBytes(Object? value) {
  final number = _asDouble(value);
  if (number == null) {
    return null;
  }
  return _formatByteAmount(number);
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
    'ONLINE' => '在线',
    'OFFLINE' => '离线',
    'STARTED' => '已启动',
    'STOPPED' => '已停止',
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
  final number = _asDouble(value);
  if (number == null) {
    return null;
  }
  final bytes = number * 1024;
  return _formatByteAmount(bytes);
}

String _formatByteAmount(double bytes) {
  const units = ['B', 'KB', 'MB', 'GB', 'TB', 'PB'];
  var amount = bytes;
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
