# Document CLIProxyAPI invalid-account cleanup

## Goal

Provide a safe, repeatable way to batch-delete invalid CLIProxyAPI authentication accounts without deleting credentials that are merely waiting for OAuth token refresh.

## Background

- The installed CLIProxyAPI version is 7.2.80.
- Its management center is served at `http://127.0.0.1:8317/management.html`.
- The 7.2.80 management center supports provider filtering, a `Problem` status filter, `Delete Problem Files`, selecting filtered results, and deleting selected files.
- The management UI classifies a credential as problematic when its runtime `status_message` is non-empty.
- An expired access-token timestamp alone is not sufficient evidence that an OAuth account is permanently invalid because a refresh token may renew it.
- The management API accepts batch deletion through `DELETE /v0/management/auth-files` with a JSON `names` array and requires a management key.

## Requirements

- Recommend the built-in management-center workflow as the default approach.
- Limit deletion to the intended provider, such as xAI, before applying the `Problem` status filter.
- Require reviewing the filtered count or selected filenames before confirmation.
- Explain that `Delete All` and filesystem wildcard deletion are not appropriate for invalid-account cleanup.
- Provide the management API contract as an optional automation path without exposing stored credentials or the management key.

## Acceptance Criteria

- [x] The user can identify the management-center controls needed to remove problematic accounts in bulk.
- [x] The instructions distinguish runtime problem status from a refreshable expired access token.
- [x] The instructions include a preview-before-delete safety step.
- [x] The optional API example deletes only explicitly selected filenames.
- [x] No project code, authentication token, or management key is modified or disclosed.

## Out of Scope

- Automatically deleting accounts from the user's running proxy.
- Determining account validity solely from the credential JSON `expired` field.
- Repairing or renewing invalid third-party xAI accounts.
