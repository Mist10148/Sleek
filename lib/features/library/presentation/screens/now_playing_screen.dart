import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/manuscript_theme.dart';
import '../../../../core/theme/mss_palette.dart';
import '../../../../core/utils/formatters.dart';
import '../../../converter/presentation/providers/theme_provider.dart';
import '../../../converter/presentation/widgets/manuscript/manuscript_background.dart';
import '../../../converter/presentation/widgets/manuscript/mss_icons.dart';
import '../../../converter/presentation/widgets/manuscript/ornaments.dart';
import '../../domain/entities/track.dart';
import '../providers/favorites_provider.dart';
import '../providers/player_controller.dart';
import '../widgets/album_art.dart';

/// Full-screen transport — ported from `Player.jsx`'s `NowPlaying`: cover,
/// title/channel, scrubber, shuffle/prev/play/next/repeat row, favourite
/// toggle, and a button to open the queue sheet.
class NowPlayingScreen extends ConsumerWidget {
  const NowPlayingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ManuscriptBinding binding = ref.watch(bindingProvider);
    final MssPalette p = paletteOf(context);
    final PlaybackState playback = ref.watch(playerControllerProvider);
    final PlayerController controller = ref.read(playerControllerProvider.notifier);
    final Track? track = controller.current;
    final Set<String> favorites = ref.watch(favoritesProvider);

    if (track == null) return const SizedBox.shrink();

    final bool gilt = binding.ornament == 2;
    final bool isFavorite = favorites.contains(track.id);
    final double frac = track.duration.inMilliseconds <= 0
        ? 0
        : (playback.position.inMilliseconds / track.duration.inMilliseconds).clamp(0.0, 1.0);
    final Duration remaining = track.duration - playback.position;

