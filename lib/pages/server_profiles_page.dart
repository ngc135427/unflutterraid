import 'dart:async';

import 'package:flutter/material.dart';

import '../l10n/generated/app_localizations.dart';
import '../services/connection_url.dart';
import '../services/file_browser_preferences.dart';
import '../services/server_profiles.dart';
import '../services/unraid_api_client.dart';
import '../theme/app_theme.dart';
import '../widgets/fade_slide.dart';
import '../widgets/phone_frame.dart';
import 'main_shell_page.dart';

class ServerProfilesPage extends StatefulWidget {
  const ServerProfilesPage({super.key});

  static const routeName = '/server-profiles';

  @override
  State<ServerProfilesPage> createState() => _ServerProfilesPageState();
}

class _ServerProfilesPageState extends State<ServerProfilesPage> {
  List<ServerProfile> _profiles = const [];
  String? _activeId;
  bool _loading = true;
  bool _connecting = false;

  @override
  void initState() {
    super.initState();
    unawaited(_reload());
  }

  Future<void> _reload() async {
    final profiles = await ServerProfilesStore.loadAll();
    final activeId = await ServerProfilesStore.loadActiveId();
    if (!mounted) {
      return;
    }
    setState(() {
      _profiles = profiles;
      _activeId = activeId;
      _loading = false;
    });
  }

