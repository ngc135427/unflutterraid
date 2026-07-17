# P0 媒体闭环：音乐播放与相册备份上传

## Goal

把 Unflutterraid 已有的「相册 / 音乐」入口从半成品壳子收成**可感知的媒体闭环**：

1. **听得见**：点歌即可从 File Browser 流式播放，并支持基础队列。
2. **传得上**：相册备份从设置原型变成可执行的上传任务（进度、失败可重试）。

用户价值：NAS 客户端从「能看服务器」升级为「能消费与沉淀家里的媒体」。

## Background / Confirmed Facts

### Product surface today

| Area | Status | Evidence |
|------|--------|----------|
| Music library scan UI | Present | `lib/pages/music_page.dart` (`MusicPage` / `MusicTracksPage`) |
| Music player UI | Shell only — static `0:00` / no-op controls | `_PlayerProgress` / `_PlayerControls` in `music_page.dart` |
| File Browser raw read | Implemented | `UnraidFileManager.readFileBytes` → `GET /api/raw/...` |
| File Browser upload | API method reserved | `UnraidFileManager.uploadBytes` → `POST /api/resources/...` |
| Album backup page | Settings shell: permissions, Wi‑Fi, charge, target dir | `AlbumBackupPage` in `album_page.dart` |
| Local media pick / upload pipeline | Missing | No photo_manager / image_picker / backup job service |
| Audio player dependency | Missing | `pubspec.yaml` has no `just_audio` / `audioplayers` |

### Critical defect (must fix in music child)

- `UnraidFileManager.listMedia` removes entries with `!entry.isMedia`.
- `UnraidFileEntry.isMedia` is defined as **image OR video only** (`isMedia => isImage \|\| isVideo`).
- `isAudio` is separate; unit test asserts `song.flac` → `isAudio == true`, `isMedia == false` (`test/unraid_api_client_test.dart`).
- `MusicPage` loads via `listMedia` then filters `isAudio` → **real music libraries are always empty**.

### Parent / child map

| Child task | Deliverable | Order |
|------------|-------------|-------|
| `07-17-music-streaming-player` | Real playback + queue + fix audio listing | **First** |
| `07-17-album-backup-upload` | Minimum viable backup upload + progress | **Second** |

Parent owns cross-child acceptance and final integration review; parent is **not** the primary implementation target.

### Ordering note

Child 2 does not hard-depend on child 1 code. Product order is value-first: close the louder gap (music) before the more complex mobile pipeline (backup).

## Requirements (parent-level)

- **R-P0-1** Both children meet their own acceptance criteria.
- **R-P0-2** Shared File Manager contracts remain the only media I/O path (`apiClient.fileManager`); no WebGUI file bypass.
- **R-P0-3** New user-facing strings: both `app_zh.arb` and `app_en.arb`; service errors via `DisplayCopy` when applicable.
- **R-P0-4** `flutter analyze` and `flutter test` pass after each child lands.
- **R-P0-5** README roadmap bullets for music playback and album backup real upload are updated when both children complete.

## Cross-child Acceptance Criteria

- [ ] User can open Music from home, see real audio tracks under the configured music root, tap a track, hear audio (or get a clear stream error), and use prev/next within a queue.
- [ ] User can open Album → Photo Backup, grant media permission, choose target directory, start a backup action, see progress, and find uploaded files on the NAS path via File Browser.
- [ ] No regression to login, dashboard, Docker/VM, share browse rename/delete, language/theme.
- [ ] Parent README / product claims match shipped behavior (no “假播放 / 假备份”).

## Out of Scope (parent)

- Share multi-select / move / copy (P1 file manager).
- Settings server-config center and notification preferences (P2).
- Background OS-level backup daemon, iCloud-style continuous sync productization.
- Online lyrics, equalizer, gapless, Chromecast, offline download cache product.
- Release signing / CI automation (P3).
- File Browser in-app login credentials.

## Decisions (locked)

| Decision | Choice | Source |
|----------|--------|--------|
| Music stream strategy | Stream File Browser raw URL (not full RAM load) | Product default |
| Backup media scope | **Photos only** | User 2026-07-17 (A) |
| Backup trigger | Manual “Backup now” first | Product default |
| Implementation order | Music child → Album backup child | P0 product order |

## Open Questions

None blocking parent planning.
