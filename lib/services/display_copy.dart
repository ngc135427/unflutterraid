import '../l10n/generated/app_localizations.dart';

/// App-owned display strings used by networking/mapping code.
///
/// Keeps [BuildContext] out of the API client while still allowing English
/// and Chinese UI copy. Update [current] when the app locale changes.
class DisplayCopy {
  const DisplayCopy({
    required this.unknown,
    required this.notReturned,
    required this.unbound,
    required this.apiUnraidServiceMissing,
    required this.apiShareActionUnsupported,
    required this.apiConnectionTimeout,
    required this.apiCannotConnect,
    required this.apiHttpError,
    required this.apiInvalidData,
    required this.apiGraphqlFailed,
    required this.apiMissingDataField,
    required this.apiActionListDirectory,
    required this.apiActionScanMedia,
    required this.apiActionReadFile,
    required this.apiActionReadThumbnail,
    required this.apiActionDelete,
    required this.apiActionRename,
    required this.apiActionUpload,
    required this.apiFileBrowserInvalidJson,
    required this.apiFileBrowserTimeout,
    required this.apiFileBrowserCannotConnect,
    required this.apiFileBrowserForbidden,
    required this.apiFileBrowserNotFound,
    required this.apiFileBrowserFailed,
    required this.installedPlugins,
    required this.countUnit,
    required this.apiKeyRolesDescription,
    required this.enabled,
    required this.disabled,
    required this.oidcProviderCount,
    required this.unraidCloudStatus,
    required this.dynamicRemoteAccess,
    required this.remoteAccess,
    required this.forwardUnknown,
    required this.portLabel,
    required this.unnamedContainer,
    required this.dockerContainer,
    required this.autoStart,
    required this.updateAvailable,
    required this.image,
    required this.ports,
    required this.online,
    required this.offline,
    required this.unnamedVm,
    required this.virtualMachine,
    required this.running,
    required this.vncAvailable,
    required this.vmDomainId,
    required this.fromVmDomainState,
    required this.status,
    required this.unnamedShare,
    required this.cache,
    required this.array,
    required this.shareDirectory,
    required this.capacity,
    required this.freeLabel,
    required this.allocationStrategy,
    required this.defaultValue,
    required this.splitLevel,
    required this.description,
    required this.none,
    required this.shareDirectoryConfig,
    required this.unknownDisk,
    required this.sleeping,
    required this.networkInterface,
    required this.noAddress,
    required this.accessAddress,
    required this.batteryLoad,
    required this.plugin,
    required this.unknownVersion,
    required this.apiCliModules,
    required this.yes,
    required this.no,
    required this.pluginInstallTask,
    required this.installTask,
    required this.log,
    required this.unknownSize,
    required this.localAccessAddress,
    required this.remoteAccessAddress,
    required this.notification,
    required this.unnamed,
    required this.directory,
    required this.unknownCpu,
    required this.coresCount,
    required this.threadsCount,
    required this.unknownMotherboard,
    required this.unknownSystem,
    required this.noPackageVersions,
    required this.noServicesReturned,
    required this.servicesOnlineSummary,
    required this.noNetworksReturned,
    required this.networksCount,
    required this.noPortConflictInfo,
    required this.noPortConflicts,
    required this.portConflictCount,
    required this.container,
    required this.noPortMappings,
    required this.totalUsage,
    required this.usedUsage,
    required this.usedTotalUsage,
    required this.started,
    required this.stopped,
    required this.paused,
    required this.idle,
    required this.shutDown,
    required this.crashed,
    required this.daysCount,
    required this.hoursCount,
    required this.minutesCount,
  });

