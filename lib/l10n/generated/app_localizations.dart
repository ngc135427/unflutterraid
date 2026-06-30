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
  /// **'语言只是一个小设置项，后续可继续加入主题、通知、显示密度等偏好。'**
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
  /// **'主题设置将后续添加'**
  String get settingsThemeToast;

  /// No description provided for @settingsNotificationsTitle.
  ///
  /// In zh, this message translates to:
  /// **'通知'**
  String get settingsNotificationsTitle;

  /// No description provided for @settingsNotificationsSubtitle.
  ///
  /// In zh, this message translates to:
  /// **'告警提醒与运行状态推送'**
  String get settingsNotificationsSubtitle;

  /// No description provided for @settingsNotificationsToast.
  ///
  /// In zh, this message translates to:
  /// **'通知偏好将后续添加'**
  String get settingsNotificationsToast;

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
  /// **'默认连接、协议与凭据管理'**
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
