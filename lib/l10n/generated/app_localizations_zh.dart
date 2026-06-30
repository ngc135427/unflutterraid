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
  String get settingsIntroDescription => '语言只是一个小设置项，后续可继续加入主题、通知、显示密度等偏好。';

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
  String get settingsThemeToast => '主题设置将后续添加';

  @override
  String get settingsNotificationsTitle => '通知';

  @override
  String get settingsNotificationsSubtitle => '告警提醒与运行状态推送';

  @override
  String get settingsNotificationsToast => '通知偏好将后续添加';

  @override
  String get settingsConnectionSection => '连接';

  @override
  String get settingsConnectionTrailing => '登录相关';

  @override
  String get settingsServerConfigTitle => '服务器配置';

  @override
  String get settingsServerConfigSubtitle => '默认连接、协议与凭据管理';

  @override
  String get settingsPlanned => '规划中';

  @override
  String get settingsServerConfigToast => '服务器配置将在后续版本集中管理';

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
}
