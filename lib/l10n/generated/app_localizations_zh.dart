// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Chinese (`zh`).
class AppLocalizationsZh extends AppLocalizations {
  AppLocalizationsZh([String locale = 'zh']) : super(locale);

  @override
  String get appTitle => 'Unflutterraid';

  @override
  String get languageSystem => '跟随系统';

  @override
  String get languageChinese => '简体中文';

  @override
  String get languageEnglish => 'English';

  @override
  String get languageSettingTitle => '语言';

  @override
  String get languageSettingSubtitle => '界面文案显示语言';

  @override
  String get loginServerAddress => '服务器地址';

  @override
  String get loginServerAddressHint => '请输入 IP 地址或域名';

  @override
  String get loginServerAddressError => '请输入有效的 IP 地址或域名';

  @override
  String get loginApiKey => 'API 密钥';

  @override
  String get loginApiKeyHint => '请输入 API 密钥';

  @override
  String get loginApiKeyError => '请输入有效的 API 密钥';

  @override
  String get loginRememberMe => '记住我';

  @override
  String get loginSuccess => '登录成功';

  @override
  String get loginConnecting => '正在连接';

  @override
  String get loginButton => '登录';

  @override
  String loginFailed(String error) {
    return '登录失败：$error';
  }

  @override
  String get showApiKey => '显示 API 密钥';

  @override
  String get hideApiKey => '隐藏 API 密钥';

  @override
  String get settingsTitle => '设置';

  @override
  String get settingsSubtitle => '应用偏好';

  @override
  String get settingsIntroEyebrow => 'App Settings';

  @override
  String get settingsIntroTitle => '简洁的应用设置';

  @override
  String get settingsIntroDescription => '语言与主题是紧凑的偏好项，后续可继续加入通知、显示密度等。';

  @override
  String get settingsGeneralSection => '通用';

  @override
  String get settingsGeneralTrailing => '基础偏好';

  @override
  String get settingsThemeTitle => '主题';

  @override
  String get settingsThemeSubtitle => '浅色、深色或跟随系统';

  @override
  String get settingsComingSoon => '即将支持';

  @override
  String settingsThemeToast(String theme) {
    return '主题：$theme';
  }

  @override
  String get settingsNotificationsTitle => '通知';

  @override
  String get settingsNotificationsSubtitle => '主页通知中心展示 Unraid 未读/告警（只读）';

  @override
  String get settingsNotificationsToast => '推送偏好尚未接入；请在主页通知模块查看列表';

  @override
  String get settingsAutoRefreshTitle => '自动刷新';

  @override
  String get settingsAutoRefreshSubtitle => '仪表盘定时拉取服务器状态';

  @override
  String settingsAutoRefreshInterval(int seconds) {
    return '间隔 $seconds 秒';
  }

  @override
  String get settingsAutoRefreshEnabled => '已开启';

  @override
  String get settingsAutoRefreshDisabled => '已关闭';

  @override
  String refreshFailed(String error) {
    return '刷新失败：$error';
  }

  @override
  String actionSucceededRefreshing(String name, String action) {
    return '$name 已$action，正在刷新…';
  }

  @override
  String get createFolder => '新建文件夹';

  @override
  String get createFolderTitle => '新建文件夹';

  @override
  String get createFolderHint => '文件夹名称';

  @override
  String get createFolderEmptyError => '名称不能为空';

  @override
  String get createFolderInvalidError => '名称不能包含 / 或 \\';

  @override
  String folderCreated(String name) {
    return '已创建 $name';
  }

  @override
  String get uploadFiles => '上传文件';

  @override
  String get uploadInProgress => '正在上传…';

  @override
  String uploadResultSummary(int success, int failed) {
    return '上传完成：成功 $success，失败 $failed';
  }

  @override
  String get uploadCancelled => '已取消上传';

  @override
  String albumViewerPage(int current, int total) {
    return '$current / $total';
  }

  @override
  String get backupResultTitle => '备份结果';

  @override
  String backupResultSuccessSection(int count) {
    return '成功 ($count)';
  }

  @override
  String backupResultSkippedSection(int count) {
    return '跳过 ($count)';
  }

  @override
  String backupResultFailedSection(int count) {
    return '失败 ($count)';
  }

