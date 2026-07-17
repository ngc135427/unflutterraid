# Implement: Album backup photos upload

## Ordered checklist

1. **Dependencies**
   - [x] `flutter pub add photo_manager connectivity_plus`
   - [x] Verify Android permissions already present for images

2. **Services**
   - [x] `lib/services/backup_preferences.dart`
   - [x] `lib/services/local_photo_source.dart` (photo_manager + unsupported platforms)
   - [x] `lib/services/backup_uploader.dart` (skip conflicts, progress, cancel)
   - [x] Unit tests: uploader conflict skip counters; uploadBytes HTTP mapping

3. **UI**
   - [x] Wire AlbumBackupPage: prefs, Backup now, progress, cancel, last sync
   - [x] Photos-only permission gate; honest auto/video copy
   - [x] Desktop/Web unsupported state

4. **l10n**
   - [x] zh + en: backup now, progress, cancel, wifi blocked, unsupported platform, last sync summary, video deferred, batch cap note if shown

5. **Docs**
   - [x] README album backup: real manual photo upload MVP

6. **Quality**
   - [x] `flutter gen-l10n` / analyze / test

## Validation

```bash
flutter pub get
flutter analyze
flutter test
```

## Risky files

- `lib/pages/album_page.dart` (large)
- `pubspec.yaml` (native plugins)
- Android photo permission UX

## Start

```bash
python ./.trellis/scripts/task.py start 07-17-album-backup-upload
```
