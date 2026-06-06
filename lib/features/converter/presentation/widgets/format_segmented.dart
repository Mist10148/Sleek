import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/theme/manuscript_theme.dart';
import '../../domain/entities/media_format.dart';
import 'manuscript/mss_icons.dart';

/// MP3 / MP4 segmented toggle with a gliding gradient indicator (`.mss-seg`).
class FormatSegmented extends StatelessWidget {
  const FormatSegmented({
    super.key,
    required this.binding,
    required this.value,
    required this.onChanged,
  });

  final ManuscriptBinding binding;
  final MediaFormat value;
  final ValueChanged<MediaFormat> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: const Color(0x800C0906),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: Mss.rule(0.2)),
      ),
      child: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints c) {
          final double w = (c.maxWidth - 4) / 2; // two options, 4px gap split
          return Stack(
            children: <Widget>[
              AnimatedAlign(
                duration: const Duration(milliseconds: 280),
                curve: Curves.easeOutCubic,
                alignment: value == MediaFormat.mp3
                    ? Alignment.centerLeft
                    : Alignment.centerRight,
                child: Container(
                  width: w,
                  height: 58,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(4),
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: <Color>[binding.accent, binding.accentDeep],
                    ),
                    boxShadow: <BoxShadow>[
                      BoxShadow(
                          color: binding.accentDeep.withValues(alpha: 0.5),
                          blurRadius: 16,
                          offset: const Offset(0, 6),
                          spreadRadius: -8),
                    ],
                  ),
                ),
              ),
              Row(
                children: <Widget>[
                  _opt(MediaFormat.mp3, 'music'),
                  _opt(MediaFormat.mp4, 'film'),
                ],
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _opt(MediaFormat f, String icon) {
    final bool on = f == value;
    final Color c = on ? Mss.ink : const Color(0xFF9D8F76);
    return Expanded(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => onChanged(f),
        child: SizedBox(
          height: 58,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              MssIcon(icon, size: 17, color: c),
              const SizedBox(height: 5),
              Text(
                f.label,
                style: GoogleFonts.spectral(
                    textStyle: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.6,
                        color: c)),
              ),
              const SizedBox(height: 1),
              Text(
                f.description.toUpperCase(),
                style: GoogleFonts.spectral(
                    textStyle: TextStyle(
                        fontSize: 10,
                        letterSpacing: 1.8,
                        color: c.withValues(alpha: 0.7))),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
