# Persistence Guidelines

> There is no SQL/ORM database in this app. This file documents **local persistence** patterns.

---

## Overview

Unflutterraid does not ship SQLite, Hive, or a remote app database. Persistence is limited to **preferences**.

| Data | Mechanism | File |
|------|-----------|------|
| Language override | `shared_preferences` key `app_language` | `lib/services/language_preferences.dart` |
| Remembered login | Android `MethodChannel` `unflutterraid/login_preferences` | `lib/services/login_preferences.dart` + Kotlin `MainActivity` |

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

## Forbidden Patterns

- Introducing a local DB for server entities without an explicit product decision.
- Persisting API responses as the source of truth for dashboard state.
- Putting secrets in plain SharedPreferences on Android for login without reviewing the existing channel approach (current design uses the channel intentionally).

---

## Naming

- Preference keys: stable string constants (`_key = 'app_language'`).
- Channel name: reverse-dns style package channel (`unflutterraid/login_preferences`).
