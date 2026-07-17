# Design: Share multi-select batch delete & move

## State on `_ManagementDetailPageState`

```dart
bool _selecting = false;
final Set<String> _selectedPaths = {};
bool _batchBusy = false;
```

- Enter select mode: long-press tile or toolbar “Select”.
- Exit: clear set + `_selecting = false`.
- Parent “..” tile never selectable.

## File Manager

```dart
Future<void> move(String path, String destinationDirectory) async {
  final name = basename(path);
  final destination = join(destinationDirectory, name);
  // PATCH rename destination=fbPath(destination), overwrite:false
}
```

Extract shared rename/move body if helpful. Keep `rename` for same-dir rename.

Optional batch helpers stay in UI loop (simpler).

## UI

### Toolbar when selecting

- Cancel selection
- Select all visible
- Delete (if any selected)
- Move (if any selected)
- Count badge

### Tile

- Leading checkbox when selecting
- onTap: toggle selection if selecting; else existing navigate/preview
- onLongPress: enter selecting + select this path

### Move destination picker

Reuse pattern from album backup dir browser (list directories under `/mnt/user`, up, select current). Can be private method dialog on same page to avoid large extract for MVP.

Guards:

- destination must not equal source parent for all (still OK if some need move)
- if entry is directory, destination must not be entry.path or under entry.path + '/'

## Error handling

Per-item try/catch; aggregate `ok/skip/fail` SnackBar via l10n.

## Tests

- `move` sends PATCH with destination under new parent
- path join / cannot-move-into-self pure function if extracted
