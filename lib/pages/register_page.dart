import 'package:flutter/material.dart';

import '../l10n/generated/app_localizations.dart';

import '../widgets/app_text_field.dart';
import '../widgets/fade_slide.dart';
import '../widgets/gradient_button.dart';
import '../widgets/phone_frame.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  static const routeName = '/register';

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _registered = false;

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _submit() {
    final isValid = _formKey.currentState?.validate() ?? false;
    if (!isValid) {
      return;
    }
    setState(() => _registered = true);
    Future<void>.delayed(const Duration(milliseconds: 900), () {
      if (mounted) {
        Navigator.of(context).pop();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return PhoneFrame(
      maxContentWidth: 520,
      child: Column(
        children: [
          const _RegisterHeader(),
          Expanded(
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(30, 38, 30, 24),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
              ),
              child: FadeSlide(
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AppTextField(
                        label: l10n.registerUsernameLabel,
                        controller: _usernameController,
                        hint: l10n.registerUsernameHint,
                        icon: Icons.person,
                        validator: (value) {
                          if ((value ?? '').trim().isEmpty) {
                            return l10n.registerUsernameError;
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 21),
                      AppTextField(
                        label: l10n.registerPasswordLabel,
                        controller: _passwordController,
                        hint: l10n.registerPasswordHint,
                        obscureText: true,
                        icon: Icons.lock,
                        validator: (value) {
                          if ((value ?? '').length < 6) {
                            return l10n.registerPasswordError;
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 21),
                      AppTextField(
                        label: l10n.registerConfirmPasswordLabel,
                        controller: _confirmPasswordController,
                        hint: l10n.registerConfirmPasswordHint,
                        obscureText: true,
                        icon: Icons.lock,
                        validator: (value) {
                          if (value != _passwordController.text) {
                            return l10n.registerConfirmPasswordError;
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 28),
                      GradientButton(
                        label: _registered
                            ? l10n.registerSuccess
                            : l10n.registerButton,
                        icon: _registered ? Icons.check : null,
                        isSuccess: _registered,
                        onPressed: _registered ? null : _submit,
                      ),
                      const SizedBox(height: 22),
                      Center(
                        child: Wrap(
                          crossAxisAlignment: WrapCrossAlignment.center,
                          children: [
                            Text(l10n.alreadyHaveAccount),
                            TextButton(
                              onPressed: () => Navigator.of(context).pop(),
                              child: Text(l10n.backToLogin),
                            ),
                          ],
                        ),
                      ),
                    ],
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

class _RegisterHeader extends StatelessWidget {
  const _RegisterHeader();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return SizedBox(
      height: 180,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              l10n.createAccount,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 28,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              l10n.registerSubtitle,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.80),
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
