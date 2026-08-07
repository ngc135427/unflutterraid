# Implementation Plan

1. Add `FileBrowserPreferences` with per-Unraid URL load/save/remove behavior and focused tests.
2. Add localized File Browser settings copy in Chinese and English, then regenerate Flutter localizations.
3. Add a dedicated File Browser configuration page and register its route.
4. Add the settings-page connection row showing the active effective File Browser URL.
5. Load and pass saved overrides from login, server reconnect, and server-profile connect flows.
6. Apply a newly saved setting immediately by constructing a replacement client and returning to the main shell.
7. Hide tags and the duplicate action row only for share cards while preserving whole-card navigation.
8. Format touched Dart files, run focused tests, run the full Flutter test suite, and run `flutter analyze`.
9. Build an Android Release APK and verify the artifact exists.
10. Review the final diff, commit only task-related changes, and push the current branch.

## Risk Points

- Reverse-proxy base paths must remain intact when File Browser API paths are joined.
- Replacing the main shell must not reuse a client that the old shell will close during disposal.
- Share-only conditions must not change Docker or VM controls.

## Validation

- `flutter test test/file_browser_preferences_test.dart`
- `flutter test test/unraid_api_client_test.dart`
- `flutter test`
- `flutter analyze`
- `flutter build apk --release`
