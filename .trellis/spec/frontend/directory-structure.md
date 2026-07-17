# Directory Structure

> How frontend code is organized in this project.

---

## Overview

Single Flutter package (`unflutterraid`). App code lives under `lib/`.

---

## Directory Layout

```
lib/
├── main.dart                 # MaterialApp, locale, routes, DisplayCopy activation
├── app_language_scope.dart   # Inherited locale preference controller
├── l10n/
│   ├── app_zh.arb            # Template locale (Simplified Chinese)
│   ├── app_en.arb            # English
│   ├── language_names.dart   # AppLanguage → display labels via l10n
│   └── generated/            # flutter gen-l10n output (commit generated files)
├── pages/                    # Route screens
├── services/                 # API client, preferences, DisplayCopy
├── models/                   # Shared models (if any)
├── theme/                    # AppTheme
└── widgets/                  # Shared UI chrome
html/                         # Static UI prototypes (login, settings, server_info)
test/                         # Widget + unit tests
```

---

## Module Organization

| Concern | Location |
|---------|----------|
| Screen routes | `lib/pages/*_page.dart` |
| GraphQL / File Browser | `lib/services/unraid_api_client.dart` |
| Language persistence | `lib/services/language_preferences.dart` (`SharedPreferences`) |
| Login credential persistence | `lib/services/login_preferences.dart` (platform channel) |
| Service-layer display strings | `lib/services/display_copy.dart` |
| ARB sources | `lib/l10n/app_*.arb` |
| l10n config | `l10n.yaml` + `flutter: generate: true` in `pubspec.yaml` |

---

## Naming Conventions

- Pages: `*_page.dart`, class `XxxPage`, `static const routeName = '/…'`.
- ARB keys: lowerCamelCase (`loginButton`, `apiConnectionTimeout`).
- Management type keys (logic): `docker` / `vm` / `share` (not localized strings).

---

## Examples

- Login + compact language dropdown: `lib/pages/login_page.dart`
- Full settings + language row: `lib/pages/settings_page.dart`
- Locale wiring: `lib/main.dart`
