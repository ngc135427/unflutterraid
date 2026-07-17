# Frontend Development Guidelines

> Best practices for Flutter UI in this project.

---

## Overview

UI lives under `lib/pages/`, `lib/widgets/`, `lib/theme/`, and `lib/l10n/`. Follow patterns that already exist in login, main shell, settings, and album pages.

---

## Guidelines Index

| Guide | Description | Status |
|-------|-------------|--------|
| [Directory Structure](./directory-structure.md) | Module organization and file layout | Active |
| [Component Guidelines](./component-guidelines.md) | Components, localization, DisplayCopy | Active |
| [Hook Guidelines](./hook-guidelines.md) | Stateful logic / data loading (Flutter, not React hooks) | Active |
| [State Management](./state-management.md) | Local state, scopes, server futures | Active |
| [Quality Guidelines](./quality-guidelines.md) | Analyze, tests, forbidden patterns | Active |
| [Type Safety](./type-safety.md) | Dart types, JSON parsing, enums | Active |

---

## Pre-Development Checklist (Frontend)

- [ ] Read [Component Guidelines](./component-guidelines.md) if touching UI copy or pages
- [ ] Read [Directory Structure](./directory-structure.md) for where l10n / services live
- [ ] Read [State Management](./state-management.md) before adding app-wide state
- [ ] Read [Hook Guidelines](./hook-guidelines.md) before adding fetch/load helpers
- [ ] Read [Quality Guidelines](./quality-guidelines.md) before claiming done
- [ ] New user-facing strings: update **both** `app_zh.arb` and `app_en.arb`, then regenerate l10n
- [ ] Service-layer display strings: use `DisplayCopy`, not hard-coded Chinese
- [ ] File/media access only via `apiClient.fileManager`

---

## How to Maintain These Guidelines

1. Document the project's **actual** conventions (not ideals)
2. Include **code examples** from real paths under `lib/`
3. List **forbidden patterns** and why
4. Add **common mistakes** discovered during tasks

---

**Language**: All documentation should be written in **English**.
