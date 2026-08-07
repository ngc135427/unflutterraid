import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:media_kit/media_kit.dart' as media_kit;
import 'package:media_kit_video/media_kit_video.dart';
import 'package:pdfrx/pdfrx.dart';

import '../l10n/generated/app_localizations.dart';
import '../services/unraid_api_client.dart';

class ShareFilePreviewPage extends StatefulWidget {
  const ShareFilePreviewPage({
    required this.client,
    required this.entries,
    required this.initialIndex,
    super.key,
  })  : assert(entries.length > 0),
        assert(initialIndex >= 0 && initialIndex < entries.length);

  final UnraidApiClient client;
  final List<UnraidFileEntry> entries;
  final int initialIndex;

  @override
  State<ShareFilePreviewPage> createState() => _ShareFilePreviewPageState();
}

class _ShareFilePreviewPageState extends State<ShareFilePreviewPage> {
  late final PageController _pageController;
  late int _index;

  @override
  void initState() {
    super.initState();
    _index = widget.initialIndex;
    _pageController = PageController(initialPage: _index);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _goTo(int index) async {
    if (index < 0 || index >= widget.entries.length || index == _index) {
      return;
    }
    await _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOutCubic,
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final entry = widget.entries[_index];
    return Scaffold(
      backgroundColor: const Color(0xFF111217),
      appBar: AppBar(
        backgroundColor: const Color(0xFF191A21),
        foregroundColor: Colors.white,
        titleSpacing: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              entry.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            Text(
              l10n.albumViewerPage(_index + 1, widget.entries.length),
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.65),
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: PageView.builder(
              controller: _pageController,
              itemCount: widget.entries.length,
              onPageChanged: (index) => setState(() => _index = index),
              itemBuilder: (context, index) {
                final item = widget.entries[index];
                return _PreviewContent(
                  key: ValueKey(item.path),
                  client: widget.client,
                  entry: item,
                  active: index == _index,
                );
              },
            ),
          ),
          Positioned(
            left: 12,
            right: 12,
            bottom: 12,
            child: SafeArea(
              top: false,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _NavigationButton(
                    tooltip: l10n.previewPreviousFile,
                    icon: Icons.chevron_left,
                    onPressed: _index > 0 ? () => _goTo(_index - 1) : null,
                  ),
                  _NavigationButton(
                    tooltip: l10n.previewNextFile,
                    icon: Icons.chevron_right,
                    onPressed: _index < widget.entries.length - 1
                        ? () => _goTo(_index + 1)
                        : null,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _NavigationButton extends StatelessWidget {
  const _NavigationButton({
    required this.tooltip,
    required this.icon,
    required this.onPressed,
  });

  final String tooltip;
  final IconData icon;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xCC252733),
      shape: const CircleBorder(),
      child: IconButton(
        tooltip: tooltip,
        onPressed: onPressed,
        color: Colors.white,
        disabledColor: Colors.white24,
        icon: Icon(icon),
      ),
    );
  }
}

class _PreviewContent extends StatelessWidget {
  const _PreviewContent({
    required this.client,
    required this.entry,
    required this.active,
    super.key,
  });

  final UnraidApiClient client;
  final UnraidFileEntry entry;
  final bool active;

  @override
  Widget build(BuildContext context) {
    return switch (entry.previewKind) {
      FilePreviewKind.image => _ImagePreviewPane(
          client: client,
          entry: entry,
        ),
      FilePreviewKind.video => _VideoPreviewPane(
          client: client,
          entry: entry,
          active: active,
        ),
      FilePreviewKind.audio => _AudioPreviewPane(
          client: client,
          entry: entry,
          active: active,
        ),
      FilePreviewKind.text => _TextPreviewPane(
          client: client,
          entry: entry,
        ),
      FilePreviewKind.pdf => _PdfPreviewPane(
          client: client,
          entry: entry,
        ),
      FilePreviewKind.unsupported => Center(
          child: Text(
            AppLocalizations.of(context).previewUnsupported,
            style: const TextStyle(color: Colors.white70),
          ),
        ),
    };
  }
}

class _ImagePreviewPane extends StatefulWidget {
  const _ImagePreviewPane({
    required this.client,
    required this.entry,
  });

  final UnraidApiClient client;
  final UnraidFileEntry entry;

  @override
  State<_ImagePreviewPane> createState() => _ImagePreviewPaneState();
}

class _ImagePreviewPaneState extends State<_ImagePreviewPane> {
  late Future<Uint8List> _previewFuture;
  Future<Uint8List>? _originalFuture;

  @override
  void initState() {
    super.initState();
    _previewFuture = _loadPreview();
  }

  Future<Uint8List> _loadPreview() {
    return widget.client.fileManager.readPreviewBytes(widget.entry.path);
  }

  void _retry() {
    setState(() {
      _previewFuture = _loadPreview();
      _originalFuture = null;
    });
  }

  void _loadOriginal() {
    if (_originalFuture != null) return;
    setState(() {
      _originalFuture =
          widget.client.fileManager.readFileBytes(widget.entry.path);
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final future = _originalFuture ?? _previewFuture;
    return Stack(
      children: [
        Positioned.fill(
          child: FutureBuilder<Uint8List>(
            future: future,
            builder: (context, snapshot) {
              if (snapshot.connectionState != ConnectionState.done) {
                return _PreviewLoading(
                  label: _originalFuture == null
                      ? null
                      : l10n.previewLoadingOriginal,
                );
              }
              if (snapshot.hasError || !snapshot.hasData) {
                return _PreviewError(
                  message: l10n.previewLoadFailed(
                    snapshot.error?.toString() ?? l10n.imageLoadFailed,
                  ),
                  onRetry: _retry,
                );
              }
              return InteractiveViewer(
                minScale: 0.5,
                maxScale: 5,
                child: Center(
                  child: Image.memory(
                    snapshot.data!,
                    fit: BoxFit.contain,
                    gaplessPlayback: true,
                  ),
                ),
              );
            },
          ),
        ),
        if (_originalFuture == null)
          Positioned(
            top: 12,
            right: 12,
            child: SafeArea(
              bottom: false,
              child: FilledButton.tonalIcon(
                onPressed: _loadOriginal,
                icon: const Icon(Icons.hd_outlined),
                label: Text(l10n.previewViewOriginal),
              ),
            ),
          ),
      ],
    );
  }
}

class _VideoPreviewPane extends StatefulWidget {
  const _VideoPreviewPane({
    required this.client,
    required this.entry,
    required this.active,
  });

  final UnraidApiClient client;
  final UnraidFileEntry entry;
  final bool active;

  @override
  State<_VideoPreviewPane> createState() => _VideoPreviewPaneState();
}

class _VideoPreviewPaneState extends State<_VideoPreviewPane> {
  late final media_kit.Player _player;
  late final VideoController _controller;
  late Future<void> _loadFuture;
  StreamSubscription<String>? _errorSubscription;
  String? _playbackError;

  @override
  void initState() {
    super.initState();
    _player = media_kit.Player();
    _controller = VideoController(_player);
    _errorSubscription = _player.stream.error.listen((error) {
      if (mounted && error.isNotEmpty) {
        setState(() => _playbackError = error);
      }
    });
    _loadFuture = _open();
  }

  Future<void> _open() {
    _playbackError = null;
    return _player.open(
      media_kit.Media(
          widget.client.fileManager.rawUri(widget.entry.path).toString()),
      play: false,
    );
  }

  void _retry() {
    setState(() => _loadFuture = _open());
  }

  @override
  void didUpdateWidget(covariant _VideoPreviewPane oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.active && !widget.active) {
      unawaited(_player.pause());
    }
  }

  @override
  void dispose() {
    unawaited(_errorSubscription?.cancel());
    unawaited(_player.dispose());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    if (_playbackError != null) {
      return _PreviewError(
        message: l10n.previewLoadFailed(_playbackError!),
        onRetry: _retry,
      );
    }
    return FutureBuilder<void>(
      future: _loadFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return _PreviewLoading(label: l10n.previewVideo);
        }
        if (snapshot.hasError) {
          return _PreviewError(
            message: l10n.previewLoadFailed(snapshot.error.toString()),
            onRetry: _retry,
          );
        }
        return Center(
          child: AspectRatio(
            aspectRatio: 16 / 9,
            child: Video(
              controller: _controller,
              controls: MaterialVideoControls,
            ),
          ),
        );
      },
    );
  }
}

class _AudioPreviewPane extends StatefulWidget {
  const _AudioPreviewPane({
    required this.client,
    required this.entry,
    required this.active,
  });

  final UnraidApiClient client;
  final UnraidFileEntry entry;
  final bool active;

  @override
  State<_AudioPreviewPane> createState() => _AudioPreviewPaneState();
}

class _AudioPreviewPaneState extends State<_AudioPreviewPane> {
  late final AudioPlayer _player;
  late Future<void> _loadFuture;

  @override
  void initState() {
    super.initState();
    _player = AudioPlayer();
    _loadFuture = _load();
  }

  Future<void> _load() async {
    await _player.setUrl(
      widget.client.fileManager.rawUri(widget.entry.path).toString(),
    );
  }

  void _retry() {
    setState(() => _loadFuture = _load());
  }

  @override
  void didUpdateWidget(covariant _AudioPreviewPane oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.active && !widget.active) {
      unawaited(_player.pause());
    }
  }

  @override
  void dispose() {
    unawaited(_player.dispose());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return FutureBuilder<void>(
      future: _loadFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return _PreviewLoading(label: l10n.previewAudio);
        }
        if (snapshot.hasError) {
          return _PreviewError(
            message: l10n.previewLoadFailed(snapshot.error.toString()),
            onRetry: _retry,
          );
        }
        return Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 560),
            child: Card(
              margin: const EdgeInsets.all(24),
              color: const Color(0xFF252733),
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.graphic_eq,
                      color: Colors.white70,
                      size: 72,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      widget.entry.name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 17,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 18),
                    _AudioProgress(player: _player),
                    const SizedBox(height: 8),
                    StreamBuilder<PlayerState>(
                      stream: _player.playerStateStream,
                      builder: (context, stateSnapshot) {
                        final playing = stateSnapshot.data?.playing == true;
                        return IconButton.filled(
                          tooltip:
                              playing ? l10n.previewPause : l10n.previewPlay,
                          iconSize: 34,
                          onPressed: () {
                            if (playing) {
                              unawaited(_player.pause());
                            } else {
                              unawaited(_player.play());
                            }
                          },
                          icon: Icon(
                            playing ? Icons.pause : Icons.play_arrow,
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _AudioProgress extends StatelessWidget {
  const _AudioProgress({required this.player});

  final AudioPlayer player;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<Duration?>(
      stream: player.durationStream,
      builder: (context, durationSnapshot) {
        final duration = durationSnapshot.data ?? Duration.zero;
        return StreamBuilder<Duration>(
          stream: player.bufferedPositionStream,
          builder: (context, bufferedSnapshot) {
            final buffered = bufferedSnapshot.data ?? Duration.zero;
            return StreamBuilder<Duration>(
              stream: player.positionStream,
              builder: (context, positionSnapshot) {
                final position = positionSnapshot.data ?? Duration.zero;
                final maxMilliseconds =
                    duration.inMilliseconds.clamp(1, 1 << 31).toDouble();
                final value = position.inMilliseconds
                    .clamp(0, maxMilliseconds.toInt())
                    .toDouble();
                final secondary = buffered.inMilliseconds
                    .clamp(value.toInt(), maxMilliseconds.toInt())
                    .toDouble();
                return Column(
                  children: [
                    Slider(
                      value: value,
                      secondaryTrackValue: secondary,
                      max: maxMilliseconds,
                      onChanged: (milliseconds) {
                        unawaited(
                          player.seek(
                            Duration(milliseconds: milliseconds.round()),
                          ),
                        );
                      },
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          _formatDuration(position),
                          style: const TextStyle(color: Colors.white60),
                        ),
                        Text(
                          _formatDuration(duration),
                          style: const TextStyle(color: Colors.white60),
                        ),
                      ],
                    ),
                  ],
                );
              },
            );
          },
        );
      },
    );
  }
}

class _TextPreviewPane extends StatefulWidget {
  const _TextPreviewPane({
    required this.client,
    required this.entry,
  });

  static const maxBytes = 2 * 1024 * 1024;

  final UnraidApiClient client;
  final UnraidFileEntry entry;

  @override
  State<_TextPreviewPane> createState() => _TextPreviewPaneState();
}

class _TextPreviewPaneState extends State<_TextPreviewPane> {
  Future<Uint8List>? _bytesFuture;

  @override
  void initState() {
    super.initState();
    if (!_metadataExceedsLimit) {
      _bytesFuture = _load();
    }
  }

  bool get _metadataExceedsLimit =>
      (widget.entry.byteSize ?? 0) > _TextPreviewPane.maxBytes;

  Future<Uint8List> _load() {
    return widget.client.fileManager.readFileBytes(
      widget.entry.path,
      maxBytes: _TextPreviewPane.maxBytes,
    );
  }

  void _retry() {
    setState(() => _bytesFuture = _load());
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    if (_metadataExceedsLimit) {
      return _PreviewError(message: l10n.apiFileTooLarge('2 MB'));
    }
    return FutureBuilder<Uint8List>(
      future: _bytesFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return _PreviewLoading(label: l10n.previewText);
        }
        if (snapshot.hasError || !snapshot.hasData) {
          return _PreviewError(
            message: l10n.previewLoadFailed(snapshot.error.toString()),
            onRetry: _retry,
          );
        }
        final decoded = utf8.decode(snapshot.data!, allowMalformed: true);
        final text =
            decoded.startsWith('\uFEFF') ? decoded.substring(1) : decoded;
        return ColoredBox(
          color: const Color(0xFF17181E),
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 88),
            child: SelectableText(
              text,
              style: const TextStyle(
                color: Color(0xFFE3E4EA),
                fontFamily: 'monospace',
                fontSize: 14,
                height: 1.5,
              ),
            ),
          ),
        );
      },
    );
  }
}

