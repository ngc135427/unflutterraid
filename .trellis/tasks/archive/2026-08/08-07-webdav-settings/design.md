# Design

## Boundaries

- Add a `FileBrowserPreferences` service under `lib/services/`.
- Store a map from normalized Unraid base URL to the optional File Browser base URL in `SharedPreferences`; the URL is non-secret connection metadata.
- Keep `UnraidApiClient` as the only owner of File Browser request construction.
- Add a dedicated settings route for editing the active connection's File Browser URL.
- Limit share-card simplification to the share branch of `_ManagementCard`.

## Data Flow

1. Login, server reconnect, or profile connect computes the Unraid base URL.
2. The flow asynchronously loads the File Browser override for that base URL.
3. `UnraidApiClient` receives the override through its existing `fileBrowserBaseUrl` constructor parameter; a missing override preserves the derived `:8080` default.
4. The File Browser settings page displays the active client's effective URL and whether it is custom or default.
5. Saving a non-empty valid HTTP(S) URL stores the normalized override. Saving an empty value removes it.
6. The page creates a replacement `UnraidApiClient` and replaces the navigation stack with `MainShellPage`, so all subsequent file operations immediately use the new URL.

## Contracts

- Preference lookup keys are normalized Unraid base URLs without trailing slashes.
- Override values are normalized HTTP(S) URLs without trailing slashes; paths are preserved for reverse-proxy deployments.
- Invalid JSON or invalid stored entries are ignored safely.
- Share cards retain their top-level `InkWell.onTap`; only share tags and the duplicated action row are hidden.

## Compatibility

- Existing installs have no override and continue using the current same-host port `8080` derivation.
- Existing server profiles do not require migration because the override store is keyed independently by base URL.
- Docker and VM rendering stays on the existing card branch.

## Trade-offs

- A separate keyed preference avoids duplicating connection metadata across remembered login and server-profile schemas.
- The task does not add File Browser credentials because the current transport sends no such authentication and the user approved the minimal File Browser approach.
- Saving applies immediately by replacing the active client rather than mutating final connection fields in place.

## Rollback

- Removing the preference service and settings route restores existing derived-port behavior.
- Removing the share-only rendering condition restores the previous tags and buttons without data migration.
