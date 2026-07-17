import 'package:shared_preferences/shared_preferences.dart';

/// Controls periodic dashboard auto-refresh while MainShell is open.
class DashboardRefreshPreferences {
  static const _enabledKey = 'dashboard_auto_refresh_enabled';
  static const _secondsKey = 'dashboard_auto_refresh_seconds';

  static const defaultSeconds = 30;
  static const minSeconds = 15;
  static const maxSeconds = 300;

  static Future<bool> loadEnabled() async {
    final preferences = await SharedPreferences.getInstance();
    return preferences.getBool(_enabledKey) ?? true;
  }

  static Future<int> loadIntervalSeconds() async {
    final preferences = await SharedPreferences.getInstance();
    final value = preferences.getInt(_secondsKey) ?? defaultSeconds;
    return value.clamp(minSeconds, maxSeconds);
  }

  static Future<void> saveEnabled(bool enabled) async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.setBool(_enabledKey, enabled);
  }

  static Future<void> saveIntervalSeconds(int seconds) async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.setInt(
      _secondsKey,
      seconds.clamp(minSeconds, maxSeconds),
    );
  }
}
