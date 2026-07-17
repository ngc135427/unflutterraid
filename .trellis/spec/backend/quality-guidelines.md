# Quality Guidelines (Services)

> Standards for service-layer and test code.

---

## Overview

Service code must stay analyzer-clean, testable with `MockClient`, and free of UI dependencies.

---

## Required Patterns

- Inject `http.Client` for tests (`UnraidApiClient(httpClient: MockClient(...))`).
- Normalize base URLs (trim trailing `/`) via `_normalizeBaseUrl`.
- Centralize File Browser port in `UnraidApiClient.defaultFileBrowserPort`.
- User-facing service strings via `DisplayCopy.current`, activated from UI locale.
- Close clients the page owns (`MainShellPage.dispose` → `client.close()`).

---

## Forbidden Patterns

- `BuildContext` parameters on API client methods.
- Hard-coded Chinese/English display strings in mapping helpers (use `DisplayCopy`).
- Calling Unraid WebGUI `Browse.php` or similar for files.
- Collecting File Browser username/password on the login page (MVP).
- Untested path encoding for nested File Browser resources when changing path helpers.

---

## Testing Requirements

| Area | File | Assert |
|------|------|--------|
| FB URL derivation | `test/unraid_api_client_test.dart` | host + port 8080 |
| Directory listing | same | method, path, mapped `/mnt/user/...` |
| Recursive media | same | filter images/videos |
| Raw / preview bytes | same | `/api/raw/…`, `/api/preview/…` |
| Auth failure copy | same | 401/403 message mentions access/proxy |

Commands:

```bash
dart format lib test
flutter analyze
flutter test
```

---

## Code Review Checklist

- [ ] GraphQL vs File Browser boundary preserved
- [ ] Partial dashboard GraphQL still considered if changing `_request`
- [ ] New exceptions use `DisplayCopy` / l10n keys in both ARB files
- [ ] Tests updated for new endpoints or path rules
- [ ] No credentials logged or committed

---

## Wrong vs Correct

### Wrong

```dart
Future<List<UnraidFileEntry>> list(BuildContext context, String path) async {
  // uses AppLocalizations.of(context) inside networking
}
```

### Correct

```dart
// UI activates DisplayCopy; service stays context-free
Future<List<UnraidFileEntry>> listDirectory(String path) async { … }
```
