import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:unflutterraid/l10n/generated/app_localizations.dart';
import 'package:unflutterraid/pages/share_file_preview_page.dart';
import 'package:unflutterraid/services/display_copy.dart';
import 'package:unflutterraid/services/unraid_api_client.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('previews text and navigates between previewable files',
      (tester) async {
    final client = UnraidApiClient(
      baseUrl: 'http://tower.local',
      apiKey: 'api-key',
      httpClient: MockClient((request) async {
        final content = switch (request.url.path) {
          '/api/raw/notes/first.txt' => 'first file contents',
          '/api/raw/notes/second.log' => 'second file contents',
          _ => throw StateError('Unexpected request: ${request.url}'),
        };
        return http.Response.bytes(utf8.encode(content), 200);
      }),
    );
    addTearDown(client.close);

    await tester.pumpWidget(
      _localizedApp(
        ShareFilePreviewPage(
          client: client,
          entries: const [
            UnraidFileEntry(
              name: 'first.txt',
              path: '/mnt/user/notes/first.txt',
              isDirectory: false,
              size: '19 B',
              modified: '',
              byteSize: 19,
            ),
            UnraidFileEntry(
              name: 'second.log',
              path: '/mnt/user/notes/second.log',
              isDirectory: false,
              size: '20 B',
              modified: '',
              byteSize: 20,
            ),
          ],
          initialIndex: 0,
        ),
      ),
    );
    await tester.pump();
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 10)),
    );
    await tester.pump();

    expect(find.text('first.txt'), findsOneWidget);
    expect(find.text('1 / 2'), findsOneWidget);
    expect(_selectableText('first file contents'), findsOneWidget);

    await tester.tap(find.byTooltip('下一个文件'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 10)),
    );
    await tester.pump();

    expect(find.text('second.log'), findsOneWidget);
    expect(find.text('2 / 2'), findsOneWidget);
    expect(_selectableText('second file contents'), findsOneWidget);
  });

  testWidgets('rejects oversized text before starting a download',
      (tester) async {
    var requestCount = 0;
    final client = UnraidApiClient(
      baseUrl: 'http://tower.local',
      apiKey: 'api-key',
      httpClient: MockClient((request) async {
        requestCount += 1;
        return http.Response('must not be requested', 200);
      }),
    );
    addTearDown(client.close);

    await tester.pumpWidget(
      _localizedApp(
        ShareFilePreviewPage(
          client: client,
          entries: const [
            UnraidFileEntry(
              name: 'huge.log',
              path: '/mnt/user/logs/huge.log',
              isDirectory: false,
              size: '3 MB',
              modified: '',
              byteSize: 3 * 1024 * 1024,
            ),
          ],
          initialIndex: 0,
        ),
      ),
    );
    await tester.pump();

    expect(find.textContaining('文件超过预览上限 2 MB'), findsOneWidget);
    expect(requestCount, 0);
  });
}

Widget _localizedApp(Widget home) {
  return MaterialApp(
    locale: const Locale('zh'),
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    builder: (context, child) {
      DisplayCopy.fromL10n(AppLocalizations.of(context)).activate();
      return child ?? const SizedBox.shrink();
    },
    home: home,
  );
}

Finder _selectableText(String value) {
  return find.byWidgetPredicate(
    (widget) => widget is SelectableText && widget.data == value,
  );
}