  @override
  String get backupResultEmptySection => '无';

  @override
  String get backupResultCancelledNote => '任务已取消，以下为已处理结果。';

  @override
  String get settingsConnectionSection => '连接';

  @override
  String get settingsConnectionTrailing => '登录相关';

  @override
  String get settingsAboutSection => '关于';

  @override
  String get settingsAboutTrailing => '版本与许可';

  @override
  String get settingsOpen => '查看';

  @override
  String get aboutTitle => '关于 Unflutterraid';

  @override
  String get aboutSettingsSubtitle => '版本、许可与凭据说明';

  @override
  String aboutVersion(String version) {
    return '版本 $version';
  }

  @override
  String get aboutDescription =>
      'Unflutterraid 是面向 Unraid 的轻量管理客户端，通过 API Key 连接服务器，并使用 File Browser 处理文件与媒体。';

  @override
  String get aboutAuthTitle => '如何登录';

  @override
  String get aboutAuthBody =>
      '在 Unraid 中创建 API Key（具备所需权限），在登录页填写服务器地址与密钥。无需应用内注册账号。';

  @override
  String get aboutLicenseTitle => '开源许可';

  @override
  String get aboutLicenseBody => '本项目使用 AGPL-3.0 许可，详见仓库 LICENSE 文件。';

  @override
  String get aboutSecurityTitle => '凭据存储';

  @override
  String get aboutSecurityBody =>
      '「记住我」会将 API Key 写入系统安全存储（如 Android Keystore）；服务器地址等非敏感项保存在本地偏好中。';

  @override
  String get powerSectionTitle => '阵列电源';

  @override
  String get powerSectionTrailing => 'array power';

  @override
  String get powerStartArray => '启动阵列';

  @override
  String get powerStopArray => '停止阵列';

  @override
  String get powerStartArrayConfirmTitle => '启动阵列？';

  @override
  String get powerStartArrayConfirmMessage =>
      '将启动 Unraid 阵列，共享与 Docker 依赖阵列可用。确认继续？';

  @override
  String get powerStopArrayConfirmTitle => '停止阵列？';

  @override
  String get powerStopArrayConfirmMessage => '停止阵列会使共享与多数容器不可用。请确认已无重要写入。';

  @override
  String get powerConfirmWordLabel => '请输入 STOP 以确认';

  @override
  String get powerConfirmWordHint => 'STOP';

  @override
  String get powerConfirmWordError => '请输入 STOP 确认';

  @override
  String powerActionSubmitted(String action) {
    return '已提交：$action';
  }

  @override
  String get powerMissingClient => '未连接服务器，无法执行电源操作';

  @override
  String get powerOsNote =>
      '当前 API 支持阵列启停；整机重启/关机未在 Connect GraphQL 暴露，请使用 WebGUI。';

  @override
  String get paritySectionTitle => '校验操作';

  @override
  String get parityStart => '开始校验';

  @override
  String get parityCancel => '取消校验';

  @override
  String get parityStartConfirmTitle => '开始奇偶校验？';

  @override
  String get parityStartConfirmMessage => '将启动非纠正模式奇偶校验，可能影响磁盘性能。';

  @override
  String get parityCancelConfirmTitle => '取消奇偶校验？';

  @override
  String get parityCancelConfirmMessage => '将取消进行中的奇偶校验任务。';

  @override
  String get dockerLogsTitle => '容器日志';

  @override
  String get dockerLogsEmpty => '没有日志行';

  @override
  String get copyLogs => '复制日志';

  @override
  String get logsCopied => '日志已复制到剪贴板';

  @override
  String get dockerLogsConsoleNote => '交互式终端未接入 GraphQL；请使用 WebUI 或 SSH。';

  @override
  String get dockerConsoleNote =>
      '控制台：优先打开容器 WebUI；完整 shell 请使用 Unraid WebGUI / SSH。';

  @override
  String get openWebUi => '打开 WebUI';

  @override
  String webUiUrlHint(String url) {
    return 'WebUI：$url';
  }

  @override
  String get batchCopy => '复制';

  @override
  String get copyToTitle => '复制到…';

  @override
  String get copyHere => '复制到此目录';

