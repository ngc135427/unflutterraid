# Implementation Plan

## Checklist

1. Service-layer File Browser adapter
   - Add centralized File Browser base URL derivation.
   - Add path encoding helpers for File Browser endpoints.
   - Add `UnraidFileManager.listRoot`.
   - Add `UnraidFileManager.listDirectory`.
   - Add `UnraidFileManager.listMedia`.
   - Add `UnraidFileManager.readFileBytes`.
   - Add `UnraidFileManager.readPreviewBytes`.
   - Keep compatibility methods on `UnraidApiClient` delegating to `fileManager`.

2. Data parsing
   - Parse File Browser resource JSON defensively.
   - Map child `items` into `UnraidFileEntry`.
   - Parse recursive listing whether it returns a root resource with nested items or a flat list.
   - Preserve media detection through existing `isImage`, `isVideo`, and `isMedia`.

3. Album page integration
   - Ensure photos/videos/groups use `apiClient.fileManager`.
   - Restore thumbnail loading through `readPreviewBytes`.
   - Keep graceful placeholders when previews fail.

4. Share detail integration
   - Ensure directory browsing uses `fileManager.listDirectory`.
   - Ensure image preview uses `fileManager.readFileBytes`.
   - Update empty/error copy if needed.

5. Tests
   - Update `test/unraid_api_client_test.dart` to mock File Browser endpoints.
   - Cover derived File Browser URL.
   - Cover directory listing.
   - Cover recursive media discovery.
   - Cover preview/raw byte retrieval.
   - Cover auth/proxy failure messages.

6. Documentation
   - Update `README.md` with File Browser deployment assumption and default port.
   - Document that login page remains simple and File Browser auth is external.

## Validation Commands

```bash
dart format lib test
flutter analyze
flutter test
```

## Risky Files

- `lib/services/unraid_api_client.dart`: shared API client and File Manager contracts.
- `lib/pages/album_page.dart`: media loading and thumbnail UI.
- `lib/pages/main_shell_page.dart`: share browsing and image preview.
- `test/unraid_api_client_test.dart`: mocks must reflect File Browser response shapes.

## Rollback Points

- If File Browser response shape differs, keep service-layer adapter isolated and adjust parser there.
- If preview endpoint is incompatible, fall back to raw bytes for image previews while keeping thumbnail method as a separate adapter method.
- If default port derivation is wrong for the user's deployment, change only the centralized default port/derivation helper.