  Future<void> _connect(ServerProfile profile) async {
    final l10n = AppLocalizations.of(context);
    if (profile.apiKey.isEmpty || profile.domain.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.serverProfileIncomplete)),
      );
      return;
    }
    setState(() => _connecting = true);
    final fileBrowserBaseUrl =
        await FileBrowserPreferences.loadOverride(profile.baseUrl);
    if (!mounted) {
      return;
    }
    final client = UnraidApiClient(
      baseUrl: profile.baseUrl,
      apiKey: profile.apiKey,
      fileBrowserBaseUrl: fileBrowserBaseUrl,
    );
    try {
      await client.checkConnection();
      await ServerProfilesStore.setActiveId(profile.id);
      await ServerProfilesStore.saveFromLogin(
        domain: profile.domain,
        apiKey: profile.apiKey,
        useHttps: profile.useHttps,
        rememberMe: true,
        preferredName: profile.name,
      );
      if (!mounted) {
        client.close();
        return;
      }
      Navigator.of(context).pushNamedAndRemoveUntil(
        MainShellPage.routeName,
        (route) => false,
        arguments: client,
      );
    } on UnraidApiException catch (error) {
      client.close();
      if (mounted) {
        setState(() => _connecting = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(error.message)),
        );
      }
    } catch (error) {
      client.close();
      if (mounted) {
        setState(() => _connecting = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.loginFailed(error.toString()))),
        );
      }
    }
  }

  Future<void> _delete(ServerProfile profile) async {
    final l10n = AppLocalizations.of(context);
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.serverProfileDeleteTitle),
        content: Text(l10n.serverProfileDeleteMessage(profile.name)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(l10n.delete),
          ),
        ],
      ),
    );
    if (ok != true) {
      return;
    }
    await ServerProfilesStore.delete(profile.id);
    await _reload();
  }

  Future<void> _edit(ServerProfile? existing) async {
    final l10n = AppLocalizations.of(context);
    final nameController = TextEditingController(text: existing?.name ?? '');
    final domainController =
        TextEditingController(text: existing?.domain ?? '');
    final apiKeyController =
        TextEditingController(text: existing?.apiKey ?? '');
    var useHttps = existing?.useHttps ?? false;

    final saved = await showDialog<bool>(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setLocal) {
            return AlertDialog(
              title: Text(
                existing == null
                    ? l10n.serverProfileAddTitle
                    : l10n.serverProfileEditTitle,
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: nameController,
                      decoration: InputDecoration(
                        labelText: l10n.serverProfileNameLabel,
                      ),
                    ),
                    TextField(
                      controller: domainController,
                      decoration: InputDecoration(
                        labelText: l10n.loginServerAddress,
                      ),
                    ),
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(useHttps ? 'https://' : 'http://'),
                      value: useHttps,
                      onChanged: (value) => setLocal(() => useHttps = value),
                    ),
                    TextField(
                      controller: apiKeyController,
                      decoration: InputDecoration(
                        labelText: l10n.loginApiKey,
                      ),
                      obscureText: true,
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: Text(l10n.cancel),
                ),
                FilledButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  child: Text(l10n.confirm),
                ),
              ],
            );
          },
        );
      },
    );

    if (saved != true) {
      nameController.dispose();
      domainController.dispose();
      apiKeyController.dispose();
      return;
    }

    final domain = domainController.text.trim();
    final apiKey = apiKeyController.text.trim();
    final name = nameController.text.trim().isEmpty
        ? domain
        : nameController.text.trim();
    nameController.dispose();
    domainController.dispose();
    apiKeyController.dispose();

    if (domain.isEmpty || apiKey.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.serverProfileIncomplete)),
        );
      }
      return;
    }

    final profile = ServerProfile(
      id: existing?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
      name: name,
      domain: domain,
      useHttps: useHttps,
      apiKey: apiKey,
    );
    await ServerProfilesStore.upsert(profile);
    await _reload();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return PhoneFrame(
      maxContentWidth: 520,
      child: Column(
        children: [
          SizedBox(
            height: 64,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(8, 12, 8, 8),
              child: Row(
                children: [
                  IconButton(
                    tooltip: l10n.back,
                    onPressed: () => Navigator.of(context).maybePop(),
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                  ),
                  Expanded(
                    child: Text(
                      l10n.serverProfilesTitle,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  IconButton(
                    tooltip: l10n.serverProfileAddTitle,
                    onPressed:
                        _connecting ? null : () => unawaited(_edit(null)),
                    icon: const Icon(Icons.add, color: Colors.white),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(20, 18, 20, 20),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
              ),
              child: _loading
                  ? const Center(child: CircularProgressIndicator())
                  : FadeSlide(
                      child: _profiles.isEmpty
                          ? Center(
                              child: Text(
                                l10n.serverProfilesEmpty,
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  color: AppTheme.textMedium,
                                ),
                              ),
                            )
                          : ListView.separated(
                              itemCount: _profiles.length,
                              separatorBuilder: (_, __) =>
                                  const SizedBox(height: 10),
                              itemBuilder: (context, index) {
                                final profile = _profiles[index];
                                final active = profile.id == _activeId;
                                return Material(
                                  color: AppTheme.background,
                                  borderRadius: BorderRadius.circular(12),
                                  child: ListTile(
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    leading: Icon(
                                      Icons.dns,
                                      color: active
                                          ? AppTheme.primary
                                          : AppTheme.textMedium,
                                    ),
                                    title: Text(
                                      profile.name,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                    subtitle: Text(
                                      '${profile.useHttps ? 'https' : 'http'}://${profile.displayHost}\n${ConnectionUrl.maskApiKey(profile.apiKey)}',
                                    ),
                                    isThreeLine: true,
                                    trailing: PopupMenuButton<String>(
                                      onSelected: (value) {
                                        if (value == 'edit') {
                                          unawaited(_edit(profile));
                                        } else if (value == 'delete') {
                                          unawaited(_delete(profile));
                                        } else if (value == 'connect') {
                                          unawaited(_connect(profile));
                                        }
                                      },
                                      itemBuilder: (context) => [
                                        PopupMenuItem(
                                          value: 'connect',
                                          child:
                                              Text(l10n.serverProfileConnect),
                                        ),
                                        PopupMenuItem(
                                          value: 'edit',
                                          child:
                                              Text(l10n.serverProfileEditTitle),
                                        ),
                                        PopupMenuItem(
                                          value: 'delete',
                                          child: Text(l10n.delete),
                                        ),
                                      ],
                                    ),
                                    onTap: _connecting
                                        ? null
                                        : () => unawaited(_connect(profile)),
                                  ),
                                );
                              },
                            ),
                    ),
            ),
          ),
          if (_connecting) const LinearProgressIndicator(minHeight: 2),
        ],
      ),
    );
  }
}
