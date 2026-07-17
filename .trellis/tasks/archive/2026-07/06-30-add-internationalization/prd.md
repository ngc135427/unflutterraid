# Add internationalization

## Goal

Add internationalization support so the Flutter app can present user-facing UI text in multiple languages without scattering hard-coded copy through pages and services.

The MVP should preserve the current Simplified Chinese experience while adding an English locale path. The app should follow the platform locale by default and provide a complete, extensible in-app settings page where language is one compact preference among future app-level settings.

## Confirmed Facts

- The project is a Flutter app in a single repository.
- `pubspec.yaml` currently depends on `flutter`, `http`, and `permission_handler`; it does not yet include `flutter_localizations`, `intl`, or generated l10n configuration.
- `MaterialApp` is configured in `lib/main.dart` and currently has no `localizationsDelegates`, `supportedLocales`, or app localization delegate.
- User-facing Simplified Chinese strings are hard-coded across `lib/pages/*`, especially login, register, main shell, details, album, and music pages.
- `lib/services/unraid_api_client.dart` also emits display-facing Chinese strings for errors, fallback labels, dashboard summaries, statuses, and file browser messages that are surfaced by the UI.
- Widget tests assert current Chinese login strings in `test/widget_test.dart`.
- The app does not currently have a global settings page. Existing "settings" mentions are local feature settings or item action buttons.
- HTML prototypes live under `html/`; `html/login.html` models the login experience and `html/server_info.html` models the main server shell/navigation. They currently do not include a complete app settings page or language switching flow.

## Requirements

- R1. Add Flutter localization infrastructure using the standard Flutter l10n flow.
- R2. Support Simplified Chinese as the existing/default content locale.
- R3. Support English for core app UI copy, validation messages, error messages, state messages, navigation labels, dialogs, snackbars, and generated dashboard/file-browser labels that are displayed to users.
- R4. Configure `MaterialApp` with generated localization delegates and supported locales.
- R5. Replace hard-coded user-facing strings with localization lookups where the string is owned by the app.
- R6. Preserve API-returned names, paths, IDs, versions, status codes, and other server-provided values exactly except where existing code already formats them for display.
- R7. Update tests so localization setup is covered and the login screen still renders expected default-locale copy.
- R8. Add a complete settings page that can host app-level preferences without letting the first language setting dominate the page.
- R9. Add a compact language setting that can choose Simplified Chinese, English, or system default.
- R10. Persist the selected language preference so the app restores it on next launch.
- R11. The settings page should use the same visual language as the rest of the app, stay simple, and be localizable.
- R12. The login page should expose only the current language in a lightweight dropdown that can switch language before login.
- R13. The logged-in app should expose the complete settings page.
- R14. Update the HTML prototypes to reflect the compact login-language control, extensible settings page, and logged-in settings entry point.

## Acceptance Criteria

- [x] The app builds with generated localization classes.
- [x] `MaterialApp` declares the generated localization delegate, Flutter material/widget/cupertino delegates, and supported locales.
- [x] Simplified Chinese remains available and matches the current user-facing copy for the converted strings.
- [x] English locale resources exist for converted strings.
- [x] A settings page exists for app-level preferences.
- [x] The login flow shows the current language before connecting to a server and allows switching through a compact dropdown.
- [x] The settings page can be opened from the logged-in main shell after connecting to a server.
- [x] A user can switch between Simplified Chinese, English, and system default from a compact language setting.
- [x] The selected language preference persists across app restarts.
- [x] HTML prototypes under `html/` are updated to show the compact login-language control, extensible settings page, and main-shell settings entry point.
- [x] Login widget tests pass with localization configured.
- [x] `flutter analyze` passes.
- [x] `flutter test` passes or any failures are documented as unrelated existing failures.

## Out of Scope

- Translating server-provided names, filesystem paths, plugin names, Docker image names, API field values that are not app-owned labels, or arbitrary remote error messages.
- Localizing non-Flutter platform launcher metadata.
- Refactoring visual layout beyond what is needed for translated text to fit safely.

## Decisions

- The complete settings page should be designed as an extensible app preferences list, with language as one compact setting.
- Before login, the UI should stay simple and show only the current language as a compact dropdown.
- After login, the complete settings page should be accessible from the main shell.

## Open Questions

- None.
