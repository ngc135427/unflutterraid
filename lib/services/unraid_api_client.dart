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
    required this.guid,
    required this.ownerName,
    required this.registration,
    required this.model,
    required this.version,
    required this.status,
    required this.lanIp,
    required this.wanIp,
    required this.localUrl,
    required this.remoteUrl,
    required this.uptime,
    required this.cpuSummary,
    required this.cpuPercent,
    required this.baseboardSummary,
    required this.osSummary,
    required this.packagesSummary,
    required this.memoryUsage,
    required this.memoryPercent,
    required this.arrayState,
    required this.arrayUsage,
    required this.arrayPercent,
    required this.paritySummary,
    required this.notificationInfo,
    required this.notificationWarning,
    required this.notificationAlert,
    required this.notificationTotal,
    required this.notifications,
    required this.diskItems,
    required this.networkItems,
    required this.upsItems,
    required this.pluginItems,
    required this.securityItems,
    required this.cloudItems,
    required this.logItems,
    required this.servicesSummary,
    required this.dockerNetworkSummary,
    required this.dockerConflictSummary,
    required this.dockerItems,
    required this.vmItems,
    required this.shareItems,
  });

  final String serverName;
  final String serverDescription;
  final String guid;
  final String ownerName;
  final String registration;
  final String model;
  final String version;
  final String status;
  final String lanIp;
  final String wanIp;
  final String localUrl;
  final String remoteUrl;
  final String uptime;
  final String cpuSummary;
  final double cpuPercent;
  final String baseboardSummary;
  final String osSummary;
  final String packagesSummary;
  final String memoryUsage;
  final double memoryPercent;
  final String arrayState;
  final String arrayUsage;
  final double arrayPercent;
  final String paritySummary;
  final int notificationInfo;
  final int notificationWarning;
  final int notificationAlert;
  final int notificationTotal;
  final List<UnraidNotification> notifications;
  final List<UnraidInfoItem> diskItems;
  final List<UnraidInfoItem> networkItems;
  final List<UnraidInfoItem> upsItems;
  final List<UnraidInfoItem> pluginItems;
  final List<UnraidInfoItem> securityItems;
  final List<UnraidInfoItem> cloudItems;
  final List<UnraidInfoItem> logItems;
  final String servicesSummary;
  final String dockerNetworkSummary;
  final String dockerConflictSummary;
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
    final notifications = _asMap(json['notifications']);
    final unreadNotifications =
        _asMap(_asMap(notifications['overview'])['unread']);
    final registration = _asMap(json['registration']);
    final owner = _asMap(json['owner']);
    final network = _asMap(json['network']);
    final remoteAccess = _asMap(json['remoteAccess']);
    final connect = _asMap(json['connect']);
    final cloud = _asMap(json['cloud']);

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
    final services = _asList(json['services']);
    final plugins = _asList(json['plugins']);
    final installedPlugins = _asList(json['installedUnraidPlugins']);
    final apiKeys = _asList(json['apiKeys']);
    final oidcProviders = _asList(json['oidcProviders']);
    final dockerNetworks = _asList(docker['networks']);
    final portConflicts = _asMap(docker['portConflicts']);
    final logFiles = _asList(json['logFiles']);

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
      guid: _firstText([server['guid'], '未知']),
      ownerName: _firstText([
        owner['username'],
        _asMap(server['owner'])['username'],
        '未绑定',
      ]),
      registration: _firstText([
        registration['type'],
        registration['state'],
        '未知',
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
      wanIp: _firstText([server['wanip'], '未知']),
      localUrl: _firstText([server['localurl'], '未返回']),
      remoteUrl: _firstText([server['remoteurl'], '未返回']),
      uptime: _formatUptime(os['uptime']),
      cpuSummary: _formatCpuSummary(cpu),
      cpuPercent: _percent(cpuMetrics['percentTotal'], 100),
      baseboardSummary: _formatBaseboardSummary(baseboard),
      osSummary: _formatOsSummary(os),
      packagesSummary:
          _formatPackagesSummary(_asMap(_asMap(info['versions'])['packages'])),
      memoryUsage: _formatBytesUsage(memoryUsed, memoryTotal),
      memoryPercent: _percent(memoryUsed, memoryTotal),
      arrayState: _formatStatus(array['state']),
      arrayUsage: _formatKilobytesUsage(arrayUsedKb, arrayTotalKb),
      arrayPercent: _percent(arrayUsedKb, arrayTotalKb),
      paritySummary: _formatParitySummary(_asMap(array['parityCheckStatus'])),
      notificationInfo: _asInt(unreadNotifications['info']),
      notificationWarning: _asInt(unreadNotifications['warning']),
      notificationAlert: _asInt(unreadNotifications['alert']),
      notificationTotal: _asInt(unreadNotifications['total']),
      notifications: _asList(notifications['warningsAndAlerts'])
          .map(UnraidNotification.fromJson)
          .toList(),
      diskItems: _asList(json['disks']).map(UnraidInfoItem.fromDisk).toList(),
      networkItems: _asList(json['networkInterfaces']).isNotEmpty
          ? _asList(json['networkInterfaces'])
              .map(UnraidInfoItem.fromNetworkInterface)
              .toList()
          : _asList(network['accessUrls'])
              .map(UnraidInfoItem.fromAccessUrl)
              .toList(),
      upsItems:
          _asList(json['upsDevices']).map(UnraidInfoItem.fromUps).toList(),
      pluginItems: [
        ...plugins.map(UnraidInfoItem.fromPlugin),
        if (installedPlugins.isNotEmpty)
          UnraidInfoItem(
            title: '已安装插件',
            value: '${installedPlugins.length} 个',
            description: installedPlugins.take(3).join(' · '),
            severity: InfoSeverity.normal,
          ),
        ..._asList(json['pluginInstallOperations'])
            .map(UnraidInfoItem.fromPluginOperation),
      ],
      securityItems: [
        UnraidInfoItem(
          title: 'API Keys',
          value: '${apiKeys.length} 个',
          description: '可用角色与权限来自 apiKeyPossibleRoles',
          severity: InfoSeverity.normal,
        ),
        UnraidInfoItem(
          title: 'SSO',
          value: json['isSSOEnabled'] == true ? '已启用' : '未启用',
          description: '${oidcProviders.length} 个 OIDC 提供方',
          severity: json['isSSOEnabled'] == true
              ? InfoSeverity.success
              : InfoSeverity.warning,
        ),
      ],
      cloudItems: [
        UnraidInfoItem(
          title: 'Cloud',
          value: _formatStatus(_asMap(cloud['cloud'])['status']),
          description: _firstText([
            _asMap(cloud['cloud'])['ip'],
            _asMap(cloud['cloud'])['error'],
            'Unraid Cloud 状态',
          ]),
          severity: _severityForStatus(_asMap(cloud['cloud'])['status']),
        ),
        UnraidInfoItem(
          title: 'Relay',
          value: _formatStatus(_asMap(cloud['relay'])['status']),
          description: _firstText([
            _asMap(cloud['relay'])['error'],
            '动态远程访问 ${_firstText([
                  _asMap(connect['dynamicRemoteAccess'])['runningType'],
                  remoteAccess['accessType'],
                  '未知'
                ])}',
          ]),
          severity: _severityForStatus(_asMap(cloud['relay'])['status']),
        ),
        UnraidInfoItem(
          title: '远程访问',
          value: _firstText([remoteAccess['accessType'], '未知']),
          description: '${_firstText([
                remoteAccess['forwardType'],
                'forward 未知'
              ])} · 端口 ${_firstText([remoteAccess['port'], '未知'])}',
          severity: InfoSeverity.normal,
        ),
      ],
      logItems: logFiles.map(UnraidInfoItem.fromLogFile).toList(),
      servicesSummary: _formatServicesSummary(services),
      dockerNetworkSummary: _formatDockerNetworkSummary(dockerNetworks),
      dockerConflictSummary: _formatDockerConflictSummary(portConflicts),
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
    this.progress = 0,
    this.tags = const [],
    this.details = const [],
  });

  final String id;
  final String title;
  final String status;
  final String description;
  final ManagementItemType type;
  final double progress;
  final List<String> tags;
  final List<UnraidInfoItem> details;

  factory UnraidManagementItem.fromDocker(Object? value) {
    final json = _asMap(value);
    final names = _asList(json['names']);
    final name = names.isEmpty ? null : names.first;
    final labels = _asMap(json['labels']);
    final ports = _asList(json['ports']);
    final hostConfig = _asMap(json['hostConfig']);
    final tailscale = _asMap(json['tailscaleStatus']);
    final updateStatus = _firstText([json['updateStatus']]);
    final networkMode = _firstText([hostConfig['networkMode']]);
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
      tags: [
        if (networkMode.isNotEmpty) networkMode,
        if (json['autoStart'] == true) '自启动',
        if (json['isUpdateAvailable'] == true || updateStatus.isNotEmpty) '有更新',
        if (json['tailscaleEnabled'] == true) 'Tailscale',
      ],
      details: [
        UnraidInfoItem(
          title: '镜像',
          value: _firstText([json['image'], '未知']),
          description: _firstText([json['imageId'], 'Docker image']),
          severity: InfoSeverity.normal,
        ),
        UnraidInfoItem(
          title: '端口',
          value: _formatContainerPorts(ports),
          description: _firstText([json['lanIpPorts'], '未返回端口映射']),
          severity: InfoSeverity.normal,
        ),
        if (json['tailscaleEnabled'] == true)
          UnraidInfoItem(
            title: 'Tailscale',
            value: tailscale['online'] == true ? '在线' : '离线',
            description: _firstText([
              tailscale['dnsName'],
              tailscale['hostname'],
              tailscale['backendState'],
            ]),
            severity: tailscale['online'] == true
                ? InfoSeverity.success
                : InfoSeverity.warning,
          ),
      ],
    );
  }

  factory UnraidManagementItem.fromVm(Object? value) {
    final json = _asMap(value);
    final domain = _asMap(json['domain']);
    final state = domain['state'] ?? json['state'];
    return UnraidManagementItem(
      id: _firstText([domain['id'], json['id']]),
      title: _firstText([domain['name'], json['name'], '未命名虚拟机']),
      status: _formatStatus(state),
      description: '虚拟机',
      type: ManagementItemType.vm,
      tags: [
        if (_firstText([domain['uuid']]).isNotEmpty) 'UUID',
        if (_formatStatus(state) == '运行中') 'VNC 可用',
      ],
      details: [
        UnraidInfoItem(
          title: 'UUID',
          value: _firstText([domain['uuid'], '未知']),
          description: '虚拟机域标识',
          severity: InfoSeverity.normal,
        ),
        UnraidInfoItem(
          title: '状态',
          value: _formatStatus(state),
          description: '来自 vms.domain.state',
          severity: _severityForStatus(state),
        ),
      ],
    );
  }

  factory UnraidManagementItem.fromShare(Object? value) {
    final json = _asMap(value);
    final used = _asDouble(json['used']);
    final total = _asDouble(json['size']);
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
      progress: _percent(used, total),
      tags: [
        if (json['cache'] == true) 'cache',
        if (_firstText([json['include']]).isNotEmpty)
          'include ${json['include']}',
        if (_firstText([json['exclude']]).isNotEmpty)
          'exclude ${json['exclude']}',
        if (_firstText([json['luksStatus']]).isNotEmpty)
          '${json['luksStatus']}',
      ],
      details: [
        UnraidInfoItem(
          title: '容量',
          value: _formatShareSize(json['used'], json['size']),
          description: 'free ${_formatKilobytes(json['free']) ?? '未知'}',
          severity: _percent(used, total) > 0.85
              ? InfoSeverity.warning
              : InfoSeverity.normal,
        ),
        UnraidInfoItem(
          title: '分配策略',
          value: _firstText([json['allocator'], '未知']),
          description: 'split level ${_firstText([json['splitLevel'], '默认'])}',
          severity: InfoSeverity.normal,
        ),
        UnraidInfoItem(
          title: '说明',
          value: _firstText([json['comment'], '无']),
          description: '共享目录配置',
          severity: InfoSeverity.normal,
        ),
      ],
    );
  }
}