class _PdfPreviewPane extends StatelessWidget {
  const _PdfPreviewPane({
    required this.client,
    required this.entry,
  });

  final UnraidApiClient client;
  final UnraidFileEntry entry;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return PdfViewer.uri(
      client.fileManager.rawUri(entry.path),
      params: PdfViewerParams(
        backgroundColor: const Color(0xFF17181E),
        loadingBannerBuilder: (context, downloaded, total) {
          return _PreviewLoading(label: l10n.previewPdf);
        },
        errorBannerBuilder: (context, error, stackTrace, documentRef) {
          return _PreviewError(
            message: l10n.previewLoadFailed(error.toString()),
            onRetry: () {
              unawaited(
                documentRef.resolveListenable().load(forceReload: true),
              );
            },
          );
        },
      ),
    );
  }
}

class _PreviewLoading extends StatelessWidget {
  const _PreviewLoading({this.label});

  final String? label;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const CircularProgressIndicator(color: Colors.white),
          if (label != null) ...[
            const SizedBox(height: 14),
            Text(label!, style: const TextStyle(color: Colors.white70)),
          ],
        ],
      ),
    );
  }
}

class _PreviewError extends StatelessWidget {
  const _PreviewError({required this.message, this.onRetry});

  final String message;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, color: Colors.redAccent, size: 46),
            const SizedBox(height: 14),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white70),
            ),
            if (onRetry != null) ...[
              const SizedBox(height: 16),
              OutlinedButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh),
                label: Text(l10n.retry),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

String _formatDuration(Duration duration) {
  final totalSeconds = duration.inSeconds;
  final hours = totalSeconds ~/ 3600;
  final minutes = (totalSeconds % 3600) ~/ 60;
  final seconds = totalSeconds % 60;
  if (hours > 0) {
    return '${hours.toString().padLeft(2, '0')}:'
        '${minutes.toString().padLeft(2, '0')}:'
        '${seconds.toString().padLeft(2, '0')}';
  }
  return '${minutes.toString().padLeft(2, '0')}:'
      '${seconds.toString().padLeft(2, '0')}';
}
