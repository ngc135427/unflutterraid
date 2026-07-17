# Error Handling

> How failures are modeled and surfaced.

---

## Overview

Networking and mapping code throws **`UnraidApiException`** with a localized, user-facing `message`. Pages catch it and show snackbars, error state cards, or inline form errors.

---

## Error Type

```dart
class UnraidApiException implements Exception {
  const UnraidApiException(this.message);
  final String message;
  @override
  String toString() => message;
}
```

**File**: `lib/services/unraid_api_client.dart`

- `message` is already suitable for UI display (via `DisplayCopy` or GraphQL error text).
- Do not nest exception types for MVP; one exception class is enough.

---

## Propagation Pattern

```text
HTTP / GraphQL / File Browser
  -> throw UnraidApiException(DisplayCopy.current.… or server message)
  -> page try/catch
  -> SnackBar / _error state / Form validator message
```

### UI catch example (login)

```dart
on UnraidApiException catch (error) {
  setState(() => _errorMessage = l10n.loginFailed(error.toString()));
}
```

### Async page loads

Album and share browser set `_error = l10n.loadFailed(e.toString())` (or equivalent) and show retry.

---

## GraphQL Errors

In `_request`:

| Condition | Behavior |
|-----------|----------|
| Timeout | `apiConnectionTimeout` |
| Transport failure | `apiCannotConnect(error)` |
| HTTP non-2xx | GraphQL error message if present, else `apiHttpError(status)` |
| Body not JSON map | `apiInvalidData` |
| `errors` present, no usable data | `apiGraphqlFailed` / first error message |
| `errors` present, `allowPartialData: true` and `data` map exists | **Continue** with partial data (dashboard) |
| Missing `data` field | `apiMissingDataField` |

### Validation & Error Matrix (File Browser)

| Condition | Message source |
|-----------|----------------|
| Timeout | `apiFileBrowserTimeout(action)` |
| Connect failure | `apiFileBrowserCannotConnect(error)` |
| HTTP 401/403 | `apiFileBrowserForbidden(status)` |
| HTTP 404 | `apiFileBrowserNotFound` |
| Other HTTP failure | `apiFileBrowserFailed(action, status)` |
| Invalid JSON body | `apiFileBrowserInvalidJson(action)` |

Auth failures intentionally mention anonymous access / reverse-proxy — credentials are **not** managed in Flutter (see PRD for File Browser task).

---

## Platform Channel Errors

`LoginPreferences` swallows `MissingPluginException` and returns empty defaults so desktop/widget tests work without the Android plugin.

---

## Forbidden Patterns

- Swallowing network errors without UI feedback.
- Throwing raw `Exception('中文…')` hard-coded outside `DisplayCopy`.
- Showing stack traces to end users.
- Requiring File Browser username/password in the app for MVP.

---

## Tests Required

- File Browser 401/403 surfaces the forbidden message (`test/unraid_api_client_test.dart`).
- Connection / mapping happy paths with `MockClient`.
