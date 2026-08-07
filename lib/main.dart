import 'package:flutter/material.dart';
import 'package:media_kit/media_kit.dart';

import 'app_language_scope.dart';
import 'app_theme_scope.dart';
import 'l10n/generated/app_localizations.dart';
import 'pages/album_page.dart';
import 'pages/detail_page.dart';
import 'pages/login_page.dart';
import 'pages/main_shell_page.dart';
import 'pages/music_page.dart';
import 'pages/about_page.dart';
import 'pages/docker_logs_page.dart';
import 'pages/file_browser_config_page.dart';
import 'pages/server_config_page.dart';
import 'pages/server_profiles_page.dart';
import 'pages/settings_page.dart';
import 'services/display_copy.dart';
import 'services/language_preferences.dart';
import 'services/theme_preferences.dart';
import 'theme/app_theme.dart';
import 'widgets/music_mini_bar.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  MediaKit.ensureInitialized();
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
            final page = child ?? const SizedBox.shrink();
            return Stack(
              fit: StackFit.expand,
              children: [
                page,
                const Align(
                  alignment: Alignment.bottomCenter,
                  child: MusicMiniBar(),
                ),
              ],
            );
          },
          initialRoute: LoginPage.routeName,
          routes: {
            LoginPage.routeName: (_) => const LoginPage(),
            MainShellPage.routeName: (_) => const MainShellPage(),
            AboutPage.routeName: (_) => const AboutPage(),
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
            ServerConfigPage.routeName: (_) => const ServerConfigPage(),
            DockerLogsPage.routeName: (_) => const DockerLogsPage(),
            FileBrowserConfigPage.routeName: (_) =>
                const FileBrowserConfigPage(),
            ServerProfilesPage.routeName: (_) => const ServerProfilesPage(),
          },
        ),
      ),
    );
  }
}
