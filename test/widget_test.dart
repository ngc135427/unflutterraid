import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:unflutterraid/main.dart';
import 'package:unflutterraid/services/login_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const channel = MethodChannel(LoginPreferences.channelName);

  setUp(() {
    SharedPreferences.setMockInitialValues({'app_language': 'zh'});
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (call) async {
      if (call.method == 'load') {
        return {
          'rememberMe': false,
          'domain': '',
          'apiKey': '',
          'useHttps': false,
        };
      }
      if (call.method == 'save') {
        return null;
      }
      throw MissingPluginException();
    });
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, null);
  });

  testWidgets('shows the login screen', (tester) async {
    await tester.pumpWidget(const UnflutterRaidApp());
    await tester.pumpAndSettle();

    expect(find.text('欢迎回来'), findsNothing);
    expect(find.text('服务器地址'), findsOneWidget);
    expect(find.text('API 密钥'), findsOneWidget);
    expect(find.text('WebGUI 用户名'), findsNothing);
    expect(find.text('WebGUI 密码'), findsNothing);
    expect(find.text('登录'), findsOneWidget);
  });

  testWidgets('switches login copy to English from language dropdown',
      (tester) async {
    await tester.pumpWidget(const UnflutterRaidApp());
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.language));
    await tester.pumpAndSettle();
    await tester.tap(find.text('English'));
    await tester.pumpAndSettle();

    expect(find.text('Server address'), findsOneWidget);
    expect(find.text('API key'), findsOneWidget);
    expect(find.text('Sign in'), findsOneWidget);
  });

  testWidgets('restores remembered login fields', (tester) async {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (call) async {
      if (call.method == 'load') {
        return {
          'rememberMe': true,
          'domain': 'tower.local',
          'apiKey': 'saved-api-key',
          'useHttps': true,
        };
      }
      if (call.method == 'save') {
        return null;
      }
      throw MissingPluginException();
    });

    await tester.pumpWidget(const UnflutterRaidApp());
    await tester.pumpAndSettle();

    final fields =
        tester.widgetList<TextFormField>(find.byType(TextFormField)).toList();
    expect(fields[0].controller?.text, 'tower.local');
    expect(fields[1].controller?.text, 'saved-api-key');
    expect(fields, hasLength(2));
    expect(tester.widget<Checkbox>(find.byType(Checkbox)).value, isTrue);
    expect(find.text('https://'), findsOneWidget);
  });
}
