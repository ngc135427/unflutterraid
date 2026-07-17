import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum AppThemePreference {
  system,
  light,
  dark;

  static AppThemePreference fromCode(String? code) {
    return switch (code) {
      'light' => AppThemePreference.light,
      'dark' => AppThemePreference.dark,
      _ => AppThemePreference.system,
    };
  }

  String? get code {
    return switch (this) {
      AppThemePreference.system => null,
      AppThemePreference.light => 'light',
      AppThemePreference.dark => 'dark',
    };
  }

  ThemeMode get themeMode {
    return switch (this) {
      AppThemePreference.system => ThemeMode.system,
      AppThemePreference.light => ThemeMode.light,
      AppThemePreference.dark => ThemeMode.dark,
    };
  }
}

class ThemePreferences {
  static const _key = 'app_theme';

  static Future<AppThemePreference> load() async {
    final preferences = await SharedPreferences.getInstance();
    return AppThemePreference.fromCode(preferences.getString(_key));
  }

  static Future<void> save(AppThemePreference theme) async {
    final preferences = await SharedPreferences.getInstance();
    final code = theme.code;
    if (code == null) {
      await preferences.remove(_key);
      return;
    }
    await preferences.setString(_key, code);
  }
}