  @override
  String get serverProfilesTitle => '服务器档案';

  @override
  String get serverProfilesSettingsSubtitle => '管理多台 Unraid 连接';

  @override
  String get serverProfilesEmpty => '还没有已保存的服务器。登录并勾选「记住我」后会自动加入档案。';

  @override
  String get serverProfileAddTitle => '添加服务器';

  @override
  String get serverProfileEditTitle => '编辑服务器';

  @override
  String get serverProfileNameLabel => '显示名称';

  @override
  String get serverProfileConnect => '连接';

  @override
  String get serverProfileIncomplete => '请填写地址与 API Key';

  @override
  String get serverProfileDeleteTitle => '删除服务器档案？';

  @override
  String serverProfileDeleteMessage(String name) {
    return '将删除「$name」的本地凭据。';
  }

  @override
  String get settingsServerConfigTitle => '服务器配置';

  @override
  String get settingsServerConfigSubtitle => '地址、协议与 API Key';

  @override
  String get settingsPlanned => '规划中';

  @override
  String get settingsServerConfigToast => '服务器配置将在后续版本集中管理';

  @override
  String get settingsNotConnected => '未连接';

  @override
  String get settingsConnected => '已连接';

  @override
  String get serverConfigTitle => '服务器连接';

  @override
  String get serverConfigSaveReconnect => '保存并重连';

  @override
  String get serverConfigDisconnect => '断开连接';

  @override
  String get serverConfigClearSaved => '清除已保存凭据';

  @override
  String get serverConfigReconnecting => '正在验证连接…';

  @override
  String get serverConfigReconnectSuccess => '已使用新连接';

  @override
  String get serverConfigDisconnected => '已断开连接';

  @override
  String get serverConfigCleared => '已清除保存的登录信息';

  @override
  String get serverConfigNoSessionHint => '当前未连接。可编辑已保存凭据并连接，或先从登录页进入。';

  @override
  String settingsLanguageToast(String language) {
    return '语言：$language';
  }

  @override
  String get navHome => '主页';

  @override
  String get navDocker => 'Docker';

  @override
  String get navVm => '虚拟机';

  @override
  String get navShare => '共享';

  @override
  String get settingsOpenTooltip => '打开设置';

  @override
  String get notificationsTooltip => '通知';

  @override
  String get back => '返回';

  @override
  String get retry => '重试';

  @override
  String get cancel => '取消';

  @override
  String get confirm => '确认';

  @override
  String get close => '关闭';

  @override
  String get refresh => '刷新';

  @override
  String get unknown => '未知';

  @override
  String get edit => '编辑';

  @override
  String get all => '全部';

  @override
  String get details => '详情';

  @override
  String get browse => '浏览';

  @override
  String get settings => '设置';

  @override
  String get start => '启动';

  @override
  String get stop => '停止';

  @override
  String get restart => '重启';

  @override
  String get status => '状态';

  @override
  String get description => '说明';

  @override
  String get location => '位置';

  @override
  String get overview => '概览';

  @override
  String get memory => '内存';

  @override
  String get array => '阵列';

  @override
  String get notifications => '通知';

  @override
  String get motherboard => '主板';

  @override
  String get disk => '磁盘';

  @override
  String get network => '网络';

  @override
  String get plugins => '插件';

  @override
  String get permissions => '权限';

  @override
  String get connection => '连接';

  @override
  String get logs => '日志';

  @override
  String get album => '相册';

  @override
  String get music => '音乐';

  @override
  String get photos => '照片';

  @override
  String get videos => '视频';

  @override
  String get file => '文件';

  @override
  String get project => '项目';

  @override
  String get connectServerFirst => '请先连接服务器';

  @override
  String get missingConnection => '缺少服务器连接';

  @override
  String get missingConnectionOrId => '缺少服务器连接或项目 ID';

  @override
  String get missingConnectionArgs => '缺少连接参数';

  @override
  String loadFailed(String error) {
    return '加载失败：$error';
  }

  @override
  String get notReturned => '未返回';

  @override
  String get notConnectedTitle => '未连接服务器';

  @override
  String get notConnectedMessage => '请返回登录页重新连接。';

  @override
  String get loadingServerTitle => '正在读取服务器';

