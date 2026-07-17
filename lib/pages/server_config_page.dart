import 'package:flutter/material.dart';

import '../l10n/generated/app_localizations.dart';
import '../services/connection_url.dart';
import '../services/login_preferences.dart';
import '../services/unraid_api_client.dart';
import '../theme/app_theme.dart';
import '../widgets/app_text_field.dart';
import '../widgets/fade_slide.dart';
import '../widgets/gradient_button.dart';
import '../widgets/phone_frame.dart';
import 'login_page.dart';
import 'main_shell_page.dart';

class ServerConfigPageArgs {
  const ServerConfigPageArgs({this.apiClient});

  final UnraidApiClient? apiClient;
}

class ServerConfigPage extends StatefulWidget {
  const ServerConfigPage({super.key});

  static const routeName = '/settings/server';

  @override
  State<ServerConfigPage> createState() => _ServerConfigPageState();
}

class _ServerConfigPageState extends State<ServerConfigPage> {
  final _formKey = GlobalKey<FormState>();
  final _domainController = TextEditingController();
  final _apiKeyController = TextEditingController();

  bool _useHttps = false;
  bool _rememberMe = true;
  bool _showApiKey = false;
  bool _loadingPrefs = true;
  bool _isSubmitting = false;
  String? _errorMessage;
  UnraidApiClient? _sessionClient;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _bootstrap());
  }

  @override
  void dispose() {
    _domainController.dispose();
    _apiKeyController.dispose();
    super.dispose();
  }

  Future<void> _bootstrap() async {
    final args = ModalRoute.of(context)?.settings.arguments;
    final pageArgs = args is ServerConfigPageArgs ? args : null;
    _sessionClient = pageArgs?.apiClient;

    final remembered = await LoginPreferences.load();
    if (!mounted) {
      return;
    }

    final client = _sessionClient;
    if (client != null) {
      final parsed = ConnectionUrl.parse(client.baseUrl);
      setState(() {
        _domainController.text = parsed.domain;
        _apiKeyController.text = client.apiKey;
        _useHttps = parsed.useHttps;
        _rememberMe = remembered.rememberMe;
        _loadingPrefs = false;
      });
      return;
    }

    setState(() {
      if (remembered.rememberMe) {
        _domainController.text = remembered.domain;
        _apiKeyController.text = remembered.apiKey;
        _useHttps = remembered.useHttps;
        _rememberMe = true;
      }
      _loadingPrefs = false;
    });
  }

  Future<void> _saveAndReconnect() async {
    final valid = _formKey.currentState?.validate() ?? false;
    if (!valid) {
      return;
    }
    final l10n = AppLocalizations.of(context);
    final baseUrl = ConnectionUrl.buildBaseUrl(
      domain: _domainController.text,
      useHttps: _useHttps,
    );
    final client = UnraidApiClient(
      baseUrl: baseUrl,
      apiKey: _apiKeyController.text.trim(),
    );

    setState(() {
      _isSubmitting = true;
      _errorMessage = null;
    });

    try {
      await client.checkConnection();
      await LoginPreferences.save(
        rememberMe: _rememberMe,
        domain: _domainController.text.trim(),
        apiKey: _apiKeyController.text.trim(),
        useHttps: _useHttps,
      );
      if (!mounted) {
        client.close();
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.serverConfigReconnectSuccess)),
      );
      Navigator.of(context).pushNamedAndRemoveUntil(
        MainShellPage.routeName,
        (route) => false,
        arguments: client,
      );
    } on UnraidApiException catch (error) {
      client.close();
      if (!mounted) {
        return;
      }
      setState(() {
        _errorMessage = error.message;
        _isSubmitting = false;
      });
    } catch (error) {
      client.close();
      if (!mounted) {
        return;
      }
      setState(() {
        _errorMessage = l10n.loginFailed(error.toString());
        _isSubmitting = false;
      });
    }
  }

  void _disconnect() {
    final l10n = AppLocalizations.of(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(l10n.serverConfigDisconnected)),
    );
    Navigator.of(context).pushNamedAndRemoveUntil(
      LoginPage.routeName,
      (route) => false,
    );
  }

  Future<void> _clearSaved() async {
    await LoginPreferences.save(
      rememberMe: false,
      domain: '',
      apiKey: '',
      useHttps: false,
    );
    if (!mounted) {
      return;
    }
    setState(() {
      _rememberMe = false;
      if (_sessionClient == null) {
        _domainController.clear();
        _apiKeyController.clear();
        _useHttps = false;
      }
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(AppLocalizations.of(context).serverConfigCleared)),
    );
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
                    onPressed: () => Navigator.of(context).maybePop(),
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                  ),
                  Expanded(
                    child: Text(
                      l10n.serverConfigTitle,
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
              child: _loadingPrefs
                  ? const Center(child: CircularProgressIndicator())
                  : FadeSlide(
                      child: Form(
                        key: _formKey,
                        child: SingleChildScrollView(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (_sessionClient == null)
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 16),
                                  child: Text(
                                    l10n.serverConfigNoSessionHint,
                                    style: const TextStyle(
                                      color: AppTheme.textMedium,
                                      fontSize: 13,
                                      height: 1.4,
                                    ),
                                  ),
                                ),
                              Text(
                                l10n.loginServerAddress,
                                style: const TextStyle(
                                  color: AppTheme.textMedium,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 8),
                              _ProtocolField(
                                useHttps: _useHttps,
                                controller: _domainController,
                                onToggle: () =>
                                    setState(() => _useHttps = !_useHttps),
                              ),
                              const SizedBox(height: 18),
                              AppTextField(
                                label: l10n.loginApiKey,
                                controller: _apiKeyController,
                                hint: l10n.loginApiKeyHint,
                                obscureText: !_showApiKey,
                                suffixIcon: IconButton(
                                  tooltip: _showApiKey
                                      ? l10n.hideApiKey
                                      : l10n.showApiKey,
                                  onPressed: () {
                                    setState(() => _showApiKey = !_showApiKey);
                                  },
                                  icon: Icon(
                                    _showApiKey
                                        ? Icons.visibility_off
                                        : Icons.visibility,
                                    color: const Color(0xFFA0A8B9),
                                  ),
                                ),
                                validator: (value) {
                                  if ((value ?? '').trim().isEmpty) {
                                    return l10n.loginApiKeyError;
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 12),
                              Row(
                                children: [
                                  Checkbox(
                                    value: _rememberMe,
                                    activeColor: AppTheme.secondary,
                                    visualDensity: VisualDensity.compact,
                                    onChanged: (value) {
                                      setState(
                                        () => _rememberMe = value ?? false,
                                      );
                                    },
                                  ),
                                  Text(
                                    l10n.loginRememberMe,
                                    style: const TextStyle(
                                      color: AppTheme.textMedium,
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                              if (_errorMessage != null) ...[
                                const SizedBox(height: 8),
                                Text(
                                  _errorMessage!,
                                  style: const TextStyle(
                                    color: AppTheme.danger,
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                              const SizedBox(height: 16),
                              GradientButton(
                                label: _isSubmitting
                                    ? l10n.serverConfigReconnecting
                                    : l10n.serverConfigSaveReconnect,
                                onPressed:
                                    _isSubmitting ? null : _saveAndReconnect,
                              ),
                              if (_sessionClient != null) ...[
                                const SizedBox(height: 12),
                                SizedBox(
                                  width: double.infinity,
                                  child: OutlinedButton.icon(
                                    onPressed:
                                        _isSubmitting ? null : _disconnect,
                                    icon: const Icon(Icons.link_off),
                                    label: Text(l10n.serverConfigDisconnect),
                                  ),
                                ),
                              ],
                              const SizedBox(height: 8),
                              SizedBox(
                                width: double.infinity,
                                child: TextButton(
                                  onPressed: _isSubmitting ? null : _clearSaved,
                                  child: Text(l10n.serverConfigClearSaved),
                                ),
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

class _ProtocolField extends StatelessWidget {
  const _ProtocolField({
    required this.useHttps,
    required this.controller,
    required this.onToggle,
  });

  final bool useHttps;
  final TextEditingController controller;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return TextFormField(
      controller: controller,
      validator: (value) {
        if ((value ?? '').trim().isEmpty) {
          return l10n.loginServerAddressError;
        }
        return null;
      },
      decoration: InputDecoration(
        hintText: l10n.loginServerAddressHint,
        prefixIconConstraints: const BoxConstraints(
          minWidth: 102,
          minHeight: 24,
        ),
        prefixIcon: Padding(
          padding: const EdgeInsets.only(left: 15, right: 10),
          child: InkWell(
            borderRadius: BorderRadius.circular(8),
            onTap: onToggle,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  useHttps ? 'https://' : 'http://',
                  style: const TextStyle(
                    color: AppTheme.textMedium,
                    fontSize: 15,
                  ),
                ),
                const Icon(Icons.swap_horiz, size: 16, color: AppTheme.primary),
              ],
            ),
          ),
        ),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppTheme.softLine),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppTheme.primary),
        ),
      ),
    );
  }
}
