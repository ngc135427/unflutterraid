import 'package:flutter/material.dart';

import '../l10n/generated/app_localizations.dart';
import '../services/unraid_api_client.dart';
import '../theme/app_theme.dart';
import '../widgets/fade_slide.dart';
import '../widgets/phone_frame.dart';

class MusicPageArgs {
  const MusicPageArgs({
    required this.apiClient,
    this.rootPath = '/mnt/user/music',
  });

  final UnraidApiClient apiClient;
  final String rootPath;
}

class MusicPage extends StatefulWidget {
  const MusicPage({super.key});

  static const routeName = '/music';

  @override
  State<MusicPage> createState() => _MusicPageState();
}

class _MusicPageState extends State<MusicPage> {
  List<UnraidFileEntry> _tracks = const [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadTracks());
  }

  MusicPageArgs? get _args {
    final args = ModalRoute.of(context)?.settings.arguments;
    return args is MusicPageArgs ? args : null;
  }

  Future<void> _loadTracks() async {
    final args = _args;
    if (args == null) {
      setState(() {
        _error = AppLocalizations.of(context).missingConnectionArgs;
        _loading = false;
      });
      return;
    }

    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final media = await args.apiClient.fileManager.listMedia(args.rootPath);
      final tracks = media.where((entry) => entry.isAudio).toList();
      if (!mounted) {
        return;
      }
      setState(() {
        _tracks = tracks;
        _loading = false;
      });
    } catch (error) {
      if (!mounted) {
        return;
      }
      setState(() {
        _error = AppLocalizations.of(context).loadFailed(error.toString());
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final preview = _tracks.take(8).toList();
    final current = _tracks.isEmpty ? null : _tracks.first;

    return _MusicScaffold(
      title: l10n.music,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _MusicSummary(
            songCount: _tracks.length,
            onSongsTap: () => Navigator.of(context).pushNamed(
              MusicTracksPage.routeName,
              arguments: _args,
            ),
          ),
          const SizedBox(height: 18),
          _NowPlayingCard(
            track: current,
            onTap: current == null
                ? null
                : () => Navigator.of(context).pushNamed(
                      MusicPlayerPage.routeName,
                      arguments: current,
                    ),
          ),
          const SizedBox(height: 22),
          Text(
            l10n.musicLibrary,
            style: const TextStyle(
              color: AppTheme.textDark,
              fontSize: 17,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          if (_loading)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 40),
              child: Center(child: CircularProgressIndicator()),
            )
          else if (_error != null)
            _MusicMessage(
              icon: Icons.error_outline,
              title: l10n.readFailedTitle,
              message: _error!,
              actionLabel: l10n.retry,
              onAction: _loadTracks,
            )
          else if (_tracks.isEmpty)
            _MusicMessage(
              icon: Icons.library_music_outlined,
              title: l10n.noMusicFound,
              message: l10n.musicLibraryEmpty,
              actionLabel: l10n.retry,
              onAction: _loadTracks,
            )
          else
            for (final track in preview)
              _TrackTile(
                track: track,
                onTap: () => Navigator.of(context).pushNamed(
                  MusicPlayerPage.routeName,
                  arguments: track,
                ),
              ),
        ],
      ),
    );
  }
}

class MusicTracksPage extends StatefulWidget {
  const MusicTracksPage({super.key});

  static const routeName = '/music-tracks';

  @override
  State<MusicTracksPage> createState() => _MusicTracksPageState();
}

class _MusicTracksPageState extends State<MusicTracksPage> {
  final _searchController = TextEditingController();
  List<UnraidFileEntry> _tracks = const [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadTracks());
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  MusicPageArgs? get _args {
    final args = ModalRoute.of(context)?.settings.arguments;
    return args is MusicPageArgs ? args : null;
  }

