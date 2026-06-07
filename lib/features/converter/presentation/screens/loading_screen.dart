import 'package:flutter/material.dart';

import '../../../../core/theme/manuscript_theme.dart';
import '../../../../core/theme/mss_palette.dart';
import '../widgets/manuscript/crest.dart';
import '../widgets/manuscript/mss_spinner.dart';
import '../widgets/manuscript/primitives.dart';

/// Phase 2 — retrieving the record. Spinner, animated dots, and a skeleton card.
class LoadingScreen extends StatefulWidget {
  const LoadingScreen({super.key, required this.binding, required this.palette});
  final ManuscriptBinding binding;
  final MssPalette palette;

  @override
  State<LoadingScreen> createState() => _LoadingScreenState();
}

class _LoadingScreenState extends State<LoadingScreen> {
  @override
  Widget build(BuildContext context) {
    final ManuscriptBinding b = widget.binding;
    final MssPalette p = widget.palette;
    return Padding(
      padding: const EdgeInsets.fromLTRB(26, 70, 26, 40),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Crest(binding: b, palette: p, small: true),
          const SizedBox(height: 40),
          Column(
            children: <Widget>[
              MssQuill(color: b.accent),
              const SizedBox(height: 18),
              _RetrievingText(binding: b, palette: p),
              const SizedBox(height: 10),
              MssLabel('Reading manifest', gold: b.gold),
            ],
          ),
          const SizedBox(height: 38),
          _SkeletonCard(binding: b, palette: p),
        ],
      ),
    );
  }
}

class _RetrievingText extends StatefulWidget {
  const _RetrievingText({required this.binding, required this.palette});
  final ManuscriptBinding binding;
  final MssPalette palette;

  @override
  State<_RetrievingText> createState() => _RetrievingTextState();
}

class _RetrievingTextState extends State<_RetrievingText> {
  String _dots = '';

  @override
  void initState() {
    super.initState();
    _tick();
  }

  Future<void> _tick() async {
    while (mounted) {
      await Future<void>.delayed(const Duration(milliseconds: 320));
      if (!mounted) return;
      setState(() => _dots = _dots.length >= 3 ? '' : '$_dots·');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Text.rich(
      TextSpan(children: <InlineSpan>[
        const TextSpan(text: 'Retrieving the record'),
        TextSpan(text: _dots, style: TextStyle(color: widget.binding.accent)),
      ]),
      style: widget.binding.display0(TextStyle(fontSize: 18, color: widget.palette.display)),
    );
  }
}

class _SkeletonCard extends StatelessWidget {
  const _SkeletonCard({required this.binding, required this.palette});
  final ManuscriptBinding binding;
  final MssPalette palette;

  @override
  Widget build(BuildContext context) {
    final MssPalette p = palette;
    return Container(
      decoration: BoxDecoration(
        color: p.cardBg,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: p.rule(0.24)),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          AspectRatio(
            aspectRatio: 16 / 9,
            child: ColorFiltered(
              colorFilter: const ColorFilter.mode(
                  Color(0x66000000), BlendMode.darken),
              child: Container(
                decoration: const BoxDecoration(
                  gradient: RadialGradient(
                    center: Alignment(-0.44, -0.6),
                    radius: 1.3,
                    colors: <Color>[
                      Color(0xFF5A3F2C),
                      Color(0xFF3A2A1E),
                      Color(0xFF241A12)
                    ],
                  ),
                ),
                child: Center(
                  child: Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: const Color(0x4DF1E7D4), width: 1.5),
                    ),
                  ),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                for (final double w in <double>[0.78, 0.54, 0.40]) ...<Widget>[
                  FractionallySizedBox(
                    alignment: Alignment.centerLeft,
                    widthFactor: w,
                    child: Container(
                      height: 11,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(3),
                        gradient: LinearGradient(colors: <Color>[
                          p.rule(0.18),
                          p.rule(0.06),
                        ]),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
