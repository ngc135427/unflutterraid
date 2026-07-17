import 'dart:async';

import 'package:flutter/material.dart';

import '../l10n/generated/app_localizations.dart';
import '../pages/music_page.dart';
import '../services/music_player_controller.dart';

/// Bottom mini player shown when [MusicPlayerController] has an active session.
class MusicMiniBar extends StatelessWidget {
  const MusicMiniBar({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = MusicPlayerController.instance;
    return ListenableBuilder(
      listenable: controller,
      builder: (context, _) {
        if (!controller.showMiniBar) {
          return const SizedBox.shrink();
        }
        final l10n = AppLocalizations.of(context);
        final track = controller.track;
        final title = track?.name ?? l10n.music;
        return Material(
          elevation: 10,
          color: Colors.transparent,
          child: SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 10),
              child: InkWell(
                borderRadius: BorderRadius.circular(14),
                onTap: () {
                  Navigator.of(context).pushNamed(
                    MusicPlayerPage.routeName,
                    arguments: MusicPlayerArgs(
                      apiClient: controller.apiClient!,
                      queue: List.of(controller.queue),
                      initialIndex: controller.index,
                    ),
                  );
                },
                child: Ink(
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF3498DB), Color(0xFF52C41A)],
                    ),
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF3498DB).withValues(alpha: 0.28),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(12, 10, 6, 10),
                    child: Row(
                      children: [
                        const Icon(Icons.music_note, color: Colors.white),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                title,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 14,
                                ),
                              ),
                              const SizedBox(height: 4),
                              ClipRRect(
                                borderRadius: BorderRadius.circular(2),
                                child: LinearProgressIndicator(
                                  value: controller.loading
                                      ? null
                                      : controller.progress,
                                  minHeight: 3,
                                  backgroundColor:
                                      Colors.white.withValues(alpha: 0.22),
                                  valueColor: const AlwaysStoppedAnimation(
                                    Colors.white,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          tooltip: l10n.collapse,
                          onPressed: () =>
                              unawaited(controller.togglePlayPause()),
                          icon: Icon(
                            controller.playing
                                ? Icons.pause_circle_filled
                                : Icons.play_circle_fill,
                            color: Colors.white,
                            size: 32,
                          ),
                        ),
                        IconButton(
                          tooltip: l10n.close,
                          onPressed: () => unawaited(controller.stopAndClear()),
                          icon: const Icon(
                            Icons.close,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
