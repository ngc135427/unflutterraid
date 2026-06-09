import 'package:flutter/material.dart';

import 'pages/detail_page.dart';
import 'pages/login_page.dart';
import 'pages/main_shell_page.dart';
import 'pages/register_page.dart';
import 'theme/app_theme.dart';

void main() {
  runApp(const UnflutterRaidApp());
}

class UnflutterRaidApp extends StatelessWidget {
  const UnflutterRaidApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Unflutterraid',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      initialRoute: LoginPage.routeName,
      routes: {
        LoginPage.routeName: (_) => const LoginPage(),
        RegisterPage.routeName: (_) => const RegisterPage(),
        MainShellPage.routeName: (_) => const MainShellPage(),
        DetailPage.routeName: (_) => const DetailPage(),
      },
    );
  }
}
