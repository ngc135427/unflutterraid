import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'connection_url.dart';
import 'login_preferences.dart';

class ServerProfile {
  const ServerProfile({
    required this.id,
    required this.name,
    required this.domain,
    required this.useHttps,
    required this.apiKey,
  });

  final String id;
  final String name;
  final String domain;
  final bool useHttps;
  final String apiKey;

  String get baseUrl => ConnectionUrl.buildBaseUrl(
        domain: domain,
        useHttps: useHttps,
      );

  String get displayHost => domain.isEmpty ? baseUrl : domain;

  Map<String, dynamic> toMetaJson() => {
        'id': id,
        'name': name,
        'domain': domain,
        'useHttps': useHttps,
      };

  factory ServerProfile.fromMetaJson(
    Map<String, dynamic> json, {
    required String apiKey,
  }) {
    return ServerProfile(
      id: (json['id'] ?? '').toString(),
      name: (json['name'] ?? '').toString(),
      domain: (json['domain'] ?? '').toString(),
      useHttps: json['useHttps'] == true,
      apiKey: apiKey,
    );
  }

  ServerProfile copyWith({
    String? name,
    String? domain,
    bool? useHttps,
    String? apiKey,
  }) {
    return ServerProfile(
      id: id,
      name: name ?? this.name,
      domain: domain ?? this.domain,
      useHttps: useHttps ?? this.useHttps,
      apiKey: apiKey ?? this.apiKey,
    );
  }
}

/// Local multi-server connection profiles (non-secret meta + secure API keys).
class ServerProfilesStore {
  static const _metaKey = 'server_profiles_meta_v1';
  static const _activeIdKey = 'server_profiles_active_id_v1';
  static const _apiKeyPrefix = 'server_profile_api_key_';

  static FlutterSecureStorage secureStorage = LoginPreferences.secureStorage;

  static Future<List<ServerProfile>> loadAll() async {
    final preferences = await SharedPreferences.getInstance();
    final raw = preferences.getString(_metaKey);
    if (raw == null || raw.isEmpty) {
      return const [];
    }
    try {
      final decoded = jsonDecode(raw);
      if (decoded is! List) {
        return const [];
      }
      final profiles = <ServerProfile>[];
      for (final item in decoded) {
        if (item is! Map) {
          continue;
        }
        final map = Map<String, dynamic>.from(item);
        final id = (map['id'] ?? '').toString();
        if (id.isEmpty) {
          continue;
        }
        final apiKey = await _readApiKey(id);
        profiles.add(ServerProfile.fromMetaJson(map, apiKey: apiKey));
      }
      return profiles;
    } catch (_) {
      return const [];
    }
  }

  static Future<String?> loadActiveId() async {
    final preferences = await SharedPreferences.getInstance();
    return preferences.getString(_activeIdKey);
  }

  static Future<void> setActiveId(String? id) async {
    final preferences = await SharedPreferences.getInstance();
    if (id == null || id.isEmpty) {
      await preferences.remove(_activeIdKey);
      return;
    }
    await preferences.setString(_activeIdKey, id);
  }

  static Future<ServerProfile?> loadActive() async {
    final profiles = await loadAll();
    if (profiles.isEmpty) {
      return null;
    }
    final activeId = await loadActiveId();
    if (activeId != null) {
      for (final profile in profiles) {
        if (profile.id == activeId) {
          return profile;
        }
      }
    }
    return profiles.first;
  }

  static Future<void> saveAll(List<ServerProfile> profiles) async {
    final preferences = await SharedPreferences.getInstance();
    final meta = profiles.map((p) => p.toMetaJson()).toList();
    await preferences.setString(_metaKey, jsonEncode(meta));
    for (final profile in profiles) {
      await secureStorage.write(
        key: '$_apiKeyPrefix${profile.id}',
        value: profile.apiKey,
      );
    }
  }

  static Future<void> upsert(ServerProfile profile) async {
    final profiles = [...await loadAll()];
    final index = profiles.indexWhere((p) => p.id == profile.id);
    if (index >= 0) {
      profiles[index] = profile;
    } else {
      profiles.add(profile);
    }
    await saveAll(profiles);
    await setActiveId(profile.id);
  }

  static Future<void> delete(String id) async {
    final profiles = (await loadAll()).where((p) => p.id != id).toList();
    await saveAll(profiles);
    await secureStorage.delete(key: '$_apiKeyPrefix$id');
    final active = await loadActiveId();
    if (active == id) {
      await setActiveId(profiles.isEmpty ? null : profiles.first.id);
    }
  }

  /// Upsert from login form and keep LoginPreferences remember-me in sync.
  static Future<void> saveFromLogin({
    required String domain,
    required String apiKey,
    required bool useHttps,
    required bool rememberMe,
    String? preferredName,
  }) async {
    if (!rememberMe) {
      await LoginPreferences.save(
        rememberMe: false,
        domain: domain,
        apiKey: apiKey,
        useHttps: useHttps,
      );
      return;
    }

    final host = domain.trim();
    final profiles = [...await loadAll()];
    final existingIndex = profiles.indexWhere(
      (p) =>
          p.domain.toLowerCase() == host.toLowerCase() &&
          p.useHttps == useHttps,
    );
    final id = existingIndex >= 0
        ? profiles[existingIndex].id
        : DateTime.now().millisecondsSinceEpoch.toString();
    final name = preferredName?.trim().isNotEmpty == true
        ? preferredName!.trim()
        : (existingIndex >= 0
            ? profiles[existingIndex].name
            : (host.isEmpty ? 'Unraid' : host));
    final profile = ServerProfile(
      id: id,
      name: name,
      domain: host,
      useHttps: useHttps,
      apiKey: apiKey.trim(),
    );
    await upsert(profile);
    await LoginPreferences.save(
      rememberMe: true,
      domain: host,
      apiKey: apiKey.trim(),
      useHttps: useHttps,
    );
  }

  static Future<String> _readApiKey(String id) async {
    try {
      return (await secureStorage.read(key: '$_apiKeyPrefix$id') ?? '').trim();
    } catch (_) {
      return '';
    }
  }
}