  @override
  String get loadingServerMessage => '正在请求 Unraid GraphQL API...';

  @override
  String get readFailedTitle => '读取失败';

  @override
  String get noDataTitle => '暂无数据';

  @override
  String get noDataMessage => '服务器没有返回可显示的数据。';

  @override
  String get viewFullInfo => '查看完整信息';

  @override
  String get liveMetrics => '实时指标';

  @override
  String get arrayAndServices => '阵列与服务';

  @override
  String get arrayState => '阵列状态';

  @override
  String get arrayCapacity => '阵列容量';

  @override
  String get noParityTask => '暂无校验任务';

  @override
  String get servicesOnline => '服务在线';

  @override
  String get recentNotifications => '最近通知';

  @override
  String get extendedManagement => '扩展管理';

  @override
  String get interfaceModules => '接口模块';

  @override
  String notificationCount(int count) {
    return '$count 条提醒';
  }

  @override
  String warningAlertCount(int warning, int alert) {
    return '$warning 警告 · $alert 严重';
  }

  @override
  String get cpuUsage => 'CPU 使用';

  @override
  String get noWarningAlerts => '暂无警告或严重通知';

  @override
  String get noNotificationDetailsTitle => '暂无通知详情';

  @override
  String get noNotificationDetailsMessage => '服务器仅返回了通知数量，未返回警告或严重通知列表。';

  @override
  String moduleNoDataMessage(String module) {
    return '服务器没有返回$module相关信息。';
  }

  @override
  String get notificationCenter => '通知中心';

  @override
  String get moduleDisksSubtitle => 'SMART / 分区 / 温度';

  @override
  String get moduleNetworkSubtitle => '接口 / 访问地址';

  @override
  String get moduleUpsSubtitle => '电量 / 负载 / 策略';

  @override
  String get modulePluginsSubtitle => '安装任务 / 模块';

  @override
  String get moduleCloudSubtitle => '远程访问 / Cloud';

  @override
  String searchTypeItems(String type) {
    return '搜索$type项目';
  }

  @override
  String typeRefreshSubmitted(String type) {
    return '$type刷新已提交';
  }

  @override
  String typeEmptyTitle(String type) {
    return '$type为空';
  }

  @override
  String typeEmptyMessage(String type) {
    return '服务器当前没有返回$type项目。';
  }

  @override
  String get noMatchesTitle => '没有匹配项';

  @override
  String get noMatchesMessage => '换一个关键词试试。';

  @override
  String actionSubmitted(String title, String action) {
    return '$title $action操作已提交';
  }

  @override
  String runningAndStopped(int running, int stopped) {
    return '$running 运行中 · $stopped 未运行';
  }

  @override
  String arrayUsageLabel(String usage) {
    return '阵列 $usage';
  }

  @override
  String runningCount(int count) {
    return '$count 运行中';
  }

  @override
  String get unknownProject => '未知项目';

  @override
  String get noInfo => '暂无信息';

  @override
  String get readingDirectoryTitle => '正在读取目录';

  @override
  String get readingDirectoryMessage => '正在通过 GraphQL 读取共享根目录...';

  @override
  String get noShareDirectoryTitle => '暂无共享目录';

  @override
  String get noShareDirectoryMessage => 'GraphQL 没有返回共享根目录数据。';

  @override
  String get parentDirectory => '上一级';

  @override
  String shareRootSize(String size) {
    return '共享根目录 · $size';
  }

  @override
  String get subdirBrowseFuture => '子目录浏览将作为 File Manager 独立功能实现';

  @override
  String get previewUnsupported => '暂不支持预览该文件类型';

  @override
  String labelActionSubmitted(String label) {
    return '$label 操作已提交';
  }

  @override
  String get imageLoadFailed => '图片加载失败';

  @override
  String get chooseServerIcon => '选择服务器图标';

  @override
  String get returnHome => '返回主页';

  @override
  String countItems(int count) {
    return '$count 个';
  }

  @override
  String countRecords(int count) {
    return '$count 条记录';
  }

  @override
  String countFiles(int count) {
    return '$count 个文件';
  }

  @override
  String get productDetails => '产品详情';

  @override
  String get basicInfo => '基本信息';