enum InfoSeverity { normal, success, warning, danger }

class UnraidInfoItem {
  const UnraidInfoItem({
    required this.title,
    required this.value,
    required this.description,
    required this.severity,
  });

  final String title;
  final String value;
  final String description;
  final InfoSeverity severity;

  factory UnraidInfoItem.fromDisk(Object? value) {
    final json = _asMap(value);
    final temp = _firstText([json['temperature']]);
    return UnraidInfoItem(
      title: _firstText([json['name'], json['device'], '未知磁盘']),
      value: _firstText([json['smartStatus'], json['type'], '未知']),
      description: [
        if (_firstText([json['vendor']]).isNotEmpty) json['vendor'],
        if (_formatBytes(json['size']) != null) _formatBytes(json['size']),
        if (temp.isNotEmpty) '$temp°C',
        if (json['isSpinning'] == false) '休眠',
      ].join(' · '),
      severity: _severityForSmart(json['smartStatus'], json['temperature']),
    );
  }

  factory UnraidInfoItem.fromNetworkInterface(Object? value) {
    final json = _asMap(value);
    return UnraidInfoItem(
      title: _firstText([json['name'], json['iface'], '网络接口']),
      value: _firstText([json['status'], json['operstate'], '未知']),
      description: [
        _firstText([json['ipAddress'], json['macAddress'], '无地址']),
        if (_firstText([json['speed']]).isNotEmpty) '${json['speed']} Mbps',
        if (_firstText([json['type']]).isNotEmpty) json['type'],
      ].join(' · '),
      severity: _severityForStatus(json['status'] ?? json['operstate']),
    );
  }

