# Hook Guidelines

> Stateful logic patterns in this Flutter app (not React hooks).

---

## Overview

This project is **Flutter/Dart**, not React. There are no custom `use*` hooks. Stateful and reusable logic uses:

| Pattern | Where | Example |
|---------|-------|---------|
| `StatefulWidget` + `State` | Pages that load/mutate data | `LoginPage`, `AlbumPage`, `MainShellPage` |
| `InheritedWidget` scope | App-wide preference controllers | `AppLanguageScope` |
| Static service helpers | Persistence / API | `LanguagePreferences`, `LoginPreferences`, `UnraidApiClient` |
| Private methods on `State` | Page-local load/refresh | `_loadMedia()`, `_refreshDashboard()` |

Do not invent a React-Query-style layer. Match existing patterns.

---

## Data Fetching

### Convention: Load in `initState` / `didChangeDependencies`, show with `FutureBuilder` or local fields

**Login connection** (`lib/pages/login_page.dart`):

- Create `UnraidApiClient` on submit.
- `await client.checkConnection()`.
- On success, `Navigator.pushReplacementNamed(MainShellPage.routeName, arguments: client)`.

**Dashboard** (`lib/pages/main_shell_page.dart`):

- Read `UnraidApiClient` from route `arguments` in `didChangeDependencies`.
- Store `Future<UnraidDashboard>? _dashboardFuture = client.fetchDashboard()`.
- Rebuild UI with `FutureBuilder`.

**Album / media** (`lib/pages/album_page.dart`):

- Read `AlbumPageArgs` (client + root path) from route arguments.
- Call `apiClient.fileManager.listMedia` / `listDirectory` from a private async method.
- Hold results in `State` fields (`_sections`, `_loading`, `_error`).

### Convention: Only use `fileManager` for files

Album, share browsing, thumbnails, and raw bytes must go through:

```dart
apiClient.fileManager.listDirectory(path);
apiClient.fileManager.listMedia(rootPath);
apiClient.fileManager.readPreviewBytes(path);
apiClient.fileManager.readFileBytes(path);
```

Do not call Unraid WebGUI file endpoints or invent parallel HTTP clients in pages.

---

## Shared Stateful Logic

### `AppLanguageScope`

**File**: `lib/app_language_scope.dart`

```dart
final scope = AppLanguageScope.of(context);
scope.onLanguageChanged(AppLanguage.en);
```

- Wraps the app under `MaterialApp` in `lib/main.dart`.
- Preference persistence: `LanguagePreferences` + `SharedPreferences` key `app_language`.

### Preferences services

| Service | Storage | Notes |
|---------|---------|-------|
| `LanguagePreferences` | `shared_preferences` | Cross-platform; mockable in tests |
| `LoginPreferences` | Android `MethodChannel` | `MissingPluginException` → empty defaults (desktop/tests) |

---

## Naming Conventions

- Private page helpers: `_load…`, `_refresh…`, `_submit…`.
- Route args classes: `AlbumPageArgs`, `ManagementDetailArgs`.
- No `useFoo` naming — that is not a local convention.

---

## Common Mistakes

### Mistake: Fetching File Browser data outside `fileManager`

**Why bad**: Breaks the two-backend architecture and scatters URL/path encoding.

**Instead**: Always use `UnraidApiClient.fileManager`.

### Mistake: Holding `BuildContext` across async gaps without `mounted`

**Pattern**: After `await`, check `if (!mounted) return;` before `setState` / `Navigator` (see login and album pages).

### Mistake: Passing `BuildContext` into services for strings

**Instead**: UI uses `AppLocalizations.of(context)`; services use `DisplayCopy.current` (activated from `MaterialApp.builder`).
