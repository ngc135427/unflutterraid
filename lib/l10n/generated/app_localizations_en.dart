// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Unflutterraid';

  @override
  String get languageSystem => 'System';

  @override
  String get languageChinese => 'Simplified Chinese';

  @override
  String get languageEnglish => 'English';

  @override
  String get languageSettingTitle => 'Language';

  @override
  String get languageSettingSubtitle => 'Interface language';

  @override
  String get loginServerAddress => 'Server address';

  @override
  String get loginServerAddressHint => 'Enter an IP address or domain';

  @override
  String get loginServerAddressError => 'Enter a valid IP address or domain';

  @override
  String get loginApiKey => 'API key';

  @override
  String get loginApiKeyHint => 'Enter API key';

  @override
  String get loginApiKeyError => 'Enter a valid API key';

  @override
  String get loginRememberMe => 'Remember me';

  @override
  String get loginSuccess => 'Signed in';

  @override
  String get loginConnecting => 'Connecting';

  @override
  String get loginButton => 'Sign in';

  @override
  String loginFailed(String error) {
    return 'Sign-in failed: $error';
  }

  @override
  String get showApiKey => 'Show API key';

  @override
  String get hideApiKey => 'Hide API key';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get settingsSubtitle => 'App preferences';

  @override
  String get settingsIntroEyebrow => 'App Settings';

  @override
  String get settingsIntroTitle => 'Simple app settings';

  @override
  String get settingsIntroDescription =>
      'Language and theme are compact preferences. Notifications and density can fit here later.';

  @override
  String get settingsGeneralSection => 'General';

  @override
  String get settingsGeneralTrailing => 'Basics';

  @override
  String get settingsThemeTitle => 'Theme';

  @override
  String get settingsThemeSubtitle => 'Light, dark, or system';

  @override
  String get settingsComingSoon => 'Coming soon';

  @override
  String settingsThemeToast(String theme) {
    return 'Theme: $theme';
  }

  @override
  String get settingsNotificationsTitle => 'Notifications';

  @override
  String get settingsNotificationsSubtitle =>
      'Alerts and server status updates';

  @override
  String get settingsNotificationsToast =>
      'Notification preferences will be added later';

  @override
  String get settingsConnectionSection => 'Connection';

  @override
  String get settingsConnectionTrailing => 'Sign-in';

  @override
  String get settingsServerConfigTitle => 'Server configuration';

  @override
  String get settingsServerConfigSubtitle =>
      'Default server, protocol, and credentials';

  @override
  String get settingsPlanned => 'Planned';

  @override
  String get settingsServerConfigToast =>
      'Server configuration will be managed here later';

  @override
  String settingsLanguageToast(String language) {
    return 'Language: $language';
  }

  @override
  String get navHome => 'Home';

  @override
  String get navDocker => 'Docker';

  @override
  String get navVm => 'VMs';

  @override
  String get navShare => 'Shares';

  @override
  String get settingsOpenTooltip => 'Open settings';

  @override
  String get notificationsTooltip => 'Notifications';

  @override
  String get back => 'Back';

  @override
  String get retry => 'Retry';

  @override
  String get cancel => 'Cancel';

  @override
  String get confirm => 'Confirm';

  @override
  String get close => 'Close';

  @override
  String get refresh => 'Refresh';

  @override
  String get unknown => 'Unknown';

  @override
  String get edit => 'Edit';

  @override
  String get all => 'All';

  @override
  String get details => 'Details';

  @override
  String get browse => 'Browse';

  @override
  String get settings => 'Settings';

  @override
  String get start => 'Start';

  @override
  String get stop => 'Stop';

  @override
  String get restart => 'Restart';

  @override
  String get status => 'Status';

  @override
  String get description => 'Description';

  @override
  String get location => 'Location';

  @override
  String get overview => 'Overview';

  @override
  String get memory => 'Memory';

  @override
  String get array => 'Array';

  @override
  String get notifications => 'Notifications';

  @override
  String get motherboard => 'Motherboard';

  @override
  String get disk => 'Disks';

  @override
  String get network => 'Network';

  @override
  String get plugins => 'Plugins';

  @override
  String get permissions => 'Permissions';

  @override
  String get connection => 'Connection';

  @override
  String get logs => 'Logs';

  @override
  String get album => 'Album';

  @override
  String get music => 'Music';

  @override
  String get photos => 'Photos';

  @override
  String get videos => 'Videos';

  @override
  String get file => 'File';

  @override
  String get project => 'Item';

  @override
  String get connectServerFirst => 'Connect to a server first';

  @override
  String get missingConnection => 'Missing server connection';

  @override
  String get missingConnectionOrId => 'Missing server connection or item ID';

  @override
  String get missingConnectionArgs => 'Missing connection parameters';

  @override
  String loadFailed(String error) {
    return 'Load failed: $error';
  }

  @override
  String get notReturned => 'Not returned';

  @override
  String get notConnectedTitle => 'Not connected';

  @override
  String get notConnectedMessage => 'Return to sign-in and connect again.';

  @override
  String get loadingServerTitle => 'Loading server';

  @override
  String get loadingServerMessage => 'Requesting Unraid GraphQL API...';

  @override
  String get readFailedTitle => 'Load failed';

  @override
  String get noDataTitle => 'No data';

  @override
  String get noDataMessage => 'The server returned nothing to display.';

  @override
  String get viewFullInfo => 'View full info';

  @override
  String get liveMetrics => 'Live metrics';

  @override
  String get arrayAndServices => 'Array and services';

  @override
  String get arrayState => 'Array state';

  @override
  String get arrayCapacity => 'Array capacity';

  @override
  String get noParityTask => 'No parity check running';

  @override
  String get servicesOnline => 'Services online';

  @override
  String get recentNotifications => 'Recent notifications';

  @override
  String get extendedManagement => 'Extended management';

  @override
  String get interfaceModules => 'API modules';

  @override
  String notificationCount(int count) {
    return '$count alerts';
  }

  @override
  String warningAlertCount(int warning, int alert) {
    return '$warning warnings · $alert critical';
  }

  @override
  String get cpuUsage => 'CPU usage';

  @override
  String get noWarningAlerts => 'No warning or critical notifications';

  @override
  String get noNotificationDetailsTitle => 'No notification details';

  @override
  String get noNotificationDetailsMessage =>
      'Only notification counts were returned, not warning or critical items.';

  @override
  String moduleNoDataMessage(String module) {
    return 'The server returned no $module data.';
  }

  @override
  String get notificationCenter => 'Notification center';

  @override
  String get moduleDisksSubtitle => 'SMART / partitions / temperature';

  @override
  String get moduleNetworkSubtitle => 'Interfaces / access URLs';

  @override
  String get moduleUpsSubtitle => 'Charge / load / policy';

  @override
  String get modulePluginsSubtitle => 'Install tasks / modules';

  @override
  String get moduleCloudSubtitle => 'Remote access / Cloud';

  @override
  String searchTypeItems(String type) {
    return 'Search $type items';
  }

  @override
  String typeRefreshSubmitted(String type) {
    return '$type refresh submitted';
  }

  @override
  String typeEmptyTitle(String type) {
    return 'No $type';
  }

  @override
  String typeEmptyMessage(String type) {
    return 'The server returned no $type items.';
  }

  @override
  String get noMatchesTitle => 'No matches';

  @override
  String get noMatchesMessage => 'Try a different keyword.';

  @override
  String actionSubmitted(String title, String action) {
    return '$title $action submitted';
  }

  @override
  String runningAndStopped(int running, int stopped) {
    return '$running running · $stopped stopped';
  }

  @override
  String arrayUsageLabel(String usage) {
    return 'Array $usage';
  }

  @override
  String runningCount(int count) {
    return '$count running';
  }

  @override
  String get unknownProject => 'Unknown item';

  @override
  String get noInfo => 'No information';

  @override
  String get readingDirectoryTitle => 'Reading directory';

  @override
  String get readingDirectoryMessage => 'Reading share roots via GraphQL...';

  @override
  String get noShareDirectoryTitle => 'No share directories';

  @override
  String get noShareDirectoryMessage => 'GraphQL returned no share root data.';

  @override
  String get parentDirectory => 'Up';

  @override
  String shareRootSize(String size) {
    return 'Share root · $size';
  }

  @override
  String get subdirBrowseFuture =>
      'Subfolder browsing will ship as a File Manager feature';

  @override
  String get previewUnsupported => 'This file type cannot be previewed yet';

  @override
  String labelActionSubmitted(String label) {
    return '$label submitted';
  }

  @override
  String get imageLoadFailed => 'Failed to load image';

  @override
  String get chooseServerIcon => 'Choose server icon';

  @override
  String get returnHome => 'Back to home';

  @override
  String countItems(int count) {
    return '$count';
  }

  @override
  String countRecords(int count) {
    return '$count records';
  }

  @override
  String countFiles(int count) {
    return '$count files';
  }

  @override
  String get productDetails => 'Product details';

  @override
  String get basicInfo => 'Basic info';

  @override
  String get detailSampleBody =>
      'This is a sample details page that follows the login page design language with the same purple-blue gradient, rounded corners, and soft motion.';

  @override
  String get featureList => 'Features';

  @override
  String get featureResponsive => 'Responsive layout';

  @override
  String get featureVisualConsistency => 'Visual consistency';

  @override
  String get featureAnimations => 'Polished animations';

  @override
  String get featureClearHierarchy => 'Clear information hierarchy';

  @override
  String get detailedDescription => 'Details';

  @override
  String get designPhilosophy => 'Design philosophy';

  @override
  String get designPhilosophyText =>
      'Continue the modern minimal login style, using a purple-blue gradient as the primary visual element for a unified professional experience.';

  @override
  String get interactionDesign => 'Interaction design';

  @override
  String get interactionDesignText =>
      'Page elements fade in sequentially for hierarchy and feedback, with clear button press states.';

  @override
  String get uiElements => 'UI elements';

  @override
  String get uiElementsText =>
      'Large corner radii, soft shadows, and balanced spacing keep the layout modern and readable.';

  @override
  String get confirmAction => 'Confirm';

  @override
  String get actionConfirmedTitle => 'Action confirmed';

  @override
  String get actionConfirmedBody => 'Wire real business logic here.';

  @override
  String get gotIt => 'Got it';

  @override
  String get serverProfile => 'Server profile';

  @override
  String get authorization => 'License';

  @override
  String get hardwareAndSystem => 'Hardware and system';

  @override
  String get model => 'Model';

  @override
  String get system => 'System';

  @override
  String get packageVersion => 'Packages';

  @override
  String get arrayAndStorage => 'Array and storage';

  @override
  String get networkAndConnection => 'Network and connection';

  @override
  String get localUrl => 'Local URL';

  @override
  String get remoteUrl => 'Remote URL';

  @override
  String get dockerNetwork => 'Docker networks';

  @override
  String get portConflicts => 'Port conflicts';

  @override
  String get cloudPluginsPermissions => 'Cloud / plugins / permissions';

  @override
  String get registerUsernameLabel => 'Username / phone';

  @override
  String get registerUsernameHint => 'Enter username or phone number';

  @override
  String get registerUsernameError => 'Enter a valid username or phone number';

  @override
  String get registerPasswordLabel => 'Password';

  @override
  String get registerPasswordHint => 'Enter password (at least 6 characters)';

  @override
  String get registerPasswordError => 'Password must be at least 6 characters';

  @override
  String get registerConfirmPasswordLabel => 'Confirm password';

  @override
  String get registerConfirmPasswordHint => 'Enter password again';

  @override
  String get registerConfirmPasswordError => 'Passwords do not match';

  @override
  String get registerSuccess => 'Registered';

  @override
  String get registerButton => 'Register';

  @override
  String get alreadyHaveAccount => 'Already have an account?';

  @override
  String get backToLogin => 'Back to sign-in';

  @override
  String get createAccount => 'Create account';

  @override
  String get registerSubtitle => 'Fill in the form to register';

  @override
  String get musicLibrary => 'Library';

  @override
  String get songs => 'Songs';

  @override
  String get allSongs => 'All songs';

  @override
  String get collapse => 'Close';

  @override
  String get albums => 'Albums';

  @override
  String get lossless => 'Lossless';

  @override
  String get searchSongsAlbums => 'Search songs and albums';

  @override
  String get nowPlaying => 'Now playing';

  @override
  String get today => 'Today';

  @override
  String get yesterday => 'Yesterday';

  @override
  String get unknownDate => 'Unknown date';

  @override
  String yearMonth(int year, int month) {
    return '$year/$month';
  }

  @override
  String get noPhotosFound => 'No photos found';

  @override
  String get noAlbumDirsFound => 'No album folders found';

  @override
  String get noVideosFound => 'No videos found';

  @override
  String get mediaPermissionRequiredBackup =>
      'Photo and video permission is required for backup';

  @override
  String get selectBackupDirectory => 'Choose backup folder';

  @override
  String get selectThisDirectory => 'Use this folder';

  @override
  String get goUp => 'Up';

  @override
  String get noSubfolders => 'No subfolders in this directory';

  @override
  String get photoBackup => 'Photo backup';

  @override
  String get permissionChecking => 'Checking permissions...';

  @override
  String get permissionCheckingSubtitle => 'Checking photo and video access';

  @override
  String get needMediaPermission => 'Media permission required';

  @override
  String get grantPermission => 'Grant permission';

  @override
  String get mediaPermission => 'Media permission';

  @override
  String get mediaPermissionGranted => 'Photo and video access granted';

  @override
  String get autoBackup => 'Auto backup';

  @override
  String get autoBackupSubtitle => 'Sync phone photos to an Unraid share';

  @override
  String get grantMediaFirst => 'Grant media permission first';

  @override
  String get targetDirectory => 'Target folder';

  @override
  String get wifiOnlyBackup => 'Wi-Fi only';

  @override
  String get wifiOnlyBackupSubtitle => 'Avoid mobile data uploads';

  @override
  String get chargeWhenBackupVideo => 'Backup videos while charging';

  @override
  String get chargeWhenBackupVideoSubtitle =>
      'Reduce battery impact for background sync';

  @override
  String get lastSync => 'Last sync';

  @override
  String get noSyncRecord => 'No sync history yet';

  @override
  String missingPermissionAccess(String permissions) {
    return 'Missing access to $permissions';
  }

  @override
  String get andJoin => ' and ';

  @override
  String get photoBackupReady => 'Photo backup is ready';

  @override
  String get needAuthToBackup => 'Authorization required for backup';

  @override
  String get photosVideosSyncToUnraid =>
      'Photos and videos will sync to Unraid';

  @override
  String get grantPhotosVideosToEnable =>
      'Grant photo and video access to enable backup';

  @override
  String get searchPhotosVideos => 'Search photos and videos';

  @override
  String get allPhotos => 'All photos';

  @override
  String get backupEnabledSample => 'On / today 09:42';

  @override
  String photoCount(int count) {
    return '$count photos';
  }

  @override
  String get apiUnraidServiceMissing =>
      'unraid-api service not found. Enable the Unraid Connect/API plugin.';

  @override
  String get apiShareActionUnsupported =>
      'This action is not supported for shares';

  @override
  String get apiConnectionTimeout => 'Connection timed out';

  @override
  String apiCannotConnect(String error) {
    return 'Cannot connect to server: $error';
  }

  @override
  String apiHttpError(int statusCode) {
    return 'Server returned HTTP $statusCode';
  }

  @override
  String get apiInvalidData => 'Server returned invalid data';

  @override
  String get apiGraphqlFailed => 'GraphQL request failed';

  @override
  String get apiMissingDataField => 'Response is missing the data field';

  @override
  String get apiActionListDirectory => 'list directory';

  @override
  String get apiActionScanMedia => 'scan media files';

  @override
  String get apiActionReadFile => 'read file';

  @override
  String get apiActionReadThumbnail => 'read thumbnail';

  @override
  String apiFileBrowserInvalidJson(String action) {
    return 'File Browser returned invalid JSON: $action';
  }

  @override
  String apiFileBrowserTimeout(String action) {
    return 'File Browser $action timed out';
  }

  @override
  String apiFileBrowserCannotConnect(String error) {
    return 'Cannot connect to File Browser: $error';
  }

  @override
  String apiFileBrowserForbidden(int statusCode) {
    return 'File Browser denied access. Check anonymous access or reverse-proxy auth (HTTP $statusCode)';
  }

  @override
  String get apiFileBrowserNotFound => 'File Browser path not found (HTTP 404)';

  @override
  String apiFileBrowserFailed(String action, int statusCode) {
    return 'File Browser $action failed: HTTP $statusCode';
  }

  @override
  String get unbound => 'Unbound';

  @override
  String get installedPlugins => 'Installed plugins';

  @override
  String countUnit(int count) {
    return '$count';
  }

  @override
  String get apiKeyRolesDescription =>
      'Roles and permissions from apiKeyPossibleRoles';

  @override
  String get enabled => 'Enabled';

  @override
  String get disabled => 'Disabled';

  @override
  String oidcProviderCount(int count) {
    return '$count OIDC providers';
  }

  @override
  String get unraidCloudStatus => 'Unraid Cloud status';

  @override
  String dynamicRemoteAccess(String type) {
    return 'Dynamic remote access $type';
  }

  @override
  String get remoteAccess => 'Remote access';

  @override
  String get forwardUnknown => 'forward unknown';

  @override
  String portLabel(String port) {
    return 'port $port';
  }

  @override
  String get unnamedContainer => 'Unnamed container';

  @override
  String get dockerContainer => 'Docker container';

  @override
  String get autoStart => 'Auto-start';

  @override
  String get updateAvailable => 'Update available';

  @override
  String get image => 'Image';

  @override
  String get ports => 'Ports';

  @override
  String get online => 'Online';

  @override
  String get offline => 'Offline';

  @override
  String get unnamedVm => 'Unnamed VM';

  @override
  String get virtualMachine => 'Virtual machine';

  @override
  String get running => 'Running';

  @override
  String get vncAvailable => 'VNC available';

  @override
  String get vmDomainId => 'VM domain ID';

  @override
  String get fromVmDomainState => 'From vms.domain.state';

  @override
  String get unnamedShare => 'Unnamed share';

  @override
  String get cache => 'Cache';

  @override
  String get shareDirectory => 'Share directory';

  @override
  String get capacity => 'Capacity';

  @override
  String freeLabel(String value) {
    return 'free $value';
  }

  @override
  String get allocationStrategy => 'Allocation';

  @override
  String get defaultValue => 'Default';

  @override
  String splitLevel(String value) {
    return 'split level $value';
  }

  @override
  String get none => 'None';

  @override
  String get shareDirectoryConfig => 'Share configuration';

  @override
  String get unknownDisk => 'Unknown disk';

  @override
  String get sleeping => 'Spun down';

  @override
  String get networkInterface => 'Network interface';

  @override
  String get noAddress => 'No address';

  @override
  String get accessAddress => 'Access URL';

  @override
  String batteryLoad(String battery, String load) {
    return 'Battery $battery% · load $load%';
  }

  @override
  String get plugin => 'Plugin';

  @override
  String get unknownVersion => 'Unknown version';

  @override
  String apiCliModules(String api, String cli) {
    return 'API $api · CLI $cli';
  }

  @override
  String get yes => 'yes';

  @override
  String get no => 'no';

  @override
  String get pluginInstallTask => 'Plugin install task';

  @override
  String get installTask => 'Install task';

  @override
  String get log => 'Log';

  @override
  String get unknownSize => 'Unknown size';

  @override
  String get localAccessAddress => 'Local access URL';

  @override
  String get remoteAccessAddress => 'Remote access URL';

  @override
  String get notification => 'Notification';

  @override
  String get unnamed => 'Unnamed';

  @override
  String get directory => 'Folder';

  @override
  String get unknownCpu => 'Unknown CPU';

  @override
  String coresCount(String count) {
    return '$count cores';
  }

  @override
  String threadsCount(String count) {
    return '$count threads';
  }

  @override
  String get unknownMotherboard => 'Unknown motherboard';

  @override
  String get unknownSystem => 'Unknown system';

  @override
  String get noPackageVersions => 'No package versions returned';

  @override
  String get noServicesReturned => 'No services returned';

  @override
  String servicesOnlineSummary(int online, int total, String names) {
    return '$online/$total online · $names';
  }

  @override
  String get noNetworksReturned => 'No networks returned';

  @override
  String networksCount(int count) {
    return '$count networks';
  }

  @override
  String get noPortConflictInfo => 'No port conflict info returned';

  @override
  String get noPortConflicts => 'No port conflicts found';

  @override
  String portConflictCount(int count) {
    return '$count port conflicts';
  }

  @override
  String get container => 'container';

  @override
  String get noPortMappings => 'No port mappings returned';

  @override
  String totalUsage(String value) {
    return 'Total $value';
  }

  @override
  String usedUsage(String value) {
    return 'Used $value';
  }

  @override
  String usedTotalUsage(String used, String total) {
    return 'Used $used / $total';
  }

  @override
  String get started => 'Started';

  @override
  String get stopped => 'Stopped';

  @override
  String get paused => 'Paused';

  @override
  String get idle => 'Idle';

  @override
  String get shutDown => 'Shut down';

  @override
  String get crashed => 'Crashed';

  @override
  String daysCount(int count) {
    return '$count days';
  }

  @override
  String hoursCount(int count) {
    return '$count hours';
  }

  @override
  String minutesCount(int count) {
    return '$count minutes';
  }

  @override
  String get themeSystem => 'System';

  @override
  String get themeLight => 'Light';

  @override
  String get themeDark => 'Dark';

  @override
  String get noMusicFound => 'No music files found';

  @override
  String get musicLibraryEmpty =>
      'No audio files under the music share. Default path: /mnt/user/music';

  @override
  String musicTrackCount(int count) {
    return '$count tracks';
  }

  @override
  String get musicLoadingTrack => 'Loading…';

  @override
  String musicPlaybackError(String error) {
    return 'Playback failed: $error';
  }

  @override
  String get musicQueueStart => 'Already at the first track';

  @override
  String get musicQueueEnd => 'Already at the last track';

  @override
  String get searchMusic => 'Search tracks';

  @override
  String get rename => 'Rename';

  @override
  String get delete => 'Delete';

  @override
  String get deleteConfirmTitle => 'Delete this item?';

  @override
  String deleteConfirmMessage(String name) {
    return 'This permanently deletes $name.';
  }

  @override
  String get renameTitle => 'Rename';

  @override
  String get renameHint => 'New name';

  @override
  String get renameEmptyError => 'Name cannot be empty';

  @override
  String fileDeleted(String name) {
    return 'Deleted $name';
  }

  @override
  String fileRenamed(String name) {
    return 'Renamed to $name';
  }

  @override
  String get moreActions => 'More actions';

  @override
  String get openFolder => 'Open';

  @override
  String get apiActionDelete => 'delete';

  @override
  String get apiActionRename => 'rename';

  @override
  String get apiActionUpload => 'upload';
}
