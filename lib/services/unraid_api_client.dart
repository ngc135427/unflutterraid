import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:http/http.dart' as http;

import 'display_copy.dart';

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
    String? fileBrowserBaseUrl,
    http.Client? httpClient,
  })  : baseUrl = _normalizeBaseUrl(baseUrl),
        fileBrowserBaseUrl = _normalizeBaseUrl(
            fileBrowserBaseUrl ?? _deriveFileBrowserBaseUrl(baseUrl)),
        apiKey = apiKey.trim(),
        _httpClient = httpClient ?? http.Client();

  final String baseUrl;
  final String fileBrowserBaseUrl;
  final String apiKey;
  final http.Client _httpClient;

  static const _clientOrigin = 'unflutterraid';
  static const defaultFileBrowserPort = 8080;

  Uri get _graphqlUri => Uri.parse('$baseUrl/graphql');

  UnraidFileManager get fileManager => UnraidFileManager._(this);

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
      throw UnraidApiException(DisplayCopy.current.apiUnraidServiceMissing);
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
      ManagementItemType.share =>
        throw UnraidApiException(DisplayCopy.current.apiShareActionUnsupported),
    };

    await _request(
      mutation,
      variables: {'id': id},
    );
  }

  Future<List<UnraidFileEntry>> fetchDirectory(String path) async {
    return fileManager.listDirectory(path);
  }

  Future<Uint8List> fetchFileBytes(String path) async {
    return fileManager.readFileBytes(path);
  }

  /// Media discovery requires a future GraphQL File Manager API.
  ///
  /// The current Unraid GraphQL schema used by this app only exposes share root
  /// metadata, not recursive file listing or thumbnails.
  Future<List<UnraidFileEntry>> fetchMediaFiles(
    String rootPath, {
    int maxDepth = 3,
  }) async {
    return fileManager.listMedia(rootPath, maxDepth: maxDepth);
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
      throw UnraidApiException(DisplayCopy.current.apiConnectionTimeout);
    } on Object catch (error) {
      throw UnraidApiException(
        DisplayCopy.current.apiCannotConnect(error.toString()),
      );
    }

    final decoded = _decodeGraphqlResponse(response.body);
    if (response.statusCode < 200 || response.statusCode >= 300) {
      final message = _firstGraphqlErrorMessage(decoded);
      throw UnraidApiException(
        message ?? DisplayCopy.current.apiHttpError(response.statusCode),
      );
    }

    if (decoded is! Map<String, dynamic>) {
      throw UnraidApiException(DisplayCopy.current.apiInvalidData);
    }

    final data = decoded['data'];
    final errors = decoded['errors'];
    if (errors is List && errors.isNotEmpty) {
      final message = _firstGraphqlErrorMessage(decoded);
      if (!allowPartialData || data is! Map<String, dynamic>) {
        throw UnraidApiException(
            message ?? DisplayCopy.current.apiGraphqlFailed);
      }
    }

    if (data is! Map<String, dynamic>) {
      throw UnraidApiException(DisplayCopy.current.apiMissingDataField);
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

  static String _deriveFileBrowserBaseUrl(String unraidBaseUrl) {
    final normalized = _normalizeBaseUrl(unraidBaseUrl);
    final uri = Uri.parse(normalized);
    return uri
        .replace(
          port: defaultFileBrowserPort,
          path: '',
          query: null,
          fragment: null,
        )
        .toString()
        .replaceFirst(RegExp(r'/$'), '');
  }
}

class UnraidFileManager {
  const UnraidFileManager._(this._client);

  final UnraidApiClient _client;

  Future<List<UnraidFileEntry>> listRoot() {
    return listDirectory('/mnt/user');
  }

  Future<List<UnraidFileEntry>> listDirectory(String path) async {
    final decoded = await _requestJson(
      _fileBrowserUri('/api/resources', path),
      actionLabel: DisplayCopy.current.apiActionListDirectory,
    );
    final entries = _parseFileBrowserDirectory(decoded, path)
      ..sort(_compareFileEntries);
    return entries;
  }

  /// Recursive visual media (images + videos). Does **not** include audio.
  /// Use [listAudio] for music library scans.
  Future<List<UnraidFileEntry>> listMedia(
    String rootPath, {
    int maxDepth = 3,
  }) async {
    return _listRecursiveFiltered(
      rootPath,
      actionLabel: DisplayCopy.current.apiActionScanMedia,
      keep: (entry) => entry.isMedia,
    );
  }

  /// Recursive audio files under [rootPath] (music library).
  Future<List<UnraidFileEntry>> listAudio(
    String rootPath, {
    int maxDepth = 3,
  }) async {
    return _listRecursiveFiltered(
      rootPath,
      actionLabel: DisplayCopy.current.apiActionScanMedia,
      keep: (entry) => entry.isAudio,
    );
  }