  final String unknown;
  final String notReturned;
  final String unbound;
  final String apiUnraidServiceMissing;
  final String apiShareActionUnsupported;
  final String apiConnectionTimeout;
  final String Function(String error) apiCannotConnect;
  final String Function(int statusCode) apiHttpError;
  final String apiInvalidData;
  final String apiGraphqlFailed;
  final String apiMissingDataField;
  final String apiActionListDirectory;
  final String apiActionScanMedia;
  final String apiActionReadFile;
  final String apiActionReadThumbnail;
  final String apiActionDelete;
  final String apiActionRename;
  final String apiActionUpload;
  final String Function(String action) apiFileBrowserInvalidJson;
  final String Function(String action) apiFileBrowserTimeout;
  final String Function(String error) apiFileBrowserCannotConnect;
  final String Function(int statusCode) apiFileBrowserForbidden;
  final String apiFileBrowserNotFound;
  final String Function(String action, int statusCode) apiFileBrowserFailed;
  final String installedPlugins;
  final String Function(int count) countUnit;
  final String apiKeyRolesDescription;
  final String enabled;
  final String disabled;
  final String Function(int count) oidcProviderCount;
  final String unraidCloudStatus;
  final String Function(String type) dynamicRemoteAccess;
  final String remoteAccess;
  final String forwardUnknown;
  final String Function(String port) portLabel;
  final String unnamedContainer;
  final String dockerContainer;
  final String autoStart;
  final String updateAvailable;
  final String image;
  final String ports;
  final String online;
  final String offline;
  final String unnamedVm;
  final String virtualMachine;
  final String running;
  final String vncAvailable;
  final String vmDomainId;
  final String fromVmDomainState;
  final String status;
  final String unnamedShare;
  final String cache;
  final String array;
  final String shareDirectory;
  final String capacity;
  final String Function(String value) freeLabel;
  final String allocationStrategy;
  final String defaultValue;
  final String Function(String value) splitLevel;
  final String description;
  final String none;
  final String shareDirectoryConfig;
  final String unknownDisk;
  final String sleeping;
  final String networkInterface;
  final String noAddress;
  final String accessAddress;
  final String Function(String battery, String load) batteryLoad;
  final String plugin;
  final String unknownVersion;
  final String Function(String api, String cli) apiCliModules;
  final String yes;
  final String no;
  final String pluginInstallTask;
  final String installTask;
  final String log;
  final String unknownSize;
  final String localAccessAddress;
  final String remoteAccessAddress;
  final String notification;
  final String unnamed;
  final String directory;
  final String unknownCpu;
  final String Function(String count) coresCount;
  final String Function(String count) threadsCount;
  final String unknownMotherboard;
  final String unknownSystem;
  final String noPackageVersions;
  final String noServicesReturned;
  final String Function(int online, int total, String names)
      servicesOnlineSummary;
  final String noNetworksReturned;
  final String Function(int count) networksCount;
  final String noPortConflictInfo;
  final String noPortConflicts;
  final String Function(int count) portConflictCount;
  final String container;
  final String noPortMappings;
  final String Function(String value) totalUsage;
  final String Function(String value) usedUsage;
  final String Function(String used, String total) usedTotalUsage;
  final String started;
  final String stopped;
  final String paused;
  final String idle;
  final String shutDown;
  final String crashed;
  final String Function(int count) daysCount;
  final String Function(int count) hoursCount;
  final String Function(int count) minutesCount;

