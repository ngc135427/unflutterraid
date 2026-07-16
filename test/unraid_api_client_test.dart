import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:unflutterraid/services/unraid_api_client.dart';

void main() {
  group('UnraidFileManager File Browser API', () {
    test('derives File Browser base URL from the Unraid URL', () {
      final client = UnraidApiClient(
        baseUrl: 'http://tower.local',
        apiKey: 'api-key',
        httpClient: MockClient((request) async => http.Response('{}', 500)),
      );

      expect(client.fileBrowserBaseUrl, 'http://tower.local:8080');
    });

    test('listDirectory reads File Browser resources and maps app paths',
        () async {
      final client = UnraidApiClient(
        baseUrl: 'http://tower.local',
        apiKey: 'api-key',
        httpClient: MockClient((request) async {
          expect(request.method, 'GET');
          expect(request.url.scheme, 'http');
          expect(request.url.host, 'tower.local');
          expect(request.url.port, 8080);
          expect(request.url.path, '/api/resources/photos');

          return http.Response(
            jsonEncode({
              'name': 'photos',
              'path': '/photos',
              'isDir': true,
              'items': [
                {
                  'name': 'a.jpg',
                  'path': '/photos/a.jpg',
                  'isDir': false,
                  'size': 1024,
                  'modified': '2026-06-02T00:00:00Z',
                },
                {
                  'name': '2026',
                  'path': '/photos/2026',
                  'isDir': true,
                  'size': 0,
                  'modified': '2026-06-01T00:00:00Z',
                },
              ],
            }),
            200,
          );
        }),
      );

      final entries =
          await client.fileManager.listDirectory('/mnt/user/photos');

      expect(entries.map((entry) => entry.name), ['2026', 'a.jpg']);
      expect(entries.first.path, '/mnt/user/photos/2026');
      expect(entries.first.isDirectory, isTrue);
      expect(entries.last.path, '/mnt/user/photos/a.jpg');
      expect(entries.last.size, '1.0 KB');
    });

    test('listMedia uses recursive resources and filters media files',
        () async {
      final client = UnraidApiClient(
        baseUrl: 'http://tower.local',
        apiKey: 'api-key',
        httpClient: MockClient((request) async {
          expect(request.method, 'GET');
          expect(request.url.path, '/api/resources/recursive/photos');

          return http.Response(
            jsonEncode({
              'name': 'photos',
              'path': '/photos',
              'isDir': true,
              'items': [
                {
                  'name': '2026',
                  'path': '/photos/2026',
                  'isDir': true,
                  'items': [
                    {
                      'name': 'clip.mp4',
                      'path': '/photos/2026/clip.mp4',
                      'isDir': false,
                      'size': 2048,
                      'modified': '2026-06-03T00:00:00Z',
                    },
                    {
                      'name': 'note.txt',
                      'path': '/photos/2026/note.txt',
                      'isDir': false,
                      'size': 12,
                      'modified': '2026-06-04T00:00:00Z',
                    },
                  ],
                },
                {
                  'name': 'cover.jpg',
                  'path': '/photos/cover.jpg',
                  'isDir': false,
                  'size': 1024,
                  'modified': '2026-06-05T00:00:00Z',
                },
              ],
            }),
            200,
          );
        }),
      );

      final entries = await client.fileManager.listMedia('/mnt/user/photos');

      expect(entries.map((entry) => entry.name), ['cover.jpg', 'clip.mp4']);
      expect(entries.first.path, '/mnt/user/photos/cover.jpg');
      expect(entries.last.path, '/mnt/user/photos/2026/clip.mp4');
    });

    test('readFileBytes calls File Browser raw endpoint', () async {
      final client = UnraidApiClient(
        baseUrl: 'http://tower.local',
        apiKey: 'api-key',
        httpClient: MockClient((request) async {
          expect(request.method, 'GET');
          expect(request.url.path, '/api/raw/photos/a.jpg');
          return http.Response.bytes([1, 2, 3], 200);
        }),
      );

      expect(
        await client.fileManager.readFileBytes('/mnt/user/photos/a.jpg'),
        [1, 2, 3],
      );
    });

    test('readPreviewBytes calls File Browser preview endpoint', () async {
      final client = UnraidApiClient(
        baseUrl: 'http://tower.local',
        apiKey: 'api-key',
        httpClient: MockClient((request) async {
          expect(request.method, 'GET');
          expect(request.url.path, '/api/preview/thumb/photos/a.jpg');
          expect(request.url.queryParameters['inline'], 'true');
          return http.Response.bytes([9, 8, 7], 200);
        }),
      );

      expect(
        await client.fileManager.readPreviewBytes('/mnt/user/photos/a.jpg'),
        [9, 8, 7],
      );
    });

    test('auth failures explain anonymous or reverse proxy access', () async {
      final client = UnraidApiClient(
        baseUrl: 'http://tower.local',
        apiKey: 'api-key',
        httpClient: MockClient((request) async => http.Response('', 403)),
      );

      await expectLater(
        client.fileManager.listDirectory('/mnt/user/photos'),
        throwsA(
          isA<UnraidApiException>().having(
            (error) => error.message,
            'message',
            contains('匿名访问或反向代理认证'),
          ),
        ),
      );
    });
  });
}
