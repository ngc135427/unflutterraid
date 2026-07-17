# Logging Guidelines

> Logging reality in this project.

---

## Overview

The app does **not** use a structured logging framework (`logger`, `talker`, etc.). Operational feedback for users is:

- Localized exceptions (`UnraidApiException.message`)
- SnackBars and page error states
- Optional `debugPrint` is rare and not a standard

Do not introduce heavy logging packages in drive-by changes. If diagnostics are needed during development, prefer temporary `debugPrint` removed before commit, or user-visible error messages.

---

## What to Surface to Users

| Event | Surface |
|-------|---------|
| Login / GraphQL failure | Form error or snackbar with exception message |
| File Browser unreachable | Localized File Browser connect/auth errors |
| Empty directory / no media | Empty-state copy (l10n), not an exception |
| Partial dashboard GraphQL errors | Allow partial data when configured; still show usable fields |

---

## What Not to Log

- API keys, passwords, full Authorization headers.
- Entire GraphQL query dumps in production UI.
- File contents.

---

## Developer Diagnostics

- Unit tests assert on exception messages and HTTP paths rather than log output.
- Analyzer (`flutter analyze`) is the primary static gate; there is no separate log-level config.

---

## If Logging Is Added Later

Prefer a single wrapper service, redact secrets, and keep default log level quiet for release builds. That would be a dedicated task — not implied by current code.
