import 'package:flutter_test/flutter_test.dart';
import 'package:unflutterraid/services/connection_url.dart';

void main() {
  group('ConnectionUrl', () {
    test('buildBaseUrl prefixes scheme', () {
      expect(
        ConnectionUrl.buildBaseUrl(domain: 'tower.local', useHttps: false),
        'http://tower.local',
      );
      expect(
        ConnectionUrl.buildBaseUrl(domain: 'tower.local', useHttps: true),
        'https://tower.local',
      );
    });

    test('buildBaseUrl keeps explicit scheme', () {
      expect(
        ConnectionUrl.buildBaseUrl(
          domain: 'https://tower.local:8443',
          useHttps: false,
        ),
        'https://tower.local:8443',
      );
    });

    test('parse extracts host and https', () {
      final parsed = ConnectionUrl.parse('https://tower.local:8443');
      expect(parsed.domain, 'tower.local:8443');
      expect(parsed.useHttps, isTrue);
    });

    test('maskApiKey hides secret tail', () {
      expect(ConnectionUrl.maskApiKey('abcd1234'), 'abcd••••');
      expect(ConnectionUrl.maskApiKey('ab'), '••••');
    });
  });
}
