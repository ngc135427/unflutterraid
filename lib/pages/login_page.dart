import 'package:flutter/material.dart';

import '../app_language_scope.dart';
import '../l10n/generated/app_localizations.dart';
import '../l10n/language_names.dart';
import '../services/connection_url.dart';
import '../services/language_preferences.dart';
import '../services/login_preferences.dart';
import '../services/unraid_api_client.dart';
import '../theme/app_theme.dart';
import '../widgets/app_text_field.dart';
import '../widgets/fade_slide.dart';
import '../widgets/gradient_button.dart';
import '../widgets/phone_frame.dart';
import 'main_shell_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  static const routeName = '/login';

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _domainController = TextEditingController();
  final _apiKeyController = TextEditingController();
  final _domainFocusNode = FocusNode();
  final _apiKeyFocusNode = FocusNode();

  bool _rememberMe = false;
  bool _useHttps = false;
  bool _loginSucceeded = false;
  bool _hasInputFocus = false;
  bool _isSubmitting = false;
  bool _showApiKey = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _domainFocusNode.addListener(_handleFocusChange);
    _apiKeyFocusNode.addListener(_handleFocusChange);
    _loadRememberedLogin();
  }

  @override
  void dispose() {
    _domainFocusNode.removeListener(_handleFocusChange);
    _apiKeyFocusNode.removeListener(_handleFocusChange);
    _domainFocusNode.dispose();
    _apiKeyFocusNode.dispose();
    _domainController.dispose();
    _apiKeyController.dispose();
    super.dispose();
  }

  void _handleFocusChange() {
    final hasFocus = _domainFocusNode.hasFocus || _apiKeyFocusNode.hasFocus;
    if (_hasInputFocus == hasFocus) {
      return;
    }
    setState(() => _hasInputFocus = hasFocus);
  }

  Future<void> _submit() async {
    final isValid = _formKey.currentState?.validate() ?? false;
    if (!isValid) {
      return;
    }

    final l10n = AppLocalizations.of(context);
    final client = UnraidApiClient(
      baseUrl: _buildBaseUrl(),
      apiKey: _apiKeyController.text,
    );

    setState(() {
      _isSubmitting = true;
      _errorMessage = null;
    });

    try {
      await client.checkConnection();
      await _saveRememberedLogin();
      if (!mounted) {
        return;
      }
      setState(() => _loginSucceeded = true);
      await Future<void>.delayed(const Duration(milliseconds: 450));
      if (!mounted) {
        return;
      }
      Navigator.of(context).pushReplacementNamed(
        MainShellPage.routeName,
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
    } on Object catch (error) {
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

  Future<void> _loadRememberedLogin() async {
    final rememberedLogin = await LoginPreferences.load();
    if (!mounted) {
      return;
    }

    setState(() {
      _rememberMe = rememberedLogin.rememberMe;
      if (rememberedLogin.rememberMe) {
        _domainController.text = rememberedLogin.domain;
        _apiKeyController.text = rememberedLogin.apiKey;
        _useHttps = rememberedLogin.useHttps;
      }
    });
  }

  Future<void> _saveRememberedLogin() async {
    await LoginPreferences.save(
      rememberMe: _rememberMe,
      domain: _domainController.text.trim(),
      apiKey: _apiKeyController.text.trim(),
      useHttps: _useHttps,
    );
  }

  String _buildBaseUrl() {
    return ConnectionUrl.buildBaseUrl(
      domain: _domainController.text,
      useHttps: _useHttps,
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return PhoneFrame(
      maxContentWidth: 520,
      child: Stack(
        children: [
          Column(
            children: [
              _AuthHeader(compact: _hasInputFocus),
              Expanded(
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.fromLTRB(30, 38, 30, 24),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius:
                        BorderRadius.vertical(top: Radius.circular(25)),
                  ),
                  child: FadeSlide(
                    child: Form(
                      key: _formKey,
                      child: SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              l10n.loginServerAddress,
                              style: const TextStyle(
                                color: AppTheme.textMedium,
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 8),
                            _ProtocolDomainField(
                              useHttps: _useHttps,
                              controller: _domainController,
                              focusNode: _domainFocusNode,
                              onToggle: () =>
                                  setState(() => _useHttps = !_useHttps),
                            ),
                            const SizedBox(height: 21),
                            AppTextField(
                              label: l10n.loginApiKey,
                              controller: _apiKeyController,
                              focusNode: _apiKeyFocusNode,
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
                            const SizedBox(height: 18),
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
                                const Spacer(),
                                const Icon(
                                  Icons.key,
                                  color: AppTheme.textLight,
                                  size: 18,
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            if (_errorMessage != null) ...[
                              Text(
                                _errorMessage!,
                                style: const TextStyle(
                                  color: AppTheme.danger,
                                  fontSize: 13,
                                ),
                              ),
                              const SizedBox(height: 12),
                            ],
                            GradientButton(
                              label: _loginSucceeded
                                  ? l10n.loginSuccess
                                  : _isSubmitting
                                      ? l10n.loginConnecting
                                      : l10n.loginButton,
                              icon: _loginSucceeded ? Icons.check : null,
                              isSuccess: _loginSucceeded,
                              onPressed: _loginSucceeded || _isSubmitting
                                  ? null
                                  : _submit,
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
          const Positioned(
            top: 22,
            right: 22,
            child: _LoginLanguageDropdown(),
          ),
        ],
      ),
    );
  }
}

class _LoginLanguageDropdown extends StatelessWidget {
  const _LoginLanguageDropdown();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final scope = AppLanguageScope.of(context);

    return PopupMenuButton<AppLanguage>(
      tooltip: l10n.languageSettingTitle,
      initialValue: scope.language,
      onSelected: scope.onLanguageChanged,
      position: PopupMenuPosition.under,
      itemBuilder: (context) => [
        for (final language in AppLanguage.values)
          PopupMenuItem(
            value: language,
            child: Row(
              children: [
                Expanded(child: Text(language.label(l10n))),
                if (language == scope.language)
                  const Icon(Icons.check, size: 16, color: AppTheme.primary),
              ],
            ),
          ),
      ],
      child: Container(
        height: 34,
        padding: const EdgeInsets.symmetric(horizontal: 10),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.16),
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: Colors.white.withValues(alpha: 0.20)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.language, color: Colors.white, size: 16),
            const SizedBox(width: 4),
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 92),
              child: Text(
                scope.language.label(l10n),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(width: 2),
            const Icon(Icons.arrow_drop_down, color: Colors.white, size: 16),
          ],
        ),
      ),
    );
  }
}

class _ProtocolDomainField extends StatelessWidget {
  const _ProtocolDomainField({
    required this.useHttps,
    required this.controller,
    required this.focusNode,
    required this.onToggle,
  });

  final bool useHttps;
  final TextEditingController controller;
  final FocusNode focusNode;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return TextFormField(
      controller: controller,
      focusNode: focusNode,
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
                const SizedBox(width: 2),
                const Icon(
                  Icons.arrow_drop_down,
                  color: AppTheme.textMedium,
                  size: 18,
                ),
                const SizedBox(width: 10),
                Container(width: 1, height: 22, color: AppTheme.line),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _AuthHeader extends StatelessWidget {
  const _AuthHeader({
    required this.compact,
  });

  final bool compact;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 240),
      curve: Curves.easeOutCubic,
      height: compact ? 108 : 180,
      child: Center(
        child: AnimatedScale(
          duration: const Duration(milliseconds: 240),
          curve: Curves.easeOutCubic,
          scale: compact ? 0.74 : 1,
          child: const _UnraidMark(),
        ),
      ),
    );
  }
}

class _UnraidMark extends StatelessWidget {
  const _UnraidMark();

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Unraid',
      child: Container(
        width: 96,
        height: 96,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.14),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.24),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.10),
              blurRadius: 24,
              offset: const Offset(0, 12),
            ),
          ],
        ),
        child: CustomPaint(
          painter: _UnraidMarkPainter(),
        ),
      ),
    );
  }
}

class _UnraidMarkPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final barPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    final orangePaint = Paint()
      ..color = const Color(0xFFFF8A00)
      ..style = PaintingStyle.fill;

    void drawBar(double x, double y, double width, double height) {
      final radius = Radius.circular(height / 2);
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(center: Offset(x, y), width: width, height: height),
          radius,
        ),
        barPaint,
      );
    }

    void drawDot(double x, double y, double radius) {
      canvas.drawCircle(Offset(x, y), radius, orangePaint);
    }

    drawBar(center.dx, center.dy - 22, size.width * 0.46, 8);
    drawBar(center.dx, center.dy, size.width * 0.62, 8);
    drawBar(center.dx, center.dy + 22, size.width * 0.46, 8);

    drawDot(center.dx - 33, center.dy - 22, 5);
    drawDot(center.dx + 33, center.dy - 22, 5);
    drawDot(center.dx - 39, center.dy, 5);
    drawDot(center.dx + 39, center.dy, 5);
    drawDot(center.dx - 33, center.dy + 22, 5);
    drawDot(center.dx + 33, center.dy + 22, 5);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}
