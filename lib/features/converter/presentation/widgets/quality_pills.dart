import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/theme/manuscript_theme.dart';
import '../../../../core/theme/mss_palette.dart';
import '../../domain/entities/media_format.dart';

/// Selectable quality pills (`.mss-pills`).
class QualityPills extends StatelessWidget {
  const QualityPills({
    super.key,
    required this.binding,
    required this.palette,
    required this.format,
    required this.options,
    required this.selected,
    required this.onChanged,
  });

  final ManuscriptBinding binding;
  final MssPalette palette;
  final MediaFormat format;
  final List<QualityOption> options;
  final QualityOption? selected;
  final ValueChanged<QualityOption> onChanged;

  @override
  Widget build(BuildContext context) {
    if (options.isEmpty) {
      return Text(
        'No quality options available for this format.',
        style: palette.serif(TextStyle(fontSize: 13.5, color: palette.muted)),
      );
    }
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: <Widget>[
        for (final QualityOption o in options) _pill(o),
      ],
    );
  }

  Widget _pill(QualityOption o) {
    final MssPalette p = palette;
    final bool on = o == selected;
    final String big = format == MediaFormat.mp4 ? '${o.q}p' : o.q;
    return GestureDetector(
      onTap: () {
        // Picking a bitrate is a real choice with consequences (file size,
        // fidelity) — a light tactile click confirms it landed, the same
        // restrained touch as the format toggle beside it.
        HapticFeedback.lightImpact();
        onChanged(o);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 9),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(3),
          color: on ? binding.accentSoft : p.pillBg,
          border: Border.all(color: on ? binding.accent : p.rule(0.26)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: <Widget>[
            Text(
              big,
              style: GoogleFonts.spectral(
                  textStyle: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: on ? p.display : p.pillLabel)),
            ),
            const SizedBox(width: 7),
            Text(
              o.meta,
              style: p.mono(TextStyle(
                  fontSize: 9.5,
                  color: (on ? p.display : p.pillLabel).withValues(alpha: 0.6))),
            ),
          ],
        ),
      ),
    );
  }
}
