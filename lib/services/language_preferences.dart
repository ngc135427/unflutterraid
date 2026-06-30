import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum AppLanguage {
  system(null),
  zh(Locale('zh')),
  en(Locale('en'));

  const AppLanguage(this.locale);

  final Locale? locale;

  static AppLanguage fromCode(String? code) {
    return switch (code) {
      'zh' => AppLanguage.zh,
      'en' => AppLanguage.en,
      _ => AppLanguage.system,
    };
  }

  String? get code {
    return switch (this) {
      AppLanguage.system => null,
      AppLanguage.zh => 'zh',
      AppLanguage.en => 'en',
    };
  }
}

class LanguagePreferences {
  static const _key = 'app_language';

  static Future<AppLanguage> load() async {
    final preferences = await SharedPreferences.getInstance();
    return AppLanguage.fromCode(preferences.getString(_key));
  }

  static Future<void> save(AppLanguage language) async {
    final preferences = await SharedPreferences.getInstance();
    final code = language.code;
    if (code == null) {
      await preferences.remove(_key);
      return;
    }
    await preferences.setString(_key, code);
  }
}
