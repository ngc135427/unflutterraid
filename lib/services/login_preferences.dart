import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

class RememberedLogin {
  const RememberedLogin({
    this.rememberMe = false,
    this.domain = '',
    this.apiKey = '',
    this.useHttps = false,
  });

  final bool rememberMe;
  final String domain;
  final String apiKey;
  final bool useHttps;
}

/// Persists login connection preferences.
///
/// Non-secret fields use [SharedPreferences]. The API key is stored with
/// [FlutterSecureStorage] (Keystore / Keychain where available).
///
/// Legacy Android MethodChannel SharedPreferences storage is read once and
/// migrated into the new layout.
class LoginPreferences {
  static const channelName = 'unflutterraid/login_preferences';
  static const _channel = MethodChannel(channelName);

  static const _rememberKey = 'login_remember_me';
  static const _domainKey = 'login_domain';
  static const _httpsKey = 'login_use_https';
  static const _apiKeySecureKey = 'login_api_key';
  static const _migratedKey = 'login_prefs_migrated_v2';

  /// Overridable for widget tests.
  static FlutterSecureStorage secureStorage = const FlutterSecureStorage();

  static Future<RememberedLogin> load() async {
    await _migrateLegacyIfNeeded();
    final preferences = await SharedPreferences.getInstance();
    final rememberMe = preferences.getBool(_rememberKey) ?? false;
    if (!rememberMe) {
      return const RememberedLogin();
    }
    final apiKey = await _readApiKey();
    return RememberedLogin(
      rememberMe: true,
      domain: (preferences.getString(_domainKey) ?? '').trim(),
      apiKey: apiKey,
      useHttps: preferences.getBool(_httpsKey) ?? false,
    );
  }

  static Future<void> save({
    required bool rememberMe,
    required String domain,
    required String apiKey,
    required bool useHttps,
  }) async {
    final preferences = await SharedPreferences.getInstance();
    if (!rememberMe) {
      await preferences.setBool(_rememberKey, false);
      await preferences.remove(_domainKey);
      await preferences.remove(_httpsKey);
      await secureStorage.delete(key: _apiKeySecureKey);
      await _clearLegacyChannel();
      return;
    }

    await preferences.setBool(_rememberKey, true);
    await preferences.setString(_domainKey, domain.trim());
    await preferences.setBool(_httpsKey, useHttps);
    await secureStorage.write(key: _apiKeySecureKey, value: apiKey.trim());
    await preferences.setBool(_migratedKey, true);
    await _clearLegacyChannel();
  }

  static Future<String> _readApiKey() async {
    try {
      return (await secureStorage.read(key: _apiKeySecureKey) ?? '').trim();
    } on PlatformException {
      return '';
    } on MissingPluginException {
      return '';
    }
  }

  static Future<void> _migrateLegacyIfNeeded() async {
    final preferences = await SharedPreferences.getInstance();
    if (preferences.getBool(_migratedKey) == true) {
      return;
    }

    // Already have new-format data.
    if (preferences.containsKey(_rememberKey)) {
      await preferences.setBool(_migratedKey, true);
      return;
    }

    // Android MethodChannel legacy prefs.
    try {
      final result = await _channel.invokeMethod<Map<dynamic, dynamic>>('load');
      if (result != null && result['rememberMe'] == true) {
        final domain = _asString(result['domain']);
        final apiKey = _asString(result['apiKey']);
        final useHttps = result['useHttps'] == true;
        await preferences.setBool(_rememberKey, true);
        await preferences.setString(_domainKey, domain);
        await preferences.setBool(_httpsKey, useHttps);
        if (apiKey.isNotEmpty) {
          await secureStorage.write(key: _apiKeySecureKey, value: apiKey);
        }
        await _clearLegacyChannel();
      }
    } on MissingPluginException {
      // Desktop / tests without native channel.
    } on PlatformException {
      // Ignore migration failures; user can re-enter credentials.
    }

    await preferences.setBool(_migratedKey, true);
  }

  static Future<void> _clearLegacyChannel() async {
    try {
      await _channel.invokeMethod<void>('save', {
        'rememberMe': false,
        'domain': '',
        'apiKey': '',
        'useHttps': false,
      });
    } on MissingPluginException {
      return;
    } on PlatformException {
      return;
    }
  }

  static String _asString(Object? value) {
    final text = value?.toString() ?? '';
    return text.trim();
  }
}