  factory UnraidInfoItem.fromAccessUrl(Object? value) {
    final json = _asMap(value);
    return UnraidInfoItem(
      title: _firstText([json['name'], json['type'], '访问地址']),
      value: _firstText([json['ipv4'], json['ipv6'], '未返回']),
      description: _firstText([json['type'], 'network.accessUrls']),
      severity: InfoSeverity.normal,
    );
  }

  factory UnraidInfoItem.fromUps(Object? value) {
    final json = _asMap(value);
    final battery = _asMap(json['battery']);
    final power = _asMap(json['power']);
    return UnraidInfoItem(
      title: _firstText([json['name'], json['model'], 'UPS']),
      value: _formatStatus(json['status']),
      description: '电量 ${_firstText([
            battery['chargeLevel'],
            '未知'
          ])}% · 负载 ${_firstText([power['loadPercentage'], '未知'])}%',
      severity: _severityForStatus(json['status']),
    );
  }

  factory UnraidInfoItem.fromPlugin(Object? value) {
    final json = _asMap(value);
    return UnraidInfoItem(
      title: _firstText([json['name'], '插件']),
      value: _firstText([json['version'], '未知版本']),
      description:
          'API ${json['hasApiModule'] == true ? '有' : '无'} · CLI ${json['hasCliModule'] == true ? '有' : '无'}',
      severity: json['hasApiModule'] == true
          ? InfoSeverity.success
          : InfoSeverity.normal,
    );
  }

  factory UnraidInfoItem.fromPluginOperation(Object? value) {
    final json = _asMap(value);
    return UnraidInfoItem(
      title: _firstText([json['name'], json['url'], '插件安装任务']),
      value: _formatStatus(json['status']),
      description: _firstText([json['updatedAt'], json['createdAt'], '安装任务']),
      severity: _severityForStatus(json['status']),
    );
  }

  factory UnraidInfoItem.fromLogFile(Object? value) {
    final json = _asMap(value);
    return UnraidInfoItem(
      title: _firstText([json['name'], json['path'], '日志']),
      value: _formatBytes(json['size']) ?? '未知大小',
      description: _firstText([json['modifiedAt'], json['path'], 'logFiles']),
      severity: InfoSeverity.normal,
    );
  }
}

