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
      'Language is just one compact preference. Theme, notifications, display density, and more can fit here later.';

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
  String get settingsThemeToast => 'Theme settings will be added later';

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
}
