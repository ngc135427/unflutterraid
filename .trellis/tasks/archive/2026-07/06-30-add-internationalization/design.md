# Add Internationalization Design

## Architecture

Use Flutter's standard generated localization flow:

- Add `flutter_localizations` from the Flutter SDK and `intl`.
- Enable `flutter: generate: true`.
- Add `l10n.yaml`.
- Add ARB files under `lib/l10n/`, with Simplified Chinese as the template locale and English as the second locale.
- Import generated `AppLocalizations` from `lib/l10n/generated/app_localizations.dart`.

`UnflutterRaidApp` should become stateful enough to own the active locale override. It will:

- Load the persisted language preference before or during startup.
- Pass the selected `Locale?` into `MaterialApp.locale`.
- Expose a small app-level controller/inherited scope so the settings page can update the locale.
- Keep `locale == null` for system default.

## Settings Page

Add a new `SettingsPage` route under `lib/pages/settings_page.dart`.

The settings page is an app-level preferences surface. It must feel like a scalable settings list rather than a dedicated language page. Initially it contains:

- A localized title.
- A compact language row.
- A small inline choice control for system default, Simplified Chinese, and English.
- Placeholder/future rows that show the page can later host more preferences, without implementing unrelated behavior in Flutter.

The settings page should follow the existing app style:

- Use `PhoneFrame` for the branded background.
- Use white rounded content surfaces similar to existing pages.
- Use compact setting rows and a small segmented control or equivalent for language.
- Keep copy and spacing simple so future settings can be added without redesigning the page.

The language preference must be adjustable before and after login:

- Login page: show a small current-language dropdown in the top/header area. Tapping it opens a minimal selector; it should not open the full settings page.
- Logged-in main shell: add a settings entry in the main server shell so users can open the full settings page after connecting.
- Settings should not require an `UnraidApiClient`; it is app-level state.

## Persistence

Create a separate language preference service rather than overloading `LoginPreferences`.

Recommended shape:

- `lib/services/language_preferences.dart`
- Store one nullable locale code:
  - `null` or empty string: system default
  - `zh`: Simplified Chinese
  - `en`: English

Because the project already uses an Android `MethodChannel` for login preferences but needs cross-platform behavior, implementation should prefer a Flutter plugin that works on the current targets if dependency constraints allow it. If avoiding a new plugin, extend the existing channel only after checking non-Android behavior and tests.

## Localization Boundaries

Localize app-owned strings:

- Page titles, navigation labels, buttons, form labels, hints, validation messages.
- Dialog titles, snackbars, empty/loading/error states.
- App-generated dashboard labels, fallback values, statuses, and summaries surfaced from `UnraidApiClient`.

Do not translate remote/user data:

- Server names, filesystem paths, Docker image names, plugin names, URLs, IDs, version strings, and raw API values that are intentionally displayed as returned.

For service-generated display strings, avoid passing `BuildContext` deep into networking code. Prefer one of these approaches during implementation:

- Introduce a lightweight text provider/formatter at the UI boundary for app-owned labels, or
- Pass a localization-aware formatter into service mapping only where display strings are created.

The final choice should minimize churn while keeping network transport and UI copy reasonably separated.

## Compatibility

The default behavior must keep Simplified Chinese available and preserve the current app experience for Chinese users. English should be selected when the app locale is English or when the user chooses English in settings.

Existing tests that assert Chinese text should explicitly run under the Chinese locale or assert through localized resources.

## HTML Prototypes

Synchronize the static prototypes under `html/` with the app design:

- `html/login.html`: replace the full settings entry with a small current-language dropdown that switches language inline.
- `html/server_info.html`: add a logged-in settings entry in the main shell/header.
- `html/settings.html`: keep the standalone settings page, but design it as an extensible list where language is only one compact row.
- Prototype content should show the same three language choices: system default, Simplified Chinese, English, without making them fill the whole page.
- Prototype changes should remain static HTML/CSS/JS and should not introduce a build step.

## Risks

- The app has many hard-coded strings, including generated summaries in service code; full conversion is broad.
- Longer English copy may affect compact mobile layouts.
- Generated l10n files require `flutter pub get` / build tooling to run successfully.
- Persisted language selection needs test-friendly behavior; platform channels or plugins must not break widget tests.
- HTML prototypes may drift from the Flutter implementation if entry points are updated in one layer but not the other.

## Rollback

Localization infrastructure can be rolled back by removing generated l10n config/dependencies and reverting `MaterialApp` configuration. Page string conversions are the largest rollback surface, so implementation should proceed in coherent chunks and run tests after wiring the core app shell.
