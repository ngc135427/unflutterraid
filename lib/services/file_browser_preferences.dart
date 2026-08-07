import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

/// Stores an optional File Browser endpoint for each Unraid server.
class FileBrowserPreferences {
  static const _overridesKey = 'file_browser_overrides_v1';

  static Future<String?> loadOverride(String unraidBaseUrl) async {
    final preferences = await SharedPreferences.getInstance();
    final raw = preferences.getString(_overridesKey);
    if (raw == null || raw.isEmpty) {
      return null;
    }
    try {
      final decoded = jsonDecode(raw);
      if (decoded is! Map) {
        return null;
      }
      final value = decoded[_serverKey(unraidBaseUrl)];
      return value is String ? normalizeHttpUrl(value) : null;
    } catch (_) {
      return null;
    }
  }

  static Future<void> saveOverride({
    required String unraidBaseUrl,
    required String? fileBrowserBaseUrl,
  }) async {
    final preferences = await SharedPreferences.getInstance();
    final overrides = _readOverrides(preferences.getString(_overridesKey));
    final key = _serverKey(unraidBaseUrl);
    final normalized = fileBrowserBaseUrl == null
        ? null
        : normalizeHttpUrl(fileBrowserBaseUrl);
    if (fileBrowserBaseUrl != null && normalized == null) {
      throw ArgumentError.value(
        fileBrowserBaseUrl,
        'fileBrowserBaseUrl',
        'Must be an HTTP(S) base URL without credentials, query, or fragment',
      );
    }
    if (normalized == null) {
      overrides.remove(key);
    } else {
      overrides[key] = normalized;
    }
    if (overrides.isEmpty) {
      await preferences.remove(_overridesKey);
    } else {
      await preferences.setString(_overridesKey, jsonEncode(overrides));
    }
  }

  /// Returns a normalized HTTP(S) base URL, or null when [value] is invalid.
  static String? normalizeHttpUrl(String value) {
    final trimmed = value.trim();
    if (trimmed.isEmpty) {
      return null;
    }
    final uri = Uri.tryParse(trimmed);
    if (uri == null ||
        (uri.scheme != 'http' && uri.scheme != 'https') ||
        uri.host.isEmpty ||
        uri.userInfo.isNotEmpty ||
        uri.hasQuery ||
        uri.hasFragment) {
      return null;
    }
    var path = uri.path;
    while (path.endsWith('/') && path.length > 1) {
      path = path.substring(0, path.length - 1);
    }
    if (path == '/') {
      path = '';
    }
    return uri
        .replace(
          scheme: uri.scheme.toLowerCase(),
          host: uri.host.toLowerCase(),
          path: path,
        )
        .toString();
  }

  static String _serverKey(String unraidBaseUrl) {
    return normalizeHttpUrl(unraidBaseUrl) ?? unraidBaseUrl.trim();
  }

  static Map<String, String> _readOverrides(String? raw) {
    if (raw == null || raw.isEmpty) {
      return <String, String>{};
    }
    try {
      final decoded = jsonDecode(raw);
      if (decoded is! Map) {
        return <String, String>{};
      }
      return {
        for (final entry in decoded.entries)
          if (entry.key is String && entry.value is String)
            entry.key as String: entry.value as String,
      };
    } catch (_) {
      return <String, String>{};
    }
  }
}
