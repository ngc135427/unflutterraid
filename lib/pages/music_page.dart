import 'dart:async';

import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';

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

class MusicPlayerArgs {
  const MusicPlayerArgs({
    required this.apiClient,
    required this.queue,
    required this.initialIndex,
  });

  final UnraidApiClient apiClient;
  final List<UnraidFileEntry> queue;
  final int initialIndex;

  UnraidFileEntry get initialTrack => queue[initialIndex];
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
      final tracks = await args.apiClient.fileManager.listAudio(args.rootPath);
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

  void _openPlayer(int index) {
    final args = _args;
    if (args == null || _tracks.isEmpty) {
      return;
    }
    final safeIndex = index.clamp(0, _tracks.length - 1);
    Navigator.of(context).pushNamed(
      MusicPlayerPage.routeName,
      arguments: MusicPlayerArgs(
        apiClient: args.apiClient,
        queue: List<UnraidFileEntry>.from(_tracks),
        initialIndex: safeIndex,
      ),
    );
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
            onTap: current == null ? null : () => _openPlayer(0),
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
            for (var i = 0; i < preview.length; i++)
              _TrackTile(
                track: preview[i],
                onTap: () => _openPlayer(i),
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
      final tracks = await args.apiClient.fileManager.listAudio(args.rootPath);
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

  List<UnraidFileEntry> get _filtered {
    final query = _searchController.text.trim().toLowerCase();
    if (query.isEmpty) {
      return _tracks;
    }
    return _tracks
        .where((track) => track.name.toLowerCase().contains(query))
        .toList();
  }

  void _openPlayer(List<UnraidFileEntry> queue, int index) {
    final args = _args;
    if (args == null || queue.isEmpty) {
      return;
    }
    final safeIndex = index.clamp(0, queue.length - 1);
    Navigator.of(context).pushNamed(
      MusicPlayerPage.routeName,
      arguments: MusicPlayerArgs(
        apiClient: args.apiClient,
        queue: List<UnraidFileEntry>.from(queue),
        initialIndex: safeIndex,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final filtered = _filtered;

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
            for (var i = 0; i < filtered.length; i++)
              _TrackTile(
                track: filtered[i],
                onTap: () => _openPlayer(filtered, i),
              ),
        ],
      ),
    );
  }
}

class MusicPlayerPage extends StatefulWidget {
  const MusicPlayerPage({super.key});

  static const routeName = '/music-player';

  @override
  State<MusicPlayerPage> createState() => _MusicPlayerPageState();
}

class _MusicPlayerPageState extends State<MusicPlayerPage> {
  final AudioPlayer _player = AudioPlayer();
  StreamSubscription<PlayerState>? _playerStateSub;
  StreamSubscription<Duration>? _positionSub;
  StreamSubscription<Duration?>? _durationSub;
  StreamSubscription<PlaybackEvent>? _eventSub;

  MusicPlayerArgs? _args;
  int _index = 0;
  bool _loading = true;
  String? _error;
  Duration _position = Duration.zero;
  Duration _duration = Duration.zero;
  bool _playing = false;
  bool _initialized = false;

  UnraidFileEntry? get _track {
    final args = _args;
    if (args == null || args.queue.isEmpty) {
      return null;
    }
    if (_index < 0 || _index >= args.queue.length) {
      return null;
    }
    return args.queue[_index];
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_initialized) {
      return;
    }
    _initialized = true;
    final raw = ModalRoute.of(context)?.settings.arguments;
    if (raw is MusicPlayerArgs && raw.queue.isNotEmpty) {
      _args = raw;
      _index = raw.initialIndex.clamp(0, raw.queue.length - 1);
      _bindPlayerStreams();
      unawaited(_loadCurrentTrack(autoplay: true));
    } else if (raw is UnraidFileEntry) {
      // Legacy single-track args are not supported without a client.
      _error = AppLocalizations.of(context).missingConnectionArgs;
      _loading = false;
    } else {
      _error = AppLocalizations.of(context).missingConnectionArgs;
      _loading = false;
    }
  }

