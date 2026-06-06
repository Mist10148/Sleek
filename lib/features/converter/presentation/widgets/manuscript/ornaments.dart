import 'package:flutter/material.dart';

import '../../../../../core/theme/manuscript_theme.dart';

/// A centered ornament glyph flanked by two fading hairlines (`.mss-fleuron`).
class Fleuron extends StatelessWidget {
  const Fleuron({super.key, required this.glyph, required this.gold});

  final String glyph;
  final Color gold;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        _ln(gold, flip: false),
        const SizedBox(width: 12),
        Transform.translate(
          offset: const Offset(0, -1),
          child: Text(
            glyph,
            style: TextStyle(
                color: gold.withValues(alpha: 0.8), fontSize: 15, height: 1),
          ),
        ),
        const SizedBox(width: 12),
        _ln(gold, flip: true),
      ],
    );
  }

  Widget _ln(Color gold, {required bool flip}) {
    final Gradient g = LinearGradient(
      begin: flip ? Alignment.centerRight : Alignment.centerLeft,
      end: flip ? Alignment.centerLeft : Alignment.centerRight,
      colors: <Color>[Colors.transparent, gold.withValues(alpha: 0.5)],
    );
    return Container(
      width: 42,
      height: 1,
      decoration: BoxDecoration(gradient: g),
    );
  }
}

/// A single fading gold hairline (`.mss-rule`).
class HairRule extends StatelessWidget {
  const HairRule({super.key, this.margin});
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
            Mss.rule(0.32),
            Mss.rule(0.32),
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
  const DoubleRule({super.key});

  @override
  Widget build(BuildContext context) {
    final Color c = Mss.rule(0.34);
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
class CornerFlourish extends StatelessWidget {
  const CornerFlourish({super.key, required this.pos, required this.color});

  final String pos;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final double rot = const <String, double>{
      'tl': 0,
      'tr': 90,
      'br': 180,
      'bl': 270,
    }[pos]!;
    final Widget art = SizedBox(
      width: 34,
      height: 34,
      child: CustomPaint(painter: _FlourishPainter(color)),
    );
    return Positioned(
      top: pos.startsWith('t') ? 6 : null,
      bottom: pos.startsWith('b') ? 6 : null,
      left: pos.endsWith('l') ? 6 : null,
      right: pos.endsWith('r') ? 6 : null,
      child: Transform.rotate(angle: rot * 3.1415926 / 180, child: art),
    );
  }
}

class _FlourishPainter extends CustomPainter {
  _FlourishPainter(this.color);
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final double k = size.width / 40; // paths authored in a 40x40 box
    final Paint stroke = Paint()
      ..color = color.withValues(alpha: 0.8)
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..strokeWidth = 1.3;

    final Path p1 = Path()
      ..moveTo(4 * k, 4 * k)
      ..lineTo(4 * k, 13 * k)
      ..cubicTo(4 * k, 19 * k, 8 * k, 21 * k, 13 * k, 21 * k);
    canvas.drawPath(p1, stroke);

    canvas.drawCircle(
        Offset(4 * k, 4 * k), 1.7 * k, Paint()..color = color.withValues(alpha: 0.8));

    final Paint faint = Paint()
      ..color = color.withValues(alpha: 0.4)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.8;
    final Path p2 = Path()
      ..moveTo(4 * k, 4 * k)
      ..cubicTo(14 * k, 4 * k, 18 * k, 9 * k, 18 * k, 18 * k);
    canvas.drawPath(p2, faint);
  }

  @override
  bool shouldRepaint(covariant _FlourishPainter old) => old.color != color;
}
