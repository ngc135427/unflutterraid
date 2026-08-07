# 共享文件预览优化 — Technical Design

## Scope and boundaries

This task changes only the Share file browser flow. It does not replace the Album viewer or the existing full music library player.

The feature spans three boundaries:

```text
File Browser resources/raw/preview
  -> UnraidFileManager + UnraidFileEntry
  -> Share preview route and type-specific preview widgets
  -> localized loading/error/control states
```

All file HTTP access remains owned by `UnraidFileManager`. Widgets receive typed `UnraidFileEntry` values and must not reconstruct File Browser paths.

## Package choices

- Use `media_kit`, `media_kit_video`, and `media_kit_libs_video` for video preview. The package supports Android, iOS, macOS, Windows, Linux, and Web, and supplies video controls and network playback. Source: https://pub.dev/packages/media_kit
- Reuse existing `just_audio` for audio preview instead of adding a second audio-only integration.
- Use `pdfrx` and `PdfViewer.uri` for PDF rendering from the File Browser raw URL. It supports the same current Flutter platform set. Source: https://pub.dev/packages/pdfrx
- Do not use Flutter's official `video_player` because its published platform list omits Windows and Linux, both present in this repository. Source: https://pub.dev/packages/video_player

`pdfrx` currently requires Windows Developer Mode during native builds because its build uses symbolic links. Treat that as an environment prerequisite, not a reason to weaken PDF behavior on other platforms.

Pinned compatible dependency ranges at planning time:

```yaml
media_kit: ^1.2.6
media_kit_video: ^2.0.1
media_kit_libs_video: ^1.0.7
pdfrx: ^2.4.7
```

Run dependency resolution before implementation proceeds past the package step. If current transitive constraints conflict, stop and revise the package choice rather than forcing overrides.

## Typed file contract

Extend `UnraidFileEntry` with:

- optional raw `byteSize`, parsed once from the File Browser resource payload;
- a normalized extension getter;
- an exhaustive `FilePreviewKind` enum: `image`, `video`, `audio`, `text`, `pdf`, `unsupported`;
- `isPreviewable`, derived from the enum.

Existing `isImage`, `isVideo`, and `isAudio` become projections of the same normalized extension classification so extension sets have one owner. Office and archive extensions always map to `unsupported`.

Text preview covers common plain-text, log, markup, config, data, script, and source extensions. UTF-8 is decoded with malformed-byte replacement; a UTF-8 BOM is removed. Encoding detection beyond UTF-8 is out of scope.

## Size-limited text reads

Add an optional byte limit to the File Manager raw-byte read contract. Limited reads use `http.Client.send` and consume the response stream incrementally:

1. Validate HTTP status with the same File Browser error mapping used by normal requests.
2. Reject immediately when `contentLength` exceeds the limit.
3. Stop consuming and throw `UnraidApiException` as soon as accumulated chunks exceed the limit.
4. Preserve the existing timeout and localized service-error behavior.

The UI also checks `UnraidFileEntry.byteSize` before requesting, but the streaming limit remains authoritative because metadata may be missing or inaccurate. The limit is `2 * 1024 * 1024` bytes.

## Preview navigation

Create `lib/pages/share_file_preview_page.dart` as a full-screen route receiving:

- `UnraidApiClient client`;
- the current directory's previewable entries in display order;
- the initially selected index.

The route owns a `PageController` and current index. Its app bar shows the remote file name and `{current}/{total}`. Previous/next buttons and horizontal page gestures drive the same controller.

Each preview child receives an `active` flag. On `active: true -> false`, media widgets pause. On disposal, every player/controller is disposed. Page changes never mutate the directory listing or selection state.

## Type-specific rendering

### Image

- Load `readPreviewBytes` first and render it inside `InteractiveViewer`.
- Offer a localized “view original” action.
- Only that action starts `readFileBytes`; once loaded, replace the thumbnail without closing the viewer.
- Preserve loading, retry/error, zoom, and pan states.

### Video

- Initialize `MediaKit` once before `runApp`.
- Open `fileManager.rawUri(entry.path)` in a page-owned `media_kit` player.
- Do not autoplay.
- Use material controls for play/pause, seek, duration, and fullscreen.
- Surface initialization/playback failures inline and allow retry by rebuilding the player.

### Audio

- Create a page-owned `just_audio.AudioPlayer` using the raw URI.
- Show file name, audio icon, play/pause, buffered/played progress, seek slider, and duration.
- Do not join or mutate the global music queue.

### Text

- Call the size-limited raw-byte method.
- Decode UTF-8, remove BOM, and show `SelectableText` in a scrollable monospace view.
- Display a localized file-too-large error without retrying the same over-limit request.

### PDF

- Use `PdfViewer.uri(fileManager.rawUri(entry.path))`.
- Keep PDF zoom/page scrolling inside the PDF widget; the outer route continues to own previous/next file navigation.
- Surface document-load and password errors through localized inline error UI when the package callback exposes them.

## Share browser integration

In `main_shell_page.dart`:

- choose icons from `FilePreviewKind`, including video, audio, text, and PDF;
- on file tap, open the new preview route with `_lastShareEntries.where(isPreviewable)` and the tapped index;
- retain `previewUnsupported` for unsupported files;
- remove the private dialog-only `_ImagePreview` after all callers move to the route.

## Localization

Add matching keys to `app_zh.arb` and `app_en.arb` for preview title/actions, original-image loading, text-too-large, generic preview failure/retry, media duration states, and PDF/media labels. Reuse existing keys such as `close`, `retry`, `paused`, `albumViewerPage`, and `imageLoadFailed` where semantics match. Regenerate and commit generated localization files.

Service-layer size-limit messages must flow through `DisplayCopy`; UI-owned controls use `AppLocalizations`.

## Compatibility and rollback

- File Browser endpoint paths do not change.
- File management mutations and directory state remain untouched.
- New model fields are optional, keeping existing constructors and partial payloads compatible.
- Rollback consists of removing the preview route/dependencies and restoring the image-only tap branch; no persisted data or migration is introduced.

## Test strategy

- Service tests: extension classification, numeric byte-size mapping, normal limited read, `contentLength` rejection, streamed overflow rejection, and unchanged raw/preview paths.
- Widget tests: text preview success, over-limit error, file counter/navigation, unsupported-file exclusion, and close behavior. Avoid invoking native media/PDF plugins in widget tests.
- Static/full suite: `flutter gen-l10n`, `dart format`, `flutter analyze`, `flutter test`.
- Build smoke check on the locally available primary target after dependency integration; document any platform toolchain unavailable on the development machine.
