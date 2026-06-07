import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/theme/manuscript_theme.dart';
import '../../../../core/theme/mss_palette.dart';

/// The downloading meter: a big percent numeral, a marching-stripe progress bar,
/// and a three-up stat grid (Elapsed / Remaining / MB per sec).
class ProgressMeter extends StatelessWidget {
  const ProgressMeter({
    super.key,
    required this.binding,
    required this.palette,
    required this.pct,
    required this.sizeLine,
    required this.elapsed,
    required this.remaining,
    required this.speed,
    this.speedLabel = 'MB / sec',
  });

  final ManuscriptBinding binding;
  final MssPalette palette;

  /// 0–100.
  final double pct;
  final String sizeLine;
  final String elapsed;
  final String remaining;
  final String speed;

  /// Caption under the third stat — swappable so phases that don't move
  /// bytes (e.g. ffmpeg re-encoding, reported as "× realtime") can still use
  /// this same meter honestly instead of mislabelling their own units.
  final String speedLabel;

  @override
  Widget build(BuildContext context) {
    final MssPalette p = palette;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: <Widget>[
            Text('${pct.floor()}',
                style: p.mono(TextStyle(
                    fontSize: 52, height: 1, color: p.display))),
            const SizedBox(width: 4),
            Text('%',
                style: p.mono(TextStyle(fontSize: 22, color: binding.accent))),
          ],
        ),
        const SizedBox(height: 8),
        Center(
          child: Text(sizeLine,
              style: p.mono(TextStyle(fontSize: 11.5, color: p.faint))),
        ),
        const SizedBox(height: 26),
        _MarchingBar(binding: binding, palette: p, value: (pct / 100).clamp(0, 1)),
        const SizedBox(height: 26),
        _statGrid(p),
      ],
    );
  }

  Widget _statGrid(MssPalette p) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(5),
        border: Border.all(color: p.rule(0.2)),
      ),
      clipBehavior: Clip.antiAlias,
      child: IntrinsicHeight(
        child: Row(
          children: <Widget>[
            _stat(p, elapsed, 'Elapsed', divider: true),
            _stat(p, remaining, 'Remaining', divider: true),
            _stat(p, speed, speedLabel, divider: false),
          ],
        ),
      ),
    );
  }

  Widget _stat(MssPalette p, String value, String key, {required bool divider}) {
    return Expanded(
      child: Container(
        decoration: divider
            ? BoxDecoration(
                border: Border(right: BorderSide(color: p.rule(0.14))))
            : null,
        padding: const EdgeInsets.symmetric(vertical: 11, horizontal: 8),
        child: Column(
          children: <Widget>[
            Text(value,
                style: p.mono(TextStyle(fontSize: 14, color: p.display))),
            const SizedBox(height: 3),
            Text(key.toUpperCase(),
                style: GoogleFonts.spectral(
                    textStyle: TextStyle(
                        fontSize: 9,
                        letterSpacing: 1.8,
                        color: p.muted))),
          ],
        ),
      ),
    );
  }
}

/// Progress track with an animated diagonal-stripe fill (`.mss-prog`).
class _MarchingBar extends StatefulWidget {
  const _MarchingBar({required this.binding, required this.palette, required this.value});
  final ManuscriptBinding binding;
  final MssPalette palette;
  final double value;

  @override
  State<_MarchingBar> createState() => _MarchingBarState();
}

class _MarchingBarState extends State<_MarchingBar>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 1000))
    ..repeat();

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ManuscriptBinding b = widget.binding;
    final MssPalette p = widget.palette;
    return Container(
      height: 9,
      decoration: BoxDecoration(
        color: p.barBg,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: p.rule(0.22)),
      ),
      clipBehavior: Clip.antiAlias,
      child: Align(
        alignment: Alignment.centerLeft,
        child: FractionallySizedBox(
          widthFactor: widget.value <= 0 ? 0.001 : widget.value,
          child: AnimatedBuilder(
            animation: _c,
            builder: (BuildContext context, _) => CustomPaint(
              painter: _StripePainter(
                  base0: b.accentDeep, base1: b.accent, phase: _c.value),
            ),
          ),
        ),
      ),
    );
  }
}

class _StripePainter extends CustomPainter {
  _StripePainter({required this.base0, required this.base1, required this.phase});
  final Color base0;
  final Color base1;
  final double phase;

  @override
  void paint(Canvas canvas, Size size) {
    final Rect r = Offset.zero & size;
    canvas.drawRect(
      r,
      Paint()
        ..shader = LinearGradient(colors: <Color>[base0, base1]).createShader(r),
    );
    final Paint stripe = Paint()..color = Colors.white.withValues(alpha: 0.16);
    const double period = 14;
    final double off = phase * period;
    canvas.save();
    canvas.clipRect(r);
    for (double x = -size.height; x < size.width + period; x += period) {
      final Path p = Path()
        ..moveTo(x + off, size.height)
        ..lineTo(x + off + 6, size.height)
        ..lineTo(x + off + 6 + size.height, 0)
        ..lineTo(x + off + size.height, 0)
        ..close();
      canvas.drawPath(p, stripe);
    }
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _StripePainter old) =>
      old.phase != phase || old.base1 != base1;
}
