# Design: Music streaming player and play queue

## Architecture

```
MusicPage / MusicTracksPage
  -> fileManager.listAudio(root)   // or listMedia(kind: audio)
  -> List<UnraidFileEntry>
  -> push MusicPlayerPage(args: MusicPlayerArgs)

MusicPlayerArgs
  - apiClient
  - queue: List<UnraidFileEntry>
  - initialIndex: int

MusicPlayerPage (Stateful)
  - owns just_audio AudioPlayer for this route
  - on init: setAudioSource(UriSource(rawUri)) + play
  - dispose: stop + dispose player

UnraidFileManager
  - rawUri(appPath) -> Uri   // public, pure mapping
  - listAudio / fixed media filter
```

No global audio service / mini-player in MVP (aligns with frontend state-management: no new app-wide store unless multi-route write is required). Queue lives only in route args for the player session.

## File Manager contracts

### Fix audio listing

**Problem:** `listMedia` drops `!isMedia`; `isMedia` is image|video only.

**Approach (prefer minimal API surface):**

1. Add `listMedia(rootPath, { MediaListKind kind = MediaListKind.visual })`  
   - `visual` = image|video (current album behavior)  
   - `audio` = isAudio  
   - `all` = image|video|audio (optional, unused in MVP)
2. Or dedicated `listAudio(rootPath)` that reuses recursive scan but filters `isAudio`.

**Recommendation:** `listAudio` thin method + keep `listMedia` as visual-only to avoid breaking album callers/tests. Document in method dartdoc.

```dart
Future<List<UnraidFileEntry>> listAudio(String rootPath, {int maxDepth = 3}) async {
  // same recursive request as listMedia
  // removeWhere directory or !isAudio
}
```

Music pages call `listAudio` instead of `listMedia` + `where isAudio`.

### Stream URI

Expose:

```dart
Uri rawUri(String appPath); // wraps existing _fileBrowserUri('/api/raw', path)
```

Do **not** stream via downloading full `readFileBytes` into memory.

Playback:

```dart
await player.setUrl(fileManager.rawUri(track.path).toString());
// or AudioSource.uri(...)
await player.play();
```

Assumption unchanged: File Browser anonymous or reverse-proxy auth; raw GET needs no Unraid API key headers today (current FB client does not attach `x-api-key` to FB requests — verify against `_send` and keep consistent).

## Player UX

| Control | Behavior |
|---------|----------|
| Play/Pause | Toggle `player.playing` |
| Seek | `player.seek` when duration known; disable while loading |
| Previous | `index-1` if `>=0` else no-op (or snackbar at start) |
| Next | `index+1` if `<queue.length` else no-op |
| Track end | Auto-advance to next if any; else stop |
| Errors | Localized banner/snackbar; keep metadata visible |

Title: `track.name`  
Subtitle: parent path segment or full `track.path` (current shell uses path).

## Queue semantics

- From `MusicPage` preview tile or now-playing: queue = full `_tracks` list, index = tapped item.
- From `MusicTracksPage`: queue = full unfiltered `_tracks` (search only filters display; recommend queue = **filtered list** if user is searching, else full list — **use currently displayed `filtered` list** so prev/next matches what user sees).
- Empty queue: do not open player.

## Dependencies

- `just_audio: ^0.9.x` (or latest compatible with SDK `>=3.4.0`)
- Mobile may need `audio_session` — add only if required for Android audio focus after smoke test.

Platform notes:

- **Android / Windows:** primary acceptance.
- **Web:** best-effort; CORS may block FB host — fail with clear message.
- **iOS:** if build works, same URL source; not blocking.

## Compatibility

- Album pages keep calling `listMedia` (visual).
- Existing tests for `listMedia` stay valid.
- New tests for `listAudio` and `rawUri` path mapping.
- `readFileBytes` remains for image preview / share; not for music play path.

## Trade-offs

| Option | Pro | Con | Decision |
|--------|-----|-----|----------|
| just_audio URL | Stream, low RAM | Extra dep | **Yes** |
| Full bytes + bytes source | No extra URL API | OOM on FLAC | No |
| Global AudioHandler | Background/lock screen | Scope creep | No MVP |
| Expand isMedia to include audio | One list method | Album semantics muddied | Prefer separate `listAudio` |

## Rollback

- Remove `just_audio` dependency and player stateful wiring; restore shell UI.
- Revert music pages to previous load call (even if buggy) only if emergency; prefer keep `listAudio` fix even if player rolls back.

## Security / privacy

- Stream URLs use same FB base as rest of app (often LAN).
- Do not log full raw URLs with credentials (none today).
- Do not persist API keys into audio plugin config.
