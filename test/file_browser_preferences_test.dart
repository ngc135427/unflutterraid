import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:unflutterraid/services/file_browser_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  test('stores independent normalized overrides per Unraid server', () async {
    await FileBrowserPreferences.saveOverride(
      unraidBaseUrl: 'HTTP://Tower.Local/',
      fileBrowserBaseUrl: 'https://Files.Example.com:9443/proxy/',
    );
    await FileBrowserPreferences.saveOverride(
      unraidBaseUrl: 'https://backup.local',
      fileBrowserBaseUrl: 'http://10.0.0.9:8088',
    );

    expect(
      await FileBrowserPreferences.loadOverride('http://tower.local'),
      'https://files.example.com:9443/proxy',
    );
    expect(
      await FileBrowserPreferences.loadOverride('https://backup.local/'),
      'http://10.0.0.9:8088',
    );
  });

  test('null override removes only the matching server value', () async {
    await FileBrowserPreferences.saveOverride(
      unraidBaseUrl: 'http://tower.local',
      fileBrowserBaseUrl: 'http://tower.local:9090',
    );
    await FileBrowserPreferences.saveOverride(
      unraidBaseUrl: 'http://other.local',
      fileBrowserBaseUrl: 'http://other.local:7070',
    );

    await FileBrowserPreferences.saveOverride(
      unraidBaseUrl: 'http://tower.local',
      fileBrowserBaseUrl: null,
    );

    expect(
      await FileBrowserPreferences.loadOverride('http://tower.local'),
      isNull,
    );
    expect(
      await FileBrowserPreferences.loadOverride('http://other.local'),
      'http://other.local:7070',
    );
  });

  test('rejects credentials, non-http schemes, queries, and fragments', () {
    expect(
        FileBrowserPreferences.normalizeHttpUrl('ftp://tower.local'), isNull);
    expect(
      FileBrowserPreferences.normalizeHttpUrl('http://user:pass@tower.local'),
      isNull,
    );
    expect(
      FileBrowserPreferences.normalizeHttpUrl('http://tower.local?a=1'),
      isNull,
    );
    expect(
      FileBrowserPreferences.normalizeHttpUrl('http://tower.local/#files'),
      isNull,
    );
  });

  test('refuses to persist an invalid non-empty override', () async {
    expect(
      () => FileBrowserPreferences.saveOverride(
        unraidBaseUrl: 'http://tower.local',
        fileBrowserBaseUrl: 'ftp://tower.local',
      ),
      throwsArgumentError,
    );
  });

  test('ignores malformed persisted JSON', () async {
    SharedPreferences.setMockInitialValues({
      'file_browser_overrides_v1': '{broken',
    });

    expect(
      await FileBrowserPreferences.loadOverride('http://tower.local'),
      isNull,
    );
  });
}
