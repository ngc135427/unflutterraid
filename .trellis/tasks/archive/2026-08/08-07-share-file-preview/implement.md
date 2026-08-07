# 共享文件预览优化 — Implementation Plan

## Ordered checklist

1. **Resolve dependencies and platform setup**
   - Add the planned media/PDF packages.
   - Run `flutter pub get` and inspect resolver/platform setup output.
   - Add one-time `MediaKit.ensureInitialized()` initialization.
   - Rollback point: revert dependency and initialization changes if resolution or current platform build setup fails.

2. **Extend the File Manager contract**
   - Add centralized extension normalization and `FilePreviewKind` classification.
   - Add optional `byteSize` mapping without breaking existing constructors.
   - Implement an incrementally enforced size-limited byte read using the existing File Browser error model.
   - Add unit tests before UI integration.

3. **Add localization contracts**
   - Add matching Chinese/English ARB keys.
   - Wire new service messages through `DisplayCopy`.
   - Run localization generation and verify generated call signatures.

4. **Build the preview route**
   - Add the typed full-screen preview page, page counter, previous/next buttons, and horizontal navigation.
   - Implement shared loading/error/retry chrome.
   - Implement image thumbnail-first/original-on-demand and text preview.
   - Add widget tests for non-plugin paths.

5. **Add media and PDF renderers**
   - Implement page-owned video, audio, and PDF preview widgets.
   - Enforce no autoplay, pause-on-page-change, and disposal-on-exit.
   - Verify fullscreen video enter/exit behavior.

6. **Integrate the Share browser**
   - Map file icons from `FilePreviewKind`.
   - Open the preview route using the current directory's previewable entries and selected index.
   - Preserve unsupported feedback and all selection/file-management paths.
   - Remove the obsolete image dialog component.

7. **Documentation and full verification**
   - Update the README Share feature list and technical stack/data flow.
   - Search for duplicate extension sets and stale image-only preview branches.
   - Run formatting, analyzer, tests, and a locally available build smoke check.

## Validation commands

```powershell
flutter pub get
flutter gen-l10n
dart format lib test
flutter analyze
flutter test
flutter build windows --debug
```

If Windows native package compilation is unavailable for an environmental reason, run an Android debug APK build when the Android toolchain is available and record the exact skipped check.

## Risk and rollback points

- **Native dependency resolution:** stop after step 1 if the current Flutter/Dart/platform constraints do not resolve cleanly.
- **Streaming limit implementation:** do not change ordinary JSON/write requests; keep the limited read path isolated and covered by `MockClient` tests.
- **Gesture conflict:** PDF/zoom gestures may contend with outer horizontal paging. Keep explicit previous/next buttons as an always-available path and adjust gesture ownership if manual QA finds conflicts.
- **Player leakage:** controller disposal and pause-on-inactive are release blockers.
- **Regression boundary:** file mutations, batch selection, album preview, and the global music queue must remain behaviorally unchanged.
