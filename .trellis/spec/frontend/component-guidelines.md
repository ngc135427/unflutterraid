# Component Guidelines

> How components are built in this project.

---

## Overview

Flutter UI pages live under `lib/pages/`. Shared chrome widgets live under `lib/widgets/`. Theme tokens live under `lib/theme/`.

---

## Localization (App-Owned Copy)

### Convention: Use generated `AppLocalizations` in UI

**What**: Every user-facing string owned by the app must come from ARB-backed `AppLocalizations`, not hard-coded Chinese/English literals in widgets.

**Why**: Login, settings, and the main shell support Simplified Chinese, English, and system locale. Hard-coded copy breaks language switching.

**How**:

1. Add keys to both `lib/l10n/app_zh.arb` (template) and `lib/l10n/app_en.arb`.
2. Run `flutter gen-l10n` (or `flutter pub get`) so `lib/l10n/generated/` updates.
3. In widgets: `final l10n = AppLocalizations.of(context);` then `l10n.someKey`.
4. Do **not** mark widgets `const` when they call `AppLocalizations.of(context)`.

```dart
// Good
final l10n = AppLocalizations.of(context);
Text(l10n.loginButton);

// Bad — hard-coded UI copy
const Text('登录');
```

### Convention: Stable internal keys vs display labels

**What**: When logic branches on a "type" (Docker / VM / Share), store a **locale-stable** key (`docker`, `vm`, `share`) and localize only for display.

**Why**: `switch (type)` cannot use `AppLocalizations.of(context).navVm` as a case pattern; localized labels also break equality after language changes.

```dart
// Good
type: 'vm',
// later
final label = switch (type) {
  'docker' => l10n.navDocker,
  'vm' => l10n.navVm,
  _ => l10n.navShare,
};

// Bad
type: AppLocalizations.of(context).navVm,
```

### Convention: Service display copy via `DisplayCopy`

**What**: Networking/mapping code in `lib/services/unraid_api_client.dart` must not take `BuildContext`. App-owned error/status/fallback labels go through `DisplayCopy.current`.

**Why**: Keeps HTTP mapping free of Flutter widget tree while still switching language with the UI.

**How**:

1. `MaterialApp.builder` activates `DisplayCopy.fromL10n(AppLocalizations.of(context)).activate()`.
2. Mapping helpers read `DisplayCopy.current.*`.
3. Default Chinese values on `DisplayCopy.current` are bootstrap-only until the first frame builds.

```dart
// Good
throw UnraidApiException(DisplayCopy.current.apiConnectionTimeout);

// Bad
throw const UnraidApiException('连接服务器超时');
// Bad — do not pass BuildContext into UnraidApiClient
```

### Do not localize remote/server values

Leave API-returned names, paths, versions, image names, and raw field values as returned. Only localize app-owned labels that format or wrap those values.

---

## Component Structure

Pages are route widgets with `static const routeName`. Prefer small private widgets in the same file when they are page-specific.

Shared chrome (import from `lib/widgets/`):

| Widget | Role |
|--------|------|
| `PhoneFrame` | Brand gradient scaffold + optional max content width |
| `FadeSlide` | Entry motion wrapper |
| `GradientButton` | Primary CTA |
| `AppTextField` | Labeled form field |
| `AppBottomNav` | Main shell bottom navigation |
| `ServerIconView` | Server icon variants |

Reference: `lib/pages/login_page.dart`, `lib/pages/settings_page.dart`, `lib/pages/main_shell_page.dart`.

---

## Props Conventions

Use required named parameters for non-optional dependencies (e.g. `UnraidDashboard`, `UnraidApiClient`). Prefer `const` constructors when the widget does not depend on localization or runtime data.

Route argument types stay typed (`AlbumPageArgs`, `ManagementDetailArgs`) and are checked with `is` / `is!` at the page boundary.

---

## Styling Patterns

Use `AppTheme` tokens (`primary`, `textDark`, `softLine`, …) and shared chrome (`PhoneFrame`, `FadeSlide`, `GradientButton`) rather than inventing one-off color constants per page.

Theme source: `lib/theme/app_theme.dart` (`AppTheme.light()`, `brandGradient`).

---

## Accessibility

Interactive icon-only controls should set `tooltip` from l10n (e.g. settings open, language menu).

---

## Common Mistakes

### Mistake: `const` + `AppLocalizations.of(context)`

**Symptom**: `const_eval_method_invocation` analyzer error.

**Cause**: `AppLocalizations.of` is not a constant expression.

**Fix**: Remove `const` from the widget that uses l10n; keep `const` on true constants (icons, padding values).

### Mistake: Status matching only Chinese tokens

**Symptom**: English status chips render with the wrong severity color.

**Cause**: Helpers like `_isRunningStatus` / `_severityFromStatus` only checked `运行` / `在线`.

**Fix**: Match both Chinese formatted labels and English/raw API tokens (`running`, `online`, `stopped`, …).
