import 'package:flutter_test/flutter_test.dart';
import 'package:unflutterraid/main.dart';

void main() {
  testWidgets('shows the login screen', (tester) async {
    await tester.pumpWidget(const UnflutterRaidApp());

    expect(find.text('欢迎回来'), findsNothing);
    expect(find.text('服务器地址'), findsOneWidget);
    expect(find.text('API 密钥'), findsOneWidget);
    expect(find.text('用户名'), findsNothing);
    expect(find.text('密码'), findsNothing);
    expect(find.text('登录'), findsOneWidget);
  });
}
