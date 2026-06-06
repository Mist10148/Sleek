import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/theme/manuscript_theme.dart';
import '../../domain/entities/media_format.dart';

/// Selectable quality pills (`.mss-pills`). For video the numeral gets a `p`
/// suffix; for audio it's the raw bitrate. Shows a friendly note when empty.
class QualityPills extends StatelessWidget {
  const QualityPills({
    super.key,
    required this.binding,
    required this.format,
    required this.options,
    required this.selected,
    required this.onChanged,
  });

  final ManuscriptBinding binding;
  final MediaFormat format;
  final List<QualityOption> options;
  final QualityOption? selected;
  final ValueChanged<QualityOption> onChanged;

  @override
  Widget build(BuildContext context) {
    if (options.isEmpty) {
      return Text(
        'No quality options available for this format.',
        style: Mss.serif(const TextStyle(fontSize: 13.5, color: Mss.muted)),
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
    final bool on = o == selected;
    final String big = format == MediaFormat.mp4 ? '${o.q}p' : o.q;
    return GestureDetector(
      onTap: () => onChanged(o),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 9),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(3),
          color: on ? binding.accentSoft : const Color(0x660C0906),
          border: Border.all(color: on ? binding.accent : Mss.rule(0.26)),
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
                      color: on ? Mss.display : const Color(0xFFB6A688))),
            ),
            const SizedBox(width: 7),
            Text(
              o.meta,
              style: Mss.mono(TextStyle(
                  fontSize: 9.5,
                  color: (on ? Mss.display : const Color(0xFFB6A688))
                      .withValues(alpha: 0.6))),
            ),
          ],
        ),
      ),
    );
  }
}
