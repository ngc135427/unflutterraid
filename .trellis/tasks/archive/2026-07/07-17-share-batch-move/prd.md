# 共享浏览：多选批量删除与移动

## Goal

在共享目录浏览器中支持多选，对选中项执行**批量删除**与**移动到另一目录**，把文件管理从「单文件菜单」提升到可日常整理 NAS 的水准。

## Confirmed Facts

- Share browser: `ManagementDetailPage` when type is share (`main_shell_page.dart`).
- Single-item rename/delete via popup menu already work.
- `UnraidFileManager.rename` PATCH `action: rename` + `destination` (can target another path for move).
- `delete` per path exists; no multi-select UI yet.
- File Browser path mapping `/mnt/user/...` ↔ FB paths already implemented.

## Requirements

### R1 — Multi-select mode

- User can enter/exit selection mode in share browser.
- Tap checkbox or long-press to select; selecting first item may enter selection mode.
- Show selected count in app bar / toolbar.
- “Select all” (current directory list only) and “Clear selection”.

### R2 — Batch delete

- Confirm dialog with count.
- Delete selected entries sequentially (or best-effort each); report success/fail summary.
- Refresh directory after; clear selection.

### R3 — Move

- Move selected items to a chosen destination directory under `/mnt/user` (picker like backup dir browser, restricted to share roots or full `/mnt/user` tree).
- Implementation: File Browser rename/move via destination path = `join(destDir, entry.name)`.
- Skip if destination equals current parent; skip name conflicts (overwrite false) with count in summary.
- Do not allow moving an item into its own path / descendant if directory (basic guard).

### R4 — Quality

- zh + en strings.
- Unit tests for move destination path building / conflict skip helpers if pure; FB move HTTP mapping.
- analyze + test green.
- Single rename/delete still available outside multi-select (or via menu when not multi-selecting).

## Acceptance Criteria

- [ ] User can multi-select files/folders in share browser.
- [ ] Batch delete removes selected items with confirmation + summary.
- [ ] Move relocates selected items to chosen folder; conflicts skipped safely.
- [ ] List refreshes; selection clears after successful batch op.
- [ ] analyze + test pass.

## Out of Scope

- Drag-and-drop.
- Copy (duplicate) as separate action.
- Cross-device / external storage moves.
- Undo trash.

## Decisions

| Item | Choice |
|------|--------|
| Move API | PATCH rename with full destination path |
| Conflict | Skip (overwrite false) |
| Scope | Current share browser only |