  @override
  String get detailSampleBody =>
      '这是一个详情页面示例，展示如何按照登录页面的设计风格创建移动端详情页。页面保持相同的紫蓝渐变、圆角设计和柔和动效，确保视觉一致性。';

  @override
  String get featureList => '功能列表';

  @override
  String get featureResponsive => '支持响应式设计';

  @override
  String get featureVisualConsistency => '保持视觉一致性';

  @override
  String get featureAnimations => '优雅的动画效果';

  @override
  String get featureClearHierarchy => '清晰的信息层次';

  @override
  String get detailedDescription => '详细说明';

  @override
  String get designPhilosophy => '设计理念';

  @override
  String get designPhilosophyText => '延续登录页面的现代简约风格，以紫蓝渐变作为主视觉元素，创建统一且专业的用户体验。';

  @override
  String get interactionDesign => '交互设计';

  @override
  String get interactionDesignText => '页面元素采用顺序淡入动画，增强层次感和用户体验，按钮包含清晰的点击反馈。';

  @override
  String get uiElements => 'UI 元素';

  @override
  String get uiElementsText => '采用大圆角设计增强现代感和友好度，适当的阴影提供层次感，合理的间距确保阅读舒适。';

  @override
  String get confirmAction => '确认操作';

  @override
  String get actionConfirmedTitle => '操作已确认';

  @override
  String get actionConfirmedBody => '这里可以接入实际业务逻辑。';

  @override
  String get gotIt => '知道了';

  @override
  String get serverProfile => '服务器资料';

  @override
  String get authorization => '授权';

  @override
  String get hardwareAndSystem => '硬件与系统';

  @override
  String get model => '型号';

  @override
  String get system => '系统';

  @override
  String get packageVersion => '包版本';

  @override
  String get arrayAndStorage => '阵列与存储';

  @override
  String get networkAndConnection => '网络与连接';

  @override
  String get localUrl => '本地 URL';

  @override
  String get remoteUrl => '远程 URL';

  @override
  String get dockerNetwork => 'Docker 网络';

  @override
  String get portConflicts => '端口冲突';

  @override
  String get cloudPluginsPermissions => 'Cloud / 插件 / 权限';

  @override
  String get registerUsernameLabel => '用户名 / 手机号';

  @override
  String get registerUsernameHint => '请输入用户名或手机号';

  @override
  String get registerUsernameError => '请输入有效的用户名或手机号';

  @override
  String get registerPasswordLabel => '密码';

  @override
  String get registerPasswordHint => '请输入密码（至少 6 位）';

  @override
  String get registerPasswordError => '密码不能少于 6 位';

  @override
  String get registerConfirmPasswordLabel => '确认密码';

  @override
  String get registerConfirmPasswordHint => '请再次输入密码';

  @override
  String get registerConfirmPasswordError => '两次输入的密码不一致';

  @override
  String get registerSuccess => '注册成功';

  @override
  String get registerButton => '注册';

  @override
  String get alreadyHaveAccount => '已有账号？';

  @override
  String get backToLogin => '返回登录';

  @override
  String get createAccount => '创建账号';

  @override
  String get registerSubtitle => '请填写以下信息完成注册';

  @override
  String get musicLibrary => '音乐库';

  @override
  String get songs => '歌曲';

  @override
  String get allSongs => '全部歌曲';

  @override
  String get collapse => '收起';

  @override
  String get albums => '专辑';

  @override
  String get lossless => '无损';

  @override
  String get searchSongsAlbums => '搜索歌曲、专辑';

  @override
  String get nowPlaying => '正在播放';

  @override
  String get today => '今天';

  @override
  String get yesterday => '昨天';

  @override
  String get unknownDate => '未知日期';

  @override
  String yearMonth(int year, int month) {
    return '$year年$month月';
  }

  @override
  String get noPhotosFound => '没有找到照片';

  @override
  String get noAlbumDirsFound => '没有找到相册目录';

  @override
  String get noVideosFound => '没有找到视频';

  @override
  String get mediaPermissionRequiredBackup => '需要照片访问权限才能进行备份';

  @override
  String get selectBackupDirectory => '选择备份目录';

  @override
  String get selectThisDirectory => '选择此目录';

