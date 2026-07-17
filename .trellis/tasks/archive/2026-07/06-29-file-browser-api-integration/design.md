# Design: File Browser API Integration

## Architecture

The app will use two backend surfaces:

- Unraid GraphQL remains responsible for server management data: dashboard, Docker, VM, share metadata, notifications, and metrics.
- File Browser HTTP API becomes the file/media backend used by `UnraidFileManager`, album pages, and share detail browsing.

`UnraidApiClient` will continue to own shared server configuration and the HTTP client. It will expose `fileManager`, which delegates to a File Browser API adapter. UI pages must call `apiClient.fileManager` rather than constructing File Browser URLs directly.

## File Browser Base URL

The MVP must not add File Browser fields to the login page.

Default derivation:

- Start from the normalized Unraid base URL.
- Keep the same scheme and host.
- Replace the port with a centralized default File Browser port, initially `8080`.
- Preserve no Unraid-specific path suffix.

Examples:

- `http://tower.local` -> `http://tower.local:8080`
- `https://tower.local` -> `https://tower.local:8080`
- `http://192.168.1.10:80` -> `http://192.168.1.10:8080`

The derivation must live in service-layer code, not UI widgets, so a future settings page can override it without touching album/share pages.

## Authentication

MVP assumes File Browser is already accessible through anonymous mode or reverse-proxy authentication. Flutter will not collect, store, or send File Browser username/password.

The adapter should still be shaped so an optional token/header can be added later. For now, it sends plain HTTP requests to the derived File Browser base URL.

## API Endpoints

The implementation will target File Browser v2 HTTP endpoints observed in upstream source:

- `GET /api/resources/<path>`: directory/file metadata.
- `GET /api/resources/recursive/<path>`: recursive listing.
- `GET /api/raw/<path>`: raw file content.
- `GET /api/preview/<size>/<path>?inline=true`: preview/thumbnail image.

Known upstream caveat: File Browser API documentation is limited; the app should parse defensively and show clear errors when response shapes differ.

## Data Contracts

Internal file model remains `UnraidFileEntry` for now to minimize UI churn.

Expected File Browser resource fields:

- `name`
- `path`
- `url`
- `type`
- `isDir`
- `size`
- `modified`
- `items` for directory children

Mapping rules:

- `isDir == true` maps to `isDirectory`.
- `name` falls back to the final path segment.
- `path` uses the File Browser path if present; otherwise derives from parent path and name.
- `size` becomes a human-readable byte string when numeric.
- `modified` remains ISO/string data and is parsed by existing `modifiedDate`.

## Album Flow

Album pages call:

- `fileManager.listMedia(rootPath)` for photos/videos.
- `fileManager.listRoot()` or `fileManager.listDirectory(path)` for backup target selection.
- `fileManager.readPreviewBytes(path)` for thumbnails when displaying media tiles.
- `fileManager.readFileBytes(path)` for full image preview where needed.

The default album root remains `/mnt/user/photos`.

## Share Detail Flow

Share detail page calls `fileManager.listDirectory(path)` and `fileManager.readFileBytes(path)` for previews. It no longer relies on Unraid GraphQL for subdirectory traversal.

## Error Handling

All File Browser failures should throw `UnraidApiException` with user-facing messages:

- Cannot connect to File Browser.
- File Browser returned non-JSON resource data where JSON was expected.
- File Browser returned HTTP 401/403, suggesting auth/proxy configuration.
- File Browser returned HTTP 404 for missing paths.
- Preview/raw download failures.

## Compatibility

Existing tests and code may still call `fetchDirectory`, `fetchMediaFiles`, and `fetchFileBytes`. These compatibility methods should delegate to `fileManager` so older callers keep working.

## Out Of Scope

- File mutation endpoints: upload, rename, delete, copy, move.
- File Browser deployment on Unraid.
- Login-page configuration fields.
- Token-based File Browser login.
