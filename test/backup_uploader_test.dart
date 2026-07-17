import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:unflutterraid/services/backup_preferences.dart';
import 'package:unflutterraid/services/backup_uploader.dart';
import 'package:unflutterraid/services/local_photo_source.dart';
import 'package:unflutterraid/services/unraid_api_client.dart';

void main() {
  group('BackupLastSync', () {
    test('encodes and parses summary', () {
      final original = BackupLastSync(
        at: DateTime.utc(2026, 7, 17, 8, 30),
        success: 3,
        failed: 1,
        skipped: 2,
      );
      final parsed = BackupLastSync.tryParse(
        atIso: original.at.toIso8601String(),
        summary: original.encodeSummary(),
      );
      expect(parsed, isNotNull);
      expect(parsed!.success, 3);
      expect(parsed.failed, 1);
      expect(parsed.skipped, 2);
    });
  });

  group('BackupUploader', () {
    test('uploads new files and skips existing names', () async {
      final uploaded = <String>[];
      final client = UnraidApiClient(
        baseUrl: 'http://tower.local',
        apiKey: 'api-key',
        httpClient: MockClient((request) async {
          if (request.method == 'GET' &&
              request.url.path == '/api/resources/photos/mobile') {
            return http.Response(
              jsonEncode({
                'name': 'mobile',
                'path': '/photos/mobile',
                'isDir': true,
                'items': [
                  {
                    'name': 'exists.jpg',
                    'path': '/photos/mobile/exists.jpg',
                    'isDir': false,
                    'size': 10,
                  },
                ],
              }),
              200,
            );
          }
          if (request.method == 'POST') {
            uploaded.add(request.url.path);
            return http.Response('', 201);
          }
          return http.Response(
              'unexpected ${request.method} ${request.url}', 500);
        }),
      );

      final photos = [
        LocalPhotoItem(
          id: '1',
          fileName: 'exists.jpg',
          readBytes: () async => Uint8List.fromList([1]),
        ),
        LocalPhotoItem(
          id: '2',
          fileName: 'new.jpg',
          readBytes: () async => Uint8List.fromList([2, 3]),
        ),
      ];

      final result = await const BackupUploader().run(
        fileManager: client.fileManager,
        targetDir: '/mnt/user/photos/mobile',
        photos: photos,
        isCancelled: () => false,
      );

      expect(result.success, 1);
      expect(result.skipped, 1);
      expect(result.failed, 0);
      expect(uploaded, ['/api/resources/photos/mobile/new.jpg']);
    });

    test('uploadBytes posts raw body to File Browser', () async {
      List<int>? body;
      final client = UnraidApiClient(
        baseUrl: 'http://tower.local',
        apiKey: 'api-key',
        httpClient: MockClient((request) async {
          expect(request.method, 'POST');
          expect(request.url.path, '/api/resources/photos/mobile/a.jpg');
          body = request.bodyBytes;
          return http.Response('', 201);
        }),
      );

      await client.fileManager.uploadBytes(
        directoryPath: '/mnt/user/photos/mobile',
        fileName: 'a.jpg',
        bytes: [9, 8, 7],
      );
      expect(body, [9, 8, 7]);
    });

    test('stops scheduling further uploads when cancelled', () async {
      var posts = 0;
      final client = UnraidApiClient(
        baseUrl: 'http://tower.local',
        apiKey: 'api-key',
        httpClient: MockClient((request) async {
          if (request.method == 'GET') {
            return http.Response(
              jsonEncode({
                'name': 'mobile',
                'path': '/photos/mobile',
                'isDir': true,
                'items': <Object>[],
              }),
              200,
            );
          }
          posts += 1;
          return http.Response('', 201);
        }),
      );

      var cancelAfterFirstProgress = false;
      final photos = List.generate(
        3,
        (index) => LocalPhotoItem(
          id: '$index',
          fileName: 'p$index.jpg',
          readBytes: () async => Uint8List.fromList([index]),
        ),
      );

      final result = await const BackupUploader().run(
        fileManager: client.fileManager,
        targetDir: '/mnt/user/photos/mobile',
        photos: photos,
        isCancelled: () => cancelAfterFirstProgress,
        onProgress: (done, total, name) {
          if (done >= 1) {
            cancelAfterFirstProgress = true;
          }
        },
      );

      expect(result.cancelled, isTrue);
      expect(posts, lessThan(3));
      expect(result.success + result.failed + result.skipped, lessThan(3));
    });
  });
}
