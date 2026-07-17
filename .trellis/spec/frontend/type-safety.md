# Type Safety

> Dart type patterns in this project.

---

## Overview

Language: **Dart 3** (`sdk: ">=3.4.0 <4.0.0"`). Prefer sound null safety, enums, and sealed-style switches. There is no TypeScript and no Zod-style schema package.

---

## Type Organization

| Kind | Location |
|------|----------|
| API models + enums | Co-located in `lib/services/unraid_api_client.dart` (`UnraidDashboard`, `UnraidManagementItem`, `UnraidFileEntry`, `ManagementItemType`, `InfoSeverity`, …) |
| UI-only data classes | Same page file when private (`ManagementData`, `AlbumPageArgs`) |
| Language enum | `lib/services/language_preferences.dart` → `AppLanguage` |
| Login DTO | `lib/services/login_preferences.dart` → `RememberedLogin` |
| Generated l10n | `lib/l10n/generated/app_localizations.dart` |

Do not create a large free-floating `models/` tree unless types are shared by many features; the existing `lib/models/` folder is minimal.

---

## JSON / Dynamic Parsing

GraphQL and File Browser responses are `Map` / `List` oriented. Helpers in `unraid_api_client.dart`:

- `_asMap`, `_asList`, `_asDouble`, `_asInt`, `_firstText`, `_firstNumber`
- Prefer `_firstText([a, b, fallback])` for defensive display fields
- Factories: `UnraidDashboard.fromJson`, `UnraidFileEntry.fromFileBrowserResource`, etc.

```dart
// Good — defensive extraction
final title = _firstText([json['name'], json['nameOrig'], DisplayCopy.current.unnamedShare]);

// Bad — unchecked casts that throw on partial GraphQL data
final title = json['name'] as String;
```

Dashboard fetch uses `allowPartialData: true` so partial GraphQL errors can still yield usable `data` when present.

---

## Enums and Switches

Use Dart 3 switch expressions for exhaustive mapping:

```dart
return switch (action) {
  ManagementAction.start => l10n.start,
  ManagementAction.stop => l10n.stop,
  ManagementAction.restart => l10n.restart,
};
```

Management type **logic** keys are plain strings `docker` | `vm` | `share`, not localized labels.

---

## Validation

- Form validation: `Form` + `TextFormField` / `AppTextField` validators returning `String?`.
- Copy for errors: `AppLocalizations` (UI) or `DisplayCopy` (service thrown messages).
- No separate validation library.

---

## Forbidden Patterns

- `dynamic` leaking into page widgets when a typed model already exists.
- Casting GraphQL fields with `as String` without null/type checks.
- `// ignore:` to silence real type errors instead of fixing models.
- Passing `Object?` route args without an `is` check:

```dart
final args = ModalRoute.of(context)?.settings.arguments;
if (args is! AlbumPageArgs) { /* error state */ }
```

---

## Tests and Types

- Prefer `MockClient` from `package:http/testing.dart` for typed HTTP fakes (`test/unraid_api_client_test.dart`).
- Widget tests: mock `MethodChannel` for login prefs; `SharedPreferences.setMockInitialValues` for language.