  static DisplayCopy current = fromL10nValues(
    unknown: '未知',
    notReturned: '未返回',
    unbound: '未绑定',
    apiUnraidServiceMissing: '未找到 unraid-api 服务，请确认 Unraid Connect/API 插件已启用',
    apiShareActionUnsupported: '共享项目不支持该操作',
    apiConnectionTimeout: '连接服务器超时',
    apiCannotConnect: (error) => '无法连接服务器：$error',
    apiHttpError: (statusCode) => '服务器返回 HTTP $statusCode',
    apiInvalidData: '服务器返回了无效数据',
    apiGraphqlFailed: 'GraphQL 请求失败',
    apiMissingDataField: '响应中缺少 data 字段',
    apiActionListDirectory: '读取目录',
    apiActionScanMedia: '扫描媒体文件',
    apiActionReadFile: '读取文件',
    apiActionReadThumbnail: '读取缩略图',
    apiActionDelete: '删除',
    apiActionRename: '重命名',
    apiActionUpload: '上传',
    apiFileBrowserInvalidJson: (action) => 'File Browser 返回了无效 JSON：$action',
    apiFileBrowserTimeout: (action) => 'File Browser $action超时',
    apiFileBrowserCannotConnect: (error) => '无法连接 File Browser：$error',
    apiFileBrowserForbidden: (statusCode) =>
        'File Browser 拒绝访问，请检查匿名访问或反向代理认证配置（HTTP $statusCode）',
    apiFileBrowserNotFound: 'File Browser 未找到路径（HTTP 404）',
    apiFileBrowserFailed: (action, statusCode) =>
        'File Browser $action失败：HTTP $statusCode',
    installedPlugins: '已安装插件',
    countUnit: (count) => '$count 个',
    apiKeyRolesDescription: '可用角色与权限来自 apiKeyPossibleRoles',
    enabled: '已启用',
    disabled: '未启用',
    oidcProviderCount: (count) => '$count 个 OIDC 提供方',
    unraidCloudStatus: 'Unraid Cloud 状态',
    dynamicRemoteAccess: (type) => '动态远程访问 $type',
    remoteAccess: '远程访问',
    forwardUnknown: 'forward 未知',
    portLabel: (port) => '端口 $port',
    unnamedContainer: '未命名容器',
    dockerContainer: 'Docker 容器',
    autoStart: '自启动',
    updateAvailable: '有更新',
    image: '镜像',
    ports: '端口',
    online: '在线',
    offline: '离线',
    unnamedVm: '未命名虚拟机',
    virtualMachine: '虚拟机',
    running: '运行中',
    vncAvailable: 'VNC 可用',
    vmDomainId: '虚拟机域标识',
    fromVmDomainState: '来自 vms.domain.state',
    status: '状态',
    unnamedShare: '未命名共享',
    cache: '缓存',
    array: '阵列',
    shareDirectory: '共享目录',
    capacity: '容量',
    freeLabel: (value) => 'free $value',
    allocationStrategy: '分配策略',
    defaultValue: '默认',
    splitLevel: (value) => 'split level $value',
    description: '说明',
    none: '无',
    shareDirectoryConfig: '共享目录配置',
    unknownDisk: '未知磁盘',
    sleeping: '休眠',
    networkInterface: '网络接口',
    noAddress: '无地址',
    accessAddress: '访问地址',
    batteryLoad: (battery, load) => '电量 $battery% · 负载 $load%',
    plugin: '插件',
    unknownVersion: '未知版本',
    apiCliModules: (api, cli) => 'API $api · CLI $cli',
    yes: '有',
    no: '无',
    pluginInstallTask: '插件安装任务',
    installTask: '安装任务',
    log: '日志',
    unknownSize: '未知大小',
    localAccessAddress: '本地访问地址',
    remoteAccessAddress: '远程访问地址',
    notification: '通知',
    unnamed: '未命名',
    directory: '目录',
    unknownCpu: '未知 CPU',
    coresCount: (count) => '$count 核',
    threadsCount: (count) => '$count 线程',
    unknownMotherboard: '未知主板',
    unknownSystem: '未知系统',
    noPackageVersions: '未返回包版本',
    noServicesReturned: '未返回服务',
    servicesOnlineSummary: (online, total, names) =>
        '$online/$total 在线 · $names',
    noNetworksReturned: '未返回网络',
    networksCount: (count) => '$count 个网络',
    noPortConflictInfo: '未返回端口冲突信息',
    noPortConflicts: '未发现端口冲突',
    portConflictCount: (count) => '$count 个端口冲突',
    container: '容器',
    noPortMappings: '未返回端口映射',
    totalUsage: (value) => '总计 $value',
    usedUsage: (value) => '已用 $value',
    usedTotalUsage: (used, total) => '已用 $used / $total',
    started: '已启动',
    stopped: '已停止',
    paused: '已暂停',
    idle: '空闲',
    shutDown: '已关闭',
    crashed: '异常',
    daysCount: (count) => '$count 天',
    hoursCount: (count) => '$count 小时',
    minutesCount: (count) => '$count 分钟',
  );

