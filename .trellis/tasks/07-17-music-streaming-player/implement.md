# Implement: Music streaming player and play queue

## Ordered checklist

1. **Service: listing + URI**
   - [x] Add `UnraidFileManager.listAudio` (recursive scan, filter `isAudio`).
   - [x] Add public `UnraidFileManager.rawUri(String appPath)`.
   - [x] Extend `test/unraid_api_client_test.dart` for listAudio (include `.mp3` in recursive fixture) and rawUri path/port.

2. **Dependency**
   - [x] Add `just_audio` to `pubspec.yaml`; `flutter pub get`.
   - [x] Confirm Android min SDK / permissions if plugin docs require (INTERNET already typical).

3. **Music load path**
   - [x] `MusicPage` / `MusicTracksPage`: use `listAudio` instead of `listMedia` + `isAudio`.
   - [x] Pass full list context into player navigation.

4. **Player args + UI**
   - [x] Introduce `MusicPlayerArgs { apiClient, queue, initialIndex }`.
   - [x] Convert `MusicPlayerPage` to StatefulWidget with `AudioPlayer`.
   - [x] Wire play/pause, position stream, duration, seek slider.
   - [x] Wire prev/next + auto-advance on completion.
   - [x] Loading / error localized strings (ARB zh+en).
   - [x] Dispose player in `dispose`.

5. **Call sites**
   - [x] Update all `pushNamed(MusicPlayerPage...)` to pass `MusicPlayerArgs`.
   - [x] Tracks page: queue = currently displayed filtered list when searching.

6. **Docs / claims**
   - [x] README music bullet: real streaming (not “后续迭代”) for this child when done.
   - [x] Do not claim album backup until child 2.

7. **Quality gate**
   - [x] `dart format` touched files
   - [x] `flutter analyze`
   - [x] `flutter test`
   - [ ] Manual smoke: Android and/or Windows against real FB if available

## Validation commands

```bash
flutter pub get
flutter analyze
flutter test
```

Optional device:

```bash
flutter run -d windows
# or android device
```

## Risky files

| File | Risk |
|------|------|
| `lib/services/unraid_api_client.dart` | Shared by album/share; keep `listMedia` behavior |
| `lib/pages/music_page.dart` | Large UI rewrite of player section |
| `pubspec.yaml` | New native plugin |
| `lib/l10n/app_*.arb` | Must update both locales |

## Rollback points

- After step 1 only: safe, improves library correctness alone.
- After step 4: if audio plugin fails platforms, keep listAudio and gate player with error UI.

## Follow-up before `task.py start`

- [x] Parent + child PRDs written
- [x] Backup scope locked to photos only (does not block this child)
- [x] design.md + implement.md for this child
- [ ] User reviews planning artifacts and approves implementation
- [ ] Run `python ./.trellis/scripts/task.py start` on **`07-17-music-streaming-player`** (not parent)

## Notes for album child (later)

Do not start `07-17-album-backup-upload` until music child is archived or user explicitly prioritizes parallel work.