class UnraidNotification {
  const UnraidNotification({
    required this.title,
    required this.subject,
    required this.description,
    required this.importance,
    required this.timestamp,
  });

  final String title;
  final String subject;
  final String description;
  final String importance;
  final String timestamp;

  factory UnraidNotification.fromJson(Object? value) {
    final json = _asMap(value);
    return UnraidNotification(
      title: _firstText([json['title'], json['subject'], '通知']),
      subject: _firstText([json['subject'], json['type'], '']),
      description: _firstText([json['description'], json['link'], '']),
      importance: _firstText([json['importance'], json['type'], 'info']),
      timestamp:
          _firstText([json['formattedTimestamp'], json['timestamp'], '']),
    );
  }

  InfoSeverity get severity {
    final raw = importance.toLowerCase();
    if (raw.contains('alert') || raw.contains('critical')) {
      return InfoSeverity.danger;
    }
    if (raw.contains('warning')) {
      return InfoSeverity.warning;
    }
    return InfoSeverity.normal;
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
  owner {
    username
    url
    avatar
  }
  registration {
    id
    type
    state
    expiration
  }
  server {
    id
    guid
    name
    comment
    status
    localurl
    remoteurl
    lanip
    wanip
    owner {
      username
    }
  }
  services {
    id
    name
    online
    version
    uptime {
      timestamp
    }
  }
  vars {
    version
    timeZone
    useNtp
    shareSmbEnabled
    shareNfsEnabled
    useSsl
    port
    portssl
    useSsh
    portssh
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
      version
    }
    os {
      id
      platform
      hostname
      distro
      release
      kernel
      arch
      uptime
    }
    versions {
      id
      packages {
        openssl
        node
        npm
        pm2
        git
        nginx
        php
        docker
      }
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
    temperature {
      id
      summary {
        average
        warningCount
        criticalCount
        hottest {
          id
          name
          type
          location
          warning
          critical
        }
      }
    }
    network {
      id
      name
      operstate
      rxSec
      txSec
      utilizationPercent
      lastUpdated
    }
  }
  notifications {
    id
    overview {
      unread {
        info
        warning
        alert
        total
      }
    }
    warningsAndAlerts {
      id
      title
      subject
      description
      importance
      link
      type
      timestamp
      formattedTimestamp
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
    parityCheckStatus {
      date
      duration
      speed
      status
      errors
      progress
      correcting
      paused
      running
    }
  }
  parityHistory {
    date
    duration
    speed
    status
    errors
    progress
    correcting
    paused
    running
  }
  docker {
    containers {
      id
      names
      image
      imageId
      command
      created
      lanIpPorts
      sizeRootFs
      sizeRw
      sizeLog
      state
      status
      hostConfig {
        networkMode
      }
      labels
      autoStart
      autoStartOrder
      webUiUrl
      templatePath
      isOrphaned
      isUpdateAvailable
      isRebuildReady
      tailscaleEnabled
      tailscaleStatus {
        online
        hostname
        dnsName
        backendState
      }
      ports {
        ip
        privatePort
        publicPort
        type
      }
    }
    networks {
      id
      name
      scope
      driver
      containers
    }
    portConflicts {
      containerPorts {
        privatePort
        type
        containers {
          id
          name
        }
      }
      lanPorts {
        lanIpPort
        publicPort
        type
      }
    }
    containerUpdateStatuses {
      name
      updateStatus
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
    id
    name
    nameOrig
    comment
    free
    used
    size
    include
    exclude
    cache
    allocator
    splitLevel
    floor
    cow
    color
    luksStatus
  }
  disks {
    id
    device
    type
    name
    vendor
    size
    smartStatus
    temperature
    interfaceType
    isSpinning
  }
  networkInterfaces {
    id
    name
    description
    macAddress
    mtu
    speed
    operstate
    type
    status
    ipAddress
    gateway
  }
  upsDevices {
    id
    name
    model
    status
    battery {
      chargeLevel
      estimatedRuntime
      health
    }
    power {
      loadPercentage
      currentPower
      nominalPower
    }
  }
  apiKeys {
    id
  }
  isSSOEnabled
  oidcProviders {
    id
    name
  }
  pluginInstallOperations {
    id
    url
    name
    status
    createdAt
    updatedAt
  }
  installedUnraidPlugins
  plugins {
    name
    version
    hasApiModule
    hasCliModule
  }
  remoteAccess {
    accessType
    forwardType
    port
  }
  connect {
    id
    dynamicRemoteAccess {
      enabledType
      runningType
      error
    }
  }
  network {
    id
    accessUrls {
      type
      name
      ipv4
      ipv6
    }
  }
  cloud {
    error
    relay {
      status
      timeout
      error
    }
    cloud {
      status
      ip
      error
    }
    minigraphql {
      status
      timeout
      error
    }
    allowedOrigins
  }
  logFiles {
    name
    path
    size
    modifiedAt
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

int _asInt(Object? value) {
  if (value is int) {
    return value;
  }
  if (value is num) {
    return value.toInt();
  }
  return int.tryParse(value?.toString() ?? '') ?? 0;
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

String _formatOsSummary(Map<String, dynamic> os) {
  return _firstText([
    [
      os['distro'],
      os['release'],
      os['kernel'],
      os['arch'],
    ].where((value) => _firstText([value]).isNotEmpty).join(' · '),
    '未知系统',
  ]);
}

String _formatPackagesSummary(Map<String, dynamic> packages) {
  final names = ['docker', 'nginx', 'php', 'node', 'git']
      .where((key) => _firstText([packages[key]]).isNotEmpty)
      .map((key) => '$key ${packages[key]}')
      .toList();
  if (names.isEmpty) {
    return '未返回包版本';
  }
  return names.take(3).join(' · ');
}

String _formatParitySummary(Map<String, dynamic> parity) {
  final status = _formatStatus(parity['status']);
  final progress = _firstText([parity['progress']]);
  final errors = _firstText([parity['errors']]);
  final speed = _firstText([parity['speed']]);
  final parts = [
    status,
    if (progress.isNotEmpty) '$progress%',
    if (speed.isNotEmpty) speed,
    if (errors.isNotEmpty) '$errors errors',
  ];
  return parts.where((part) => part.isNotEmpty && part != '未知').join(' · ');
}

String _formatServicesSummary(List<Object?> services) {
  final online =
      services.where((value) => _asMap(value)['online'] == true).length;
  final names = services
      .map((value) => _firstText([_asMap(value)['name']]))
      .where((value) => value.isNotEmpty)
      .take(3)
      .toList();
  if (services.isEmpty) {
    return '未返回服务';
  }
  return '$online/${services.length} 在线 · ${names.join(' · ')}';
}

String _formatDockerNetworkSummary(List<Object?> networks) {
  if (networks.isEmpty) {
    return '未返回网络';
  }
  final names = networks
      .map((value) => _firstText([_asMap(value)['name']]))
      .where((value) => value.isNotEmpty)
      .take(3)
      .join(' · ');
  return '${networks.length} 个网络${names.isEmpty ? '' : ' · $names'}';
}

String _formatDockerConflictSummary(Map<String, dynamic> conflicts) {
  final containerPorts = _asList(conflicts['containerPorts']);
  final lanPorts = _asList(conflicts['lanPorts']);
  final total = containerPorts.length + lanPorts.length;
  if (total == 0) {
    return '未发现端口冲突';
  }
  return '$total 个端口冲突';
}

String _formatContainerPorts(List<Object?> ports) {
  final mapped = ports.map((value) {
    final json = _asMap(value);
    final privatePort = _firstText([json['privatePort']]);
    final publicPort = _firstText([json['publicPort']]);
    final type = _firstText([json['type'], 'tcp']);
    if (privatePort.isEmpty && publicPort.isEmpty) {
      return '';
    }
    if (publicPort.isEmpty) {
      return '$privatePort/$type';
    }
    return '$publicPort:$privatePort/$type';
  }).where((value) => value.isNotEmpty);
  return mapped.take(3).join(' · ');
}

InfoSeverity _severityForStatus(Object? value) {
  final raw = value?.toString().toLowerCase() ?? '';
  if (raw.contains('alert') ||
      raw.contains('critical') ||
      raw.contains('error') ||
      raw.contains('fail') ||
      raw.contains('down') ||
      raw.contains('offline') ||
      raw.contains('crash')) {
    return InfoSeverity.danger;
  }
  if (raw.contains('warn') ||
      raw.contains('pause') ||
      raw.contains('stop') ||
      raw.contains('idle')) {
    return InfoSeverity.warning;
  }
  if (raw.contains('online') ||
      raw.contains('running') ||
      raw.contains('started') ||
      raw.contains('ok') ||
      raw.contains('active')) {
    return InfoSeverity.success;
  }
  return InfoSeverity.normal;
}

InfoSeverity _severityForSmart(Object? smartStatus, Object? temperature) {
  final smart = smartStatus?.toString().toLowerCase() ?? '';
  final temp = _asDouble(temperature);
  if (smart.contains('fail') ||
      smart.contains('bad') ||
      (temp != null && temp >= 55)) {
    return InfoSeverity.danger;
  }
  if (smart.contains('warn') || (temp != null && temp >= 45)) {
    return InfoSeverity.warning;
  }
  if (smart.contains('ok') || smart.contains('passed')) {
    return InfoSeverity.success;
  }
  return InfoSeverity.normal;
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