  /// Public File Browser raw stream URL for [appPath] (e.g. `/mnt/user/music/a.mp3`).
  Uri rawUri(String appPath) {
    return _fileBrowserUri('/api/raw', appPath);
  }

  Future<List<UnraidFileEntry>> _listRecursiveFiltered(
    String rootPath, {
    required String actionLabel,
    required bool Function(UnraidFileEntry entry) keep,
  }) async {
    final decoded = await _requestJson(
      _fileBrowserUri('/api/resources/recursive', rootPath),
      actionLabel: actionLabel,
    );
    final entries = <UnraidFileEntry>[];
    _collectFileBrowserEntries(decoded, rootPath, entries);
    entries.removeWhere((entry) => entry.isDirectory || !keep(entry));
    entries.sort((a, b) {
      final da = a.modifiedDate ?? DateTime(0);
      final db = b.modifiedDate ?? DateTime(0);
      return db.compareTo(da);
    });
    return entries;
  }

  Future<Uint8List> readFileBytes(String path) async {
    return _requestBytes(
      _fileBrowserUri('/api/raw', path),
      actionLabel: DisplayCopy.current.apiActionReadFile,
    );
  }

  Future<Uint8List> readPreviewBytes(
    String path, {
    String size = 'thumb',
  }) async {
    return _requestBytes(
      _fileBrowserUri('/api/preview/$size', path, queryParameters: {
        'inline': 'true',
      }),
      actionLabel: DisplayCopy.current.apiActionReadThumbnail,
    );
  }

  Future<void> delete(String path) async {
    await _send(
      'DELETE',
      _fileBrowserUri('/api/resources', path),
      actionLabel: DisplayCopy.current.apiActionDelete,
    );
  }

  Future<void> rename(String path, String newName) async {
    final trimmed = newName.trim();
    if (trimmed.isEmpty) {
      throw UnraidApiException(DisplayCopy.current.apiInvalidData);
    }
    final parent = _parentAppPath(path);
    final destination = _joinAppPaths(parent, trimmed);
    await _renameToDestination(path, destination);
  }

  /// Move [path] into [destinationDirectory], keeping the same base name.
  ///
  /// Uses File Browser rename with a cross-directory destination.
  /// Throws [UnraidApiException] if the move would nest a folder into itself.
  Future<void> move(String path, String destinationDirectory) async {
    final destDir = destinationDirectory.trim().isEmpty
        ? '/mnt/user'
        : destinationDirectory.trim();
    if (isInvalidMoveTarget(path, destDir)) {
      throw UnraidApiException(DisplayCopy.current.apiInvalidData);
    }
    final name = _entryName(path);
    if (name.isEmpty) {
      throw UnraidApiException(DisplayCopy.current.apiInvalidData);
    }
    final destination = _joinAppPaths(destDir, name);
    if (destination == path) {
      throw UnraidApiException(DisplayCopy.current.apiInvalidData);
    }
    await _renameToDestination(path, destination);
  }

  Future<void> _renameToDestination(String path, String destination) async {
    await _send(
      'PATCH',
      _fileBrowserUri('/api/resources', path),
      actionLabel: DisplayCopy.current.apiActionRename,
      body: {
        'action': 'rename',
        'destination': _appPathToFileBrowserPath(destination),
        'overwrite': false,
      },
    );
  }

  /// True when [destinationDirectory] is [sourcePath] or a descendant of it.
  static bool isInvalidMoveTarget(
      String sourcePath, String destinationDirectory) {
    final source = _normalizeAppPath(sourcePath);
    final dest = _normalizeAppPath(destinationDirectory);
    if (source.isEmpty || dest.isEmpty) {
      return true;
    }
    return dest == source || dest.startsWith('$source/');
  }

  static String _normalizeAppPath(String path) {
    var value = path.trim();
    if (value.length > 1 && value.endsWith('/')) {
      value = value.substring(0, value.length - 1);
    }
    return value;
  }

  static String _entryName(String path) {
    final normalized = _normalizeAppPath(path);
    final index = normalized.lastIndexOf('/');
    if (index < 0 || index == normalized.length - 1) {
      return normalized;
    }
    return normalized.substring(index + 1);
  }

  Future<void> uploadBytes({
    required String directoryPath,
    required String fileName,
    required List<int> bytes,
  }) async {
    final target = _joinAppPaths(directoryPath, fileName);
    await _send(
      'POST',
      _fileBrowserUri('/api/resources', target),
      actionLabel: DisplayCopy.current.apiActionUpload,
      bodyBytes: bytes,
      contentType: 'application/octet-stream',
    );
  }

  Future<Object?> _requestJson(Uri uri, {required String actionLabel}) async {
    final response = await _get(uri, actionLabel: actionLabel);
    try {
      return jsonDecode(response.body);
    } on FormatException {
      throw UnraidApiException(
          DisplayCopy.current.apiFileBrowserInvalidJson(actionLabel));
    }
  }

