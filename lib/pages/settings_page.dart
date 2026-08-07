import 'dart:async';

import 'package:flutter/material.dart';

import '../app_language_scope.dart';
import '../app_theme_scope.dart';
import '../l10n/generated/app_localizations.dart';
import '../l10n/language_names.dart';
import '../services/connection_url.dart';
import '../services/dashboard_refresh_preferences.dart';
import '../services/language_preferences.dart';
import '../services/theme_preferences.dart';
import '../services/unraid_api_client.dart';
import '../theme/app_theme.dart';
import '../widgets/phone_frame.dart';
import 'about_page.dart';
import 'file_browser_config_page.dart';
import 'server_config_page.dart';
import 'server_profiles_page.dart';

class SettingsPageArgs {
  const SettingsPageArgs({this.apiClient});

  final UnraidApiClient? apiClient;
}

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  static const routeName = '/settings';

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool _autoRefreshEnabled = true;
  int _autoRefreshSeconds = DashboardRefreshPreferences.defaultSeconds;
  bool _prefsLoaded = false;

  @override
  void initState() {
    super.initState();
    unawaited(_loadRefreshPrefs());
  }

  Future<void> _loadRefreshPrefs() async {
    final enabled = await DashboardRefreshPreferences.loadEnabled();
    final seconds = await DashboardRefreshPreferences.loadIntervalSeconds();
    if (!mounted) {
      return;
    }
    setState(() {
      _autoRefreshEnabled = enabled;
      _autoRefreshSeconds = seconds;
      _prefsLoaded = true;
    });
  }

  Future<void> _setAutoRefreshEnabled(bool value) async {
    setState(() => _autoRefreshEnabled = value);
    await DashboardRefreshPreferences.saveEnabled(value);
  }

  Future<void> _setAutoRefreshSeconds(int value) async {
    setState(() => _autoRefreshSeconds = value);
    await DashboardRefreshPreferences.saveIntervalSeconds(value);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final languageScope = AppLanguageScope.of(context);
    final themeScope = AppThemeScope.of(context);
    final args = ModalRoute.of(context)?.settings.arguments;
    final pageArgs = args is SettingsPageArgs ? args : null;
    final client = pageArgs?.apiClient;
    final connectionValue = client == null
        ? l10n.settingsNotConnected
        : ConnectionUrl.parse(client.baseUrl).domain;
    final connectionSubtitle = client == null
        ? l10n.settingsServerConfigSubtitle
        : '${client.baseUrl} · ${ConnectionUrl.maskApiKey(client.apiKey)}';

    return PhoneFrame(
      maxContentWidth: 520,
      child: Column(
        children: [
          _SettingsHeader(l10n: l10n),
          Expanded(
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(20, 22, 20, 24),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
              ),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _SettingsIntro(l10n: l10n),
                    const SizedBox(height: 18),
                    _SectionTitle(
                      title: l10n.settingsGeneralSection,
                      trailing: l10n.settingsGeneralTrailing,
                    ),
                    const SizedBox(height: 9),
                    _SettingsCard(
                      children: [
                        _LanguageSettingRow(
                          language: languageScope.language,
                          onChanged: languageScope.onLanguageChanged,
                        ),
                        _ThemeSettingRow(
                          theme: themeScope.theme,
                          onChanged: themeScope.onThemeChanged,
                        ),
                        _SettingRow(
                          icon: Icons.notifications,
                          iconColor: const Color(0xFF188D50),
                          iconBackground: const Color(0xFFEAF8F0),
                          title: l10n.settingsNotificationsTitle,
                          subtitle: l10n.settingsNotificationsSubtitle,
                          value: l10n.notifications,
                          onTap: () => _showMessage(
                            context,
                            l10n.settingsNotificationsToast,
                          ),
                        ),
                        if (_prefsLoaded)
                          _AutoRefreshSettingRow(
                            enabled: _autoRefreshEnabled,
                            seconds: _autoRefreshSeconds,
                            onEnabledChanged: (value) =>
                                unawaited(_setAutoRefreshEnabled(value)),
                            onSecondsChanged: (value) =>
                                unawaited(_setAutoRefreshSeconds(value)),
                          ),
                      ],
                    ),
                    const SizedBox(height: 18),
                    _SectionTitle(
                      title: l10n.settingsConnectionSection,
                      trailing: l10n.settingsConnectionTrailing,
                    ),
                    const SizedBox(height: 9),
                    _SettingsCard(
                      children: [
                        _SettingRow(
                          icon: Icons.dns,
                          title: l10n.settingsServerConfigTitle,
                          subtitle: connectionSubtitle,
                          value: connectionValue.isEmpty
                              ? l10n.settingsNotConnected
                              : (client == null
                                  ? l10n.settingsNotConnected
                                  : l10n.settingsConnected),
                          onTap: () {
                            Navigator.of(context).pushNamed(
                              ServerConfigPage.routeName,
                              arguments: ServerConfigPageArgs(
                                apiClient: client,
                              ),
                            );
                          },
                        ),
                        _SettingRow(
                          icon: Icons.storage,
                          iconColor: const Color(0xFF5C4B8A),
                          iconBackground: const Color(0xFFF1ECFA),
                          title: l10n.serverProfilesTitle,
                          subtitle: l10n.serverProfilesSettingsSubtitle,
                          value: l10n.settingsOpen,
                          onTap: () {
                            Navigator.of(context).pushNamed(
                              ServerProfilesPage.routeName,
                            );
                          },
                        ),
                        _SettingRow(
                          icon: Icons.cloud_outlined,
                          iconColor: const Color(0xFF0E7490),
                          iconBackground: const Color(0xFFE6F7FA),
                          title: l10n.fileBrowserSettingsTitle,
                          subtitle: client?.fileBrowserBaseUrl ??
                              l10n.fileBrowserSettingsSubtitle,
                          value: client == null
                              ? l10n.settingsNotConnected
                              : l10n.settingsOpen,
                          onTap: client == null
                              ? null
                              : () {
                                  Navigator.of(context).pushNamed(
                                    FileBrowserConfigPage.routeName,
                                    arguments: FileBrowserConfigPageArgs(
                                      apiClient: client,
                                    ),
                                  );
                                },
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),
                    _SectionTitle(
                      title: l10n.settingsAboutSection,
                      trailing: l10n.settingsAboutTrailing,
                    ),
                    const SizedBox(height: 9),
                    _SettingsCard(
                      children: [
                        _SettingRow(
                          icon: Icons.info_outline,
                          iconColor: const Color(0xFF3D5A80),
                          iconBackground: const Color(0xFFEAF1FB),
                          title: l10n.aboutTitle,
                          subtitle: l10n.aboutSettingsSubtitle,
                          value: l10n.settingsOpen,
                          onTap: () {
                            Navigator.of(context).pushNamed(
                              AboutPage.routeName,
                            );
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showMessage(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }
}

class _AutoRefreshSettingRow extends StatelessWidget {
  const _AutoRefreshSettingRow({
    required this.enabled,
    required this.seconds,
    required this.onEnabledChanged,
    required this.onSecondsChanged,
  });

  final bool enabled;
  final int seconds;
  final ValueChanged<bool> onEnabledChanged;
  final ValueChanged<int> onSecondsChanged;

  static const _options = [15, 30, 60, 120];

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Column(
      children: [
        _SettingRow(
          icon: Icons.autorenew,
          iconColor: const Color(0xFF0B6E4F),
          iconBackground: const Color(0xFFE8F7F1),
          title: l10n.settingsAutoRefreshTitle,
          subtitle: l10n.settingsAutoRefreshSubtitle,
          value: enabled
              ? l10n.settingsAutoRefreshEnabled
              : l10n.settingsAutoRefreshDisabled,
        ),
        SwitchListTile(
          contentPadding: const EdgeInsets.fromLTRB(52, 0, 12, 0),
          title: Text(
            enabled
                ? l10n.settingsAutoRefreshInterval(seconds)
                : l10n.settingsAutoRefreshDisabled,
            style: const TextStyle(fontSize: 13, color: AppTheme.textMedium),
          ),
          value: enabled,
          onChanged: onEnabledChanged,
        ),
        if (enabled)
          Padding(
            padding: const EdgeInsets.fromLTRB(52, 0, 12, 12),
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final option in _options)
                  ChoiceChip(
                    label: Text('${option}s'),
                    selected: seconds == option,
                    onSelected: (_) => onSecondsChanged(option),
                  ),
              ],
            ),
          ),
      ],
    );
  }
}

class _SettingsHeader extends StatelessWidget {
  const _SettingsHeader({required this.l10n});

  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 104,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _HeaderIconButton(
              tooltip: l10n.back,
              icon: Icons.arrow_back,
              onPressed: () => Navigator.of(context).maybePop(),
            ),
            Expanded(
              child: Column(
                children: [
                  Text(
                    l10n.settingsTitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    l10n.settingsSubtitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.82),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            _HeaderIconButton(
              tooltip: l10n.settingsTitle,
              icon: Icons.settings,
              onPressed: null,
            ),
          ],
        ),
      ),
    );
  }
}

class _HeaderIconButton extends StatelessWidget {
  const _HeaderIconButton({
    required this.tooltip,
    required this.icon,
    required this.onPressed,
  });

  final String tooltip;
  final IconData icon;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      tooltip: tooltip,
      onPressed: onPressed,
      style: IconButton.styleFrom(
        backgroundColor: Colors.white.withValues(alpha: 0.16),
        foregroundColor: Colors.white,
        disabledBackgroundColor: Colors.white.withValues(alpha: 0.16),
        disabledForegroundColor: Colors.white,
      ),
      icon: Icon(icon),
    );
  }
}

class _SettingsIntro extends StatelessWidget {
  const _SettingsIntro({required this.l10n});

  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.settingsIntroEyebrow,
          style: const TextStyle(
            color: AppTheme.primary,
            fontSize: 11,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 5),
        Text(
          l10n.settingsIntroTitle,
          style: const TextStyle(
            color: AppTheme.textDark,
            fontSize: 20,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          l10n.settingsIntroDescription,
          style: const TextStyle(
            color: AppTheme.textLight,
            fontSize: 12,
            height: 1.45,
          ),
        ),
      ],
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({
    required this.title,
    required this.trailing,
  });

  final String title;
  final String trailing;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: const TextStyle(
              color: AppTheme.textDark,
              fontSize: 15,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        Text(
          trailing,
          style: const TextStyle(color: AppTheme.textLight, fontSize: 12),
        ),
      ],
    );
  }
}

