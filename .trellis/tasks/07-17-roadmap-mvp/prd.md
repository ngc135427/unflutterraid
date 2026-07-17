# Roadmap MVP: theme, music library, file writes, Trellis git

## Goal

Deliver the previously suggested follow-ups in one coherent MVP:

1. Track Trellis specs/tasks/journals in git (narrow `.gitignore`).
2. Align `README.md` with current architecture (l10n, DisplayCopy, dual backend).
3. Implement theme preference (system / light / dark) in settings, persisted.
4. Load music library from File Browser media under a music share path.
5. File Browser write MVP: delete and rename in share browser; upload optional if low-risk.

## Requirements

- R1. Root `.gitignore` must not ignore all of `.trellis/`; ignore only runtime/backup paths.
- R2. Commit tracked Trellis `spec/`, `tasks/`, `workspace/` journals (not `.runtime/`).
- R3. README documents i18n, DisplayCopy, language/theme prefs, dual-backend.
- R4. Theme: system/light/dark, settings UI, persist via SharedPreferences, apply on `MaterialApp`.
- R5. Music page receives `UnraidApiClient` (or args) and lists audio files via `fileManager`.
- R6. Share browser: enter subdirectories; delete and rename entries with confirmation.
- R7. File write methods on `UnraidFileManager` with localized errors.
- R8. Tests for theme prefs, music listing filter, delete/rename HTTP mapping.
- R9. `flutter analyze` and `flutter test` pass.

## Acceptance Criteria

- [x] `.trellis/spec` and archived tasks can be `git add` without `-f` for intended paths.
- [x] README architecture section lists l10n / settings / DisplayCopy.
- [x] User can switch theme in settings and it restores on relaunch.
- [x] Music shortcut opens a library loaded from File Browser (empty/error states localized).
- [x] Share browser can open subfolders and delete/rename with feedback.
- [x] analyze + test green.

## Out of Scope

- Full media player streaming UI polish.
- Album backup real upload pipeline.
- CI signing / release automation.
- File Browser login credentials in app.