  factory DisplayCopy.fromL10n(AppLocalizations l10n) {
    return fromL10nValues(
      unknown: l10n.unknown,
      notReturned: l10n.notReturned,
      unbound: l10n.unbound,
      apiUnraidServiceMissing: l10n.apiUnraidServiceMissing,
      apiShareActionUnsupported: l10n.apiShareActionUnsupported,
      apiConnectionTimeout: l10n.apiConnectionTimeout,
      apiCannotConnect: l10n.apiCannotConnect,
      apiHttpError: l10n.apiHttpError,
      apiInvalidData: l10n.apiInvalidData,
      apiGraphqlFailed: l10n.apiGraphqlFailed,
      apiMissingDataField: l10n.apiMissingDataField,
      apiActionListDirectory: l10n.apiActionListDirectory,
      apiActionScanMedia: l10n.apiActionScanMedia,
      apiActionReadFile: l10n.apiActionReadFile,
      apiActionReadThumbnail: l10n.apiActionReadThumbnail,
      apiActionDelete: l10n.apiActionDelete,
      apiActionRename: l10n.apiActionRename,
      apiActionUpload: l10n.apiActionUpload,
      apiFileBrowserInvalidJson: l10n.apiFileBrowserInvalidJson,
      apiFileBrowserTimeout: l10n.apiFileBrowserTimeout,
      apiFileBrowserCannotConnect: l10n.apiFileBrowserCannotConnect,
      apiFileBrowserForbidden: l10n.apiFileBrowserForbidden,
      apiFileBrowserNotFound: l10n.apiFileBrowserNotFound,
      apiFileBrowserFailed: l10n.apiFileBrowserFailed,
      installedPlugins: l10n.installedPlugins,
      countUnit: l10n.countUnit,
      apiKeyRolesDescription: l10n.apiKeyRolesDescription,
      enabled: l10n.enabled,
      disabled: l10n.disabled,
      oidcProviderCount: l10n.oidcProviderCount,
      unraidCloudStatus: l10n.unraidCloudStatus,
      dynamicRemoteAccess: l10n.dynamicRemoteAccess,
      remoteAccess: l10n.remoteAccess,
      forwardUnknown: l10n.forwardUnknown,
      portLabel: l10n.portLabel,
      unnamedContainer: l10n.unnamedContainer,
      dockerContainer: l10n.dockerContainer,
      autoStart: l10n.autoStart,
      updateAvailable: l10n.updateAvailable,
      image: l10n.image,
      ports: l10n.ports,
      online: l10n.online,
      offline: l10n.offline,
      unnamedVm: l10n.unnamedVm,
      virtualMachine: l10n.virtualMachine,
      running: l10n.running,
      vncAvailable: l10n.vncAvailable,
      vmDomainId: l10n.vmDomainId,
      fromVmDomainState: l10n.fromVmDomainState,
      status: l10n.status,
      unnamedShare: l10n.unnamedShare,
      cache: l10n.cache,
      array: l10n.array,
      shareDirectory: l10n.shareDirectory,
      capacity: l10n.capacity,
      freeLabel: l10n.freeLabel,
      allocationStrategy: l10n.allocationStrategy,
      defaultValue: l10n.defaultValue,
      splitLevel: l10n.splitLevel,
      description: l10n.description,
      none: l10n.none,
      shareDirectoryConfig: l10n.shareDirectoryConfig,
      unknownDisk: l10n.unknownDisk,
      sleeping: l10n.sleeping,
      networkInterface: l10n.networkInterface,
      noAddress: l10n.noAddress,
      accessAddress: l10n.accessAddress,
      batteryLoad: l10n.batteryLoad,
      plugin: l10n.plugin,
      unknownVersion: l10n.unknownVersion,
      apiCliModules: l10n.apiCliModules,
      yes: l10n.yes,
      no: l10n.no,
      pluginInstallTask: l10n.pluginInstallTask,
      installTask: l10n.installTask,
      log: l10n.log,
      unknownSize: l10n.unknownSize,
      localAccessAddress: l10n.localAccessAddress,
      remoteAccessAddress: l10n.remoteAccessAddress,
      notification: l10n.notification,
      unnamed: l10n.unnamed,
      directory: l10n.directory,
      unknownCpu: l10n.unknownCpu,
      coresCount: l10n.coresCount,
      threadsCount: l10n.threadsCount,
      unknownMotherboard: l10n.unknownMotherboard,
      unknownSystem: l10n.unknownSystem,
      noPackageVersions: l10n.noPackageVersions,
      noServicesReturned: l10n.noServicesReturned,
      servicesOnlineSummary: l10n.servicesOnlineSummary,
      noNetworksReturned: l10n.noNetworksReturned,
      networksCount: l10n.networksCount,
      noPortConflictInfo: l10n.noPortConflictInfo,
      noPortConflicts: l10n.noPortConflicts,
      portConflictCount: l10n.portConflictCount,
      container: l10n.container,
      noPortMappings: l10n.noPortMappings,
      totalUsage: l10n.totalUsage,
      usedUsage: l10n.usedUsage,
      usedTotalUsage: l10n.usedTotalUsage,
      started: l10n.started,
      stopped: l10n.stopped,
      paused: l10n.paused,
      idle: l10n.idle,
      shutDown: l10n.shutDown,
      crashed: l10n.crashed,
      daysCount: l10n.daysCount,
      hoursCount: l10n.hoursCount,
      minutesCount: l10n.minutesCount,
    );
  }