  @override
  String get goUp => '返回上级';

  @override
  String get noSubfolders => '此目录下没有子文件夹';

  @override
  String get photoBackup => '照片备份';

  @override
  String get permissionChecking => '权限检查中...';

  @override
  String get permissionCheckingSubtitle => '正在检查照片访问权限';

  @override
  String get needMediaPermission => '需要照片权限';

  @override
  String get grantPermission => '授予权限';

  @override
  String get mediaPermission => '照片权限';

  @override
  String get mediaPermissionGranted => '照片访问权限已授予';

  @override
  String get autoBackup => '自动备份（偏好）';

  @override
  String get autoBackupSubtitle => '仅记住偏好，不会在后台自动运行；请点「立即备份」';

  @override
  String get grantMediaFirst => '请先授予照片权限';

  @override
  String get targetDirectory => '目标目录';

  @override
  String get wifiOnlyBackup => '仅 Wi-Fi 备份';

  @override
  String get wifiOnlyBackupSubtitle => '避免使用移动网络上传';

  @override
  String get chargeWhenBackupVideo => '充电时备份视频';

  @override
  String get chargeWhenBackupVideoSubtitle => '视频备份将在后续版本支持';

  @override
  String get lastSync => '上次同步';

  @override
  String get noSyncRecord => '暂无同步记录';

  @override
  String missingPermissionAccess(String permissions) {
    return '缺少$permissions访问权限';
  }

  @override
  String get andJoin => '和';

  @override
  String get photoBackupReady => '照片备份已就绪';

  @override
  String get needAuthToBackup => '需要授权才能备份';

  @override
  String get photosVideosSyncToUnraid => '可将最近照片手动上传到 Unraid（每次最多 50 张）';

  @override
  String get grantPhotosVideosToEnable => '请授予照片访问权限以启用备份';

  @override
  String get backupNow => '立即备份';

  @override
  String get backupCancel => '取消备份';

  @override
  String backupRunning(int current, int total) {
    return '正在备份 $current/$total';
  }

  @override
  String backupCurrentFile(String name) {
    return '当前：$name';
  }

  @override
  String get backupWifiBlocked => '当前为移动网络。请连接 Wi-Fi，或关闭「仅 Wi-Fi 备份」。';

  @override
  String get backupUnsupportedPlatform => '相册备份目前仅支持 Android / iOS。';

  @override
  String get backupNoPhotos => '没有可备份的本地照片。';

  @override
  String get backupNeedConnection => '请先连接 Unraid 服务器后再备份。';

  @override
  String backupDoneSummary(int success, int skipped, int failed) {
    return '完成：成功 $success，跳过 $skipped，失败 $failed';
  }

  @override
  String backupCancelledSummary(int success, int skipped, int failed) {
    return '已取消。成功 $success，跳过 $skipped，失败 $failed';
  }

  @override
  String lastSyncSummary(String time, int success, int skipped, int failed) {
    return '$time · 成功 $success / 跳过 $skipped / 失败 $failed';
  }

  @override
  String get backupBatchHint => '每次上传设备上最新的最多 50 张照片；同名文件会跳过。';

  @override
  String get searchPhotosVideos => '搜索照片、视频';

  @override
  String get allPhotos => '全部照片';

  @override
  String get backupEnabledSample => '已开启 / 今天 09:42';

  @override
  String photoCount(int count) {
    return '$count 张';
  }

  @override
  String get apiUnraidServiceMissing =>
      '未找到 unraid-api 服务，请确认 Unraid Connect/API 插件已启用';

  @override
  String get apiShareActionUnsupported => '共享项目不支持该操作';

  @override
  String get apiConnectionTimeout => '连接服务器超时';

  @override
  String apiCannotConnect(String error) {
    return '无法连接服务器：$error';
  }

  @override
  String apiHttpError(int statusCode) {
    return '服务器返回 HTTP $statusCode';
  }

  @override
  String get apiInvalidData => '服务器返回了无效数据';

  @override
  String get apiGraphqlFailed => 'GraphQL 请求失败';

  @override
  String get apiMissingDataField => '响应中缺少 data 字段';

  @override
  String get apiActionListDirectory => '读取目录';