  Future<Uint8List> _requestBytes(
    Uri uri, {
    required String actionLabel,
  }) async {
    final response = await _get(uri, actionLabel: actionLabel);
    return response.bodyBytes;
  }

  Future<http.Response> _get(Uri uri, {required String actionLabel}) async {
    return _send('GET', uri, actionLabel: actionLabel);
  }

  Future<http.Response> _send(
    String method,
    Uri uri, {
    required String actionLabel,
    Map<String, dynamic>? body,
    List<int>? bodyBytes,
    String? contentType,
  }) async {
    late http.Response response;
    try {
      final headers = <String, String>{
        'accept': '*/*',
        if (contentType != null) 'content-type': contentType,
        if (body != null) 'content-type': 'application/json',
      };
      final client = _client._httpClient;
      response = await switch (method) {
        'GET' => client.get(uri, headers: headers),
        'DELETE' => client.delete(uri, headers: headers),
        'PATCH' => client.patch(
            uri,
            headers: headers,
            body: body == null ? null : jsonEncode(body),
          ),
        'POST' => client.post(
            uri,
            headers: headers,
            body: bodyBytes ?? (body == null ? null : jsonEncode(body)),
          ),
        _ => throw UnraidApiException(DisplayCopy.current.apiInvalidData),
      }
          .timeout(const Duration(seconds: 20));
    } on TimeoutException {
      throw UnraidApiException(
          DisplayCopy.current.apiFileBrowserTimeout(actionLabel));
    } on UnraidApiException {
      rethrow;
    } on Object catch (error) {
      throw UnraidApiException(
        DisplayCopy.current.apiFileBrowserCannotConnect(error.toString()),
      );
    }

    if (response.statusCode == 401 || response.statusCode == 403) {
      throw UnraidApiException(
        DisplayCopy.current.apiFileBrowserForbidden(response.statusCode),
      );
    }
    if (response.statusCode == 404) {
      throw UnraidApiException(DisplayCopy.current.apiFileBrowserNotFound);
    }
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw UnraidApiException(
        DisplayCopy.current
            .apiFileBrowserFailed(actionLabel, response.statusCode),
      );
    }
    return response;
  }

  Uri _fileBrowserUri(
    String apiPath,
    String appPath, {
    Map<String, String>? queryParameters,
  }) {
    final base = Uri.parse(_client.fileBrowserBaseUrl);
    final fileBrowserPath = _appPathToFileBrowserPath(appPath);
    final fullPath = _joinUriPaths([
      base.path,
      apiPath,
      fileBrowserPath == '/' ? '' : fileBrowserPath,
    ]);
    return base.replace(path: fullPath, queryParameters: queryParameters);
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
    final logFiles = _asList(json['logFiles']);
    final networkInterfaces = _asList(json['networkInterfaces']);
    final accessUrls = _asList(network['accessUrls']);

    return UnraidDashboard(
      serverName: _firstText([
        server['name'],
        os['hostname'],
        'Unraid',
      ]),
      serverDescription: _firstText([
        os['distro'],
        cpu['brand'],
        'Media server',
      ]),
      guid: _firstText([server['guid'], DisplayCopy.current.unknown]),
      ownerName: _firstText([
        owner['username'],
        _asMap(server['owner'])['username'],
        DisplayCopy.current.unbound,
      ]),
      registration: _firstText([
        registration['type'],
        registration['state'],
        DisplayCopy.current.unknown,
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
        DisplayCopy.current.unknown,
      ]),
      status: _formatStatus(server['status']),
      lanIp: _firstText([server['lanip'], DisplayCopy.current.unknown]),
      wanIp: _firstText([server['wanip'], DisplayCopy.current.unknown]),
      localUrl:
          _firstText([server['localurl'], DisplayCopy.current.notReturned]),
      remoteUrl:
          _firstText([server['remoteurl'], DisplayCopy.current.notReturned]),
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
      notifications: const [],
      diskItems: _asList(json['disks']).map(UnraidInfoItem.fromDisk).toList(),
      networkItems: networkInterfaces.isNotEmpty
          ? networkInterfaces.map(UnraidInfoItem.fromNetworkInterface).toList()
          : accessUrls.isNotEmpty
              ? accessUrls.map(UnraidInfoItem.fromAccessUrl).toList()
              : _serverNetworkItems(server),
      upsItems:
          _asList(json['upsDevices']).map(UnraidInfoItem.fromUps).toList(),
      pluginItems: [
        ...plugins.map(UnraidInfoItem.fromPlugin),
        if (installedPlugins.isNotEmpty)
          UnraidInfoItem(
            title: DisplayCopy.current.installedPlugins,
            value: DisplayCopy.current.countUnit(installedPlugins.length),
            description: installedPlugins.take(3).join(' · '),
            severity: InfoSeverity.normal,
          ),
        ..._asList(json['pluginInstallOperations'])
            .map(UnraidInfoItem.fromPluginOperation),
      ],
      securityItems: [
        UnraidInfoItem(
          title: 'API Keys',
          value: DisplayCopy.current.countUnit(apiKeys.length),
          description: DisplayCopy.current.apiKeyRolesDescription,
          severity: InfoSeverity.normal,
        ),
        UnraidInfoItem(
          title: 'SSO',
          value: json['isSSOEnabled'] == true
              ? DisplayCopy.current.enabled
              : DisplayCopy.current.disabled,
          description:
              DisplayCopy.current.oidcProviderCount(oidcProviders.length),
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
            DisplayCopy.current.unraidCloudStatus,
          ]),
          severity: _severityForStatus(_asMap(cloud['cloud'])['status']),
        ),
        UnraidInfoItem(
          title: 'Relay',
          value: _formatStatus(_asMap(cloud['relay'])['status']),
          description: _firstText([
            _asMap(cloud['relay'])['error'],
            DisplayCopy.current.dynamicRemoteAccess(_firstText([
              _asMap(connect['dynamicRemoteAccess'])['runningType'],
              remoteAccess['accessType'],
              DisplayCopy.current.unknown,
            ])),
          ]),
          severity: _severityForStatus(_asMap(cloud['relay'])['status']),
        ),
        UnraidInfoItem(
          title: DisplayCopy.current.remoteAccess,
          value: _firstText(
              [remoteAccess['accessType'], DisplayCopy.current.unknown]),
          description: '${_firstText([
                remoteAccess['forwardType'],
                DisplayCopy.current.forwardUnknown,
              ])} · ${DisplayCopy.current.portLabel(_firstText([
                remoteAccess['port'],
                DisplayCopy.current.unknown
              ]))}',
          severity: InfoSeverity.normal,
        ),
      ],
      logItems: logFiles.map(UnraidInfoItem.fromLogFile).toList(),
      servicesSummary: _formatServicesSummary(services),
      dockerNetworkSummary: _formatDockerNetworkSummary(dockerNetworks),
      dockerConflictSummary:
          _formatDockerConflictSummary(docker['portConflicts']),
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
          _firstText([json['image'], DisplayCopy.current.unnamedContainer]),
      status: _formatStatus(json['state'] ?? json['status']),
      description: _firstText([
        json['status'],
        json['image'],
        labels['net.unraid.docker.webui'],
        DisplayCopy.current.dockerContainer,
      ]),
      type: ManagementItemType.docker,
      tags: [
        if (networkMode.isNotEmpty) networkMode,
        if (json['autoStart'] == true) DisplayCopy.current.autoStart,
        if (json['isUpdateAvailable'] == true || updateStatus.isNotEmpty)
          DisplayCopy.current.updateAvailable,
        if (json['tailscaleEnabled'] == true) 'Tailscale',
      ],
      details: [
        UnraidInfoItem(
          title: DisplayCopy.current.image,
          value: _firstText([json['image'], DisplayCopy.current.unknown]),
          description: _firstText([json['imageId'], 'Docker image']),
          severity: InfoSeverity.normal,
        ),
        UnraidInfoItem(
          title: DisplayCopy.current.ports,
          value: _formatContainerPorts(ports),
          description: _formatContainerPortDescription(ports),
          severity: InfoSeverity.normal,
        ),
        if (json['tailscaleEnabled'] == true)
          UnraidInfoItem(
            title: 'Tailscale',
            value: tailscale['online'] == true
                ? DisplayCopy.current.online
                : DisplayCopy.current.offline,
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
      title: _firstText(
          [domain['name'], json['name'], DisplayCopy.current.unnamedVm]),
      status: _formatStatus(state),
      description: DisplayCopy.current.virtualMachine,
      type: ManagementItemType.vm,
      tags: [
        if (_firstText([domain['uuid']]).isNotEmpty) 'UUID',
        if (_formatStatus(state) == DisplayCopy.current.running)
          DisplayCopy.current.vncAvailable,
      ],
      details: [
        UnraidInfoItem(
          title: 'UUID',
          value: _firstText([domain['uuid'], DisplayCopy.current.unknown]),
          description: DisplayCopy.current.vmDomainId,
          severity: InfoSeverity.normal,
        ),
        UnraidInfoItem(
          title: DisplayCopy.current.status,
          value: _formatStatus(state),
          description: DisplayCopy.current.fromVmDomainState,
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
      title: _firstText(
          [json['name'], json['nameOrig'], DisplayCopy.current.unnamedShare]),
      status: json['cache'] == true
          ? DisplayCopy.current.cache
          : DisplayCopy.current.array,
      description: _firstText([
        json['comment'],
        _formatShareSize(json['used'], json['size']),
        DisplayCopy.current.shareDirectory,
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
          title: DisplayCopy.current.capacity,
          value: _formatShareSize(json['used'], json['size']),
          description: DisplayCopy.current.freeLabel(
              _formatKilobytes(json['free']) ?? DisplayCopy.current.unknown),
          severity: _percent(used, total) > 0.85
              ? InfoSeverity.warning
              : InfoSeverity.normal,
        ),
        UnraidInfoItem(
          title: DisplayCopy.current.allocationStrategy,
          value: _firstText([json['allocator'], DisplayCopy.current.unknown]),
          description: DisplayCopy.current.splitLevel(_firstText(
              [json['splitLevel'], DisplayCopy.current.defaultValue])),
          severity: InfoSeverity.normal,
        ),
        UnraidInfoItem(
          title: DisplayCopy.current.description,
          value: _firstText([json['comment'], DisplayCopy.current.none]),
          description: DisplayCopy.current.shareDirectoryConfig,
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
      title: _firstText(
          [json['name'], json['device'], DisplayCopy.current.unknownDisk]),
      value: _firstText(
          [json['smartStatus'], json['type'], DisplayCopy.current.unknown]),
      description: [
        if (_firstText([json['vendor']]).isNotEmpty) json['vendor'],
        if (_formatBytes(json['size']) != null) _formatBytes(json['size']),
        if (temp.isNotEmpty) '$temp°C',
        if (json['isSpinning'] == false) DisplayCopy.current.sleeping,
      ].join(' · '),
      severity: _severityForSmart(json['smartStatus'], json['temperature']),
    );
  }

  factory UnraidInfoItem.fromNetworkInterface(Object? value) {
    final json = _asMap(value);
    return UnraidInfoItem(
      title: _firstText(
          [json['name'], json['iface'], DisplayCopy.current.networkInterface]),
      value: _firstText(
          [json['status'], json['operstate'], DisplayCopy.current.unknown]),
      description: [
        _firstText([
          json['ipAddress'],
          json['macAddress'],
          DisplayCopy.current.noAddress
        ]),
        if (_firstText([json['speed']]).isNotEmpty) '${json['speed']} Mbps',
        if (_firstText([json['type']]).isNotEmpty) json['type'],
      ].join(' · '),
      severity: _severityForStatus(json['status'] ?? json['operstate']),
    );
  }

  factory UnraidInfoItem.fromAccessUrl(Object? value) {
    final json = _asMap(value);
    return UnraidInfoItem(
      title: _firstText(
          [json['name'], json['type'], DisplayCopy.current.accessAddress]),
      value: _firstText(
          [json['ipv4'], json['ipv6'], DisplayCopy.current.notReturned]),
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
      description: DisplayCopy.current.batteryLoad(
        _firstText([battery['chargeLevel'], DisplayCopy.current.unknown]),
        _firstText([power['loadPercentage'], DisplayCopy.current.unknown]),
      ),
      severity: _severityForStatus(json['status']),
    );
  }

  factory UnraidInfoItem.fromPlugin(Object? value) {
    final json = _asMap(value);
    return UnraidInfoItem(
      title: _firstText([json['name'], DisplayCopy.current.plugin]),
      value: _firstText([json['version'], DisplayCopy.current.unknownVersion]),
      description: DisplayCopy.current.apiCliModules(
        json['hasApiModule'] == true
            ? DisplayCopy.current.yes
            : DisplayCopy.current.no,
        json['hasCliModule'] == true
            ? DisplayCopy.current.yes
            : DisplayCopy.current.no,
      ),
      severity: json['hasApiModule'] == true
          ? InfoSeverity.success
          : InfoSeverity.normal,
    );
  }

  factory UnraidInfoItem.fromPluginOperation(Object? value) {
    final json = _asMap(value);
    return UnraidInfoItem(
      title: _firstText(
          [json['name'], json['url'], DisplayCopy.current.pluginInstallTask]),
      value: _formatStatus(json['status']),
      description: _firstText([
        json['updatedAt'],
        json['createdAt'],
        DisplayCopy.current.installTask
      ]),
      severity: _severityForStatus(json['status']),
    );
  }

  factory UnraidInfoItem.fromLogFile(Object? value) {
    final json = _asMap(value);
    return UnraidInfoItem(
      title: _firstText([json['name'], json['path'], DisplayCopy.current.log]),
      value: _formatBytes(json['size']) ?? DisplayCopy.current.unknownSize,
      description: _firstText([json['modifiedAt'], json['path'], 'logFiles']),
      severity: InfoSeverity.normal,
    );
  }
}

List<UnraidInfoItem> _serverNetworkItems(Map<String, dynamic> server) {
  final lanIp = _firstText([server['lanip']]);
  final wanIp = _firstText([server['wanip']]);
  final localUrl = _firstText([server['localurl']]);
  final remoteUrl = _firstText([server['remoteurl']]);
  return [
    if (lanIp.isNotEmpty || localUrl.isNotEmpty)
      UnraidInfoItem(
        title: 'LAN',
        value: _firstText([lanIp, DisplayCopy.current.notReturned]),
        description:
            _firstText([localUrl, DisplayCopy.current.localAccessAddress]),
        severity: InfoSeverity.normal,
      ),
    if (wanIp.isNotEmpty || remoteUrl.isNotEmpty)
      UnraidInfoItem(
        title: 'WAN',
        value: _firstText([wanIp, DisplayCopy.current.notReturned]),
        description:
            _firstText([remoteUrl, DisplayCopy.current.remoteAccessAddress]),
        severity: InfoSeverity.normal,
      ),
  ];
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
      title: _firstText(
          [json['title'], json['subject'], DisplayCopy.current.notification]),
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

  factory UnraidFileEntry.fromShare(Object? value) {
    final json = _asMap(value);
    final name = _firstText([json['name'], json['nameOrig']]);
    return UnraidFileEntry(
      name: name,
      path: '/mnt/user/$name',
      isDirectory: true,
      size: _formatShareSize(json['used'], json['size']),
      modified: _firstText([json['comment']]),
    );
  }

  factory UnraidFileEntry.fromFileBrowserResource(
    Object? value, {
    required String parentPath,
  }) {
    final json = _asMap(value);
    final name = _firstText([
      json['name'],
      _lastPathSegment(_firstText([json['path'], json['url']])),
      DisplayCopy.current.unnamed,
    ]);
    final type = _firstText([json['type']]).toLowerCase();
    final isDirectory = json['isDir'] == true ||
        json['isDirectory'] == true ||
        type == 'directory' ||
        type == 'dir' ||
        type == 'folder';
    final rawPath = _firstText([json['path'], json['url']]);
    final path = rawPath.isEmpty
        ? _joinAppPaths(parentPath, name)
        : _fileBrowserPathToAppPath(rawPath, parentPath);
    final modified = _firstText([
      json['modified'],
      json['modifiedAt'],
      json['modTime'],
      json['updatedAt'],
    ]);
    return UnraidFileEntry(
      name: name,
      path: path,
      isDirectory: isDirectory,
      size: isDirectory
          ? DisplayCopy.current.directory
          : _formatBytes(json['size']) ?? '',
      modified: modified,
    );
  }

  static const _videoExtensions = {
    'mp4',
    'mov',
    'avi',
    'mkv',
    'webm',
    'flv',
    'wmv',
    'm4v',
    '3gp',
    'mpg',
    'mpeg',
  };

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

  bool get isVideo {
    final ext = name.split('.').last.toLowerCase();
    return _videoExtensions.contains(ext);
  }

  bool get isMedia => isImage || isVideo;

  bool get isAudio {
    final ext = name.split('.').last.toLowerCase();
    return const {
      'mp3',
      'flac',
      'm4a',
      'aac',
      'wav',
      'ogg',
      'opus',
      'wma',
      'aiff',
      'alac',
    }.contains(ext);
  }

  DateTime? get modifiedDate {
    if (modified.isEmpty) return null;
    return DateTime.tryParse(modified);
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
  docker {
    containers {
      id
      names
      image
      imageId
      state
      status
      hostConfig {
        networkMode
      }
      labels
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
  apiKeys {
    id
  }
  isSSOEnabled
  oidcProviders {
    id
    name
  }
  plugins {
    name
    version
    hasApiModule
    hasCliModule
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
  final brand = _firstText([
    cpu['brand'],
    cpu['manufacturer'],
    DisplayCopy.current.unknownCpu,
  ]);
  final cores = _firstText([cpu['cores']]);
  final threads = _firstText([cpu['threads']]);
  final specs = [
    if (cores.isNotEmpty) DisplayCopy.current.coresCount(cores),
    if (threads.isNotEmpty) DisplayCopy.current.threadsCount(threads),
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
    DisplayCopy.current.unknownMotherboard,
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
    DisplayCopy.current.unknownSystem,
  ]);
}

String _formatPackagesSummary(Map<String, dynamic> packages) {
  final names = ['docker', 'nginx', 'php', 'node', 'git']
      .where((key) => _firstText([packages[key]]).isNotEmpty)
      .map((key) => '$key ${packages[key]}')
      .toList();
  if (names.isEmpty) {
    return DisplayCopy.current.noPackageVersions;
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
  return parts
      .where((part) => part.isNotEmpty && part != DisplayCopy.current.unknown)
      .join(' · ');
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
    return DisplayCopy.current.noServicesReturned;
  }
  return DisplayCopy.current
      .servicesOnlineSummary(online, services.length, names.join(' · '));
}

String _formatDockerNetworkSummary(List<Object?> networks) {
  if (networks.isEmpty) {
    return DisplayCopy.current.noNetworksReturned;
  }
  final names = networks
      .map((value) => _firstText([_asMap(value)['name']]))
      .where((value) => value.isNotEmpty)
      .take(3)
      .join(' · ');
  return '${DisplayCopy.current.networksCount(networks.length)}${names.isEmpty ? '' : ' · $names'}';
}

String _formatDockerConflictSummary(Object? conflictsValue) {
  if (conflictsValue == null) {
    return DisplayCopy.current.noPortConflictInfo;
  }
  final conflicts = _asMap(conflictsValue);
  final containerPorts = _asList(conflicts['containerPorts']);
  final lanPorts = _asList(conflicts['lanPorts']);
  final total = containerPorts.length + lanPorts.length;
  if (total == 0) {
    return DisplayCopy.current.noPortConflicts;
  }
  return DisplayCopy.current.portConflictCount(total);
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

String _formatContainerPortDescription(List<Object?> ports) {
  final mapped = ports.map((value) {
    final json = _asMap(value);
    final ip = _firstText([json['ip']]);
    final privatePort = _firstText([json['privatePort']]);
    final publicPort = _firstText([json['publicPort']]);
    final type = _firstText([json['type'], 'tcp']);
    if (privatePort.isEmpty && publicPort.isEmpty) {
      return '';
    }
    final binding = publicPort.isEmpty
        ? privatePort
        : '$publicPort -> ${privatePort.isEmpty ? '?' : privatePort}';
    return '${ip.isEmpty ? DisplayCopy.current.container : ip} · $binding/$type';
  }).where((value) => value.isNotEmpty);
  final description = mapped.take(3).join(' · ');
  return description.isEmpty ? DisplayCopy.current.noPortMappings : description;
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
    return DisplayCopy.current.unknown;
  }
  if (usedText == null) {
    return DisplayCopy.current.totalUsage(totalText!);
  }
  if (totalText == null) {
    return DisplayCopy.current.usedUsage(usedText);
  }
  return '$usedText / $totalText';
}

String _formatKilobytesUsage(Object? used, Object? total) {
  final usedText = _formatKilobytes(used);
  final totalText = _formatKilobytes(total);
  if (usedText == null && totalText == null) {
    return DisplayCopy.current.unknown;
  }
  if (usedText == null) {
    return DisplayCopy.current.totalUsage(totalText!);
  }
  if (totalText == null) {
    return DisplayCopy.current.usedUsage(usedText);
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
    'RUNNING' => DisplayCopy.current.running,
    'ONLINE' => DisplayCopy.current.online,
    'OFFLINE' => DisplayCopy.current.offline,
    'STARTED' => DisplayCopy.current.started,
    'STOPPED' => DisplayCopy.current.stopped,
    'PAUSED' => DisplayCopy.current.paused,
    'EXITED' => DisplayCopy.current.stopped,
    'IDLE' => DisplayCopy.current.idle,
    'SHUTDOWN' || 'SHUTOFF' => DisplayCopy.current.shutDown,
    'CRASHED' => DisplayCopy.current.crashed,
    'PMSUSPENDED' => DisplayCopy.current.sleeping,
    null || '' => DisplayCopy.current.unknown,
    _ => raw,
  };
}

String _formatShareSize(Object? used, Object? total) {
  final usedText = _formatKilobytes(used);
  final totalText = _formatKilobytes(total);
  if (usedText == null && totalText == null) {
    return DisplayCopy.current.shareDirectory;
  }
  if (usedText == null) {
    return DisplayCopy.current.totalUsage(totalText!);
  }
  if (totalText == null) {
    return DisplayCopy.current.usedUsage(usedText);
  }
  return DisplayCopy.current.usedTotalUsage(usedText, totalText);
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
    return DisplayCopy.current.unknown;
  }
  final bootTime = DateTime.tryParse(raw);
  if (bootTime == null) {
    return raw;
  }
  final elapsed = DateTime.now().difference(bootTime);
  if (elapsed.inDays > 0) {
    return DisplayCopy.current.daysCount(elapsed.inDays);
  }
  if (elapsed.inHours > 0) {
    return DisplayCopy.current.hoursCount(elapsed.inHours);
  }
  return DisplayCopy.current.minutesCount(elapsed.inMinutes);
}

List<UnraidFileEntry> _parseFileBrowserDirectory(
  Object? decoded,
  String requestedPath,
) {
  final entries = <UnraidFileEntry>[];
  if (decoded is List) {
    for (final item in decoded) {
      entries.add(UnraidFileEntry.fromFileBrowserResource(
        item,
        parentPath: requestedPath,
      ));
    }
    return entries;
  }

  final json = _asMap(decoded);
  final items = _asList(json['items']);
  if (items.isNotEmpty) {
    for (final item in items) {
      entries.add(UnraidFileEntry.fromFileBrowserResource(
        item,
        parentPath: requestedPath,
      ));
    }
    return entries;
  }

  if (json.isNotEmpty) {
    final entry = UnraidFileEntry.fromFileBrowserResource(
      json,
      parentPath: _parentAppPath(requestedPath),
    );
    if (entry.path != requestedPath || !entry.isDirectory) {
      entries.add(entry);
    }
  }
  return entries;
}

void _collectFileBrowserEntries(
  Object? decoded,
  String parentPath,
  List<UnraidFileEntry> result,
) {
  if (decoded is List) {
    for (final item in decoded) {
      _collectFileBrowserEntries(item, parentPath, result);
    }
    return;
  }

  final json = _asMap(decoded);
  if (json.isEmpty) {
    return;
  }

  final entry = UnraidFileEntry.fromFileBrowserResource(
    json,
    parentPath: parentPath,
  );
  result.add(entry);

  final childParent = entry.isDirectory ? entry.path : parentPath;
  for (final item in _asList(json['items'])) {
    _collectFileBrowserEntries(item, childParent, result);
  }
}

int _compareFileEntries(UnraidFileEntry a, UnraidFileEntry b) {
  if (a.isDirectory != b.isDirectory) {
    return a.isDirectory ? -1 : 1;
  }
  return a.name.toLowerCase().compareTo(b.name.toLowerCase());
}

String _parentAppPath(String path) {
  final trimmed = path.trim();
  if (trimmed.isEmpty || trimmed == '/' || trimmed == '/mnt/user') {
    return '/mnt/user';
  }
  final withoutTrailing = trimmed.endsWith('/') && trimmed.length > 1
      ? trimmed.substring(0, trimmed.length - 1)
      : trimmed;
  final index = withoutTrailing.lastIndexOf('/');
  if (index <= 0) {
    return '/mnt/user';
  }
  final parent = withoutTrailing.substring(0, index);
  return parent.isEmpty ? '/mnt/user' : parent;
}

String _appPathToFileBrowserPath(String path) {
  final trimmed = path.trim();
  if (trimmed.isEmpty || trimmed == '/' || trimmed == '/mnt/user') {
    return '/';
  }
  final withoutTrailingSlash = trimmed.endsWith('/') && trimmed.length > 1
      ? trimmed.substring(0, trimmed.length - 1)
      : trimmed;
  if (withoutTrailingSlash == '/mnt/user') {
    return '/';
  }
  if (withoutTrailingSlash.startsWith('/mnt/user/')) {
    return withoutTrailingSlash.substring('/mnt/user'.length);
  }
  return withoutTrailingSlash.startsWith('/')
      ? withoutTrailingSlash
      : '/$withoutTrailingSlash';
}

String _fileBrowserPathToAppPath(String value, String fallbackParent) {
  final clean = value.split('?').first.trim();
  if (clean.isEmpty || clean == '/') {
    return '/mnt/user';
  }
  if (clean.startsWith('/mnt/user')) {
    return clean;
  }
  final normalized = clean.startsWith('/') ? clean : '/$clean';
  if (normalized.startsWith('/api/resources/')) {
    return _fileBrowserPathToAppPath(
      normalized.substring('/api/resources'.length),
      fallbackParent,
    );
  }
  if (normalized.startsWith('/api/raw/')) {
    return _fileBrowserPathToAppPath(
      normalized.substring('/api/raw'.length),
      fallbackParent,
    );
  }
  if (normalized.startsWith('/api/preview/')) {
    final parts = normalized.split('/').where((part) => part.isNotEmpty);
    final withoutApiPreviewSize = parts.skip(3).join('/');
    return _fileBrowserPathToAppPath('/$withoutApiPreviewSize', fallbackParent);
  }
  if (fallbackParent.startsWith('/mnt/user') && !clean.contains('/')) {
    return _joinAppPaths(fallbackParent, clean);
  }
  return '/mnt/user$normalized';
}

String _joinUriPaths(List<String> parts) {
  final segments = <String>[];
  for (final part in parts) {
    final clean = part.trim().replaceAll(RegExp(r'^/+|/+$'), '');
    if (clean.isNotEmpty) {
      segments.add(clean);
    }
  }
  return '/${segments.join('/')}';
}

String _joinAppPaths(String parent, String name) {
  final cleanParent = parent.endsWith('/') && parent.length > 1
      ? parent.substring(0, parent.length - 1)
      : parent;
  final cleanName = name.replaceAll(RegExp(r'^/+'), '');
  return cleanName.isEmpty ? cleanParent : '$cleanParent/$cleanName';
}

String _lastPathSegment(String path) {
  final clean = path.split('?').first.replaceAll(RegExp(r'/+$'), '');
  if (clean.isEmpty || clean == '/') {
    return '';
  }
  final index = clean.lastIndexOf('/');
  return index == -1 ? clean : clean.substring(index + 1);
}
