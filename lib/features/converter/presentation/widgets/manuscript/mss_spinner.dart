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

/// A quill nib tracing an inked stroke around a circular rule, trailing a
/// curl of ink that dries — fades — as the nib moves on. The manuscript's
/// answer to a loading spinner: used wherever the app is *composing*
/// something (retrieving a record, setting audio to verse) rather than
/// moving bytes, which already has its own marching-stripe meter.
class MssQuill extends StatefulWidget {
  const MssQuill({super.key, required this.color, this.size = 38});

  final Color color;
  final double size;

  @override
  State<MssQuill> createState() => _MssQuillState();
}

class _MssQuillState extends State<MssQuill> with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 2200))
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
        builder: (BuildContext context, _) => CustomPaint(
          painter: _QuillPainter(color: widget.color, phase: _c.value),
        ),
      ),
    );
  }
}

class _QuillPainter extends CustomPainter {
  _QuillPainter({required this.color, required this.phase});

  final Color color;

  /// 0→1, looping — the nib's position along its circuit.
  final double phase;

  static const double _sweep = 4.4; // ≈ 252° — leaves a visible "unwritten" gap
  static const int _segments = 22;

  @override
  void paint(Canvas canvas, Size size) {
    final Rect r = (Offset.zero & size).deflate(2.5);
    final double start = phase * 2 * math.pi;

    // The faint circular rule the nib travels along — the page's guideline.
    canvas.drawArc(
      r,
      0,
      2 * math.pi,
      false,
      Paint()
        ..color = color.withValues(alpha: 0.10)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.2,
    );

    // The inked trail itself: short overlapping strokes, each a touch
    // fainter and thinner than the last — wet ink drying behind a moving
    // nib, freshest (boldest, most opaque) right at the tip.
    const double step = _sweep / _segments;
    for (int i = 0; i < _segments; i++) {
      final double t = i / (_segments - 1); // 0 at tail → 1 at the nib
      canvas.drawArc(
        r,
        start + step * i,
        step * 1.7, // slight overlap so the trail reads as continuous ink
        false,
        Paint()
          ..color = color.withValues(alpha: 0.04 + 0.46 * t * t)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.3 + 1.5 * t
          ..strokeCap = StrokeCap.round,
      );
    }

    // The nib tip — a small bright point with a soft halo, where the ink is
    // freshest and the "writing" is actively happening right now.
    final double nibAngle = start + _sweep;
    final Offset nib = Offset(
      r.center.dx + r.width / 2 * math.cos(nibAngle),
      r.center.dy + r.height / 2 * math.sin(nibAngle),
    );
    canvas.drawCircle(nib, 5.5, Paint()..color = color.withValues(alpha: 0.20));
    canvas.drawCircle(nib, 2.4, Paint()..color = color);
  }

  @override
  bool shouldRepaint(covariant _QuillPainter old) =>
      old.phase != phase || old.color != color;
}
