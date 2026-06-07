import 'package:flutter/material.dart';

import '../../../../../core/theme/mss_palette.dart';

/// The shared "aged page" surface: a radial warm gradient, faint parchment
/// grain (fine horizontal rules), and a vignette. Adapts automatically to
/// dark (deep amber) and light (warm parchment) themes — and now *eases*
/// between them rather than snapping, so switching binding or theme mode in
/// Settings feels like the light over the page genuinely shifting, not a
/// hard cut.
class ManuscriptBackground extends StatelessWidget {
  const ManuscriptBackground({super.key, required this.child});

  final Widget child;

  static const Duration _fade = Duration(milliseconds: 520);
  static const Curve _curve = Curves.easeInOutCubic;

  @override
  Widget build(BuildContext context) {
    final MssPalette p = paletteOf(context);

    final Widget surface = Stack(
      children: <Widget>[
        Positioned.fill(
          child: IgnorePointer(
            child: CustomPaint(painter: _GrainPainter(p.isDark)),
          ),
        ),
        Positioned.fill(child: child),
      ],
    );

    // Three independently-tweened stops — each `TweenAnimationBuilder`
    // notices when its target color changes and glides there from wherever
    // it currently sits, so rapid switches mid-transition stay seamless.
    return _animatedStop(
      end: p.bg0,
      builder: (Color c0) => _animatedStop(
        end: p.bg1,
        builder: (Color c1) => _animatedStop(
          end: p.bg2,
          builder: (Color c2) => DecoratedBox(
            decoration: BoxDecoration(
              gradient: RadialGradient(
                center: const Alignment(0, -1),
                radius: 1.1,
                colors: <Color>[c0, c1, c2],
                stops: const <double>[0.0, 0.46, 1.0],
              ),
            ),
            child: surface,
          ),
        ),
      ),
    );
  }

  Widget _animatedStop({required Color end, required Widget Function(Color) builder}) {
    return TweenAnimationBuilder<Color?>(
      tween: ColorTween(end: end),
      duration: _fade,
      curve: _curve,
      builder: (BuildContext context, Color? value, Widget? _) => builder(value ?? end),
    );
  }
}

class _GrainPainter extends CustomPainter {
  const _GrainPainter(this.isDark);
  final bool isDark;

  @override
  void paint(Canvas canvas, Size size) {
    // Fine horizontal rules — dark mode: black lines; light: warm-brown lines.
    final Paint line = Paint()
      ..color = (isDark ? Colors.black : const Color(0xFF6B4A2A))
          .withValues(alpha: isDark ? 0.025 : 0.04)
      ..strokeWidth = 1;
    for (double y = 0; y < size.height; y += 3) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), line);
    }
    // Vignette.
    final Rect rect = Offset.zero & size;
    final Paint vignette = Paint()
      ..shader = RadialGradient(
        center: const Alignment(0, -0.1),
        radius: 1.0,
        colors: <Color>[
          Colors.transparent,
          Colors.black.withValues(alpha: isDark ? 0.42 : 0.12),
        ],
        stops: const <double>[0.55, 1.0],
      ).createShader(rect);
    canvas.drawRect(rect, vignette);
  }

  @override
  bool shouldRepaint(covariant _GrainPainter old) => old.isDark != isDark;
}
