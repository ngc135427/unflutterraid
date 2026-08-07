import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:unflutterraid/l10n/generated/app_localizations.dart';
import 'package:unflutterraid/pages/main_shell_page.dart';
import 'package:unflutterraid/services/unraid_api_client.dart';

void main() {
  testWidgets('share cards hide raw tags and buttons but remain browsable',
      (tester) async {
    Uri? fileBrowserRequest;
    final dashboard = UnraidDashboard.fromJson({
      'shares': [
        {
          'id': 'appdata',
          'name': 'appdata',
          'status': 'ARRAY',
          'used': 165 * 1024 * 1024,
          'size': 0,
          'include': [],
          'exclude': [],
          'luksStatus': 0,
        },
      ],
    });
    final client = _FakeUnraidApiClient(
      dashboard: dashboard,
      httpClient: MockClient((request) async {
        fileBrowserRequest = request.url;
        return http.Response(
          jsonEncode({
            'name': 'appdata',
            'path': '/appdata',
            'isDir': true,
            'items': [],
          }),
          200,
        );
      }),
    );

    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('zh'),
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: AppLocalizations.supportedLocales,
        onGenerateRoute: (settings) {
          if (settings.name == ManagementDetailPage.routeName) {
            return MaterialPageRoute<void>(
              settings: settings,
              builder: (_) => const ManagementDetailPage(),
            );
          }
          return MaterialPageRoute<void>(
            settings: RouteSettings(
              name: settings.name,
              arguments: client,
            ),
            builder: (_) => const MainShellPage(),
          );
        },
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('共享'));
    await tester.pumpAndSettle();

    expect(find.text('appdata'), findsOneWidget);
    expect(find.text('include []'), findsNothing);
    expect(find.text('exclude []'), findsNothing);
    expect(find.text('0'), findsNothing);
    expect(find.text('浏览'), findsNothing);
    expect(find.text('设置'), findsNothing);

    await tester.tap(find.text('appdata'));
    await tester.pumpAndSettle();

    expect(find.byType(ManagementDetailPage), findsOneWidget);
    expect(fileBrowserRequest?.path, '/api/resources/appdata');
  });
}

class _FakeUnraidApiClient extends UnraidApiClient {
  _FakeUnraidApiClient({
    required this.dashboard,
    required super.httpClient,
  }) : super(baseUrl: 'http://tower.local', apiKey: 'api-key');

  final UnraidDashboard dashboard;

  @override
  Future<UnraidDashboard> fetchDashboard() async => dashboard;

  @override
  void close() {}
}