  void _bindPlayerStreams() {
    _positionSub = _player.positionStream.listen((position) {
      if (!mounted) {
        return;
      }
      setState(() => _position = position);
    });
    _durationSub = _player.durationStream.listen((duration) {
      if (!mounted || duration == null) {
        return;
      }
      setState(() => _duration = duration);
    });
    _playerStateSub = _player.playerStateStream.listen((state) {
      if (!mounted) {
        return;
      }
      setState(() => _playing = state.playing);
      if (state.processingState == ProcessingState.completed) {
        unawaited(_onTrackCompleted());
      }
    });
    _eventSub = _player.playbackEventStream.listen(
      (_) {},
      onError: (Object error, StackTrace stackTrace) {
        if (!mounted) {
          return;
        }
        setState(() {
          _loading = false;
          _error =
              AppLocalizations.of(context).musicPlaybackError(error.toString());
        });
      },
    );
  }

  Future<void> _loadCurrentTrack({required bool autoplay}) async {
    final args = _args;
    final track = _track;
    if (args == null || track == null) {
      return;
    }

    setState(() {
      _loading = true;
      _error = null;
      _position = Duration.zero;
      _duration = Duration.zero;
    });

    try {
      final uri = args.apiClient.fileManager.rawUri(track.path);
      await _player.setAudioSource(AudioSource.uri(uri));
      if (!mounted) {
        return;
      }
      setState(() {
        _loading = false;
        _duration = _player.duration ?? Duration.zero;
      });
      if (autoplay) {
        await _player.play();
      }
    } catch (error) {
      if (!mounted) {
        return;
      }
      setState(() {
        _loading = false;
        _error =
            AppLocalizations.of(context).musicPlaybackError(error.toString());
      });
    }
  }

  Future<void> _onTrackCompleted() async {
    final args = _args;
    if (args == null) {
      return;
    }
    if (_index + 1 < args.queue.length) {
      setState(() => _index += 1);
      await _loadCurrentTrack(autoplay: true);
    } else {
      await _player.seek(Duration.zero);
      await _player.pause();
    }
  }

  Future<void> _togglePlayPause() async {
    if (_loading || _error != null) {
      return;
    }
    if (_player.playing) {
      await _player.pause();
    } else {
      await _player.play();
    }
  }

  Future<void> _seek(double value) async {
    if (_duration.inMilliseconds <= 0) {
      return;
    }
    final position = Duration(
      milliseconds: (value * _duration.inMilliseconds).round(),
    );
    await _player.seek(position);
  }