  Future<void> _loadTracks() async {
    final args = _args;
    if (args == null) {
      setState(() {
        _error = AppLocalizations.of(context).missingConnectionArgs;
        _loading = false;
      });
      return;
    }
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final media = await args.apiClient.fileManager.listMedia(args.rootPath);
      final tracks = media.where((entry) => entry.isAudio).toList();
      if (!mounted) {
        return;
      }
      setState(() {
        _tracks = tracks;
        _loading = false;
      });
    } catch (error) {
      if (!mounted) {
        return;
      }
      setState(() {
        _error = AppLocalizations.of(context).loadFailed(error.toString());
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final query = _searchController.text.trim().toLowerCase();
    final filtered = query.isEmpty
        ? _tracks
        : _tracks
            .where((track) => track.name.toLowerCase().contains(query))
            .toList();

    return _MusicScaffold(
      title: l10n.songs,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _TrackSearchBox(
            controller: _searchController,
            onChanged: (_) => setState(() {}),
          ),
          const SizedBox(height: 18),
          Text(
            l10n.allSongs,
            style: const TextStyle(
              color: AppTheme.textDark,
              fontSize: 17,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          if (_loading)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 40),
              child: Center(child: CircularProgressIndicator()),
            )
          else if (_error != null)
            _MusicMessage(
              icon: Icons.error_outline,
              title: l10n.readFailedTitle,
              message: _error!,
              actionLabel: l10n.retry,
              onAction: _loadTracks,
            )
          else if (filtered.isEmpty)
            _MusicMessage(
              icon: Icons.search_off,
              title: l10n.noMatchesTitle,
              message: l10n.noMatchesMessage,
            )
          else
            for (final track in filtered)
              _TrackTile(
                track: track,
                onTap: () => Navigator.of(context).pushNamed(
                  MusicPlayerPage.routeName,
                  arguments: track,
                ),
              ),
        ],
      ),
    );
  }
}

class MusicPlayerPage extends StatelessWidget {
  const MusicPlayerPage({super.key});

