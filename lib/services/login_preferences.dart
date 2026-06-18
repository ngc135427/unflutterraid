import 'package:flutter/services.dart';

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

class LoginPreferences {
  static const channelName = 'unflutterraid/login_preferences';
  static const _channel = MethodChannel(channelName);

  static Future<RememberedLogin> load() async {
    try {
      final result = await _channel.invokeMethod<Map<dynamic, dynamic>>('load');
      if (result == null) {
        return const RememberedLogin();
      }

      return RememberedLogin(
        rememberMe: result['rememberMe'] == true,
        domain: _asString(result['domain']),
        apiKey: _asString(result['apiKey']),
        useHttps: result['useHttps'] == true,
      );
    } on MissingPluginException {
      return const RememberedLogin();
    }
  }

  static Future<void> save({
    required bool rememberMe,
    required String domain,
    required String apiKey,
    required bool useHttps,
  }) async {
    try {
      await _channel.invokeMethod<void>('save', {
        'rememberMe': rememberMe,
        'domain': domain,
        'apiKey': apiKey,
        'useHttps': useHttps,
      });
    } on MissingPluginException {
      return;
    }
  }

  static String _asString(Object? value) {
    final text = value?.toString() ?? '';
    return text.trim();
  }
}