class _SettingsCard extends StatelessWidget {
  const _SettingsCard({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppTheme.softLine),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF49597A).withValues(alpha: 0.05),
            blurRadius: 14,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(children: children),
    );
  }
}

class _LanguageSettingRow extends StatelessWidget {
  const _LanguageSettingRow({
    required this.language,
    required this.onChanged,
  });

  final AppLanguage language;
  final ValueChanged<AppLanguage> onChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Column(
      children: [
        _SettingRow(
          icon: Icons.translate,
          title: l10n.languageSettingTitle,
          subtitle: l10n.languageSettingSubtitle,
          value: language.label(l10n),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(52, 0, 12, 12),
          child: _LanguageSegmentedControl(
            language: language,
            onChanged: (value) {
              onChanged(value);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                    content:
                        Text(l10n.settingsLanguageToast(value.label(l10n)))),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _ThemeSettingRow extends StatelessWidget {
  const _ThemeSettingRow({
    required this.theme,
    required this.onChanged,
  });

  final AppThemePreference theme;
  final ValueChanged<AppThemePreference> onChanged;

  String _label(AppLocalizations l10n, AppThemePreference value) {
    return switch (value) {
      AppThemePreference.system => l10n.themeSystem,
      AppThemePreference.light => l10n.themeLight,
      AppThemePreference.dark => l10n.themeDark,
    };
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Column(
      children: [
        _SettingRow(
          icon: Icons.palette,
          iconColor: const Color(0xFF9A6200),
          iconBackground: const Color(0xFFFFF6E5),
          title: l10n.settingsThemeTitle,
          subtitle: l10n.settingsThemeSubtitle,
          value: _label(l10n, theme),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(52, 0, 12, 12),
          child: _ThemeSegmentedControl(
            theme: theme,
            labelFor: (value) => _label(l10n, value),
            onChanged: (value) {
              onChanged(value);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(l10n.settingsThemeToast(_label(l10n, value))),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _ThemeSegmentedControl extends StatelessWidget {
  const _ThemeSegmentedControl({
    required this.theme,
    required this.labelFor,
    required this.onChanged,
  });

  final AppThemePreference theme;
  final String Function(AppThemePreference value) labelFor;
  final ValueChanged<AppThemePreference> onChanged;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppTheme.background,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppTheme.softLine),
      ),
      child: Padding(
        padding: const EdgeInsets.all(4),
        child: Row(
          children: [
            for (final option in AppThemePreference.values)
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 2),
                  child: _LanguageOptionButton(
                    label: labelFor(option),
                    selected: option == theme,
                    onTap: () => onChanged(option),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _LanguageSegmentedControl extends StatelessWidget {
  const _LanguageSegmentedControl({
    required this.language,
    required this.onChanged,
  });

  final AppLanguage language;
  final ValueChanged<AppLanguage> onChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppTheme.background,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppTheme.softLine),
      ),
      child: Padding(
        padding: const EdgeInsets.all(4),
        child: Row(
          children: [
            for (final option in AppLanguage.values)
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 2),
                  child: _LanguageOptionButton(
                    label: option == AppLanguage.system
                        ? l10n.languageSystem
                        : option.label(l10n),
                    selected: option == language,
                    onTap: () => onChanged(option),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _LanguageOptionButton extends StatelessWidget {
  const _LanguageOptionButton({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 34,
      child: TextButton(
        onPressed: onTap,
        style: TextButton.styleFrom(
          backgroundColor: selected ? AppTheme.primary : Colors.transparent,
          foregroundColor: selected ? Colors.white : AppTheme.textMedium,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
          padding: EdgeInsets.zero,
          textStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
        ),
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(label),
        ),
      ),
    );
  }
}

class _SettingRow extends StatelessWidget {
  const _SettingRow({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.value,
    this.iconColor = AppTheme.primary,
    this.iconBackground = const Color(0xFFEFF3FF),
    this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final String value;
  final Color iconColor;
  final Color iconBackground;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  color: iconBackground,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: iconColor, size: 20),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: AppTheme.textDark,
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      subtitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: AppTheme.textLight,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    value,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: AppTheme.textLight,
                      fontSize: 12,
                    ),
                  ),
                  if (onTap != null) ...[
                    const SizedBox(width: 3),
                    const Icon(
                      Icons.chevron_right,
                      color: AppTheme.textLight,
                      size: 18,
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
