import 'package:shared_preferences/shared_preferences.dart';

class BackupLastSync {
  const BackupLastSync({
    required this.at,
    required this.success,
    required this.failed,
    required this.skipped,
  });

  final DateTime at;
  final int success;
  final int failed;
  final int skipped;

  String encodeSummary() => 'ok=$success fail=$failed skip=$skipped';

  static BackupLastSync? tryParse({
    required String? atIso,
    required String? summary,
  }) {
    if (atIso == null || atIso.isEmpty || summary == null || summary.isEmpty) {
      return null;
    }
    final at = DateTime.tryParse(atIso);
    if (at == null) {
      return null;
    }
    final ok = _readInt(summary, 'ok');
    final fail = _readInt(summary, 'fail');
    final skip = _readInt(summary, 'skip');
    return BackupLastSync(
      at: at,
      success: ok,
      failed: fail,
      skipped: skip,
    );
  }

  static int _readInt(String summary, String key) {
    final match = RegExp('$key=(\\d+)').firstMatch(summary);
    if (match == null) {
      return 0;
    }
    return int.tryParse(match.group(1)!) ?? 0;
  }
}

class BackupPreferencesState {
  const BackupPreferencesState({
    required this.autoBackup,
    required this.wifiOnly,
    required this.targetDir,
    this.lastSync,
  });

  final bool autoBackup;
  final bool wifiOnly;
  final String targetDir;
  final BackupLastSync? lastSync;

  static const defaultTargetDir = '/mnt/user/photos/mobile';

  BackupPreferencesState copyWith({
    bool? autoBackup,
    bool? wifiOnly,
    String? targetDir,
    BackupLastSync? lastSync,
    bool clearLastSync = false,
  }) {
    return BackupPreferencesState(
      autoBackup: autoBackup ?? this.autoBackup,
      wifiOnly: wifiOnly ?? this.wifiOnly,
      targetDir: targetDir ?? this.targetDir,
      lastSync: clearLastSync ? null : (lastSync ?? this.lastSync),
    );
  }
}

class BackupPreferences {
  static const _autoKey = 'backup_auto';
  static const _wifiKey = 'backup_wifi_only';
  static const _targetKey = 'backup_target_dir';
  static const _lastAtKey = 'backup_last_sync_at';
  static const _lastSummaryKey = 'backup_last_sync_summary';

  static Future<BackupPreferencesState> load() async {
    final preferences = await SharedPreferences.getInstance();
    final lastSync = BackupLastSync.tryParse(
      atIso: preferences.getString(_lastAtKey),
      summary: preferences.getString(_lastSummaryKey),
    );
    return BackupPreferencesState(
      autoBackup: preferences.getBool(_autoKey) ?? false,
      wifiOnly: preferences.getBool(_wifiKey) ?? true,
      targetDir: preferences.getString(_targetKey) ??
          BackupPreferencesState.defaultTargetDir,
      lastSync: lastSync,
    );
  }

  static Future<void> save(BackupPreferencesState state) async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.setBool(_autoKey, state.autoBackup);
    await preferences.setBool(_wifiKey, state.wifiOnly);
    await preferences.setString(_targetKey, state.targetDir);
    final last = state.lastSync;
    if (last == null) {
      await preferences.remove(_lastAtKey);
      await preferences.remove(_lastSummaryKey);
      return;
    }
    await preferences.setString(_lastAtKey, last.at.toIso8601String());
    await preferences.setString(_lastSummaryKey, last.encodeSummary());
  }

  static Future<void> saveLastSync(BackupLastSync lastSync) async {
    final current = await load();
    await save(current.copyWith(lastSync: lastSync));
  }
}