  @override
  String get apiActionScanMedia => '扫描媒体文件';

  @override
  String get apiActionReadFile => '读取文件';

  @override
  String get apiActionReadThumbnail => '读取缩略图';

  @override
  String apiFileBrowserInvalidJson(String action) {
    return 'File Browser 返回了无效 JSON：$action';
  }

  @override
  String apiFileBrowserTimeout(String action) {
    return 'File Browser $action超时';
  }

  @override
  String apiFileBrowserCannotConnect(String error) {
    return '无法连接 File Browser：$error';
  }

  @override
  String apiFileBrowserForbidden(int statusCode) {
    return 'File Browser 拒绝访问，请检查匿名访问或反向代理认证配置（HTTP $statusCode）';
  }

  @override
  String get apiFileBrowserNotFound => 'File Browser 未找到路径（HTTP 404）';

  @override
  String apiFileBrowserFailed(String action, int statusCode) {
    return 'File Browser $action失败：HTTP $statusCode';
  }

  @override
  String get unbound => '未绑定';

  @override
  String get installedPlugins => '已安装插件';

  @override
  String countUnit(int count) {
    return '$count 个';
  }

  @override
  String get apiKeyRolesDescription => '可用角色与权限来自 apiKeyPossibleRoles';

  @override
  String get enabled => '已启用';

  @override
  String get disabled => '未启用';

  @override
  String oidcProviderCount(int count) {
    return '$count 个 OIDC 提供方';
  }

  @override
  String get unraidCloudStatus => 'Unraid Cloud 状态';

  @override
  String dynamicRemoteAccess(String type) {
    return '动态远程访问 $type';
  }

  @override
  String get remoteAccess => '远程访问';

  @override
  String get forwardUnknown => 'forward 未知';

  @override
  String portLabel(String port) {
    return '端口 $port';
  }

  @override
  String get unnamedContainer => '未命名容器';

  @override
  String get dockerContainer => 'Docker 容器';

  @override
  String get autoStart => '自启动';

  @override
  String get updateAvailable => '有更新';

  @override
  String get image => '镜像';

  @override
  String get ports => '端口';

  @override
  String get online => '在线';

  @override
  String get offline => '离线';

  @override
  String get unnamedVm => '未命名虚拟机';

  @override
  String get virtualMachine => '虚拟机';

  @override
  String get running => '运行中';

  @override
  String get vncAvailable => 'VNC 可用';

  @override
  String get vmDomainId => '虚拟机域标识';

  @override
  String get fromVmDomainState => '来自 vms.domain.state';

  @override
  String get unnamedShare => '未命名共享';

  @override
  String get cache => '缓存';

  @override
  String get shareDirectory => '共享目录';

  @override
  String get capacity => '容量';

  @override
  String freeLabel(String value) {
    return 'free $value';
  }

  @override
  String get allocationStrategy => '分配策略';

  @override
  String get defaultValue => '默认';

  @override
  String splitLevel(String value) {
    return 'split level $value';
  }

  @override
  String get none => '无';

  @override
  String get shareDirectoryConfig => '共享目录配置';

  @override
  String get unknownDisk => '未知磁盘';

  @override
  String get sleeping => '休眠';

  @override
  String get networkInterface => '网络接口';

  @override
  String get noAddress => '无地址';

  @override
  String get accessAddress => '访问地址';

  @override
  String batteryLoad(String battery, String load) {
    return '电量 $battery% · 负载 $load%';
  }

  @override
  String get plugin => '插件';

  @override
  String get unknownVersion => '未知版本';

  @override
  String apiCliModules(String api, String cli) {
    return 'API $api · CLI $cli';
  }

  @override
  String get yes => '有';

  @override
  String get no => '无';

  @override
  String get pluginInstallTask => '插件安装任务';

  @override
  String get installTask => '安装任务';

  @override
  String get log => '日志';

  @override
  String get unknownSize => '未知大小';

  @override
  String get localAccessAddress => '本地访问地址';

  @override
  String get remoteAccessAddress => '远程访问地址';

  @override
  String get notification => '通知';

  @override
  String get unnamed => '未命名';

  @override
  String get directory => '目录';

  @override
  String get unknownCpu => '未知 CPU';

