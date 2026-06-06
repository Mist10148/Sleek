import 'dart:math' as math;

import 'package:flutter/material.dart';

/// A rotating arc spinner (`.mss-spin`) — a dashed ring in the accent color.
class MssSpinner extends StatefulWidget {
  const MssSpinner({super.key, required this.color, this.size = 38});

  final Color color;
  final double size;

  @override
  State<MssSpinner> createState() => _MssSpinnerState();
}

class _MssSpinnerState extends State<MssSpinner>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 1100))
    ..repeat();

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: AnimatedBuilder(
        animation: _c,
        builder: (BuildContext context, _) => Transform.rotate(
          angle: _c.value * 2 * math.pi,
          child: CustomPaint(painter: _ArcPainter(widget.color)),
        ),
      ),
    );
  }
}

class _ArcPainter extends CustomPainter {
  _ArcPainter(this.color);
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final Paint p = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 2;
    final Rect r = Offset.zero & size;
    // ~150° sweep arc (dasharray 90/60 equivalent).
    canvas.drawArc(r.deflate(2), 0, 2.6, false, p);
  }

  @override
  bool shouldRepaint(covariant _ArcPainter old) => old.color != color;
}
