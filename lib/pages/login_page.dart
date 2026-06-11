import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import '../widgets/app_text_field.dart';
import '../widgets/fade_slide.dart';
import '../widgets/gradient_button.dart';
import '../widgets/phone_frame.dart';
import 'main_shell_page.dart';
import 'register_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  static const routeName = '/login';

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _domainController = TextEditingController();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _rememberMe = false;
  bool _useHttps = false;
  bool _loginSucceeded = false;

  @override
  void dispose() {
    _domainController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _submit() {
    final isValid = _formKey.currentState?.validate() ?? false;
    if (!isValid) {
      return;
    }
    setState(() => _loginSucceeded = true);
    Future<void>.delayed(const Duration(milliseconds: 650), () {
      if (!mounted) {
        return;
      }
      Navigator.of(context).pushReplacementNamed(MainShellPage.routeName);
    });
  }

  @override
  Widget build(BuildContext context) {
    return PhoneFrame(
      maxContentWidth: 520,
      child: Column(
        children: [
          const _AuthHeader(
            title: '欢迎回来',
            subtitle: '请登录您的账号',
          ),
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
                      const Text(
                        '服务器地址',
                        style: TextStyle(
                          color: AppTheme.textMedium,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 8),
                      _ProtocolDomainField(
                        useHttps: _useHttps,
                        controller: _domainController,
                        onToggle: () => setState(() => _useHttps = !_useHttps),
                      ),
                      const SizedBox(height: 21),
                      AppTextField(
                        label: '用户名',
                        controller: _usernameController,
                        hint: '请输入用户名',
                        icon: Icons.person,
                        validator: (value) {
                          if ((value ?? '').trim().isEmpty) {
                            return '请输入有效的用户名';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 21),
                      AppTextField(
                        label: '密码',
                        controller: _passwordController,
                        hint: '请输入密码',
                        obscureText: true,
                        icon: Icons.lock,
                        validator: (value) {
                          if ((value ?? '').length < 6) {
                            return '密码不能少于 6 位';
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
                              setState(() => _rememberMe = value ?? false);
                            },
                          ),
                          const Text(
                            '记住我',
                            style: TextStyle(
                              color: AppTheme.textMedium,
                              fontSize: 14,
                            ),
                          ),
                          const Spacer(),
                          TextButton(
                            onPressed: () {},
                            child: const Text('忘记密码?'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      GradientButton(
                        label: _loginSucceeded ? '登录成功' : '登录',
                        icon: _loginSucceeded ? Icons.check : null,
                        isSuccess: _loginSucceeded,
                        onPressed: _loginSucceeded ? null : _submit,
                      ),
                      const SizedBox(height: 14),
                      Center(
                        child: TextButton(
                          onPressed: () {
                            Navigator.of(context).pushNamed(
                              RegisterPage.routeName,
                            );
                          },
                          child: const Text('创建新账号'),
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

class _ProtocolDomainField extends StatelessWidget {
  const _ProtocolDomainField({
    required this.useHttps,
    required this.controller,
    required this.onToggle,
  });

  final bool useHttps;
  final TextEditingController controller;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      validator: (value) {
        if ((value ?? '').trim().isEmpty) {
          return '请输入有效的 IP 地址或域名';
        }
        return null;
      },
      decoration: InputDecoration(
        hintText: '请输入 IP 地址或域名',
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
    required this.title,
    required this.subtitle,
  });

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 180,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 28,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              subtitle,
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
