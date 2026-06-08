import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/manuscript_theme.dart';
import '../../../../core/theme/mss_palette.dart';
import '../../../converter/presentation/providers/theme_provider.dart';
import '../../../converter/presentation/widgets/manuscript/mss_icons.dart';
import '../../domain/entities/track.dart';
import '../providers/player_controller.dart';
import 'album_art.dart';

/// The persistent bottom mini-bar — ported from `Player.jsx`'s `MiniPlayer`:
/// art, title/channel, play/pause, next, and a hairline progress bar along
/// the bottom edge.
class MiniPlayer extends ConsumerWidget {
  const MiniPlayer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ManuscriptBinding binding = ref.watch(bindingProvider);
    final MssPalette p = paletteOf(context);
    final PlaybackState playback = ref.watch(playerControllerProvider);
    final PlayerController controller = ref.read(playerControllerProvider.notifier);
    final Track? track = controller.current;

    if (track == null) return const SizedBox.shrink();

    final double frac = track.duration.inMilliseconds <= 0
        ? 0
        : (playback.position.inMilliseconds / track.duration.inMilliseconds).clamp(0.0, 1.0);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: controller.openNowPlaying,
        child: Stack(
          children: <Widget>[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
              decoration: BoxDecoration(
                color: p.menuBg.withValues(alpha: 0.92),
                border: Border(top: BorderSide(color: p.rule(0.18))),
              ),
              child: Row(
                children: <Widget>[
                  SizedBox(
                    width: 42,
                    height: 42,
                    child: AlbumArt(track: track, size: 42, radius: 5, gold: binding.gold),
                  ),
                  const SizedBox(width: 11),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          track.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: p.serif(TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: p.display)),
                        ),
                        Text(
                          track.artist,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: p.serif(TextStyle(fontSize: 11.5, color: p.muted)),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  _circleButton(
                    palette: p,
                    binding: binding,
                    icon: playback.playing ? 'pause' : 'play',
                    filled: true,
                    onTap: () {
                      HapticFeedback.lightImpact();
                      controller.togglePlay();
                    },
                  ),
                  const SizedBox(width: 8),
                  _circleButton(
                    palette: p,
                    binding: binding,
                    icon: 'next',
                    filled: false,
                    onTap: () {
                      HapticFeedback.lightImpact();
                      controller.next();
                    },
                  ),
                ],
              ),
            ),
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: FractionallySizedBox(
                alignment: Alignment.centerLeft,
                widthFactor: frac,
                child: Container(height: 2, color: binding.accent),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _circleButton({
    required MssPalette palette,
    required ManuscriptBinding binding,
    required String icon,
    required bool filled,
    required VoidCallback onTap,
  }) {
    return Material(
      color: filled ? palette.fieldBg : Colors.transparent,
      shape: CircleBorder(side: BorderSide(color: filled ? palette.rule(0.3) : Colors.transparent)),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: SizedBox(
          width: 40,
          height: 40,
          child: Center(
            child: MssIcon(icon, size: filled ? 18 : 20, color: filled ? binding.accent : palette.muted),
          ),
        ),
      ),
    );
  }
}
