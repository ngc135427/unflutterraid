# Design: Settings server config

## Args

```dart
class SettingsPageArgs {
  final UnraidApiClient? apiClient; // null if opened without session
}
```

`MainShell` opens settings with `apiClient: _apiClient`.

## UI

Settings connection row → push or expand `ServerConfigPage` (same file or route).

Prefer dedicated route `/settings/server` registered in main.dart for clarity:

- `ServerConfigPage` StatefulWidget
- Prefill from `apiClient` or `LoginPreferences.load()`
- Actions: Save & reconnect, Disconnect, Clear saved credentials

## Reconnect flow

1. Build `UnraidApiClient(baseUrl, apiKey)`
2. `await checkConnection()`
3. Save LoginPreferences if remember
4. `pushNamedAndRemoveUntil(MainShell, arguments: newClient)`
5. Old shell dispose closes old client

## Disconnect

`pushNamedAndRemoveUntil(Login)` — do not auto-clear remember unless user taps clear.

## URL helpers

Share logic with login: if domain already has scheme, use as-is; else prefix http/https.
