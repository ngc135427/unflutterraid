# Add Internationalization Implementation Plan

## Checklist

1. Run pre-development context for frontend work.
2. Add Flutter l10n dependencies/config:
   - `flutter_localizations`
   - `intl`
   - `flutter: generate: true`
   - `l10n.yaml`
   - `lib/l10n/app_zh.arb`
   - `lib/l10n/app_en.arb`
3. Add app locale state and preference persistence:
   - language preference model
   - load/save service
   - app-level locale controller/scope
4. Configure `MaterialApp`:
   - generated delegates
   - Flutter delegates
   - supported locales
   - selected locale override
   - settings route
5. Add `SettingsPage` as an extensible app preferences page with compact language selection.
6. Add language/settings entry points:
   - login page current-language dropdown
   - logged-in main shell entry
7. Convert user-facing app-owned strings to `AppLocalizations`:
   - app shell and settings
   - login/register
   - main shell/navigation/state messages
   - detail page
   - album/music pages
   - service-generated display labels and messages that are app-owned
8. Update HTML prototypes:
   - simplify settings prototype into a compact extensible settings list
   - show a current-language dropdown in `html/login.html`
   - link from `html/server_info.html`
   - show system default, Simplified Chinese, and English choices
9. Update widget tests for localization and persisted preference mocks.
10. Run format and quality checks.

## Validation Commands

```bash
flutter pub get
dart format lib test
flutter analyze
flutter test
```

## Risky Files

- `pubspec.yaml`: dependency and generate configuration.
- `lib/main.dart`: app startup, routes, and localization delegates.
- `lib/services/unraid_api_client.dart`: broad app-owned display string conversion.
- `lib/pages/main_shell_page.dart`: large file with many user-facing strings and compact UI.
- `html/login.html` and `html/server_info.html`: static prototypes must stay in sync with app entry points.
- `html/settings.html` if a standalone settings prototype is added.
- `test/widget_test.dart`: needs localization-aware expectations and preference mocks.

## Review Gates

- After core l10n setup, run `flutter pub get` and ensure generated localization import resolves.
- After settings page and locale switching, run widget tests for the login/settings flow.
- After HTML prototype updates, open or inspect the static pages to confirm the settings entry points and language choices are visible.
- After broad string conversion, run `flutter analyze` and inspect any remaining app-owned Chinese strings with `rg -n "[一-龥]" lib test`.

## Rollback Points

- If l10n generation fails, revert dependency/config changes before converting page strings.
- If language persistence introduces platform-test instability, replace persistence implementation with a small testable abstraction before continuing broad conversion.
- If service-level string conversion becomes too large, split it into a follow-up only after preserving UI-level localization in this task.
