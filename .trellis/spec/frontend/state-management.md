# State Management

> How state is managed in this Flutter app.

---

## Overview

No third-party state library (no Riverpod, Bloc, Provider package, Redux). State is:

1. **Ephemeral UI state** — `setState` on the owning `State` class.
2. **App locale preference** — `AppLanguageScope` + `LanguagePreferences`.
3. **Server state** — fetched via `UnraidApiClient` / `fileManager`, held as `Future` or list fields on the page.

---

## State Categories

| Category | Mechanism | Examples |
|----------|-----------|----------|
| Local form UI | Controllers + `setState` | Login domain/API key fields, remember-me checkbox |
| Local list/filter | `TextEditingController` + filter in `build` | Docker/VM search on management page |
| Route arguments | `ModalRoute.of(context)?.settings.arguments` | `UnraidApiClient`, `UnraidDashboard`, `AlbumPageArgs` |
| App language | `AppLanguageScope` | Login dropdown, settings language row |
| Dashboard snapshot | `Future<UnraidDashboard>` on shell state | Home / management tabs |
| Media sections | `List<_MediaSection>` on album state | Photos / videos timelines |

---

## When to Use App-Level State

Promote to app-level only when:

- The value must survive navigation across routes **and**
- Multiple unrelated pages read/write it **and**
- It is not server data that should be re-fetched.

Today that is essentially **language preference** (`AppLanguageScope`). Do not invent a global store for dashboard data; keep it on `MainShellPage` and pass via route arguments when needed.

---

## Server State

### Unraid GraphQL (management)

- Owned by `UnraidApiClient` in `lib/services/unraid_api_client.dart`.
- Dashboard loaded once into `_dashboardFuture`; refresh by reassigning the future.
- Docker/VM actions call `runManagementAction`, then UI shows snackbar (list refresh is best-effort / re-enter).

### File Browser (files/media)

- Owned by `UnraidFileManager` via `client.fileManager`.
- Path mapping: app paths under `/mnt/user/...` ↔ File Browser resource paths.
- Default base URL: same host as Unraid, port `UnraidApiClient.defaultFileBrowserPort` (`8080`).

### Caching

There is **no** persistent server-state cache layer. Each page load/fetch is independent. Do not add a silent global cache without an explicit task.

---

## Derived State

- Management type keys are stable (`docker` / `vm` / `share`); labels come from l10n at display time.
- Status severity (`InfoSeverity`) is derived from status strings with bilingual token matching (`运行` / `running`, etc.).
- Media section titles use stable keys (`__today__`, `__yesterday__`, `__ym__Y_M`) then localize for display.

---

## Common Mistakes

### Mistake: Storing localized strings as the source of truth for branches

```dart
// Bad
type: AppLocalizations.of(context).navVm;

// Good
type: 'vm';
```

### Mistake: Closing the API client while another route still needs it

`MainShellPage` owns the client from login and closes it in `dispose`. Album routes receive the same client instance via args — do not `close()` from a short-lived page.

### Mistake: Putting language persistence only on Android channels

Language uses `shared_preferences` so widget tests and non-Android platforms work. Login credentials still use the MethodChannel on Android.
