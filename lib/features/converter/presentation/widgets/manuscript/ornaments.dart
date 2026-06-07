import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import '../../../../../core/theme/mss_palette.dart';

/// A centered ornament glyph flanked by two fading hairlines (`.mss-fleuron`).
///
/// Blooms in the moment it first appears — the hairlines draw outward from
/// the centre while the glyph settles in from a faint, slightly-shrunken
/// state, like ink spreading from a quill's first touch to the page. Plays
/// once per mount; if you need it to replay, give the widget a fresh [key].
class Fleuron extends StatefulWidget {
  const Fleuron({super.key, required this.glyph, required this.gold});

  final String glyph;
  final Color gold;

  @override
  State<Fleuron> createState() => _FleuronState();
}

class _FleuronState extends State<Fleuron> with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 820))
    ..forward();

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _c,
      builder: (BuildContext context, _) {
        final double v = _c.value;
        // The hairlines draw first (0 → 75% of the timeline)…
        final double lineT = Curves.easeOutCubic.transform((v / 0.75).clamp(0.0, 1.0));
        // …and the glyph blooms in just behind their lead, catching up by the end.
        final double glyphT = Curves.easeOut.transform(((v - 0.3) / 0.7).clamp(0.0, 1.0));
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            _ln(flip: false, t: lineT),
            const SizedBox(width: 12),
            Opacity(
              opacity: glyphT,
              child: Transform.scale(
                scale: 0.55 + 0.45 * glyphT,
                child: Transform.translate(
                  offset: const Offset(0, -1),
                  child: Text(
                    widget.glyph,
                    style: TextStyle(
                        color: widget.gold.withValues(alpha: 0.8),
                        fontSize: 15,
                        height: 1),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            _ln(flip: true, t: lineT),
          ],
        );
      },
    );
  }

  Widget _ln({required bool flip, required double t}) {
    final Gradient g = LinearGradient(
      begin: flip ? Alignment.centerRight : Alignment.centerLeft,
      end: flip ? Alignment.centerLeft : Alignment.centerRight,
      colors: <Color>[Colors.transparent, widget.gold.withValues(alpha: 0.5 * t)],
    );
    return Container(
      width: 42 * t,
      height: 1,
      decoration: BoxDecoration(gradient: g),
    );
  }
}

/// A single fading gold hairline (`.mss-rule`).
class HairRule extends StatelessWidget {
  const HairRule({super.key, required this.palette, this.margin});
  final MssPalette palette;
  final EdgeInsetsGeometry? margin;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin,
      height: 1,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: <Color>[
            Colors.transparent,
            palette.rule(0.32),
            palette.rule(0.32),
            Colors.transparent,
          ],
          stops: const <double>[0.0, 0.18, 0.82, 1.0],
        ),
      ),
    );
  }
}

/// Two parallel gold hairlines (`.mss-rule-double`).
class DoubleRule extends StatelessWidget {
  const DoubleRule({super.key, required this.palette});
  final MssPalette palette;

  @override
  Widget build(BuildContext context) {
    final Color c = palette.rule(0.34);
    return SizedBox(
      height: 4,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Container(height: 1, color: c),
          Container(height: 1, color: c),
        ],
      ),
    );
  }
}

/// A corner flourish (illuminated binding). `pos` ∈ {tl,tr,br,bl}.
///
/// Traces itself on like a nib drawing the curl onto vellum: the corner dot
/// touches down first, the bold curl sweeps out from it, and the faint
/// flourish trails in last — all once, on first appearance.
class CornerFlourish extends StatefulWidget {
  const CornerFlourish({super.key, required this.pos, required this.color});

  final String pos;
  final Color color;

  @override
  State<CornerFlourish> createState() => _CornerFlourishState();
}

class _CornerFlourishState extends State<CornerFlourish>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 1000))
    ..forward();

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final double rot = const <String, double>{
      'tl': 0,
      'tr': 90,
      'br': 180,
      'bl': 270,
    }[widget.pos]!;
    final Widget art = SizedBox(
      width: 34,
      height: 34,
      child: AnimatedBuilder(
        animation: _c,
        builder: (BuildContext context, _) => CustomPaint(
          painter: _FlourishPainter(
              widget.color, Curves.easeOutCubic.transform(_c.value)),
        ),
      ),
    );
    return Positioned(
      top: widget.pos.startsWith('t') ? 6 : null,
      bottom: widget.pos.startsWith('b') ? 6 : null,
      left: widget.pos.endsWith('l') ? 6 : null,
      right: widget.pos.endsWith('r') ? 6 : null,
      child: Transform.rotate(angle: rot * 3.1415926 / 180, child: art),
    );
  }
}

class _FlourishPainter extends CustomPainter {
  _FlourishPainter(this.color, this.progress);
  final Color color;

  /// 0→1 — how much of the flourish has been "drawn" so far.
  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    final double k = size.width / 40;
    final double t = progress.clamp(0.0, 1.0);

    final Paint stroke = Paint()
      ..color = color.withValues(alpha: 0.8)
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..strokeWidth = 1.3;

    // The corner dot: the nib's first touch — appears almost immediately,
    // then the curls trace outward from it.
    final double dotT = (t / 0.16).clamp(0.0, 1.0);
    if (dotT > 0) {
      canvas.drawCircle(Offset(4 * k, 4 * k), 1.7 * k * dotT,
          Paint()..color = color.withValues(alpha: 0.8 * dotT));
    }

    final Path p1 = Path()
      ..moveTo(4 * k, 4 * k)
      ..lineTo(4 * k, 13 * k)
      ..cubicTo(4 * k, 19 * k, 8 * k, 21 * k, 13 * k, 21 * k);
    canvas.drawPath(_trim(p1, (t / 0.7).clamp(0.0, 1.0)), stroke);

    final Paint faint = Paint()
      ..color = color.withValues(alpha: 0.4)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.8;
    final Path p2 = Path()
      ..moveTo(4 * k, 4 * k)
      ..cubicTo(14 * k, 4 * k, 18 * k, 9 * k, 18 * k, 18 * k);
    canvas.drawPath(_trim(p2, ((t - 0.3) / 0.7).clamp(0.0, 1.0)), faint);
  }

  /// Returns the leading [fraction] of [source] — the freshly-inked portion
  /// of the stroke a nib would have traced by this point.
  Path _trim(Path source, double fraction) {
    if (fraction <= 0) return Path();
    if (fraction >= 1) return source;
    final Path out = Path();
    for (final ui.PathMetric metric in source.computeMetrics()) {
      out.addPath(metric.extractPath(0, metric.length * fraction), Offset.zero);
    }
    return out;
  }

  @override
  bool shouldRepaint(covariant _FlourishPainter old) =>
      old.color != color || old.progress != progress;
}