  Future<void> _previous() async {
    final l10n = AppLocalizations.of(context);
    if (_index <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.musicQueueStart)),
      );
      return;
    }
    setState(() => _index -= 1);
    await _loadCurrentTrack(autoplay: true);
  }

  Future<void> _next() async {
    final args = _args;
    final l10n = AppLocalizations.of(context);
    if (args == null || _index + 1 >= args.queue.length) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.musicQueueEnd)),
      );
      return;
    }
    setState(() => _index += 1);
    await _loadCurrentTrack(autoplay: true);
  }

  @override
  void dispose() {
    _playerStateSub?.cancel();
    _positionSub?.cancel();
    _durationSub?.cancel();
    _eventSub?.cancel();
    unawaited(_player.dispose());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final track = _track;
    final title = track?.name ?? l10n.music;
    final subtitle = track?.path ?? '';
    final progress = _duration.inMilliseconds <= 0
        ? 0.0
        : (_position.inMilliseconds / _duration.inMilliseconds)
            .clamp(0.0, 1.0)
            .toDouble();

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
                      l10n.collapse,
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
                          child: _loading
                              ? const Center(
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                  ),
                                )
                              : const Icon(
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
                      subtitle,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.74),
                        fontSize: 15,
                      ),
                    ),
                    if (_error != null) ...[
                      const SizedBox(height: 12),
                      Text(
                        _error!,
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.red.shade100,
                          fontSize: 13,
                        ),
                      ),
                      TextButton(
                        onPressed: () =>
                            unawaited(_loadCurrentTrack(autoplay: true)),
                        child: Text(
                          l10n.retry,
                          style: const TextStyle(color: Colors.white),
                        ),
                      ),
                    ] else if (_loading) ...[
                      const SizedBox(height: 12),
                      Text(
                        l10n.musicLoadingTrack,
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.8),
                          fontSize: 13,
                        ),
                      ),
                    ],
                    const SizedBox(height: 26),
                    _PlayerProgress(
                      progress: progress,
                      position: _position,
                      duration: _duration,
                      enabled: !_loading && _error == null,
                      onSeek: (value) => unawaited(_seek(value)),
                    ),
                    const SizedBox(height: 24),
                    _PlayerControls(
                      playing: _playing,
                      enabled: !_loading && _error == null,
                      onPrevious: () => unawaited(_previous()),
                      onPlayPause: () => unawaited(_togglePlayPause()),
                      onNext: () => unawaited(_next()),
                    ),
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
  const _PlayerProgress({
    required this.progress,
    required this.position,
    required this.duration,
    required this.enabled,
    required this.onSeek,
  });

  final double progress;
  final Duration position;
  final Duration duration;
  final bool enabled;
  final ValueChanged<double> onSeek;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            trackHeight: 4,
            thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 7),
            overlayShape: const RoundSliderOverlayShape(overlayRadius: 14),
            activeTrackColor: Colors.white,
            inactiveTrackColor: Colors.white.withValues(alpha: 0.18),
            thumbColor: Colors.white,
            overlayColor: Colors.white.withValues(alpha: 0.16),
          ),
          child: Slider(
            value: progress.clamp(0.0, 1.0),
            onChanged: enabled ? onSeek : null,
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              _formatDuration(position),
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.76),
                fontSize: 12,
              ),
            ),
            Text(
              duration.inMilliseconds <= 0 ? '—:—' : _formatDuration(duration),
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
  const _PlayerControls({
    required this.playing,
    required this.enabled,
    required this.onPrevious,
    required this.onPlayPause,
    required this.onNext,
  });

  final bool playing;
  final bool enabled;
  final VoidCallback onPrevious;
  final VoidCallback onPlayPause;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(
          onPressed: enabled ? onPrevious : null,
          icon: Icon(
            Icons.skip_previous,
            color: Colors.white.withValues(alpha: enabled ? 1 : 0.4),
            size: 34,
          ),
        ),
        const SizedBox(width: 18),
        Material(
          color: Colors.white,
          shape: const CircleBorder(),
          child: InkWell(
            customBorder: const CircleBorder(),
            onTap: enabled ? onPlayPause : null,
            child: SizedBox(
              width: 64,
              height: 64,
              child: Icon(
                playing ? Icons.pause : Icons.play_arrow,
                color: enabled
                    ? AppTheme.primary
                    : AppTheme.primary.withValues(alpha: 0.4),
                size: 34,
              ),
            ),
          ),
        ),
        const SizedBox(width: 18),
        IconButton(
          onPressed: enabled ? onNext : null,
          icon: Icon(
            Icons.skip_next,
            color: Colors.white.withValues(alpha: enabled ? 1 : 0.4),
            size: 34,
          ),
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
                const Icon(Icons.play_arrow, color: AppTheme.primary),
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
          Icon(icon, size: 44, color: AppTheme.textLight),
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

String _formatDuration(Duration value) {
  final totalSeconds = value.inSeconds;
  final minutes = totalSeconds ~/ 60;
  final seconds = totalSeconds % 60;
  return '$minutes:${seconds.toString().padLeft(2, '0')}';
}
