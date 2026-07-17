# Quality Guidelines

> Code quality standards for frontend development.

---

## Overview

This Flutter app prefers analyzer-clean code, generated l10n, and widget tests for login/locale flows.

---

## Forbidden Patterns

- Hard-coded user-facing Chinese/English strings in `lib/pages/**` for app-owned copy.
- Passing `BuildContext` into `UnraidApiClient` / pure service mapping for string lookup.
- Using localized labels as `switch` case values or persisted preference codes.
- Committing without regenerating `lib/l10n/generated/` after ARB edits.
- Bypassing `apiClient.fileManager` for directory/media/preview/raw file access.
- Calling Unraid WebGUI file endpoints from UI code.

---

## Required Patterns

- `flutter analyze` clean before claiming done.
- `flutter test` green (or document pre-existing unrelated failures).
- New UI strings: both `app_zh.arb` and `app_en.arb`.
- Widget tests that assert Chinese default copy should set language preference (or locale) explicitly, e.g. `SharedPreferences.setMockInitialValues({'app_language': 'zh'})`.

---

## Testing Requirements

| Area | Expectation |
|------|-------------|
| Login screen | Widget test: default zh labels; language dropdown switches to English |
| File Browser client | Unit tests with `MockClient` (path mapping, auth errors) |
| New l10n keys with placeholders | Ensure ARB `@key.placeholders` types match call sites (`int` vs `String`) |

---

## Code Review Checklist

- [ ] User-facing strings go through l10n / `DisplayCopy`
- [ ] No invalid `const` around `AppLocalizations.of`
- [ ] Server-provided values not translated
- [ ] Language preference still persists (`LanguagePreferences`)
- [ ] HTML prototypes updated if entry points changed (`html/login.html`, `html/settings.html`, `html/server_info.html`)
- [ ] `flutter analyze` + `flutter test`

---

## Validation Commands

```bash
flutter pub get
flutter gen-l10n
dart format lib test
flutter analyze
flutter test
```