    return ManuscriptBackground(
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(22, 14, 22, 26),
          child: Column(
            children: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  _circleIconButton(
                    icon: 'chevron',
                    color: p.faint,
                    onTap: controller.closeNowPlaying,
                  ),
                  Column(
                    children: <Widget>[
                      Text('Now Playing',
                          style: p.label(binding.gold).copyWith(fontSize: 9)),
                      const SizedBox(height: 2),
                      Text(
                        '${track.format.name.toUpperCase()}'
                        '${track.qualityLabel.isNotEmpty ? ' · ${track.qualityLabel}' : ''}',
                        style: p.serif(TextStyle(fontSize: 11, color: p.muted)),
                      ),
                    ],
                  ),
                  _circleIconButton(
                    icon: 'queue',
                    color: p.faint,
                    onTap: controller.openQueue,
                  ),
                ],
              ),
              const SizedBox(height: 18),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6),
                child: AspectRatio(
                  aspectRatio: 1,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: p.rule(0.4)),
                      boxShadow: <BoxShadow>[
                        BoxShadow(
                            color: Colors.black.withValues(alpha: 0.4),
                            blurRadius: 60,
                            offset: const Offset(0, 30),
                            spreadRadius: -30),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: AlbumArt(track: track, frame: gilt, gold: binding.gold),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 26),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          track.title,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: binding.display0(TextStyle(
                              fontSize: 21, height: 1.22, fontWeight: FontWeight.w500, color: p.display)),
                        ),
                        const SizedBox(height: 6),
                        Text(track.artist, style: p.serif(TextStyle(fontSize: 14, color: binding.gold))),
                      ],
                    ),
                  ),
                  _toolButton(
                    icon: isFavorite ? 'heartFill' : 'heart',
                    active: isFavorite,
                    accent: binding.accent,
                    muted: p.muted,
                    size: 21,
                    onTap: () {
                      HapticFeedback.lightImpact();
                      ref.read(favoritesProvider.notifier).toggle(track.id);
                    },
                  ),
                ],
              ),
              const SizedBox(height: 18),
              _Scrubber(
                fraction: frac,
                accent: binding.accent,
                accentDeep: binding.accentDeep,
                accentSoft: binding.accentSoft,
                trackColor: p.barBg,
                lineColor: p.rule(0.3),
                onSeek: controller.seekFraction,
              ),
              const SizedBox(height: 6),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Text(Formatters.duration(playback.position), style: p.mono(TextStyle(fontSize: 11, color: p.muted))),
                  Text('-${Formatters.duration(remaining.isNegative ? Duration.zero : remaining)}',
                      style: p.mono(TextStyle(fontSize: 11, color: p.faint))),
                ],
              ),
              const SizedBox(height: 14),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  _toolButton(
                    icon: 'shuffle',
                    active: playback.shuffle,
                    accent: binding.accent,
                    muted: p.muted,
                    size: 20,
                    onTap: controller.toggleShuffle,
                  ),
                  _transportButton(icon: 'prev', size: 26, dim: 50, color: p.muted, onTap: controller.prev),
                  _PlayButton(binding: binding, palette: p, playing: playback.playing, onTap: controller.togglePlay),
                  _transportButton(icon: 'next', size: 26, dim: 50, color: p.muted, onTap: controller.next),
                  _toolButton(
                    icon: playback.repeat == PlaybackRepeat.one ? 'repeatOne' : 'repeat',
                    active: playback.repeat != PlaybackRepeat.off,
                    accent: binding.accent,
                    muted: p.muted,
                    size: 20,
                    onTap: controller.cycleRepeat,
                  ),
                ],
              ),
              const SizedBox(height: 14),
              const Spacer(),
              if (gilt)
                Fleuron(glyph: '⁂', gold: binding.gold)
              else
                HairRule(palette: p),
            ],
          ),
        ),
      ),
    );
  }

  Widget _circleIconButton({required String icon, required Color color, required VoidCallback onTap}) {
    return Material(
      color: Colors.transparent,
      shape: const CircleBorder(),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(9),
          child: MssIcon(icon, size: 20, color: color),
        ),
      ),
    );
  }

  Widget _toolButton({
    required String icon,
    required bool active,
    required Color accent,
    required Color muted,
    required double size,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      shape: const CircleBorder(),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: SizedBox(
          width: 44,
          height: 44,
          child: Stack(
            alignment: Alignment.center,
            children: <Widget>[
              MssIcon(icon, size: size, color: active ? accent : muted),
              if (active)
                Positioned(
                  bottom: 4,
                  child: Container(
                    width: 4,
                    height: 4,
                    decoration: BoxDecoration(shape: BoxShape.circle, color: accent),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _transportButton({
    required String icon,
    required double size,
    required double dim,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      shape: const CircleBorder(),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: SizedBox(width: dim, height: dim, child: Center(child: MssIcon(icon, size: size, color: color))),
      ),
    );
  }
}

class _PlayButton extends StatefulWidget {
  const _PlayButton({required this.binding, required this.palette, required this.playing, required this.onTap});

  final ManuscriptBinding binding;
  final MssPalette palette;
  final bool playing;
  final VoidCallback onTap;

  @override
  State<_PlayButton> createState() => _PlayButtonState();
}

class _PlayButtonState extends State<_PlayButton> {
  bool _down = false;

  @override
  Widget build(BuildContext context) {
    final ManuscriptBinding b = widget.binding;
    return GestureDetector(
      onTapDown: (_) => setState(() => _down = true),
      onTapUp: (_) => setState(() => _down = false),
      onTapCancel: () => setState(() => _down = false),
      onTap: () {
        HapticFeedback.lightImpact();
        widget.onTap();
      },
      child: AnimatedScale(
        scale: _down ? 0.94 : 1,
        duration: const Duration(milliseconds: 140),
        child: Container(
          width: 74,
          height: 74,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: RadialGradient(center: const Alignment(0, -0.3), colors: <Color>[b.accent, b.accentDeep]),
            boxShadow: <BoxShadow>[
              BoxShadow(color: b.accentDeep.withValues(alpha: 0.55), blurRadius: 30, offset: const Offset(0, 14), spreadRadius: -12),
            ],
          ),
          child: Center(
            child: MssIcon(widget.playing ? 'pause' : 'play', size: 28, color: widget.palette.ink),
          ),
        ),
      ),
    );
  }
}

class _Scrubber extends StatelessWidget {
  const _Scrubber({
    required this.fraction,
    required this.accent,
    required this.accentDeep,
    required this.accentSoft,
    required this.trackColor,
    required this.lineColor,
    required this.onSeek,
  });

  final double fraction;
  final Color accent;
  final Color accentDeep;
  final Color accentSoft;
  final Color trackColor;
  final Color lineColor;
  final ValueChanged<double> onSeek;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 24,
      child: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints c) {
          void seekAt(double dx) => onSeek((dx / c.maxWidth).clamp(0.0, 1.0));
          return GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTapDown: (TapDownDetails d) => seekAt(d.localPosition.dx),
            onHorizontalDragUpdate: (DragUpdateDetails d) => seekAt(d.localPosition.dx),
            child: Stack(
              alignment: Alignment.centerLeft,
              children: <Widget>[
                Container(
                  height: 4,
                  decoration: BoxDecoration(
                    color: trackColor,
                    borderRadius: BorderRadius.circular(3),
                    border: Border.all(color: lineColor),
                  ),
                ),
                FractionallySizedBox(
                  widthFactor: fraction,
                  child: Container(
                    height: 4,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(3),
                      gradient: LinearGradient(colors: <Color>[accentDeep, accent]),
                    ),
                  ),
                ),
                Align(
                  alignment: Alignment(fraction * 2 - 1, 0),
                  child: Container(
                    width: 14,
                    height: 14,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: accent,
                      boxShadow: <BoxShadow>[
                        BoxShadow(color: accentSoft, blurRadius: 0, spreadRadius: 4),
                        const BoxShadow(color: Color(0x66000000), blurRadius: 6, offset: Offset(0, 2)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
