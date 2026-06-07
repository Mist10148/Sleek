import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/track.dart';
import '../providers/device_library_provider.dart';

/// Procedural "illuminated" cover — a radial gradient in the track's tint
/// pair, fine grain, concentric rings, an optional gilded frame, and a
/// centered glyph. Ported verbatim from `kit.jsx`'s `AlbumArt`.
///
/// Device tracks with real embedded artwork show that instead, falling back
/// to the procedural cover when none is available.
class AlbumArt extends StatelessWidget {
  const AlbumArt({
    super.key,
    required this.track,
    this.size,
    this.radius = 0,
    this.frame = false,
    this.gold,
  });

  final Track track;
  final double? size;
  final double radius;
  final bool frame;
  final Color? gold;

  @override
  Widget build(BuildContext context) {
    final Widget art = ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: track.hasRealArtwork
          ? _RealOrProcedural(track: track, glyph: track.glyph, colors: track.coverColors, gold: gold)
          : _ProceduralCover(colors: track.coverColors, glyph: track.glyph, size: size),
    );
    if (!frame) {
      return SizedBox(width: size, height: size, child: art);
    }
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        fit: StackFit.expand,
        children: <Widget>[
          art,
          IgnorePointer(
            child: CustomPaint(
              painter: _GiltFramePainter(gold ?? const Color(0xFFCBA86A), radius),
            ),
          ),
        ],
      ),
    );
  }
}

/// Looks up the real artwork bytes for a device track via `queryArtwork`,
/// falling back to the procedural cover while loading or on a miss.
class _RealOrProcedural extends ConsumerWidget {
  const _RealOrProcedural({required this.track, required this.glyph, required this.colors, this.gold});

  final Track track;
  final String glyph;
  final List<Color> colors;
  final Color? gold;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final int? songId = track.deviceSongId;
    if (songId == null) return _ProceduralCover(colors: colors, glyph: glyph);
    return FutureBuilder<Uint8List?>(
      future: ref.read(deviceLibraryServiceProvider).queryArtwork(songId),
      builder: (BuildContext context, AsyncSnapshot<Uint8List?> snap) {
        final Uint8List? bytes = snap.data;
        if (bytes == null || bytes.isEmpty) {
          return _ProceduralCover(colors: colors, glyph: glyph);
        }
        return Image.memory(bytes, fit: BoxFit.cover, gaplessPlayback: true);
      },
    );
  }
}

class _ProceduralCover extends StatelessWidget {
  const _ProceduralCover({required this.colors, required this.glyph, this.size});

  final List<Color> colors;
  final String glyph;
  final double? size;

  @override
  Widget build(BuildContext context) {
    final Color a = colors.isNotEmpty ? colors[0] : const Color(0xFF5A3F2C);
    final Color b = colors.length > 1 ? colors[1] : const Color(0xFF241A12);
    return Stack(
      fit: StackFit.expand,
      children: <Widget>[
        DecoratedBox(
          decoration: BoxDecoration(
            gradient: RadialGradient(
              center: const Alignment(-0.4, -0.56),
              radius: 1.2,
              colors: <Color>[a, b],
              stops: const <double>[0.0, 0.72],
            ),
          ),
        ),
        IgnorePointer(child: CustomPaint(painter: _GrainPainter())),
        IgnorePointer(child: CustomPaint(painter: _RingsPainter())),
        Center(
          child: Text(
            glyph,
            style: TextStyle(
              fontSize: size != null ? (size! * 0.32).clamp(13.0, 999.0) : 34,
              color: const Color(0xE6FFF6E6),
              fontFamily: 'Spectral',
              shadows: const <Shadow>[Shadow(color: Color(0x66000000), blurRadius: 8, offset: Offset(0, 2))],
            ),
          ),
        ),
      ],
    );
  }
}

/// Fine repeating horizontal grain, multiplied over the gradient
/// (`.grain2` — `repeating-linear-gradient` at `mix-blend-mode: multiply`).
class _GrainPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final Paint p = Paint()
      ..color = const Color(0x1A000000)
      ..blendMode = BlendMode.multiply;
    for (double y = 0; y < size.height; y += 3) {
      canvas.drawRect(Rect.fromLTWH(0, y, size.width, 1), p);
    }
  }

  @override
  bool shouldRepaint(covariant _GrainPainter oldDelegate) => false;
}

/// Three faint concentric rings centered on the cover (the design's inline
/// `<svg viewBox="0 0 100 100">` circles).
class _RingsPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final Offset center = size.center(Offset.zero);
    final double k = size.shortestSide / 100;
    final Paint stroke = Paint()
      ..style = PaintingStyle.stroke
      ..color = const Color(0x80FFF5E4);
    for (final (double r, double w) in const <(double, double)>[(34, 0.6), (26, 0.4), (42, 0.4)]) {
      canvas.drawCircle(center, r * k, stroke..strokeWidth = w * k);
    }
  }

  @override
  bool shouldRepaint(covariant _RingsPainter oldDelegate) => false;
}

/// A thin double-rule gilded frame inset from the edges (the design's
/// `frame` overlay on illuminated-binding now-playing art).
class _GiltFramePainter extends CustomPainter {
  _GiltFramePainter(this.color, this.radius);
  final Color color;
  final double radius;

  @override
  void paint(Canvas canvas, Size size) {
    final double k = size.shortestSide / 100;
    final Paint outer = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.8 * k
      ..color = color.withValues(alpha: 0.9);
    final Paint inner = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.4 * k
      ..color = color.withValues(alpha: 0.6 * 0.9);
    final RRect outerRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(6 * k, 6 * k, size.width - 12 * k, size.height - 12 * k),
      Radius.circular(2 * k),
    );
    final RRect innerRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(9 * k, 9 * k, size.width - 18 * k, size.height - 18 * k),
      Radius.circular(1 * k),
    );
    canvas.drawRRect(outerRect, outer);
    canvas.drawRRect(innerRect, inner);
  }

  @override
  bool shouldRepaint(covariant _GiltFramePainter oldDelegate) =>
      oldDelegate.color != color || oldDelegate.radius != radius;
}

/// The little four-bar "now playing" equalizer (`.mss-eq` / `@keyframes
/// mss-eq`) — each bar bounces between 4px and 14px on its own staggered
/// delay, looping while the track plays.
class Eq extends StatefulWidget {
  const Eq({super.key, required this.color});
  final Color color;

  @override
  State<Eq> createState() => _EqState();
}

class _EqState extends State<Eq> with SingleTickerProviderStateMixin {
  late final AnimationController _c =
      AnimationController(vsync: this, duration: const Duration(milliseconds: 900))..repeat();

  static const List<double> _delays = <double>[0, 0.25, 0.5, 0.15];

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 18,
      height: 14,
      child: AnimatedBuilder(
        animation: _c,
        builder: (BuildContext context, _) {
          return Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: <Widget>[
              for (final double delay in _delays) _bar(delay),
            ],
          );
        },
      ),
    );
  }

  Widget _bar(double delay) {
    final double t = (_c.value + delay) % 1.0;
    // ease-in-out between 4px and 14px, troughing at the cycle's start/end.
    final double h = 4 + 10 * (0.5 - 0.5 * (1 - 2 * t).abs() * (2 - (1 - 2 * t).abs()));
    return Container(
      width: 2.5,
      height: h,
      decoration: BoxDecoration(color: widget.color, borderRadius: BorderRadius.circular(2)),
    );
  }
}
