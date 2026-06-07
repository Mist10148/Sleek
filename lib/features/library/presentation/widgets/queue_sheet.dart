import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/manuscript_theme.dart';
import '../../../../core/theme/mss_palette.dart';
import '../../../../core/utils/formatters.dart';
import '../../../converter/presentation/providers/theme_provider.dart';
import '../../../converter/presentation/widgets/manuscript/mss_icons.dart';
import '../../domain/entities/track.dart';
import '../providers/player_controller.dart';
import 'album_art.dart';

/// "Up Next" — ported from `Player.jsx`'s `QueueSheet`: a bottom sheet
/// listing the play order, each row numbered, with the live equalizer on the
/// current track.
class QueueSheet extends ConsumerWidget {
  const QueueSheet({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ManuscriptBinding binding = ref.watch(bindingProvider);
    final MssPalette p = paletteOf(context);
    final PlaybackState playback = ref.watch(playerControllerProvider);
    final PlayerController controller = ref.read(playerControllerProvider.notifier);
    final List<Track> queue = controller.queue;

    return Stack(
      children: <Widget>[
        Positioned.fill(
          child: GestureDetector(
            onTap: controller.closeQueue,
            child: ColoredBox(color: Colors.black.withValues(alpha: 0.5)),
          ),
        ),
        Align(
          alignment: Alignment.bottomCenter,
          child: ConstrainedBox(
            constraints: BoxConstraints(maxHeight: MediaQuery.sizeOf(context).height * 0.74),
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: p.menuBg,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                border: Border.all(color: p.rule(0.4)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Container(
                    width: 38,
                    height: 4,
                    margin: const EdgeInsets.only(top: 10, bottom: 4),
                    decoration: BoxDecoration(color: p.rule(0.3), borderRadius: BorderRadius.circular(3)),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(22, 8, 22, 10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text('UP NEXT', style: p.label(binding.gold)),
                            const SizedBox(height: 2),
                            Text('${queue.length} in queue',
                                style: p.serif(TextStyle(fontSize: 12, color: p.muted))),
                          ],
                        ),
                        Material(
                          color: Colors.transparent,
                          shape: const CircleBorder(),
                          clipBehavior: Clip.antiAlias,
                          child: InkWell(
                            onTap: controller.closeQueue,
                            child: Padding(
                              padding: const EdgeInsets.all(8),
                              child: MssIcon('x', size: 16, color: p.faint),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(height: 1, margin: const EdgeInsets.symmetric(horizontal: 22), color: p.rule(0.2)),
                  Flexible(
                    child: ListView.builder(
                      shrinkWrap: true,
                      padding: const EdgeInsets.fromLTRB(22, 8, 22, 18),
                      itemCount: queue.length,
                      itemBuilder: (BuildContext context, int i) {
                        final Track track = queue[i];
                        final bool isCurrent = track.id == playback.currentId;
                        return InkWell(
                          onTap: () => controller.playTrack(track.id),
                          borderRadius: BorderRadius.circular(6),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            child: Row(
                              children: <Widget>[
                                SizedBox(
                                  width: 18,
                                  child: Text(
                                    '${i + 1}',
                                    style: p.mono(TextStyle(fontSize: 11, color: isCurrent ? binding.accent : p.faint)),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                SizedBox(
                                  width: 42,
                                  height: 42,
                                  child: AlbumArt(track: track, size: 42, radius: 5, gold: binding.gold),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    mainAxisSize: MainAxisSize.min,
                                    children: <Widget>[
                                      Text(
                                        track.title,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: p.serif(TextStyle(
                                            fontSize: 13.5,
                                            fontWeight: FontWeight.w600,
                                            color: isCurrent ? binding.accent : p.text)),
                                      ),
                                      Text(
                                        track.artist,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: p.serif(TextStyle(fontSize: 12, color: p.muted)),
                                      ),
                                    ],
                                  ),
                                ),
                                if (isCurrent && playback.playing)
                                  Eq(color: binding.accent)
                                else
                                  Text(Formatters.duration(track.duration),
                                      style: p.mono(TextStyle(fontSize: 11, color: p.faint))),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
