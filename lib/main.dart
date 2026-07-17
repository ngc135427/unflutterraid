import 'package:flutter/material.dart';

import 'app_language_scope.dart';
import 'app_theme_scope.dart';
import 'l10n/generated/app_localizations.dart';
import 'pages/album_page.dart';
import 'pages/detail_page.dart';
import 'pages/login_page.dart';
import 'pages/main_shell_page.dart';
import 'pages/music_page.dart';
import 'pages/register_page.dart';
import 'pages/settings_page.dart';
import 'services/display_copy.dart';
import 'services/language_preferences.dart';
import 'services/theme_preferences.dart';
import 'theme/app_theme.dart';

void main() {
  runApp(const UnflutterRaidApp());
}

class UnflutterRaidApp extends StatefulWidget {
  const UnflutterRaidApp({super.key});

  @override
  State<UnflutterRaidApp> createState() => _UnflutterRaidAppState();
}

class _UnflutterRaidAppState extends State<UnflutterRaidApp> {
  AppLanguage _language = AppLanguage.system;
  AppThemePreference _theme = AppThemePreference.system;

  @override
  void initState() {
    super.initState();
    _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    final language = await LanguagePreferences.load();
    final theme = await ThemePreferences.load();
    if (!mounted) {
      return;
    }
    setState(() {
      _language = language;
      _theme = theme;
    });
  }

  Future<void> _setLanguage(AppLanguage language) async {
    setState(() => _language = language);
    await LanguagePreferences.save(language);
  }

  Future<void> _setTheme(AppThemePreference theme) async {
    setState(() => _theme = theme);
    await ThemePreferences.save(theme);
  }

  @override
  Widget build(BuildContext context) {
    return AppLanguageScope(
      language: _language,
      onLanguageChanged: _setLanguage,
      child: AppThemeScope(
        theme: _theme,
        onThemeChanged: _setTheme,
        child: MaterialApp(
          title: 'Unflutterraid',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.light(),
          darkTheme: AppTheme.dark(),
          themeMode: _theme.themeMode,
          locale: _language.locale,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          builder: (context, child) {
            DisplayCopy.fromL10n(AppLocalizations.of(context)).activate();
            return child ?? const SizedBox.shrink();
          },
          initialRoute: LoginPage.routeName,
          routes: {
            LoginPage.routeName: (_) => const LoginPage(),
            RegisterPage.routeName: (_) => const RegisterPage(),
            MainShellPage.routeName: (_) => const MainShellPage(),
            ManagementDetailPage.routeName: (_) => const ManagementDetailPage(),
            AlbumPage.routeName: (_) => const AlbumPage(),
            AlbumGroupsPage.routeName: (_) => const AlbumGroupsPage(),
            AlbumVideosPage.routeName: (_) => const AlbumVideosPage(),
            AlbumBackupPage.routeName: (_) => const AlbumBackupPage(),
            MusicPage.routeName: (_) => const MusicPage(),
            MusicTracksPage.routeName: (_) => const MusicTracksPage(),
            MusicPlayerPage.routeName: (_) => const MusicPlayerPage(),
            DetailPage.routeName: (_) => const DetailPage(),
            SettingsPage.routeName: (_) => const SettingsPage(),
          },
        ),
      ),
    );
  }
}
