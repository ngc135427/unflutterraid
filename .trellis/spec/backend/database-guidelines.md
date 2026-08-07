# Persistence Guidelines

> There is no SQL/ORM database in this app. This file documents **local persistence** patterns.

---

## Overview

Unflutterraid does not ship SQLite, Hive, or a remote app database. Persistence is limited to **preferences**.

| Data | Mechanism | File |
|------|-----------|------|
| Language override | `shared_preferences` key `app_language` | `lib/services/language_preferences.dart` |
| Remembered login | Android `MethodChannel` `unflutterraid/login_preferences` | `lib/services/login_preferences.dart` + Kotlin `MainActivity` |
| File Browser endpoint overrides | `shared_preferences` JSON map `file_browser_overrides_v1` | `lib/services/file_browser_preferences.dart` |

Server inventory, Docker state, and file listings are **always fetched live** from Unraid GraphQL / File Browser — never cached as a local DB.

---

## Language Preference Contract

| Code stored | Meaning |
|-------------|---------|
| (missing / removed) | System default (`AppLanguage.system`, `locale == null`) |
| `zh` | Simplified Chinese |
| `en` | English |

```dart
await LanguagePreferences.save(AppLanguage.en);
final language = await LanguagePreferences.load();
```

Widget tests:

```dart
SharedPreferences.setMockInitialValues({'app_language': 'zh'});
```

---

## Login Preference Contract

Channel methods: `load`, `save`.

Payload fields:

| Field | Type | Notes |
|-------|------|-------|
| `rememberMe` | bool | |
| `domain` | string | Host without scheme |
| `apiKey` | string | Unraid API key |
| `useHttps` | bool | |

On non-Android / missing plugin: load returns empty `RememberedLogin`; save is a no-op.

**Do not** store File Browser credentials here (MVP assumes anonymous or reverse-proxy auth).

---

## Scenario: Per-server File Browser endpoint overrides

### 1. Scope / Trigger

- Trigger: file browsing, preview, or backup must use a custom port or reverse-proxy base path instead of the derived same-host `:8080` default.

### 2. Signatures

```dart
Future<String?> FileBrowserPreferences.loadOverride(String unraidBaseUrl)
Future<void> FileBrowserPreferences.saveOverride({
  required String unraidBaseUrl,
  required String? fileBrowserBaseUrl,
})
String? FileBrowserPreferences.normalizeHttpUrl(String value)
```

Every login, server reconnect, and saved-profile connect flow must load the override before constructing:

```dart
UnraidApiClient(
  baseUrl: baseUrl,
  apiKey: apiKey,
  fileBrowserBaseUrl: override,
)
```

### 3. Contracts

- Storage key: `file_browser_overrides_v1`.
- Stored value: JSON object mapping normalized Unraid base URLs to normalized File Browser base URLs.
- URL schemes: `http` or `https` only.
- Custom ports and base paths are preserved; trailing slashes are removed.
- Credentials, queries, and fragments are forbidden.
- `null` removes the override; a missing override preserves the derived `:8080` behavior.
- This store contains no username, password, API key, or other secret.

### 4. Validation & Error Matrix

| Condition | Behavior |
|-----------|----------|
| Missing preference / server key | Return `null` |
| Malformed stored JSON | Return `null` |
| Invalid stored URL | Ignore it and return `null` |
| Invalid non-empty URL passed to `saveOverride` | Throw `ArgumentError` without changing the store |
| `null` passed to `saveOverride` | Remove only the matching server override |

### 5. Good/Base/Bad Cases

- Good: `https://files.example.com:9443/unraid` persists and preserves `/unraid` for `/api/...` joining.
- Base: no override for `http://tower.local` yields `http://tower.local:8080` through `UnraidApiClient` derivation.
- Bad: `http://user:pass@tower.local`, `ftp://tower.local`, or a URL with `?query` is rejected.

### 6. Tests Required

- Unit: two Unraid server keys round-trip independently.
- Unit: removing one override preserves the other.
- Unit: malformed JSON and invalid stored values return `null`.
- Unit: invalid non-empty saves throw and do not silently delete configuration.
- Client regression: a reverse-proxy path produces `<base-path>/api/resources/<resource>`.
- UI regression: a saved setting is applied through a replacement `UnraidApiClient`.

### 7. Wrong vs Correct

#### Wrong

```dart
final client = UnraidApiClient(baseUrl: baseUrl, apiKey: apiKey);
// Silently forgets the user's custom File Browser endpoint.
```

#### Correct

```dart
final override = await FileBrowserPreferences.loadOverride(baseUrl);
final client = UnraidApiClient(
  baseUrl: baseUrl,
  apiKey: apiKey,
  fileBrowserBaseUrl: override,
);
```

---

## Forbidden Patterns

- Introducing a local DB for server entities without an explicit product decision.
- Persisting API responses as the source of truth for dashboard state.
- Putting secrets in plain SharedPreferences on Android for login without reviewing the existing channel approach (current design uses the channel intentionally).

---

## Naming

- Preference keys: stable string constants (`_key = 'app_language'`).
- Channel name: reverse-dns style package channel (`unflutterraid/login_preferences`).
