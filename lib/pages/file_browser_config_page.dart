import 'package:flutter/material.dart';

import '../l10n/generated/app_localizations.dart';
import '../services/file_browser_preferences.dart';
import '../services/unraid_api_client.dart';
import '../theme/app_theme.dart';
import '../widgets/fade_slide.dart';
import '../widgets/gradient_button.dart';
import '../widgets/phone_frame.dart';
import 'main_shell_page.dart';

class FileBrowserConfigPageArgs {
  const FileBrowserConfigPageArgs({required this.apiClient});

  final UnraidApiClient apiClient;
}

class FileBrowserConfigPage extends StatefulWidget {
  const FileBrowserConfigPage({super.key});

  static const routeName = '/settings/file-browser';

  @override
  State<FileBrowserConfigPage> createState() => _FileBrowserConfigPageState();
}

class _FileBrowserConfigPageState extends State<FileBrowserConfigPage> {
  final _formKey = GlobalKey<FormState>();
  final _urlController = TextEditingController();

  UnraidApiClient? _sessionClient;
  String _defaultUrl = '';
  bool _loading = true;
  bool _submitting = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _bootstrap());
  }

  @override
  void dispose() {
    _urlController.dispose();
    super.dispose();
  }

  Future<void> _bootstrap() async {
    final args = ModalRoute.of(context)?.settings.arguments;
    final pageArgs = args is FileBrowserConfigPageArgs ? args : null;
    final client = pageArgs?.apiClient;
    if (client == null) {
      if (!mounted) {
        return;
      }
      setState(() {
        _errorMessage = AppLocalizations.of(context).missingConnection;
        _loading = false;
      });
      return;
    }
    _sessionClient = client;
    _defaultUrl = UnraidApiClient.deriveFileBrowserBaseUrl(client.baseUrl);
    final override = await FileBrowserPreferences.loadOverride(client.baseUrl);
    if (!mounted) {
      return;
    }
    setState(() {
      _urlController.text = override ?? _defaultUrl;
      _loading = false;
    });
  }

  void _restoreDefault() {
    setState(() {
      _urlController.text = _defaultUrl;
      _errorMessage = null;
    });
  }

  Future<void> _saveAndApply() async {
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }
    final sessionClient = _sessionClient;
    if (sessionClient == null) {
      return;
    }
    final l10n = AppLocalizations.of(context);
    final raw = _urlController.text.trim();
    final normalized = raw.isEmpty
        ? _defaultUrl
        : FileBrowserPreferences.normalizeHttpUrl(raw);
    if (normalized == null) {
      setState(() => _errorMessage = l10n.fileBrowserUrlInvalid);
      return;
    }
    final override = normalized == _defaultUrl ? null : normalized;
    final replacementClient = UnraidApiClient(
      baseUrl: sessionClient.baseUrl,
      apiKey: sessionClient.apiKey,
      fileBrowserBaseUrl: override,
    );
    setState(() {
      _submitting = true;
      _errorMessage = null;
    });

    try {
      await replacementClient.fileManager.listRoot();
      await FileBrowserPreferences.saveOverride(
        unraidBaseUrl: sessionClient.baseUrl,
        fileBrowserBaseUrl: override,
      );
      if (!mounted) {
        replacementClient.close();
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.fileBrowserSaveSuccess)),
      );
      await Future<void>.delayed(const Duration(milliseconds: 300));
      if (!mounted) {
        replacementClient.close();
        return;
      }
      Navigator.of(context).pushNamedAndRemoveUntil(
        MainShellPage.routeName,
        (route) => false,
        arguments: replacementClient,
      );
    } on UnraidApiException catch (error) {
      replacementClient.close();
      if (!mounted) {
        return;
      }
      setState(() {
        _errorMessage = error.message;
        _submitting = false;
      });
    } catch (error) {
      replacementClient.close();
      if (!mounted) {
        return;
      }
      setState(() {
        _errorMessage = l10n.loadFailed(error.toString());
        _submitting = false;
      });
    }
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
              padding: const EdgeInsets.fromLTRB(12, 12, 12, 8),
              child: Row(
                children: [
                  IconButton(
                    tooltip: l10n.back,
                    onPressed: _submitting
                        ? null
                        : () => Navigator.of(context).maybePop(),
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                  ),
                  Expanded(
                    child: Text(
                      l10n.fileBrowserConfigTitle,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  const SizedBox(width: 48),
                ],
              ),
            ),
          ),
          Expanded(
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(24, 22, 24, 24),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
              ),
              child: _loading
                  ? const Center(child: CircularProgressIndicator())
                  : FadeSlide(
                      child: Form(
                        key: _formKey,
                        child: SingleChildScrollView(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                l10n.fileBrowserUrlLabel,
                                style: const TextStyle(
                                  color: AppTheme.textDark,
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(height: 8),
                              TextFormField(
                                controller: _urlController,
                                enabled: !_submitting,
                                keyboardType: TextInputType.url,
                                autocorrect: false,
                                decoration: InputDecoration(
                                  hintText: l10n.fileBrowserUrlHint,
                                  prefixIcon: const Icon(Icons.cloud_outlined),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                validator: (value) {
                                  final text = (value ?? '').trim();
                                  if (text.isEmpty) {
                                    return null;
                                  }
                                  return FileBrowserPreferences
                                              .normalizeHttpUrl(
                                            text,
                                          ) ==
                                          null
                                      ? l10n.fileBrowserUrlInvalid
                                      : null;
                                },
                              ),
                              const SizedBox(height: 10),
                              Text(
                                l10n.fileBrowserUrlHelp,
                                style: const TextStyle(
                                  color: AppTheme.textMedium,
                                  fontSize: 13,
                                  height: 1.45,
                                ),
                              ),
                              const SizedBox(height: 12),
                              SizedBox(
                                width: double.infinity,
                                child: OutlinedButton.icon(
                                  onPressed:
                                      _submitting ? null : _restoreDefault,
                                  icon: const Icon(Icons.restore),
                                  label: Text(l10n.fileBrowserUseDefault),
                                ),
                              ),
                              if (_errorMessage != null) ...[
                                const SizedBox(height: 12),
                                Text(
                                  _errorMessage!,
                                  style: const TextStyle(
                                    color: AppTheme.danger,
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                              const SizedBox(height: 18),
                              GradientButton(
                                label: _submitting
                                    ? l10n.fileBrowserChecking
                                    : l10n.fileBrowserSaveApply,
                                onPressed: _submitting ? null : _saveAndApply,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
