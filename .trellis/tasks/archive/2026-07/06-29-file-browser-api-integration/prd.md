# Integrate File Browser API

## Goal

Integrate File Browser as the app's file-management backend so album, share browsing, thumbnails, and file content access use File Browser HTTP API instead of Unraid WebGUI file endpoints or unsupported Unraid GraphQL file fields.

## Background

- The Flutter app currently uses Unraid GraphQL for dashboard, Docker, VM, and share-root metadata.
- The supplied Apollo Sandbox files (`knowledge/query.txt`, `knowledge/mutation.txt`, `knowledge/subscription.txt`) do not expose generic file listing, recursive directory browsing, thumbnails, or arbitrary file content fields.
- A previous boundary implementation introduced `UnraidFileManager`, but it currently only reads GraphQL share roots and returns empty media lists.
- The user wants to directly call File Browser API for complete file management capability.
- File Browser is an independent service commonly deployed beside Unraid and mounted to a root such as `/mnt/user`.

## Requirements

- R1. Add a File Browser API integration layer that can authenticate and call File Browser directly.
- R2. `UnraidFileManager` must use the File Browser integration for directory listing, recursive media discovery, thumbnail/preview retrieval, and raw file content retrieval.
- R3. Album page flows must call `apiClient.fileManager` only, not lower-level HTTP paths or Unraid WebGUI endpoints.
- R4. Share detail browsing must use the File Manager layer for browsing rather than Unraid WebGUI.
- R5. Keep Unraid GraphQL integration for server dashboard, Docker, VM, and share metadata.
- R6. Do not reintroduce WebGUI username/password or `Browse.php` dependencies.
- R7. Handle File Browser connection/auth failures with user-facing error messages.
- R8. Tests must cover File Browser URL derivation, directory listing, nested path handling, media discovery, preview byte retrieval, and raw file byte retrieval behavior.
- R9. README must describe the two-backend architecture: Unraid GraphQL for server management, File Browser API for files/media.
- R10. Do not add File Browser fields to the login page in the MVP.
- R11. Derive the default File Browser base URL from the Unraid base URL using a centralized default port/configuration point.
- R12. MVP assumes File Browser is reachable without Flutter-managed credentials because anonymous access or reverse-proxy authentication is configured outside the app.

## Acceptance Criteria

- [x] App derives a default File Browser base URL without adding login-page fields.
- [x] File Browser configuration is centralized and does not scatter constants through UI code.
- [x] The app does not collect or store File Browser credentials.
- [x] `UnraidFileManager.listDirectory(path)` returns real File Browser directory entries.
- [x] `UnraidFileManager.listMedia(rootPath)` recursively discovers image/video entries.
- [x] `UnraidFileManager.readFileBytes(path)` returns raw bytes from File Browser.
- [x] Album page uses File Manager for photos, videos, groups, and preview/thumbnail data.
- [x] Share detail page uses File Manager for directory browsing.
- [x] No code path calls Unraid WebGUI file endpoints for file browsing or preview.
- [x] `flutter analyze` passes.
- [x] `flutter test` passes.

## Out Of Scope

- Building or deploying the File Browser container on Unraid.
- Implementing a custom backend proxy.
- File mutation features such as upload, delete, rename, move, chmod, or editing.
- Replacing Unraid GraphQL for dashboard, Docker, VM, or share metadata.

## Decisions

- D1. The login page must remain simple. File Browser settings will not be added there for the MVP.
- D2. The MVP derives the File Browser URL from the Unraid URL and uses a centralized default port/configuration point. A dedicated settings screen can be added later if needed.
- D3. The MVP assumes File Browser is already anonymously accessible or protected by external reverse-proxy authentication. Flutter will not call `/api/login` or store File Browser credentials in this iteration.