  static DisplayCopy fromL10nValues({
    required String unknown,
    required String notReturned,
    required String unbound,
    required String apiUnraidServiceMissing,
    required String apiShareActionUnsupported,
    required String apiConnectionTimeout,
    required String Function(String error) apiCannotConnect,
    required String Function(int statusCode) apiHttpError,
    required String apiInvalidData,
    required String apiGraphqlFailed,
    required String apiMissingDataField,
    required String apiActionListDirectory,
    required String apiActionScanMedia,
    required String apiActionReadFile,
    required String apiActionReadThumbnail,
    required String apiActionDelete,
    required String apiActionRename,
    required String apiActionUpload,
    required String Function(String action) apiFileBrowserInvalidJson,
    required String Function(String action) apiFileBrowserTimeout,
    required String Function(String error) apiFileBrowserCannotConnect,
    required String Function(int statusCode) apiFileBrowserForbidden,
    required String apiFileBrowserNotFound,
    required String Function(String action, int statusCode)
        apiFileBrowserFailed,
    required String installedPlugins,
    required String Function(int count) countUnit,
    required String apiKeyRolesDescription,
    required String enabled,
    required String disabled,
    required String Function(int count) oidcProviderCount,
    required String unraidCloudStatus,
    required String Function(String type) dynamicRemoteAccess,
    required String remoteAccess,
    required String forwardUnknown,
    required String Function(String port) portLabel,
    required String unnamedContainer,
    required String dockerContainer,
    required String autoStart,
    required String updateAvailable,
    required String image,
    required String ports,
    required String online,
    required String offline,
    required String unnamedVm,
    required String virtualMachine,
    required String running,
    required String vncAvailable,
    required String vmDomainId,
    required String fromVmDomainState,
    required String status,
    required String unnamedShare,
    required String cache,
    required String array,
    required String shareDirectory,
    required String capacity,
    required String Function(String value) freeLabel,
    required String allocationStrategy,
    required String defaultValue,
    required String Function(String value) splitLevel,
    required String description,
    required String none,
    required String shareDirectoryConfig,
    required String unknownDisk,
    required String sleeping,
    required String networkInterface,
    required String noAddress,
    required String accessAddress,
    required String Function(String battery, String load) batteryLoad,
    required String plugin,
    required String unknownVersion,
    required String Function(String api, String cli) apiCliModules,
    required String yes,
    required String no,
    required String pluginInstallTask,
    required String installTask,
    required String log,
    required String unknownSize,
    required String localAccessAddress,
    required String remoteAccessAddress,
    required String notification,
    required String unnamed,
    required String directory,
    required String unknownCpu,
    required String Function(String count) coresCount,
    required String Function(String count) threadsCount,
    required String unknownMotherboard,
    required String unknownSystem,
    required String noPackageVersions,
    required String noServicesReturned,
    required String Function(int online, int total, String names)
        servicesOnlineSummary,
    required String noNetworksReturned,
    required String Function(int count) networksCount,
    required String noPortConflictInfo,
    required String noPortConflicts,
    required String Function(int count) portConflictCount,
    required String container,
    required String noPortMappings,
    required String Function(String value) totalUsage,
    required String Function(String value) usedUsage,
    required String Function(String used, String total) usedTotalUsage,
    required String started,
    required String stopped,
    required String paused,
    required String idle,
    required String shutDown,
    required String crashed,
    required String Function(int count) daysCount,
    required String Function(int count) hoursCount,
    required String Function(int count) minutesCount,
  }) {
    return DisplayCopy(
      unknown: unknown,
      notReturned: notReturned,
      unbound: unbound,
      apiUnraidServiceMissing: apiUnraidServiceMissing,
      apiShareActionUnsupported: apiShareActionUnsupported,
      apiConnectionTimeout: apiConnectionTimeout,
      apiCannotConnect: apiCannotConnect,
      apiHttpError: apiHttpError,
      apiInvalidData: apiInvalidData,
      apiGraphqlFailed: apiGraphqlFailed,
      apiMissingDataField: apiMissingDataField,
      apiActionListDirectory: apiActionListDirectory,
      apiActionScanMedia: apiActionScanMedia,
      apiActionReadFile: apiActionReadFile,
      apiActionReadThumbnail: apiActionReadThumbnail,
      apiActionDelete: apiActionDelete,
      apiActionRename: apiActionRename,
      apiActionUpload: apiActionUpload,
      apiFileBrowserInvalidJson: apiFileBrowserInvalidJson,
      apiFileBrowserTimeout: apiFileBrowserTimeout,
      apiFileBrowserCannotConnect: apiFileBrowserCannotConnect,
      apiFileBrowserForbidden: apiFileBrowserForbidden,
      apiFileBrowserNotFound: apiFileBrowserNotFound,
      apiFileBrowserFailed: apiFileBrowserFailed,
      installedPlugins: installedPlugins,
      countUnit: countUnit,
      apiKeyRolesDescription: apiKeyRolesDescription,
      enabled: enabled,
      disabled: disabled,
      oidcProviderCount: oidcProviderCount,
      unraidCloudStatus: unraidCloudStatus,
      dynamicRemoteAccess: dynamicRemoteAccess,
      remoteAccess: remoteAccess,
      forwardUnknown: forwardUnknown,
      portLabel: portLabel,
      unnamedContainer: unnamedContainer,
      dockerContainer: dockerContainer,
      autoStart: autoStart,
      updateAvailable: updateAvailable,
      image: image,
      ports: ports,
      online: online,
      offline: offline,
      unnamedVm: unnamedVm,
      virtualMachine: virtualMachine,
      running: running,
      vncAvailable: vncAvailable,
      vmDomainId: vmDomainId,
      fromVmDomainState: fromVmDomainState,
      status: status,
      unnamedShare: unnamedShare,
      cache: cache,
      array: array,
      shareDirectory: shareDirectory,
      capacity: capacity,
      freeLabel: freeLabel,
      allocationStrategy: allocationStrategy,
      defaultValue: defaultValue,
      splitLevel: splitLevel,
      description: description,
      none: none,
      shareDirectoryConfig: shareDirectoryConfig,
      unknownDisk: unknownDisk,
      sleeping: sleeping,
      networkInterface: networkInterface,
      noAddress: noAddress,
      accessAddress: accessAddress,
      batteryLoad: batteryLoad,
      plugin: plugin,
      unknownVersion: unknownVersion,
      apiCliModules: apiCliModules,
      yes: yes,
      no: no,
      pluginInstallTask: pluginInstallTask,
      installTask: installTask,
      log: log,
      unknownSize: unknownSize,
      localAccessAddress: localAccessAddress,
      remoteAccessAddress: remoteAccessAddress,
      notification: notification,
      unnamed: unnamed,
      directory: directory,
      unknownCpu: unknownCpu,
      coresCount: coresCount,
      threadsCount: threadsCount,
      unknownMotherboard: unknownMotherboard,
      unknownSystem: unknownSystem,
      noPackageVersions: noPackageVersions,
      noServicesReturned: noServicesReturned,
      servicesOnlineSummary: servicesOnlineSummary,
      noNetworksReturned: noNetworksReturned,
      networksCount: networksCount,
      noPortConflictInfo: noPortConflictInfo,
      noPortConflicts: noPortConflicts,
      portConflictCount: portConflictCount,
      container: container,
      noPortMappings: noPortMappings,
      totalUsage: totalUsage,
      usedUsage: usedUsage,
      usedTotalUsage: usedTotalUsage,
      started: started,
      stopped: stopped,
      paused: paused,
      idle: idle,
      shutDown: shutDown,
      crashed: crashed,
      daysCount: daysCount,
      hoursCount: hoursCount,
      minutesCount: minutesCount,
    );
  }

  void activate() {
    current = this;
  }
}
