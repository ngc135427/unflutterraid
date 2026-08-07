# Directory Structure (Services / Networking)

> Where non-UI logic lives in this Flutter app.

---

## Overview

There is **no separate Node/Java backend** in this repository. “Backend” for Trellis means the **service and integration layer** inside the Flutter client: Unraid GraphQL, File Browser HTTP, preferences, and display-copy helpers.

---

## Layout

```
lib/services/
  unraid_api_client.dart   # GraphQL client, dashboard models, File Manager
  display_copy.dart        # Locale-aware app-owned service strings
  language_preferences.dart
  login_preferences.dart
  file_browser_preferences.dart # Per-server File Browser endpoint overrides

lib/l10n/                  # ARB + generated AppLocalizations (UI + DisplayCopy source)
test/
  unraid_api_client_test.dart
  widget_test.dart
```

Platform-native code (login prefs channel):

```
android/app/src/main/kotlin/.../MainActivity.kt
```

---

## Module Boundaries

| Module | Responsibility | Must not |
|--------|----------------|----------|
| `UnraidApiClient` | GraphQL transport, auth headers, dashboard mapping, management mutations | Own UI widgets or `BuildContext` |
| `UnraidFileManager` | File Browser HTTP (list/recursive/raw/preview), path mapping | Call Unraid WebGUI file endpoints |
| `DisplayCopy` | App-owned error/status/fallback strings for services | Depend on widgets |
| `LanguagePreferences` | Persist locale override | Store server credentials |
| `LoginPreferences` | Remember-me credentials via MethodChannel | Store File Browser secrets |

---

## Naming

- Service files: `snake_case.dart`.
- Public types: `UpperCamelCase` (`UnraidApiException`, `UnraidFileEntry`).
- Private helpers at library level: `_asMap`, `_formatStatus`, `_deriveFileBrowserBaseUrl`.
- Constants: `defaultFileBrowserPort`, `channelName`.

---

## Two-Backend Architecture

Documented in `README.md`:

1. **Unraid GraphQL** — server info, Docker, VM, share metadata, mutations.
2. **File Browser API** — directory listing, recursive media, thumbnails, raw bytes.

Default File Browser URL: same scheme/host as Unraid base URL, port `8080` (`UnraidApiClient.defaultFileBrowserPort`). Settings persist an optional per-server override through `FileBrowserPreferences`; every client-creation flow loads it and passes it to the existing `fileBrowserBaseUrl` constructor parameter.

---

## Adding New Integration Code

1. Prefer extending `UnraidApiClient` / `UnraidFileManager` rather than a new top-level HTTP client in a page.
2. Keep JSON parsing next to the client (same file today).
3. User-facing service strings: add ARB keys + wire through `DisplayCopy`.
4. Add/extend unit tests with `package:http/testing.dart` `MockClient`.
