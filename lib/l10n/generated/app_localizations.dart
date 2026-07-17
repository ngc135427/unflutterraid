import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_zh.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'generated/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('zh')
  ];

  /// No description provided for @appTitle.
  ///
  /// In zh, this message translates to:
  /// **'Unflutterraid'**
  String get appTitle;

  /// No description provided for @languageSystem.
  ///
  /// In zh, this message translates to:
  /// **'跟随系统'**
  String get languageSystem;

  /// No description provided for @languageChinese.
  ///
  /// In zh, this message translates to:
  /// **'简体中文'**
  String get languageChinese;

  /// No description provided for @languageEnglish.
  ///
  /// In zh, this message translates to:
  /// **'English'**
  String get languageEnglish;

  /// No description provided for @languageSettingTitle.
  ///
  /// In zh, this message translates to:
  /// **'语言'**
  String get languageSettingTitle;

  /// No description provided for @languageSettingSubtitle.
  ///
  /// In zh, this message translates to:
  /// **'界面文案显示语言'**
  String get languageSettingSubtitle;

  /// No description provided for @loginServerAddress.
  ///
  /// In zh, this message translates to:
  /// **'服务器地址'**
  String get loginServerAddress;

  /// No description provided for @loginServerAddressHint.
  ///
  /// In zh, this message translates to:
  /// **'请输入 IP 地址或域名'**
  String get loginServerAddressHint;

  /// No description provided for @loginServerAddressError.
  ///
  /// In zh, this message translates to:
  /// **'请输入有效的 IP 地址或域名'**
  String get loginServerAddressError;

  /// No description provided for @loginApiKey.
  ///
  /// In zh, this message translates to:
  /// **'API 密钥'**
  String get loginApiKey;

  /// No description provided for @loginApiKeyHint.
  ///
  /// In zh, this message translates to:
  /// **'请输入 API 密钥'**
  String get loginApiKeyHint;

  /// No description provided for @loginApiKeyError.
  ///
  /// In zh, this message translates to:
  /// **'请输入有效的 API 密钥'**
  String get loginApiKeyError;

  /// No description provided for @loginRememberMe.
  ///
  /// In zh, this message translates to:
  /// **'记住我'**
  String get loginRememberMe;

  /// No description provided for @loginSuccess.
  ///
  /// In zh, this message translates to:
  /// **'登录成功'**
  String get loginSuccess;

  /// No description provided for @loginConnecting.
  ///
  /// In zh, this message translates to:
  /// **'正在连接'**
  String get loginConnecting;

  /// No description provided for @loginButton.
  ///
  /// In zh, this message translates to:
  /// **'登录'**
  String get loginButton;

  /// No description provided for @loginFailed.
  ///
  /// In zh, this message translates to:
  /// **'登录失败：{error}'**
  String loginFailed(String error);

  /// No description provided for @showApiKey.
  ///
  /// In zh, this message translates to:
  /// **'显示 API 密钥'**
  String get showApiKey;

  /// No description provided for @hideApiKey.
  ///
  /// In zh, this message translates to:
  /// **'隐藏 API 密钥'**
  String get hideApiKey;

  /// No description provided for @settingsTitle.
  ///
  /// In zh, this message translates to:
  /// **'设置'**
  String get settingsTitle;

  /// No description provided for @settingsSubtitle.
  ///
  /// In zh, this message translates to:
  /// **'应用偏好'**
  String get settingsSubtitle;

  /// No description provided for @settingsIntroEyebrow.
  ///
  /// In zh, this message translates to:
  /// **'App Settings'**
  String get settingsIntroEyebrow;

  /// No description provided for @settingsIntroTitle.
  ///
  /// In zh, this message translates to:
  /// **'简洁的应用设置'**
  String get settingsIntroTitle;

  /// No description provided for @settingsIntroDescription.
  ///
  /// In zh, this message translates to:
  /// **'语言与主题是紧凑的偏好项，后续可继续加入通知、显示密度等。'**
  String get settingsIntroDescription;

  /// No description provided for @settingsGeneralSection.
  ///
  /// In zh, this message translates to:
  /// **'通用'**
  String get settingsGeneralSection;

  /// No description provided for @settingsGeneralTrailing.
  ///
  /// In zh, this message translates to:
  /// **'基础偏好'**
  String get settingsGeneralTrailing;

  /// No description provided for @settingsThemeTitle.
  ///
  /// In zh, this message translates to:
  /// **'主题'**
  String get settingsThemeTitle;

  /// No description provided for @settingsThemeSubtitle.
  ///
  /// In zh, this message translates to:
  /// **'浅色、深色或跟随系统'**
  String get settingsThemeSubtitle;

  /// No description provided for @settingsComingSoon.
  ///
  /// In zh, this message translates to:
  /// **'即将支持'**
  String get settingsComingSoon;

  /// No description provided for @settingsThemeToast.
  ///
  /// In zh, this message translates to:
  /// **'主题：{theme}'**
  String settingsThemeToast(String theme);

  /// No description provided for @settingsNotificationsTitle.
  ///
  /// In zh, this message translates to:
  /// **'通知'**
  String get settingsNotificationsTitle;

  /// No description provided for @settingsNotificationsSubtitle.
  ///
  /// In zh, this message translates to:
  /// **'主页通知中心展示 Unraid 未读/告警（只读）'**
  String get settingsNotificationsSubtitle;

  /// No description provided for @settingsNotificationsToast.
  ///
  /// In zh, this message translates to:
  /// **'推送偏好尚未接入；请在主页通知模块查看列表'**
  String get settingsNotificationsToast;

  /// No description provided for @settingsAutoRefreshTitle.
  ///
  /// In zh, this message translates to:
  /// **'自动刷新'**
  String get settingsAutoRefreshTitle;

  /// No description provided for @settingsAutoRefreshSubtitle.
  ///
  /// In zh, this message translates to:
  /// **'仪表盘定时拉取服务器状态'**
  String get settingsAutoRefreshSubtitle;

  /// No description provided for @settingsAutoRefreshInterval.
  ///
  /// In zh, this message translates to:
  /// **'间隔 {seconds} 秒'**
  String settingsAutoRefreshInterval(int seconds);

  /// No description provided for @settingsAutoRefreshEnabled.
  ///
  /// In zh, this message translates to:
  /// **'已开启'**
  String get settingsAutoRefreshEnabled;

  /// No description provided for @settingsAutoRefreshDisabled.
  ///
  /// In zh, this message translates to:
  /// **'已关闭'**
  String get settingsAutoRefreshDisabled;

  /// No description provided for @refreshFailed.
  ///
  /// In zh, this message translates to:
  /// **'刷新失败：{error}'**
  String refreshFailed(String error);

  /// No description provided for @actionSucceededRefreshing.
  ///
  /// In zh, this message translates to:
  /// **'{name} 已{action}，正在刷新…'**
  String actionSucceededRefreshing(String name, String action);

  /// No description provided for @createFolder.
  ///
  /// In zh, this message translates to:
  /// **'新建文件夹'**
  String get createFolder;

  /// No description provided for @createFolderTitle.
  ///
  /// In zh, this message translates to:
  /// **'新建文件夹'**
  String get createFolderTitle;

  /// No description provided for @createFolderHint.
  ///
  /// In zh, this message translates to:
  /// **'文件夹名称'**
  String get createFolderHint;

  /// No description provided for @createFolderEmptyError.
  ///
  /// In zh, this message translates to:
  /// **'名称不能为空'**
  String get createFolderEmptyError;

  /// No description provided for @createFolderInvalidError.
  ///
  /// In zh, this message translates to:
  /// **'名称不能包含 / 或 \\'**
  String get createFolderInvalidError;

  /// No description provided for @folderCreated.
  ///
  /// In zh, this message translates to:
  /// **'已创建 {name}'**
  String folderCreated(String name);

  /// No description provided for @uploadFiles.
  ///
  /// In zh, this message translates to:
  /// **'上传文件'**
  String get uploadFiles;

  /// No description provided for @uploadInProgress.
  ///
  /// In zh, this message translates to:
  /// **'正在上传…'**
  String get uploadInProgress;

  /// No description provided for @uploadResultSummary.
  ///
  /// In zh, this message translates to:
  /// **'上传完成：成功 {success}，失败 {failed}'**
  String uploadResultSummary(int success, int failed);

  /// No description provided for @uploadCancelled.
  ///
  /// In zh, this message translates to:
  /// **'已取消上传'**
  String get uploadCancelled;

  /// No description provided for @albumViewerPage.
  ///
  /// In zh, this message translates to:
  /// **'{current} / {total}'**
  String albumViewerPage(int current, int total);

  /// No description provided for @backupResultTitle.
  ///
  /// In zh, this message translates to:
  /// **'备份结果'**
  String get backupResultTitle;

  /// No description provided for @backupResultSuccessSection.
  ///
  /// In zh, this message translates to:
  /// **'成功 ({count})'**
  String backupResultSuccessSection(int count);

  /// No description provided for @backupResultSkippedSection.
  ///
  /// In zh, this message translates to:
  /// **'跳过 ({count})'**
  String backupResultSkippedSection(int count);

  /// No description provided for @backupResultFailedSection.
  ///
  /// In zh, this message translates to:
  /// **'失败 ({count})'**
  String backupResultFailedSection(int count);

  /// No description provided for @backupResultEmptySection.
  ///
  /// In zh, this message translates to:
  /// **'无'**
  String get backupResultEmptySection;

  /// No description provided for @backupResultCancelledNote.
  ///
  /// In zh, this message translates to:
  /// **'任务已取消，以下为已处理结果。'**
  String get backupResultCancelledNote;

  /// No description provided for @settingsConnectionSection.
  ///
  /// In zh, this message translates to:
  /// **'连接'**
  String get settingsConnectionSection;

  /// No description provided for @settingsConnectionTrailing.
  ///
  /// In zh, this message translates to:
  /// **'登录相关'**
  String get settingsConnectionTrailing;

  /// No description provided for @settingsServerConfigTitle.
  ///
  /// In zh, this message translates to:
  /// **'服务器配置'**
  String get settingsServerConfigTitle;

  /// No description provided for @settingsServerConfigSubtitle.
  ///
  /// In zh, this message translates to:
  /// **'地址、协议与 API Key'**
  String get settingsServerConfigSubtitle;

  /// No description provided for @settingsPlanned.
  ///
  /// In zh, this message translates to:
  /// **'规划中'**
  String get settingsPlanned;

  /// No description provided for @settingsServerConfigToast.
  ///
  /// In zh, this message translates to:
  /// **'服务器配置将在后续版本集中管理'**
  String get settingsServerConfigToast;

  /// No description provided for @settingsNotConnected.
  ///
  /// In zh, this message translates to:
  /// **'未连接'**
  String get settingsNotConnected;

  /// No description provided for @settingsConnected.
  ///
  /// In zh, this message translates to:
  /// **'已连接'**
  String get settingsConnected;

  /// No description provided for @serverConfigTitle.
  ///
  /// In zh, this message translates to:
  /// **'服务器连接'**
  String get serverConfigTitle;

  /// No description provided for @serverConfigSaveReconnect.
  ///
  /// In zh, this message translates to:
  /// **'保存并重连'**
  String get serverConfigSaveReconnect;

  /// No description provided for @serverConfigDisconnect.
  ///
  /// In zh, this message translates to:
  /// **'断开连接'**
  String get serverConfigDisconnect;

  /// No description provided for @serverConfigClearSaved.
  ///
  /// In zh, this message translates to:
  /// **'清除已保存凭据'**
  String get serverConfigClearSaved;

  /// No description provided for @serverConfigReconnecting.
  ///
  /// In zh, this message translates to:
  /// **'正在验证连接…'**
  String get serverConfigReconnecting;

  /// No description provided for @serverConfigReconnectSuccess.
  ///
  /// In zh, this message translates to:
  /// **'已使用新连接'**
  String get serverConfigReconnectSuccess;

  /// No description provided for @serverConfigDisconnected.
  ///
  /// In zh, this message translates to:
  /// **'已断开连接'**
  String get serverConfigDisconnected;

  /// No description provided for @serverConfigCleared.
  ///
  /// In zh, this message translates to:
  /// **'已清除保存的登录信息'**
  String get serverConfigCleared;

  /// No description provided for @serverConfigNoSessionHint.
  ///
  /// In zh, this message translates to:
  /// **'当前未连接。可编辑已保存凭据并连接，或先从登录页进入。'**
  String get serverConfigNoSessionHint;

  /// No description provided for @settingsLanguageToast.
  ///
  /// In zh, this message translates to:
  /// **'语言：{language}'**
  String settingsLanguageToast(String language);

  /// No description provided for @navHome.
  ///
  /// In zh, this message translates to:
  /// **'主页'**
  String get navHome;

  /// No description provided for @navDocker.
  ///
  /// In zh, this message translates to:
  /// **'Docker'**
  String get navDocker;

  /// No description provided for @navVm.
  ///
  /// In zh, this message translates to:
  /// **'虚拟机'**
  String get navVm;

  /// No description provided for @navShare.
  ///
  /// In zh, this message translates to:
  /// **'共享'**
  String get navShare;

  /// No description provided for @settingsOpenTooltip.
  ///
  /// In zh, this message translates to:
  /// **'打开设置'**
  String get settingsOpenTooltip;

  /// No description provided for @notificationsTooltip.
  ///
  /// In zh, this message translates to:
  /// **'通知'**
  String get notificationsTooltip;

  /// No description provided for @back.
  ///
  /// In zh, this message translates to:
  /// **'返回'**
  String get back;

  /// No description provided for @retry.
  ///
  /// In zh, this message translates to:
  /// **'重试'**
  String get retry;

  /// No description provided for @cancel.
  ///
  /// In zh, this message translates to:
  /// **'取消'**
  String get cancel;

  /// No description provided for @confirm.
  ///
  /// In zh, this message translates to:
  /// **'确认'**
  String get confirm;

  /// No description provided for @close.
  ///
  /// In zh, this message translates to:
  /// **'关闭'**
  String get close;

  /// No description provided for @refresh.
  ///
  /// In zh, this message translates to:
  /// **'刷新'**
  String get refresh;

  /// No description provided for @unknown.
  ///
  /// In zh, this message translates to:
  /// **'未知'**
  String get unknown;

  /// No description provided for @edit.
  ///
  /// In zh, this message translates to:
  /// **'编辑'**
  String get edit;

  /// No description provided for @all.
  ///
  /// In zh, this message translates to:
  /// **'全部'**
  String get all;

  /// No description provided for @details.
  ///
  /// In zh, this message translates to:
  /// **'详情'**
  String get details;

  /// No description provided for @browse.
  ///
  /// In zh, this message translates to:
  /// **'浏览'**
  String get browse;

  /// No description provided for @settings.
  ///
  /// In zh, this message translates to:
  /// **'设置'**
  String get settings;

  /// No description provided for @start.
  ///
  /// In zh, this message translates to:
  /// **'启动'**
  String get start;

  /// No description provided for @stop.
  ///
  /// In zh, this message translates to:
  /// **'停止'**
  String get stop;

  /// No description provided for @restart.
  ///
  /// In zh, this message translates to:
  /// **'重启'**
  String get restart;

  /// No description provided for @status.
  ///
  /// In zh, this message translates to:
  /// **'状态'**
  String get status;

  /// No description provided for @description.
  ///
  /// In zh, this message translates to:
  /// **'说明'**
  String get description;

  /// No description provided for @location.
  ///
  /// In zh, this message translates to:
  /// **'位置'**
  String get location;

  /// No description provided for @overview.
  ///
  /// In zh, this message translates to:
  /// **'概览'**
  String get overview;

  /// No description provided for @memory.
  ///
  /// In zh, this message translates to:
  /// **'内存'**
  String get memory;

  /// No description provided for @array.
  ///
  /// In zh, this message translates to:
  /// **'阵列'**
  String get array;

  /// No description provided for @notifications.
  ///
  /// In zh, this message translates to:
  /// **'通知'**
  String get notifications;

  /// No description provided for @motherboard.
  ///
  /// In zh, this message translates to:
  /// **'主板'**
  String get motherboard;

  /// No description provided for @disk.
  ///
  /// In zh, this message translates to:
  /// **'磁盘'**
  String get disk;

  /// No description provided for @network.
  ///
  /// In zh, this message translates to:
  /// **'网络'**
  String get network;

  /// No description provided for @plugins.
  ///
  /// In zh, this message translates to:
  /// **'插件'**
  String get plugins;

  /// No description provided for @permissions.
  ///
  /// In zh, this message translates to:
  /// **'权限'**
  String get permissions;

  /// No description provided for @connection.
  ///
  /// In zh, this message translates to:
  /// **'连接'**
  String get connection;

  /// No description provided for @logs.
  ///
  /// In zh, this message translates to:
  /// **'日志'**
  String get logs;

  /// No description provided for @album.
  ///
  /// In zh, this message translates to:
  /// **'相册'**
  String get album;

  /// No description provided for @music.
  ///
  /// In zh, this message translates to:
  /// **'音乐'**
  String get music;

  /// No description provided for @photos.
  ///
  /// In zh, this message translates to:
  /// **'照片'**
  String get photos;

  /// No description provided for @videos.
  ///
  /// In zh, this message translates to:
  /// **'视频'**
  String get videos;

  /// No description provided for @file.
  ///
  /// In zh, this message translates to:
  /// **'文件'**
  String get file;

  /// No description provided for @project.
  ///
  /// In zh, this message translates to:
  /// **'项目'**
  String get project;

  /// No description provided for @connectServerFirst.
  ///
  /// In zh, this message translates to:
  /// **'请先连接服务器'**
  String get connectServerFirst;

  /// No description provided for @missingConnection.
  ///
  /// In zh, this message translates to:
  /// **'缺少服务器连接'**
  String get missingConnection;

  /// No description provided for @missingConnectionOrId.
  ///
  /// In zh, this message translates to:
  /// **'缺少服务器连接或项目 ID'**
  String get missingConnectionOrId;

  /// No description provided for @missingConnectionArgs.
  ///
  /// In zh, this message translates to:
  /// **'缺少连接参数'**
  String get missingConnectionArgs;

  /// No description provided for @loadFailed.
  ///
  /// In zh, this message translates to:
  /// **'加载失败：{error}'**
  String loadFailed(String error);

  /// No description provided for @notReturned.
  ///
  /// In zh, this message translates to:
  /// **'未返回'**
  String get notReturned;

  /// No description provided for @notConnectedTitle.
  ///
  /// In zh, this message translates to:
  /// **'未连接服务器'**
  String get notConnectedTitle;

  /// No description provided for @notConnectedMessage.
  ///
  /// In zh, this message translates to:
  /// **'请返回登录页重新连接。'**
  String get notConnectedMessage;

  /// No description provided for @loadingServerTitle.
  ///
  /// In zh, this message translates to:
  /// **'正在读取服务器'**
  String get loadingServerTitle;

  /// No description provided for @loadingServerMessage.
  ///
  /// In zh, this message translates to:
  /// **'正在请求 Unraid GraphQL API...'**
  String get loadingServerMessage;

  /// No description provided for @readFailedTitle.
  ///
  /// In zh, this message translates to:
  /// **'读取失败'**
  String get readFailedTitle;

  /// No description provided for @noDataTitle.
  ///
  /// In zh, this message translates to:
  /// **'暂无数据'**
  String get noDataTitle;

  /// No description provided for @noDataMessage.
  ///
  /// In zh, this message translates to:
  /// **'服务器没有返回可显示的数据。'**
  String get noDataMessage;

  /// No description provided for @viewFullInfo.
  ///
  /// In zh, this message translates to:
  /// **'查看完整信息'**
  String get viewFullInfo;

  /// No description provided for @liveMetrics.
  ///
  /// In zh, this message translates to:
  /// **'实时指标'**
  String get liveMetrics;

  /// No description provided for @arrayAndServices.
  ///
  /// In zh, this message translates to:
  /// **'阵列与服务'**
  String get arrayAndServices;

  /// No description provided for @arrayState.
  ///
  /// In zh, this message translates to:
  /// **'阵列状态'**
  String get arrayState;

  /// No description provided for @arrayCapacity.
  ///
  /// In zh, this message translates to:
  /// **'阵列容量'**
  String get arrayCapacity;

  /// No description provided for @noParityTask.
  ///
  /// In zh, this message translates to:
  /// **'暂无校验任务'**
  String get noParityTask;

  /// No description provided for @servicesOnline.
  ///
  /// In zh, this message translates to:
  /// **'服务在线'**
  String get servicesOnline;

  /// No description provided for @recentNotifications.
  ///
  /// In zh, this message translates to:
  /// **'最近通知'**
  String get recentNotifications;

  /// No description provided for @extendedManagement.
  ///
  /// In zh, this message translates to:
  /// **'扩展管理'**
  String get extendedManagement;

  /// No description provided for @interfaceModules.
  ///
  /// In zh, this message translates to:
  /// **'接口模块'**
  String get interfaceModules;

  /// No description provided for @notificationCount.
  ///
  /// In zh, this message translates to:
  /// **'{count} 条提醒'**
  String notificationCount(int count);

  /// No description provided for @warningAlertCount.
  ///
  /// In zh, this message translates to:
  /// **'{warning} 警告 · {alert} 严重'**
  String warningAlertCount(int warning, int alert);

  /// No description provided for @cpuUsage.
  ///
  /// In zh, this message translates to:
  /// **'CPU 使用'**
  String get cpuUsage;

  /// No description provided for @noWarningAlerts.
  ///
  /// In zh, this message translates to:
  /// **'暂无警告或严重通知'**
  String get noWarningAlerts;

  /// No description provided for @noNotificationDetailsTitle.
  ///
  /// In zh, this message translates to:
  /// **'暂无通知详情'**
  String get noNotificationDetailsTitle;

  /// No description provided for @noNotificationDetailsMessage.
  ///
  /// In zh, this message translates to:
  /// **'服务器仅返回了通知数量，未返回警告或严重通知列表。'**
  String get noNotificationDetailsMessage;

  /// No description provided for @moduleNoDataMessage.
  ///
  /// In zh, this message translates to:
  /// **'服务器没有返回{module}相关信息。'**
  String moduleNoDataMessage(String module);

  /// No description provided for @notificationCenter.
  ///
  /// In zh, this message translates to:
  /// **'通知中心'**
  String get notificationCenter;

  /// No description provided for @moduleDisksSubtitle.
  ///
  /// In zh, this message translates to:
  /// **'SMART / 分区 / 温度'**
  String get moduleDisksSubtitle;

  /// No description provided for @moduleNetworkSubtitle.
  ///
  /// In zh, this message translates to:
  /// **'接口 / 访问地址'**
  String get moduleNetworkSubtitle;

  /// No description provided for @moduleUpsSubtitle.
  ///
  /// In zh, this message translates to:
  /// **'电量 / 负载 / 策略'**
  String get moduleUpsSubtitle;

  /// No description provided for @modulePluginsSubtitle.
  ///
  /// In zh, this message translates to:
  /// **'安装任务 / 模块'**
  String get modulePluginsSubtitle;

  /// No description provided for @moduleCloudSubtitle.
  ///
  /// In zh, this message translates to:
  /// **'远程访问 / Cloud'**
  String get moduleCloudSubtitle;

  /// No description provided for @searchTypeItems.
  ///
  /// In zh, this message translates to:
  /// **'搜索{type}项目'**
  String searchTypeItems(String type);

  /// No description provided for @typeRefreshSubmitted.
  ///
  /// In zh, this message translates to:
  /// **'{type}刷新已提交'**
  String typeRefreshSubmitted(String type);

  /// No description provided for @typeEmptyTitle.
  ///
  /// In zh, this message translates to:
  /// **'{type}为空'**
  String typeEmptyTitle(String type);

  /// No description provided for @typeEmptyMessage.
  ///
  /// In zh, this message translates to:
  /// **'服务器当前没有返回{type}项目。'**
  String typeEmptyMessage(String type);

  /// No description provided for @noMatchesTitle.
  ///
  /// In zh, this message translates to:
  /// **'没有匹配项'**
  String get noMatchesTitle;

  /// No description provided for @noMatchesMessage.
  ///
  /// In zh, this message translates to:
  /// **'换一个关键词试试。'**
  String get noMatchesMessage;

  /// No description provided for @actionSubmitted.
  ///
  /// In zh, this message translates to:
  /// **'{title} {action}操作已提交'**
  String actionSubmitted(String title, String action);

  /// No description provided for @runningAndStopped.
  ///
  /// In zh, this message translates to:
  /// **'{running} 运行中 · {stopped} 未运行'**
  String runningAndStopped(int running, int stopped);

  /// No description provided for @arrayUsageLabel.
  ///
  /// In zh, this message translates to:
  /// **'阵列 {usage}'**
  String arrayUsageLabel(String usage);

  /// No description provided for @runningCount.
  ///
  /// In zh, this message translates to:
  /// **'{count} 运行中'**
  String runningCount(int count);

  /// No description provided for @unknownProject.
  ///
  /// In zh, this message translates to:
  /// **'未知项目'**
  String get unknownProject;

  /// No description provided for @noInfo.
  ///
  /// In zh, this message translates to:
  /// **'暂无信息'**
  String get noInfo;

  /// No description provided for @readingDirectoryTitle.
  ///
  /// In zh, this message translates to:
  /// **'正在读取目录'**
  String get readingDirectoryTitle;

  /// No description provided for @readingDirectoryMessage.
  ///
  /// In zh, this message translates to:
  /// **'正在通过 GraphQL 读取共享根目录...'**
  String get readingDirectoryMessage;

  /// No description provided for @noShareDirectoryTitle.
  ///
  /// In zh, this message translates to:
  /// **'暂无共享目录'**
  String get noShareDirectoryTitle;

  /// No description provided for @noShareDirectoryMessage.
  ///
  /// In zh, this message translates to:
  /// **'GraphQL 没有返回共享根目录数据。'**
  String get noShareDirectoryMessage;

  /// No description provided for @parentDirectory.
  ///
  /// In zh, this message translates to:
  /// **'上一级'**
  String get parentDirectory;

  /// No description provided for @shareRootSize.
  ///
  /// In zh, this message translates to:
  /// **'共享根目录 · {size}'**
  String shareRootSize(String size);

  /// No description provided for @subdirBrowseFuture.
  ///
  /// In zh, this message translates to:
  /// **'子目录浏览将作为 File Manager 独立功能实现'**
  String get subdirBrowseFuture;

  /// No description provided for @previewUnsupported.
  ///
  /// In zh, this message translates to:
  /// **'暂不支持预览该文件类型'**
  String get previewUnsupported;

  /// No description provided for @labelActionSubmitted.
  ///
  /// In zh, this message translates to:
  /// **'{label} 操作已提交'**
  String labelActionSubmitted(String label);

  /// No description provided for @imageLoadFailed.
  ///
  /// In zh, this message translates to:
  /// **'图片加载失败'**
  String get imageLoadFailed;

  /// No description provided for @chooseServerIcon.
  ///
  /// In zh, this message translates to:
  /// **'选择服务器图标'**
  String get chooseServerIcon;

  /// No description provided for @returnHome.
  ///
  /// In zh, this message translates to:
  /// **'返回主页'**
  String get returnHome;

  /// No description provided for @countItems.
  ///
  /// In zh, this message translates to:
  /// **'{count} 个'**
  String countItems(int count);

  /// No description provided for @countRecords.
  ///
  /// In zh, this message translates to:
  /// **'{count} 条记录'**
  String countRecords(int count);

  /// No description provided for @countFiles.
  ///
  /// In zh, this message translates to:
  /// **'{count} 个文件'**
  String countFiles(int count);

  /// No description provided for @productDetails.
  ///
  /// In zh, this message translates to:
  /// **'产品详情'**
  String get productDetails;

  /// No description provided for @basicInfo.
  ///
  /// In zh, this message translates to:
  /// **'基本信息'**
  String get basicInfo;

  /// No description provided for @detailSampleBody.
  ///
  /// In zh, this message translates to:
  /// **'这是一个详情页面示例，展示如何按照登录页面的设计风格创建移动端详情页。页面保持相同的紫蓝渐变、圆角设计和柔和动效，确保视觉一致性。'**
  String get detailSampleBody;

  /// No description provided for @featureList.
  ///
  /// In zh, this message translates to:
  /// **'功能列表'**
  String get featureList;

  /// No description provided for @featureResponsive.
  ///
  /// In zh, this message translates to:
  /// **'支持响应式设计'**
  String get featureResponsive;

  /// No description provided for @featureVisualConsistency.
  ///
  /// In zh, this message translates to:
  /// **'保持视觉一致性'**
  String get featureVisualConsistency;

  /// No description provided for @featureAnimations.
  ///
  /// In zh, this message translates to:
  /// **'优雅的动画效果'**
  String get featureAnimations;

  /// No description provided for @featureClearHierarchy.
  ///
  /// In zh, this message translates to:
  /// **'清晰的信息层次'**
  String get featureClearHierarchy;

  /// No description provided for @detailedDescription.
  ///
  /// In zh, this message translates to:
  /// **'详细说明'**
  String get detailedDescription;

  /// No description provided for @designPhilosophy.
  ///
  /// In zh, this message translates to:
  /// **'设计理念'**
  String get designPhilosophy;

  /// No description provided for @designPhilosophyText.
  ///
  /// In zh, this message translates to:
  /// **'延续登录页面的现代简约风格，以紫蓝渐变作为主视觉元素，创建统一且专业的用户体验。'**
  String get designPhilosophyText;

  /// No description provided for @interactionDesign.
  ///
  /// In zh, this message translates to:
  /// **'交互设计'**
  String get interactionDesign;

  /// No description provided for @interactionDesignText.
  ///
  /// In zh, this message translates to:
  /// **'页面元素采用顺序淡入动画，增强层次感和用户体验，按钮包含清晰的点击反馈。'**
  String get interactionDesignText;

  /// No description provided for @uiElements.
  ///
  /// In zh, this message translates to:
  /// **'UI 元素'**
  String get uiElements;

  /// No description provided for @uiElementsText.
  ///
  /// In zh, this message translates to:
  /// **'采用大圆角设计增强现代感和友好度，适当的阴影提供层次感，合理的间距确保阅读舒适。'**
  String get uiElementsText;

  /// No description provided for @confirmAction.
  ///
  /// In zh, this message translates to:
  /// **'确认操作'**
  String get confirmAction;

  /// No description provided for @actionConfirmedTitle.
  ///
  /// In zh, this message translates to:
  /// **'操作已确认'**
  String get actionConfirmedTitle;

  /// No description provided for @actionConfirmedBody.
  ///
  /// In zh, this message translates to:
  /// **'这里可以接入实际业务逻辑。'**
  String get actionConfirmedBody;

  /// No description provided for @gotIt.
  ///
  /// In zh, this message translates to:
  /// **'知道了'**
  String get gotIt;

  /// No description provided for @serverProfile.
  ///
  /// In zh, this message translates to:
  /// **'服务器资料'**
  String get serverProfile;

  /// No description provided for @authorization.
  ///
  /// In zh, this message translates to:
  /// **'授权'**
  String get authorization;

  /// No description provided for @hardwareAndSystem.
  ///
  /// In zh, this message translates to:
  /// **'硬件与系统'**
  String get hardwareAndSystem;

  /// No description provided for @model.
  ///
  /// In zh, this message translates to:
  /// **'型号'**
  String get model;

  /// No description provided for @system.
  ///
  /// In zh, this message translates to:
  /// **'系统'**
  String get system;

  /// No description provided for @packageVersion.
  ///
  /// In zh, this message translates to:
  /// **'包版本'**
  String get packageVersion;

  /// No description provided for @arrayAndStorage.
  ///
  /// In zh, this message translates to:
  /// **'阵列与存储'**
  String get arrayAndStorage;

  /// No description provided for @networkAndConnection.
  ///
  /// In zh, this message translates to:
  /// **'网络与连接'**
  String get networkAndConnection;

  /// No description provided for @localUrl.
  ///
  /// In zh, this message translates to:
  /// **'本地 URL'**
  String get localUrl;

  /// No description provided for @remoteUrl.
  ///
  /// In zh, this message translates to:
  /// **'远程 URL'**
  String get remoteUrl;

  /// No description provided for @dockerNetwork.
  ///
  /// In zh, this message translates to:
  /// **'Docker 网络'**
  String get dockerNetwork;

  /// No description provided for @portConflicts.
  ///
  /// In zh, this message translates to:
  /// **'端口冲突'**
  String get portConflicts;

  /// No description provided for @cloudPluginsPermissions.
  ///
  /// In zh, this message translates to:
  /// **'Cloud / 插件 / 权限'**
  String get cloudPluginsPermissions;

  /// No description provided for @registerUsernameLabel.
  ///
  /// In zh, this message translates to:
  /// **'用户名 / 手机号'**
  String get registerUsernameLabel;

  /// No description provided for @registerUsernameHint.
  ///
  /// In zh, this message translates to:
  /// **'请输入用户名或手机号'**
  String get registerUsernameHint;

  /// No description provided for @registerUsernameError.
  ///
  /// In zh, this message translates to:
  /// **'请输入有效的用户名或手机号'**
  String get registerUsernameError;

  /// No description provided for @registerPasswordLabel.
  ///
  /// In zh, this message translates to:
  /// **'密码'**
  String get registerPasswordLabel;

  /// No description provided for @registerPasswordHint.
  ///
  /// In zh, this message translates to:
  /// **'请输入密码（至少 6 位）'**
  String get registerPasswordHint;

  /// No description provided for @registerPasswordError.
  ///
  /// In zh, this message translates to:
  /// **'密码不能少于 6 位'**
  String get registerPasswordError;

  /// No description provided for @registerConfirmPasswordLabel.
  ///
  /// In zh, this message translates to:
  /// **'确认密码'**
  String get registerConfirmPasswordLabel;

  /// No description provided for @registerConfirmPasswordHint.
  ///
  /// In zh, this message translates to:
  /// **'请再次输入密码'**
  String get registerConfirmPasswordHint;

  /// No description provided for @registerConfirmPasswordError.
  ///
  /// In zh, this message translates to:
  /// **'两次输入的密码不一致'**
  String get registerConfirmPasswordError;

  /// No description provided for @registerSuccess.
  ///
  /// In zh, this message translates to:
  /// **'注册成功'**
  String get registerSuccess;

  /// No description provided for @registerButton.
  ///
  /// In zh, this message translates to:
  /// **'注册'**
  String get registerButton;

  /// No description provided for @alreadyHaveAccount.
  ///
  /// In zh, this message translates to:
  /// **'已有账号？'**
  String get alreadyHaveAccount;

  /// No description provided for @backToLogin.
  ///
  /// In zh, this message translates to:
  /// **'返回登录'**
  String get backToLogin;

  /// No description provided for @createAccount.
  ///
  /// In zh, this message translates to:
  /// **'创建账号'**
  String get createAccount;

  /// No description provided for @registerSubtitle.
  ///
  /// In zh, this message translates to:
  /// **'请填写以下信息完成注册'**
  String get registerSubtitle;

  /// No description provided for @musicLibrary.
  ///
  /// In zh, this message translates to:
  /// **'音乐库'**
  String get musicLibrary;

  /// No description provided for @songs.
  ///
  /// In zh, this message translates to:
  /// **'歌曲'**
  String get songs;

  /// No description provided for @allSongs.
  ///
  /// In zh, this message translates to:
  /// **'全部歌曲'**
  String get allSongs;

  /// No description provided for @collapse.
  ///
  /// In zh, this message translates to:
  /// **'收起'**
  String get collapse;

  /// No description provided for @albums.
  ///
  /// In zh, this message translates to:
  /// **'专辑'**
  String get albums;

  /// No description provided for @lossless.
  ///
  /// In zh, this message translates to:
  /// **'无损'**
  String get lossless;

  /// No description provided for @searchSongsAlbums.
  ///
  /// In zh, this message translates to:
  /// **'搜索歌曲、专辑'**
  String get searchSongsAlbums;

  /// No description provided for @nowPlaying.
  ///
  /// In zh, this message translates to:
  /// **'正在播放'**
  String get nowPlaying;

  /// No description provided for @today.
  ///
  /// In zh, this message translates to:
  /// **'今天'**
  String get today;

  /// No description provided for @yesterday.
  ///
  /// In zh, this message translates to:
  /// **'昨天'**
  String get yesterday;

  /// No description provided for @unknownDate.
  ///
  /// In zh, this message translates to:
  /// **'未知日期'**
  String get unknownDate;

  /// No description provided for @yearMonth.
  ///
  /// In zh, this message translates to:
  /// **'{year}年{month}月'**
  String yearMonth(int year, int month);

  /// No description provided for @noPhotosFound.
  ///
  /// In zh, this message translates to:
  /// **'没有找到照片'**
  String get noPhotosFound;

  /// No description provided for @noAlbumDirsFound.
  ///
  /// In zh, this message translates to:
  /// **'没有找到相册目录'**
  String get noAlbumDirsFound;

  /// No description provided for @noVideosFound.
  ///
  /// In zh, this message translates to:
  /// **'没有找到视频'**
  String get noVideosFound;

  /// No description provided for @mediaPermissionRequiredBackup.
  ///
  /// In zh, this message translates to:
  /// **'需要照片访问权限才能进行备份'**
  String get mediaPermissionRequiredBackup;

  /// No description provided for @selectBackupDirectory.
  ///
  /// In zh, this message translates to:
  /// **'选择备份目录'**
  String get selectBackupDirectory;

  /// No description provided for @selectThisDirectory.
  ///
  /// In zh, this message translates to:
  /// **'选择此目录'**
  String get selectThisDirectory;

  /// No description provided for @goUp.
  ///
  /// In zh, this message translates to:
  /// **'返回上级'**
  String get goUp;

  /// No description provided for @noSubfolders.
  ///
  /// In zh, this message translates to:
  /// **'此目录下没有子文件夹'**
  String get noSubfolders;

  /// No description provided for @photoBackup.
  ///
  /// In zh, this message translates to:
  /// **'照片备份'**
  String get photoBackup;

  /// No description provided for @permissionChecking.
  ///
  /// In zh, this message translates to:
  /// **'权限检查中...'**
  String get permissionChecking;

  /// No description provided for @permissionCheckingSubtitle.
  ///
  /// In zh, this message translates to:
  /// **'正在检查照片访问权限'**
  String get permissionCheckingSubtitle;

  /// No description provided for @needMediaPermission.
  ///
  /// In zh, this message translates to:
  /// **'需要照片权限'**
  String get needMediaPermission;

  /// No description provided for @grantPermission.
  ///
  /// In zh, this message translates to:
  /// **'授予权限'**
  String get grantPermission;

  /// No description provided for @mediaPermission.
  ///
  /// In zh, this message translates to:
  /// **'照片权限'**
  String get mediaPermission;

  /// No description provided for @mediaPermissionGranted.
  ///
  /// In zh, this message translates to:
  /// **'照片访问权限已授予'**
  String get mediaPermissionGranted;

  /// No description provided for @autoBackup.
  ///
  /// In zh, this message translates to:
  /// **'自动备份（偏好）'**
  String get autoBackup;

  /// No description provided for @autoBackupSubtitle.
  ///
  /// In zh, this message translates to:
  /// **'仅记住偏好，不会在后台自动运行；请点「立即备份」'**
  String get autoBackupSubtitle;

  /// No description provided for @grantMediaFirst.
  ///
  /// In zh, this message translates to:
  /// **'请先授予照片权限'**
  String get grantMediaFirst;

  /// No description provided for @targetDirectory.
  ///
  /// In zh, this message translates to:
  /// **'目标目录'**
  String get targetDirectory;

  /// No description provided for @wifiOnlyBackup.
  ///
  /// In zh, this message translates to:
  /// **'仅 Wi-Fi 备份'**
  String get wifiOnlyBackup;

  /// No description provided for @wifiOnlyBackupSubtitle.
  ///
  /// In zh, this message translates to:
  /// **'避免使用移动网络上传'**
  String get wifiOnlyBackupSubtitle;

  /// No description provided for @chargeWhenBackupVideo.
  ///
  /// In zh, this message translates to:
  /// **'充电时备份视频'**
  String get chargeWhenBackupVideo;

  /// No description provided for @chargeWhenBackupVideoSubtitle.
  ///
  /// In zh, this message translates to:
  /// **'视频备份将在后续版本支持'**
  String get chargeWhenBackupVideoSubtitle;

  /// No description provided for @lastSync.
  ///
  /// In zh, this message translates to:
  /// **'上次同步'**
  String get lastSync;

  /// No description provided for @noSyncRecord.
  ///
  /// In zh, this message translates to:
  /// **'暂无同步记录'**
  String get noSyncRecord;

  /// No description provided for @missingPermissionAccess.
  ///
  /// In zh, this message translates to:
  /// **'缺少{permissions}访问权限'**
  String missingPermissionAccess(String permissions);

  /// No description provided for @andJoin.
  ///
  /// In zh, this message translates to:
  /// **'和'**
  String get andJoin;

  /// No description provided for @photoBackupReady.
  ///
  /// In zh, this message translates to:
  /// **'照片备份已就绪'**
  String get photoBackupReady;

  /// No description provided for @needAuthToBackup.
  ///
  /// In zh, this message translates to:
  /// **'需要授权才能备份'**
  String get needAuthToBackup;

  /// No description provided for @photosVideosSyncToUnraid.
  ///
  /// In zh, this message translates to:
  /// **'可将最近照片手动上传到 Unraid（每次最多 50 张）'**
  String get photosVideosSyncToUnraid;

  /// No description provided for @grantPhotosVideosToEnable.
  ///
  /// In zh, this message translates to:
  /// **'请授予照片访问权限以启用备份'**
  String get grantPhotosVideosToEnable;

  /// No description provided for @backupNow.
  ///
  /// In zh, this message translates to:
  /// **'立即备份'**
  String get backupNow;

  /// No description provided for @backupCancel.
  ///
  /// In zh, this message translates to:
  /// **'取消备份'**
  String get backupCancel;

  /// No description provided for @backupRunning.
  ///
  /// In zh, this message translates to:
  /// **'正在备份 {current}/{total}'**
  String backupRunning(int current, int total);

  /// No description provided for @backupCurrentFile.
  ///
  /// In zh, this message translates to:
  /// **'当前：{name}'**
  String backupCurrentFile(String name);

  /// No description provided for @backupWifiBlocked.
  ///
  /// In zh, this message translates to:
  /// **'当前为移动网络。请连接 Wi-Fi，或关闭「仅 Wi-Fi 备份」。'**
  String get backupWifiBlocked;

  /// No description provided for @backupUnsupportedPlatform.
  ///
  /// In zh, this message translates to:
  /// **'相册备份目前仅支持 Android / iOS。'**
  String get backupUnsupportedPlatform;

  /// No description provided for @backupNoPhotos.
  ///
  /// In zh, this message translates to:
  /// **'没有可备份的本地照片。'**
  String get backupNoPhotos;

  /// No description provided for @backupNeedConnection.
  ///
  /// In zh, this message translates to:
  /// **'请先连接 Unraid 服务器后再备份。'**
  String get backupNeedConnection;

  /// No description provided for @backupDoneSummary.
  ///
  /// In zh, this message translates to:
  /// **'完成：成功 {success}，跳过 {skipped}，失败 {failed}'**
  String backupDoneSummary(int success, int skipped, int failed);

  /// No description provided for @backupCancelledSummary.
  ///
  /// In zh, this message translates to:
  /// **'已取消。成功 {success}，跳过 {skipped}，失败 {failed}'**
  String backupCancelledSummary(int success, int skipped, int failed);

  /// No description provided for @lastSyncSummary.
  ///
  /// In zh, this message translates to:
  /// **'{time} · 成功 {success} / 跳过 {skipped} / 失败 {failed}'**
  String lastSyncSummary(String time, int success, int skipped, int failed);

  /// No description provided for @backupBatchHint.
  ///
  /// In zh, this message translates to:
  /// **'每次上传设备上最新的最多 50 张照片；同名文件会跳过。'**
  String get backupBatchHint;

  /// No description provided for @searchPhotosVideos.
  ///
  /// In zh, this message translates to:
  /// **'搜索照片、视频'**
  String get searchPhotosVideos;

  /// No description provided for @allPhotos.
  ///
  /// In zh, this message translates to:
  /// **'全部照片'**
  String get allPhotos;

  /// No description provided for @backupEnabledSample.
  ///
  /// In zh, this message translates to:
  /// **'已开启 / 今天 09:42'**
  String get backupEnabledSample;

  /// No description provided for @photoCount.
  ///
  /// In zh, this message translates to:
  /// **'{count} 张'**
  String photoCount(int count);

  /// No description provided for @apiUnraidServiceMissing.
  ///
  /// In zh, this message translates to:
  /// **'未找到 unraid-api 服务，请确认 Unraid Connect/API 插件已启用'**
  String get apiUnraidServiceMissing;

  /// No description provided for @apiShareActionUnsupported.
  ///
  /// In zh, this message translates to:
  /// **'共享项目不支持该操作'**
  String get apiShareActionUnsupported;

  /// No description provided for @apiConnectionTimeout.
  ///
  /// In zh, this message translates to:
  /// **'连接服务器超时'**
  String get apiConnectionTimeout;

  /// No description provided for @apiCannotConnect.
  ///
  /// In zh, this message translates to:
  /// **'无法连接服务器：{error}'**
  String apiCannotConnect(String error);

  /// No description provided for @apiHttpError.
  ///
  /// In zh, this message translates to:
  /// **'服务器返回 HTTP {statusCode}'**
  String apiHttpError(int statusCode);

  /// No description provided for @apiInvalidData.
  ///
  /// In zh, this message translates to:
  /// **'服务器返回了无效数据'**
  String get apiInvalidData;

  /// No description provided for @apiGraphqlFailed.
  ///
  /// In zh, this message translates to:
  /// **'GraphQL 请求失败'**
  String get apiGraphqlFailed;

  /// No description provided for @apiMissingDataField.
  ///
  /// In zh, this message translates to:
  /// **'响应中缺少 data 字段'**
  String get apiMissingDataField;

  /// No description provided for @apiActionListDirectory.
  ///
  /// In zh, this message translates to:
  /// **'读取目录'**
  String get apiActionListDirectory;

  /// No description provided for @apiActionScanMedia.
  ///
  /// In zh, this message translates to:
  /// **'扫描媒体文件'**
  String get apiActionScanMedia;

  /// No description provided for @apiActionReadFile.
  ///
  /// In zh, this message translates to:
  /// **'读取文件'**
  String get apiActionReadFile;

  /// No description provided for @apiActionReadThumbnail.
  ///
  /// In zh, this message translates to:
  /// **'读取缩略图'**
  String get apiActionReadThumbnail;

  /// No description provided for @apiFileBrowserInvalidJson.
  ///
  /// In zh, this message translates to:
  /// **'File Browser 返回了无效 JSON：{action}'**
  String apiFileBrowserInvalidJson(String action);

  /// No description provided for @apiFileBrowserTimeout.
  ///
  /// In zh, this message translates to:
  /// **'File Browser {action}超时'**
  String apiFileBrowserTimeout(String action);

  /// No description provided for @apiFileBrowserCannotConnect.
  ///
  /// In zh, this message translates to:
  /// **'无法连接 File Browser：{error}'**
  String apiFileBrowserCannotConnect(String error);

  /// No description provided for @apiFileBrowserForbidden.
  ///
  /// In zh, this message translates to:
  /// **'File Browser 拒绝访问，请检查匿名访问或反向代理认证配置（HTTP {statusCode}）'**
  String apiFileBrowserForbidden(int statusCode);

  /// No description provided for @apiFileBrowserNotFound.
  ///
  /// In zh, this message translates to:
  /// **'File Browser 未找到路径（HTTP 404）'**
  String get apiFileBrowserNotFound;

  /// No description provided for @apiFileBrowserFailed.
  ///
  /// In zh, this message translates to:
  /// **'File Browser {action}失败：HTTP {statusCode}'**
  String apiFileBrowserFailed(String action, int statusCode);

  /// No description provided for @unbound.
  ///
  /// In zh, this message translates to:
  /// **'未绑定'**
  String get unbound;

  /// No description provided for @installedPlugins.
  ///
  /// In zh, this message translates to:
  /// **'已安装插件'**
  String get installedPlugins;

  /// No description provided for @countUnit.
  ///
  /// In zh, this message translates to:
  /// **'{count} 个'**
  String countUnit(int count);

  /// No description provided for @apiKeyRolesDescription.
  ///
  /// In zh, this message translates to:
  /// **'可用角色与权限来自 apiKeyPossibleRoles'**
  String get apiKeyRolesDescription;

  /// No description provided for @enabled.
  ///
  /// In zh, this message translates to:
  /// **'已启用'**
  String get enabled;

  /// No description provided for @disabled.
  ///
  /// In zh, this message translates to:
  /// **'未启用'**
  String get disabled;

  /// No description provided for @oidcProviderCount.
  ///
  /// In zh, this message translates to:
  /// **'{count} 个 OIDC 提供方'**
  String oidcProviderCount(int count);

  /// No description provided for @unraidCloudStatus.
  ///
  /// In zh, this message translates to:
  /// **'Unraid Cloud 状态'**
  String get unraidCloudStatus;

  /// No description provided for @dynamicRemoteAccess.
  ///
  /// In zh, this message translates to:
  /// **'动态远程访问 {type}'**
  String dynamicRemoteAccess(String type);

  /// No description provided for @remoteAccess.
  ///
  /// In zh, this message translates to:
  /// **'远程访问'**
  String get remoteAccess;

  /// No description provided for @forwardUnknown.
  ///
  /// In zh, this message translates to:
  /// **'forward 未知'**
  String get forwardUnknown;

  /// No description provided for @portLabel.
  ///
  /// In zh, this message translates to:
  /// **'端口 {port}'**
  String portLabel(String port);

  /// No description provided for @unnamedContainer.
  ///
  /// In zh, this message translates to:
  /// **'未命名容器'**
  String get unnamedContainer;

  /// No description provided for @dockerContainer.
  ///
  /// In zh, this message translates to:
  /// **'Docker 容器'**
  String get dockerContainer;

  /// No description provided for @autoStart.
  ///
  /// In zh, this message translates to:
  /// **'自启动'**
  String get autoStart;

  /// No description provided for @updateAvailable.
  ///
  /// In zh, this message translates to:
  /// **'有更新'**
  String get updateAvailable;

  /// No description provided for @image.
  ///
  /// In zh, this message translates to:
  /// **'镜像'**
  String get image;

  /// No description provided for @ports.
  ///
  /// In zh, this message translates to:
  /// **'端口'**
  String get ports;

  /// No description provided for @online.
  ///
  /// In zh, this message translates to:
  /// **'在线'**
  String get online;

  /// No description provided for @offline.
  ///
  /// In zh, this message translates to:
  /// **'离线'**
  String get offline;

  /// No description provided for @unnamedVm.
  ///
  /// In zh, this message translates to:
  /// **'未命名虚拟机'**
  String get unnamedVm;

  /// No description provided for @virtualMachine.
  ///
  /// In zh, this message translates to:
  /// **'虚拟机'**
  String get virtualMachine;

  /// No description provided for @running.
  ///
  /// In zh, this message translates to:
  /// **'运行中'**
  String get running;

  /// No description provided for @vncAvailable.
  ///
  /// In zh, this message translates to:
  /// **'VNC 可用'**
  String get vncAvailable;

  /// No description provided for @vmDomainId.
  ///
  /// In zh, this message translates to:
  /// **'虚拟机域标识'**
  String get vmDomainId;

  /// No description provided for @fromVmDomainState.
  ///
  /// In zh, this message translates to:
  /// **'来自 vms.domain.state'**
  String get fromVmDomainState;

  /// No description provided for @unnamedShare.
  ///
  /// In zh, this message translates to:
  /// **'未命名共享'**
  String get unnamedShare;

  /// No description provided for @cache.
  ///
  /// In zh, this message translates to:
  /// **'缓存'**
  String get cache;

  /// No description provided for @shareDirectory.
  ///
  /// In zh, this message translates to:
  /// **'共享目录'**
  String get shareDirectory;

  /// No description provided for @capacity.
  ///
  /// In zh, this message translates to:
  /// **'容量'**
  String get capacity;

  /// No description provided for @freeLabel.
  ///
  /// In zh, this message translates to:
  /// **'free {value}'**
  String freeLabel(String value);

  /// No description provided for @allocationStrategy.
  ///
  /// In zh, this message translates to:
  /// **'分配策略'**
  String get allocationStrategy;

  /// No description provided for @defaultValue.
  ///
  /// In zh, this message translates to:
  /// **'默认'**
  String get defaultValue;

  /// No description provided for @splitLevel.
  ///
  /// In zh, this message translates to:
  /// **'split level {value}'**
  String splitLevel(String value);

  /// No description provided for @none.
  ///
  /// In zh, this message translates to:
  /// **'无'**
  String get none;

  /// No description provided for @shareDirectoryConfig.
  ///
  /// In zh, this message translates to:
  /// **'共享目录配置'**
  String get shareDirectoryConfig;

  /// No description provided for @unknownDisk.
  ///
  /// In zh, this message translates to:
  /// **'未知磁盘'**
  String get unknownDisk;

  /// No description provided for @sleeping.
  ///
  /// In zh, this message translates to:
  /// **'休眠'**
  String get sleeping;

  /// No description provided for @networkInterface.
  ///
  /// In zh, this message translates to:
  /// **'网络接口'**
  String get networkInterface;

  /// No description provided for @noAddress.
  ///
  /// In zh, this message translates to:
  /// **'无地址'**
  String get noAddress;

  /// No description provided for @accessAddress.
  ///
  /// In zh, this message translates to:
  /// **'访问地址'**
  String get accessAddress;

  /// No description provided for @batteryLoad.
  ///
  /// In zh, this message translates to:
  /// **'电量 {battery}% · 负载 {load}%'**
  String batteryLoad(String battery, String load);

  /// No description provided for @plugin.
  ///
  /// In zh, this message translates to:
  /// **'插件'**
  String get plugin;

  /// No description provided for @unknownVersion.
  ///
  /// In zh, this message translates to:
  /// **'未知版本'**
  String get unknownVersion;

  /// No description provided for @apiCliModules.
  ///
  /// In zh, this message translates to:
  /// **'API {api} · CLI {cli}'**
  String apiCliModules(String api, String cli);

  /// No description provided for @yes.
  ///
  /// In zh, this message translates to:
  /// **'有'**
  String get yes;

  /// No description provided for @no.
  ///
  /// In zh, this message translates to:
  /// **'无'**
  String get no;

  /// No description provided for @pluginInstallTask.
  ///
  /// In zh, this message translates to:
  /// **'插件安装任务'**
  String get pluginInstallTask;

  /// No description provided for @installTask.
  ///
  /// In zh, this message translates to:
  /// **'安装任务'**
  String get installTask;

  /// No description provided for @log.
  ///
  /// In zh, this message translates to:
  /// **'日志'**
  String get log;

  /// No description provided for @unknownSize.
  ///
  /// In zh, this message translates to:
  /// **'未知大小'**
  String get unknownSize;

  /// No description provided for @localAccessAddress.
  ///
  /// In zh, this message translates to:
  /// **'本地访问地址'**
  String get localAccessAddress;

  /// No description provided for @remoteAccessAddress.
  ///
  /// In zh, this message translates to:
  /// **'远程访问地址'**
  String get remoteAccessAddress;

  /// No description provided for @notification.
  ///
  /// In zh, this message translates to:
  /// **'通知'**
  String get notification;

  /// No description provided for @unnamed.
  ///
  /// In zh, this message translates to:
  /// **'未命名'**
  String get unnamed;

  /// No description provided for @directory.
  ///
  /// In zh, this message translates to:
  /// **'目录'**
  String get directory;

  /// No description provided for @unknownCpu.
  ///
  /// In zh, this message translates to:
  /// **'未知 CPU'**
  String get unknownCpu;

  /// No description provided for @coresCount.
  ///
  /// In zh, this message translates to:
  /// **'{count} 核'**
  String coresCount(String count);

  /// No description provided for @threadsCount.
  ///
  /// In zh, this message translates to:
  /// **'{count} 线程'**
  String threadsCount(String count);

  /// No description provided for @unknownMotherboard.
  ///
  /// In zh, this message translates to:
  /// **'未知主板'**
  String get unknownMotherboard;

  /// No description provided for @unknownSystem.
  ///
  /// In zh, this message translates to:
  /// **'未知系统'**
  String get unknownSystem;

  /// No description provided for @noPackageVersions.
  ///
  /// In zh, this message translates to:
  /// **'未返回包版本'**
  String get noPackageVersions;

  /// No description provided for @noServicesReturned.
  ///
  /// In zh, this message translates to:
  /// **'未返回服务'**
  String get noServicesReturned;

  /// No description provided for @servicesOnlineSummary.
  ///
  /// In zh, this message translates to:
  /// **'{online}/{total} 在线 · {names}'**
  String servicesOnlineSummary(int online, int total, String names);

  /// No description provided for @noNetworksReturned.
  ///
  /// In zh, this message translates to:
  /// **'未返回网络'**
  String get noNetworksReturned;

  /// No description provided for @networksCount.
  ///
  /// In zh, this message translates to:
  /// **'{count} 个网络'**
  String networksCount(int count);

  /// No description provided for @noPortConflictInfo.
  ///
  /// In zh, this message translates to:
  /// **'未返回端口冲突信息'**
  String get noPortConflictInfo;

  /// No description provided for @noPortConflicts.
  ///
  /// In zh, this message translates to:
  /// **'未发现端口冲突'**
  String get noPortConflicts;

  /// No description provided for @portConflictCount.
  ///
  /// In zh, this message translates to:
  /// **'{count} 个端口冲突'**
  String portConflictCount(int count);

  /// No description provided for @container.
  ///
  /// In zh, this message translates to:
  /// **'容器'**
  String get container;

  /// No description provided for @noPortMappings.
  ///
  /// In zh, this message translates to:
  /// **'未返回端口映射'**
  String get noPortMappings;

  /// No description provided for @totalUsage.
  ///
  /// In zh, this message translates to:
  /// **'总计 {value}'**
  String totalUsage(String value);

  /// No description provided for @usedUsage.
  ///
  /// In zh, this message translates to:
  /// **'已用 {value}'**
  String usedUsage(String value);

  /// No description provided for @usedTotalUsage.
  ///
  /// In zh, this message translates to:
  /// **'已用 {used} / {total}'**
  String usedTotalUsage(String used, String total);

  /// No description provided for @started.
  ///
  /// In zh, this message translates to:
  /// **'已启动'**
  String get started;

  /// No description provided for @stopped.
  ///
  /// In zh, this message translates to:
  /// **'已停止'**
  String get stopped;

  /// No description provided for @paused.
  ///
  /// In zh, this message translates to:
  /// **'已暂停'**
  String get paused;

  /// No description provided for @idle.
  ///
  /// In zh, this message translates to:
  /// **'空闲'**
  String get idle;

  /// No description provided for @shutDown.
  ///
  /// In zh, this message translates to:
  /// **'已关闭'**
  String get shutDown;

  /// No description provided for @crashed.
  ///
  /// In zh, this message translates to:
  /// **'异常'**
  String get crashed;

  /// No description provided for @daysCount.
  ///
  /// In zh, this message translates to:
  /// **'{count} 天'**
  String daysCount(int count);

  /// No description provided for @hoursCount.
  ///
  /// In zh, this message translates to:
  /// **'{count} 小时'**
  String hoursCount(int count);

  /// No description provided for @minutesCount.
  ///
  /// In zh, this message translates to:
  /// **'{count} 分钟'**
  String minutesCount(int count);

  /// No description provided for @themeSystem.
  ///
  /// In zh, this message translates to:
  /// **'跟随系统'**
  String get themeSystem;

  /// No description provided for @themeLight.
  ///
  /// In zh, this message translates to:
  /// **'浅色'**
  String get themeLight;

  /// No description provided for @themeDark.
  ///
  /// In zh, this message translates to:
  /// **'深色'**
  String get themeDark;

  /// No description provided for @noMusicFound.
  ///
  /// In zh, this message translates to:
  /// **'没有找到音乐文件'**
  String get noMusicFound;

  /// No description provided for @musicLibraryEmpty.
  ///
  /// In zh, this message translates to:
  /// **'在共享目录中未发现音频。默认路径：/mnt/user/music'**
  String get musicLibraryEmpty;

  /// No description provided for @musicTrackCount.
  ///
  /// In zh, this message translates to:
  /// **'{count} 首'**
  String musicTrackCount(int count);

  /// No description provided for @musicLoadingTrack.
  ///
  /// In zh, this message translates to:
  /// **'正在加载…'**
  String get musicLoadingTrack;

  /// No description provided for @musicPlaybackError.
  ///
  /// In zh, this message translates to:
  /// **'播放失败：{error}'**
  String musicPlaybackError(String error);

  /// No description provided for @musicQueueStart.
  ///
  /// In zh, this message translates to:
  /// **'已是队列第一首'**
  String get musicQueueStart;

  /// No description provided for @musicQueueEnd.
  ///
  /// In zh, this message translates to:
  /// **'已是队列最后一首'**
  String get musicQueueEnd;

  /// No description provided for @searchMusic.
  ///
  /// In zh, this message translates to:
  /// **'搜索歌曲'**
  String get searchMusic;

  /// No description provided for @rename.
  ///
  /// In zh, this message translates to:
  /// **'重命名'**
  String get rename;

  /// No description provided for @delete.
  ///
  /// In zh, this message translates to:
  /// **'删除'**
  String get delete;

  /// No description provided for @deleteConfirmTitle.
  ///
  /// In zh, this message translates to:
  /// **'删除此项？'**
  String get deleteConfirmTitle;

  /// No description provided for @deleteConfirmMessage.
  ///
  /// In zh, this message translates to:
  /// **'将永久删除 {name}。'**
  String deleteConfirmMessage(String name);

  /// No description provided for @renameTitle.
  ///
  /// In zh, this message translates to:
  /// **'重命名'**
  String get renameTitle;

  /// No description provided for @renameHint.
  ///
  /// In zh, this message translates to:
  /// **'新名称'**
  String get renameHint;

  /// No description provided for @renameEmptyError.
  ///
  /// In zh, this message translates to:
  /// **'名称不能为空'**
  String get renameEmptyError;

  /// No description provided for @fileDeleted.
  ///
  /// In zh, this message translates to:
  /// **'已删除 {name}'**
  String fileDeleted(String name);

  /// No description provided for @fileRenamed.
  ///
  /// In zh, this message translates to:
  /// **'已重命名为 {name}'**
  String fileRenamed(String name);

  /// No description provided for @moreActions.
  ///
  /// In zh, this message translates to:
  /// **'更多操作'**
  String get moreActions;

  /// No description provided for @selectMode.
  ///
  /// In zh, this message translates to:
  /// **'选择'**
  String get selectMode;

  /// No description provided for @cancelSelection.
  ///
  /// In zh, this message translates to:
  /// **'取消选择'**
  String get cancelSelection;

  /// No description provided for @selectAll.
  ///
  /// In zh, this message translates to:
  /// **'全选'**
  String get selectAll;

  /// No description provided for @selectedCount.
  ///
  /// In zh, this message translates to:
  /// **'已选 {count} 项'**
  String selectedCount(int count);

  /// No description provided for @batchDelete.
  ///
  /// In zh, this message translates to:
  /// **'删除'**
  String get batchDelete;

  /// No description provided for @batchMove.
  ///
  /// In zh, this message translates to:
  /// **'移动'**
  String get batchMove;

  /// No description provided for @batchDeleteConfirmTitle.
  ///
  /// In zh, this message translates to:
  /// **'删除所选项目？'**
  String get batchDeleteConfirmTitle;

  /// No description provided for @batchDeleteConfirmMessage.
  ///
  /// In zh, this message translates to:
  /// **'将永久删除 {count} 个项目。'**
  String batchDeleteConfirmMessage(int count);

  /// No description provided for @batchResultSummary.
  ///
  /// In zh, this message translates to:
  /// **'完成：成功 {success}，跳过 {skipped}，失败 {failed}'**
  String batchResultSummary(int success, int skipped, int failed);

  /// No description provided for @moveToTitle.
  ///
  /// In zh, this message translates to:
  /// **'移动到…'**
  String get moveToTitle;

  /// No description provided for @selectMoveDestination.
  ///
  /// In zh, this message translates to:
  /// **'选择目标文件夹'**
  String get selectMoveDestination;

  /// No description provided for @moveHere.
  ///
  /// In zh, this message translates to:
  /// **'移动到此目录'**
  String get moveHere;

  /// No description provided for @cannotMoveIntoSelf.
  ///
  /// In zh, this message translates to:
  /// **'不能将文件夹移动到其自身或子目录中'**
  String get cannotMoveIntoSelf;

  /// No description provided for @batchBusy.
  ///
  /// In zh, this message translates to:
  /// **'正在处理…'**
  String get batchBusy;

  /// No description provided for @openFolder.
  ///
  /// In zh, this message translates to:
  /// **'打开'**
  String get openFolder;

  /// No description provided for @apiActionDelete.
  ///
  /// In zh, this message translates to:
  /// **'删除'**
  String get apiActionDelete;

  /// No description provided for @apiActionRename.
  ///
  /// In zh, this message translates to:
  /// **'重命名'**
  String get apiActionRename;

  /// No description provided for @apiActionUpload.
  ///
  /// In zh, this message translates to:
  /// **'上传'**
  String get apiActionUpload;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'zh'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'zh':
      return AppLocalizationsZh();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
