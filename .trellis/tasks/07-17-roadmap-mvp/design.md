# Design: Roadmap MVP

## Theme

Mirror language preferences:

- `AppThemeMode` enum: system / light / dark
- `ThemePreferences` + SharedPreferences key `app_theme`
- `AppThemeScope` InheritedWidget
- `MaterialApp.theme` / `darkTheme` / `themeMode`
- Settings row: segmented control like language

## Music

- Pass `MusicPageArgs(apiClient, rootPath: '/mnt/user/music')` from home shortcut (fallback empty if no client — already gated).
- `listMedia` + filter `isAudio` on `UnraidFileEntry` (new extension set: mp3, flac, m4a, wav, aac, ogg, opus, wma).
- Stateful library list with search filter; player page can show selected track name or first track.

## File writes

`UnraidFileManager`:

- `delete(path)` → DELETE File Browser resource URI
- `rename(path, newName)` → PATCH with action rename (File Browser protocol)
- Share browser: long-press or trailing menu → rename dialog / delete confirm
- Enable subdirectory navigation (remove "future feature" block for share roots listing children)

## Trellis git

Root `.gitignore`:

```
# remove blanket .trellis/
# keep .trellis/.runtime/, backups via .trellis/.gitignore
```

Rely on `.trellis/.gitignore` for local-only files.