  static const routeName = '/music-player';

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)?.settings.arguments;
    final track = args is UnraidFileEntry ? args : null;
    final title = track?.name ?? AppLocalizations.of(context).music;
    final album = track?.path ?? '';

    return PhoneFrame(
      maxContentWidth: 900,
      child: Column(
        children: [
          SizedBox(
            height: 68,
            child: Stack(
              children: [
                Positioned(
                  left: 12,
                  top: 10,
                  child: TextButton.icon(
                    onPressed: () => Navigator.of(context).maybePop(),
                    icon: const Icon(Icons.keyboard_arrow_down,
                        color: Colors.white),
                    label: Text(
                      AppLocalizations.of(context).collapse,
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(30, 20, 30, 34),
              child: FadeSlide(
                child: Column(
                  children: [
                    Expanded(
                      child: Center(
                        child: Container(
                          width: 240,
                          height: 240,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [Color(0xFF3498DB), Color(0xFF52C41A)],
                            ),
                            borderRadius: BorderRadius.circular(28),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF3498DB)
                                    .withValues(alpha: 0.28),
                                blurRadius: 28,
                                offset: const Offset(0, 14),
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.music_note,
                            color: Colors.white,
                            size: 78,
                          ),
                        ),
                      ),
                    ),
                    Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      album,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.74),
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 26),
                    const _PlayerProgress(),
                    const SizedBox(height: 24),
                    const _PlayerControls(),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MusicScaffold extends StatelessWidget {
  const _MusicScaffold({
    required this.title,
    required this.child,
  });

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return PhoneFrame(
      maxContentWidth: 900,
      child: Column(
        children: [
          SizedBox(
            height: 48,
            child: Stack(
              children: [
                Positioned(
                  left: 8,
                  top: 0,
                  bottom: 0,
                  child: TextButton.icon(
                    onPressed: () => Navigator.of(context).maybePop(),
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                    label: Text(
                      AppLocalizations.of(context).back,
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                ),
                Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 112),
                    child: Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
              ),
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(30, 12, 30, 30),
                child: FadeSlide(
                  child: child,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MusicSummary extends StatelessWidget {
  const _MusicSummary({
    required this.songCount,
    required this.onSongsTap,
  });

  final int songCount;
  final VoidCallback onSongsTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: AppTheme.background,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primary.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          _MusicStat(
            label: l10n.songs,
            value: songCount.toString(),
            onTap: onSongsTap,
          ),
          _MusicStat(label: l10n.albums, value: '—'),
          _MusicStat(label: l10n.lossless, value: '—'),
        ],
      ),
    );
  }
}

class _MusicStat extends StatelessWidget {
  const _MusicStat({required this.label, required this.value, this.onTap});

  final String label;
  final String value;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(10),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Column(
              children: [
                Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppTheme.primary,
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style:
                      const TextStyle(color: AppTheme.textLight, fontSize: 12),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _TrackSearchBox extends StatelessWidget {
  const _TrackSearchBox({
    required this.controller,
    required this.onChanged,
  });

  final TextEditingController controller;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 44,
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: AppTheme.background,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.softLine),
      ),
      child: Row(
        children: [
          const Icon(Icons.search, color: AppTheme.primary, size: 20),
          const SizedBox(width: 9),
          Expanded(
            child: TextField(
              controller: controller,
              onChanged: onChanged,
              decoration: InputDecoration(
                isDense: true,
                border: InputBorder.none,
                hintText: AppLocalizations.of(context).searchMusic,
                hintStyle:
                    const TextStyle(color: AppTheme.textLight, fontSize: 14),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PlayerProgress extends StatelessWidget {
  const _PlayerProgress();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: 0,
            minHeight: 5,
            backgroundColor: Colors.white.withValues(alpha: 0.18),
            valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
          ),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '0:00',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.76),
                fontSize: 12,
              ),
            ),
            Text(
              '—:—',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.76),
                fontSize: 12,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _PlayerControls extends StatelessWidget {
  const _PlayerControls();

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(
          onPressed: () {},
          icon: const Icon(Icons.skip_previous, color: Colors.white, size: 34),
        ),
        const SizedBox(width: 18),
        Container(
          width: 64,
          height: 64,
          decoration: const BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.play_arrow,
            color: AppTheme.primary,
            size: 34,
          ),
        ),
        const SizedBox(width: 18),
        IconButton(
          onPressed: () {},
          icon: const Icon(Icons.skip_next, color: Colors.white, size: 34),
        ),
      ],
    );
  }
}

class _NowPlayingCard extends StatelessWidget {
  const _NowPlayingCard({
    required this.track,
    required this.onTap,
  });

  final UnraidFileEntry? track;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Ink(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF3498DB), Color(0xFF52C41A)],
            ),
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF3498DB).withValues(alpha: 0.25),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              const Icon(Icons.play_circle_fill, color: Colors.white, size: 42),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.nowPlaying,
                      style:
                          const TextStyle(color: Colors.white70, fontSize: 12),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      track?.name ?? l10n.noMusicFound,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 17,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TrackTile extends StatelessWidget {
  const _TrackTile({
    required this.track,
    required this.onTap,
  });

  final UnraidFileEntry track;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Ink(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppTheme.background,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppTheme.softLine),
            ),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: AppTheme.primary.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.music_note, color: AppTheme.primary),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        track.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: AppTheme.textDark,
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        track.path,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: AppTheme.textLight,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                if (track.size.isNotEmpty)
                  Text(
                    track.size,
                    style: const TextStyle(
                      color: AppTheme.textLight,
                      fontSize: 12,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _MusicMessage extends StatelessWidget {
  const _MusicMessage({
    required this.icon,
    required this.title,
    required this.message,
    this.actionLabel,
    this.onAction,
  });

  final IconData icon;
  final String title;
  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 28),
      child: Column(
        children: [
          Icon(icon, size: 42, color: AppTheme.textLight),
          const SizedBox(height: 12),
          Text(
            title,
            style: const TextStyle(
              color: AppTheme.textDark,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(color: AppTheme.textMedium, fontSize: 13),
          ),
          if (actionLabel != null && onAction != null) ...[
            const SizedBox(height: 14),
            TextButton(onPressed: onAction, child: Text(actionLabel!)),
          ],
        ],
      ),
    );
  }
}