  @override
  String coresCount(String count) {
    return '$count 核';
  }

  @override
  String threadsCount(String count) {
    return '$count 线程';
  }

  @override
  String get unknownMotherboard => '未知主板';

  @override
  String get unknownSystem => '未知系统';

  @override
  String get noPackageVersions => '未返回包版本';

  @override
  String get noServicesReturned => '未返回服务';

  @override
  String servicesOnlineSummary(int online, int total, String names) {
    return '$online/$total 在线 · $names';
  }

  @override
  String get noNetworksReturned => '未返回网络';

  @override
  String networksCount(int count) {
    return '$count 个网络';
  }

  @override
  String get noPortConflictInfo => '未返回端口冲突信息';

  @override
  String get noPortConflicts => '未发现端口冲突';

  @override
  String portConflictCount(int count) {
    return '$count 个端口冲突';
  }

  @override
  String get container => '容器';

  @override
  String get noPortMappings => '未返回端口映射';

  @override
  String totalUsage(String value) {
    return '总计 $value';
  }

  @override
  String usedUsage(String value) {
    return '已用 $value';
  }

  @override
  String usedTotalUsage(String used, String total) {
    return '已用 $used / $total';
  }

  @override
  String get started => '已启动';

  @override
  String get stopped => '已停止';

  @override
  String get paused => '已暂停';

  @override
  String get idle => '空闲';

  @override
  String get shutDown => '已关闭';

  @override
  String get crashed => '异常';

  @override
  String daysCount(int count) {
    return '$count 天';
  }

  @override
  String hoursCount(int count) {
    return '$count 小时';
  }

  @override
  String minutesCount(int count) {
    return '$count 分钟';
  }

  @override
  String get themeSystem => '跟随系统';

  @override
  String get themeLight => '浅色';

  @override
  String get themeDark => '深色';

  @override
  String get noMusicFound => '没有找到音乐文件';

  @override
  String get musicLibraryEmpty => '在共享目录中未发现音频。默认路径：/mnt/user/music';

  @override
  String musicTrackCount(int count) {
    return '$count 首';
  }

  @override
  String get musicLoadingTrack => '正在加载…';

  @override
  String musicPlaybackError(String error) {
    return '播放失败：$error';
  }

  @override
  String get musicQueueStart => '已是队列第一首';

  @override
  String get musicQueueEnd => '已是队列最后一首';

  @override
  String get searchMusic => '搜索歌曲';

  @override
  String get rename => '重命名';

  @override
  String get delete => '删除';

  @override
  String get deleteConfirmTitle => '删除此项？';

  @override
  String deleteConfirmMessage(String name) {
    return '将永久删除 $name。';
  }

  @override
  String get renameTitle => '重命名';

  @override
  String get renameHint => '新名称';

  @override
  String get renameEmptyError => '名称不能为空';

  @override
  String fileDeleted(String name) {
    return '已删除 $name';
  }

  @override
  String fileRenamed(String name) {
    return '已重命名为 $name';
  }

  @override
  String get moreActions => '更多操作';

  @override
  String get selectMode => '选择';

  @override
  String get cancelSelection => '取消选择';

  @override
  String get selectAll => '全选';

  @override
  String selectedCount(int count) {
    return '已选 $count 项';
  }

  @override
  String get batchDelete => '删除';

  @override
  String get batchMove => '移动';

  @override
  String get batchDeleteConfirmTitle => '删除所选项目？';

  @override
  String batchDeleteConfirmMessage(int count) {
    return '将永久删除 $count 个项目。';
  }

  @override
  String batchResultSummary(int success, int skipped, int failed) {
    return '完成：成功 $success，跳过 $skipped，失败 $failed';
  }

  @override
  String get moveToTitle => '移动到…';

  @override
  String get selectMoveDestination => '选择目标文件夹';

  @override
  String get moveHere => '移动到此目录';

  @override
  String get cannotMoveIntoSelf => '不能将文件夹移动到其自身或子目录中';

  @override
  String get batchBusy => '正在处理…';

  @override
  String get openFolder => '打开';

  @override
  String get apiActionDelete => '删除';

  @override
  String get apiActionRename => '重命名';

  @override
  String get apiActionUpload => '上传';
}
