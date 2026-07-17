# 音乐真实流式播放与播放队列

**Parent:** `07-17-p0-media-closed-loop`  
**Order:** first P0 child  

## Goal

用户从首页进入音乐 → 看到真实曲库 → 点选即播 → 进度可拖 → 上一首/下一首在队列内工作。把 `MusicPlayerPage` 从静态壳变成可用播放器。

## Confirmed Facts

- Library UI and search exist (`MusicPage`, `MusicTracksPage`).
- Player is shell: progress fixed at 0, controls `onPressed: () {}` (`music_page.dart` ~589–663).
- Route args today: player receives only `UnraidFileEntry`; no queue / client.
- File Browser raw: `GET /api/raw/<fb-path>` via `readFileBytes` (loads entire body — unsuitable as sole strategy for large FLAC).
- **Bug:** `listMedia` filters with `isMedia` only → audio excluded; music page filters `isAudio` → empty library.
- No audio package in `pubspec.yaml`.
- Platforms in repo: Android, Windows, Web, iOS/macOS/Linux folders present; primary product is mobile/desktop Unraid client.

## Requirements

### R1 — Audio listing correctness

- Provide a File Manager API path that returns audio files under a root (either fix `listMedia` semantics or add `listAudio` / media-kind filter).
- Music pages must load **audio**, not only images/videos.
- Keep album photo/video behavior correct (images + videos still list as today).
- Tests cover: recursive scan includes `.mp3`/`.flac` for audio listing; photo `listMedia` still returns images/videos.

### R2 — Streamable source URL

- Expose a method to build the File Browser raw `Uri` for a given app path (same derivation as existing FB client: protocol/host + port 8080 unless overridden).
- Playback MUST prefer **streaming/progressive** from that URI; must NOT require loading the entire file into Dart memory for normal play.
- Auth model remains: anonymous FB or reverse-proxy already authenticated (no new FB login UI).

### R3 — Real playback controls

- Play / pause toggles real player state.
- Seek bar reflects position/duration; user can seek when duration known.
- Loading and error states are visible and localized (network fail, 403, unsupported format).
- Leaving the player page does not silently leave a stuck error; dispose/stop policy documented in design (recommend: stop on dispose for MVP unless mini-player is in scope — mini-player is out of scope).

### R4 — Playback queue

- Opening a track from library sets queue = current filtered/list context (at least: all loaded tracks on that page, or full library list passed via args).
- Previous / next moves within queue; wraps or stops at ends (recommend: stop at ends, no infinite loop).
- Player args must include: `apiClient` (or stream base), `queue: List<UnraidFileEntry>`, `initialIndex`.
- Now Playing card on music home reflects current track when possible; if no global audio service, at least show first track or last selected after return (design may use a lightweight in-memory holder for session).

### R5 — Localization & quality

- All new UI strings in zh + en ARB.
- Service errors through existing exception/`DisplayCopy` patterns.
- `flutter analyze` + `flutter test` green.
- Widget or unit tests for: audio listing filter; queue index next/prev edge; raw URI builder if pure logic.

## Acceptance Criteria

- [ ] With File Browser serving `/mnt/user/music` containing audio files, Music home shows non-empty library (not always empty due to `isMedia` bug).
- [ ] Tap a track → player opens → audio actually plays on at least **Android** and **Windows** (Web best-effort if CORS/FB allows; document limitation if Web blocked).
- [ ] Pause/play, seek, prev/next work with correct queue membership.
- [ ] Stream/auth/format failures show localized SnackBar or inline error, not a frozen shell.
- [ ] Album media listing still shows photos/videos.
- [ ] analyze + test pass.

## Out of Scope

- Background playback notification / lock-screen controls (nice-to-have follow-up).
- Persistent playlists, shuffle/repeat modes beyond optional simple repeat-off default.
- Lyrics, equalizer, gapless crossfade.
- Downloading offline cache.
- Artwork extraction from tags (keep gradient cover art for MVP).
- Changing default music root in settings UI.

## Recommended defaults (product)

| Decision | Recommendation | Rationale |
|----------|-----------------|-----------|
| Player engine | `just_audio` (+ `audio_session` if needed on mobile) | Mature URL streaming in Flutter |
| Stream vs full download | Stream raw URL | Memory + start latency |
| Queue source | Full current library list / tracks page list | Matches user expectation of prev/next |
| End of queue | Stop | Predictable |
| Mini-player | No | Scope control |
| Web | Best-effort | CORS/FB often blocks |

## Open Questions

None blocking if recommendations accepted. Optional override: player package choice (`just_audio` vs `audioplayers`).
