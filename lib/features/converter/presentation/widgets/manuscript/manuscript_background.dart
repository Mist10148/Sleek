import 'package:flutter/material.dart';

import '../../../../../core/theme/manuscript_theme.dart';

/// The shared dark "aged page" surface: a radial warm gradient, faint parchment
/// grain (fine horizontal rules under a multiply blend), and a vignette.
/// Equivalent to `.mss-root` + `.mss-grain` in the design's `kit.jsx`.
class ManuscriptBackground extends StatelessWidget {
  const ManuscriptBackground({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        gradient: RadialGradient(
          center: Alignment(0, -1),
          radius: 1.1,
          colors: <Color>[Mss.bg0, Mss.bg1, Mss.bg2],
          stops: <double>[0.0, 0.46, 1.0],
        ),
      ),
      child: Stack(
        children: <Widget>[
          Positioned.fill(
            child: IgnorePointer(
              child: CustomPaint(painter: _GrainPainter()),
            ),
          ),
          Positioned.fill(child: child),
        ],
      ),
    );
  }
}

class _GrainPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    // Fine horizontal rules @ ~2.5% black every 3px (parchment grain).
    final Paint line = Paint()
      ..color = Colors.black.withValues(alpha: 0.025)
      ..strokeWidth = 1;
    for (double y = 0; y < size.height; y += 3) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), line);
    }
    // Vignette — darkening toward the edges/bottom.
    final Rect rect = Offset.zero & size;
    final Paint vignette = Paint()
      ..shader = RadialGradient(
        center: const Alignment(0, -0.1),
        radius: 1.0,
        colors: <Color>[Colors.transparent, Colors.black.withValues(alpha: 0.42)],
        stops: const <double>[0.55, 1.0],
      ).createShader(rect);
    canvas.drawRect(rect, vignette);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
