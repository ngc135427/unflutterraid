# Backend Development Guidelines

> Service-layer conventions for the Unflutterraid Flutter client (not a separate server process).

---

## Overview

This layer covers networking, mapping, preferences, and exception surfaces used by the UI. Source of truth is `lib/services/` plus tests under `test/`.

---

## Guidelines Index

| Guide | Description | Status |
|-------|-------------|--------|
| [Directory Structure](./directory-structure.md) | Service layout, two-backend split | Active |
| [Persistence](./database-guidelines.md) | Preferences only (no SQL DB) | Active |
| [Error Handling](./error-handling.md) | `UnraidApiException`, GraphQL/FB errors | Active |
| [Quality Guidelines](./quality-guidelines.md) | Tests, forbidden patterns | Active |
| [Logging Guidelines](./logging-guidelines.md) | User-facing errors vs logging | Active |

---

## Pre-Development Checklist (Services)

- [ ] Read [Directory Structure](./directory-structure.md) for GraphQL vs File Browser boundaries
- [ ] Read [Error Handling](./error-handling.md) before changing `_request` / File Browser helpers
- [ ] Read [Persistence](./database-guidelines.md) before adding stored fields
- [ ] New user-facing service strings → ARB + `DisplayCopy`
- [ ] Extend `test/unraid_api_client_test.dart` (or add focused tests) for new endpoints

---

## Related Frontend Specs

- Localization / `DisplayCopy` activation: `.trellis/spec/frontend/component-guidelines.md`
- State ownership of clients: `.trellis/spec/frontend/state-management.md`

---

**Language**: Spec documents are written in **English**.
