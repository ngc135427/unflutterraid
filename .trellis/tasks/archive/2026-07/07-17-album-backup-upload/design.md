# Design: Album backup minimum viable upload (photos only)

## Goal

Wire `AlbumBackupPage` to a real **manual photo upload** pipeline: enumerate local photos → upload via File Browser `uploadBytes` → show progress / cancel / last-sync persistence.

## Architecture

```
AlbumBackupPage
  -> BackupPreferences (SharedPreferences: auto, wifiOnly, targetDir, lastSync summary)
  -> LocalPhotoSource.listPhotos()   // Android via photo_manager; else empty + unsupported
  -> Connectivity check (wifiOnly)
  -> BackupUploader.run(client, photos, targetDir, onProgress, cancelToken)
       -> listDirectory(target) for existing names (skip conflicts)
       -> for each photo: read bytes -> fileManager.uploadBytes
  -> UI: progress dialog / inline progress, Backup now button
```

## Components

### 1. `BackupPreferences` (`lib/services/backup_preferences.dart`)

Keys:

| Key | Type | Default |
|-----|------|---------|
| `backup_auto` | bool | false (honest: no daemon) |
| `backup_wifi_only` | bool | true |
| `backup_target_dir` | String | `/mnt/user/photos/mobile` |
| `backup_last_sync_at` | String ISO8601 | empty |
| `backup_last_sync_summary` | String | empty (locale-agnostic counts: `ok=3 fail=1 skip=2`) |

Parse summary for display with l10n at render time.

### 2. `LocalPhotoSource` (`lib/services/local_photo_source.dart`)

```dart
class LocalPhotoItem {
  final String id;
  final String fileName;
  final Future<Uint8List?> Function() readBytes;
}
```

- **Android:** `photo_manager` — request permission, query recent images only (`RequestType.image`), cap batch size (e.g. first **50** by modified desc for MVP to avoid huge first runs).
- **iOS:** same plugin path if available; not primary acceptance.
- **Windows / Web / Linux / macOS desktop:** return empty + `isSupported == false`; UI shows honest message.

Do not request video permission for MVP readiness.

### 3. Connectivity

- Dependency: `connectivity_plus`.
- If `wifiOnly` and active interface is mobile/cellular → block start with SnackBar.
- If connectivity unknown, allow with caution (or block only when clearly mobile).

### 4. `BackupUploader` pure logic

```dart
class BackupRunResult {
  final int success;
  final int failed;
  final int skipped;
  final List<String> failedNames;
}

Future<BackupRunResult> runBackup({
  required UnraidFileManager fileManager,
  required String targetDir,
  required List<LocalPhotoItem> photos,
  required bool Function() isCancelled,
  required void Function(int done, int total, String currentName) onProgress,
})
```

Conflict policy: **skip if name exists** in target directory listing (one list at start; optional refresh not required for MVP).

### 5. UI changes (`AlbumBackupPage`)

- Load/save preferences on enter / toggle.
- Hide or disable “charge when backing up video” with subtitle that video is future.
- Auto backup subtitle: honest — preference only, no background daemon; still need Backup now.
- Primary CTA: **Backup now** when photos permission OK + api client present.
- While running: progress (done/total + file name) + Cancel.
- Permissions: only photos required for CTA enablement; video permission not required.
- Desktop: CTA disabled + message “相册备份目前仅支持 Android”.

### 6. File Manager

- Reuse `uploadBytes`.
- Unit test: POST to `/api/resources/...` with body bytes.

Optional helper:

```dart
Future<Set<String>> listFileNames(String directoryPath)
```

or inline in uploader via `listDirectory`.

## Platform notes

| Platform | Behavior |
|----------|----------|
| Android | Full MVP |
| Others | Graceful degrade, no fake success |

Android already has `READ_MEDIA_IMAGES` / storage permissions.

## Trade-offs

| Option | Decision |
|--------|----------|
| photo_manager vs image_picker | **photo_manager** — batch enumerate |
| Full library vs cap 50 | Cap **50 newest** per run (document; avoid multi-GB first run) |
| Background WorkManager | Out of scope |
| Content-hash dedup | Out of scope; name skip only |

## Rollback

Remove photo_manager / connectivity_plus, revert AlbumBackupPage to settings shell, keep uploadBytes API tests if harmless.

## Security

- Do not log photo bytes or paths to console in release.
- Upload only to user-selected `/mnt/user/...` path under File Browser root mapping.
