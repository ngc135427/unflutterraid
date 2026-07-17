# 相册备份最小可用上传任务

**Parent:** `07-17-p0-media-closed-loop`  
**Order:** second P0 child (after music streaming lands preferred)  

## Goal

用户在相册备份页完成权限与目标目录配置后，能**真正发起一次上传**，看到进度与结果，并在 NAS 目标路径看到文件。把备份从「设置原型」收成最小可用闭环。

## Confirmed Facts

- UI exists: auto backup toggle, Wi‑Fi only, charge-for-video, target dir browser, permission request (`AlbumBackupPage`).
- Target dir browser uses `fileManager.listDirectory` under `/mnt/user`.
- `uploadBytes(directoryPath, fileName, bytes)` exists on `UnraidFileManager`.
- No local gallery query dependency yet (`permission_handler` only).
- No job queue, progress, last-sync persistence, or “Backup now” action wired to upload.
- Last sync row is static “no record” copy.
- Platforms: photo library access is primarily **Android** (and iOS later); Windows/Web lack the same mobile gallery model.

## Requirements

### R1 — Local media source (MVP)

- On Android (primary): after photos permission granted, enumerate local **photos only** eligible for backup.
- Videos are **out of MVP scope** (decision locked: option A).
- Must not claim backup “ready” without a path to actual local photo files.
- Video permission / charge-for-video UI may remain but must not imply video backup ships in this task (honest copy or disable).

### R2 — Upload execution

- Provide explicit **「立即备份」/ Backup now** primary action when permissions + target dir OK.
- For each selected/pending file: read bytes → `fileManager.uploadBytes` to target directory.
- Filename strategy: preserve original name; on conflict either skip, auto-suffix, or overwrite — **recommend skip if exists** (safe for re-run). Existence check may use directory list or upload error handling; document in design.
- Do not upload when permission missing; show localized guidance.

### R3 — Progress & result

- Show overall progress (completed / total) and current file name.
- Allow cancel mid-batch (best-effort: stop scheduling further uploads).
- On completion: update “last sync” subtitle with timestamp + success/fail counts (persist via `SharedPreferences`).
- Failures: per-file error retained; user can retry failed set.

### R4 — Policy toggles (MVP behavior)

| Toggle | MVP behavior (recommended) |
|--------|----------------------------|
| Auto backup | Persist preference; **no OS background daemon** in MVP. If on, may offer reminder copy that auto runs only when user opens app / taps backup — be honest in UI subtitle. |
| Wi‑Fi only | If enabled, block cellular backup start with clear message (Android connectivity check). |
| Charge when backing up video | **N/A for MVP** (photos only). Hide, disable, or subtitle “后续支持视频” — do not implement video charge gating. |

### R5 — Localization & quality

- zh + en strings for new actions/states.
- Service upload errors via existing patterns.
- Unit tests for upload HTTP mapping (extend existing FB tests); pure logic tests for conflict naming / progress counters.
- `flutter analyze` + `flutter test` green.

## Acceptance Criteria

- [ ] On Android with photos permission and reachable File Browser, user can tap Backup now and at least one local photo appears under the chosen `/mnt/user/...` path.
- [ ] Progress UI updates during multi-file upload; cancel stops further files.
- [ ] Last sync reflects last completed run after restart (persisted).
- [ ] Wi‑Fi-only setting prevents cellular start when enabled (or documented platform limitation).
- [ ] Desktop/Web: honest empty/disabled state if gallery access unavailable (no fake success).
- [ ] analyze + test pass.

## Out of Scope

- True always-on background backup with WorkManager/BGTask reliability productization.
- Dedup via content hash / HEIC transcoding pipeline.
- iCloud/Google Photos style selective album multi-source.
- Video live backup if photos-only MVP chosen.
- Bandwidth scheduling beyond Wi‑Fi flag.
- Backup encryption.

## Decisions (locked)

| Decision | Choice | Locked by |
|----------|--------|-----------|
| Media scope | **Photos only** | User 2026-07-17 (option A) |
| Videos | Out of this task | Same |
| Trigger | Manual Backup now | Product default |
| Auto toggle | Preference + honest copy (no OS daemon) | Product default |
| Conflict | Skip existing name | Product default |
| Platforms | Android full; desktop/Web graceful degrade | Product default |

## Open Questions

None blocking. Ready for design/implement after music child.
