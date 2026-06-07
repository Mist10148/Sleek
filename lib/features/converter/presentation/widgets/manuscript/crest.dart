import 'package:flutter/material.dart';

import '../../../../../core/constants/app_constants.dart';
import '../../../../../core/theme/manuscript_theme.dart';
import '../../../../../core/theme/mss_palette.dart';
import 'mss_icons.dart';

/// The masthead: a quill seal, the SLEEK wordmark, and a small-caps subtitle.
/// `small` drops the seal + subtitle (used on loading/downloading screens).
class Crest extends StatelessWidget {
  const Crest({super.key, required this.binding, required this.palette, this.small = false});

  final ManuscriptBinding binding;
  final MssPalette palette;
  final bool small;

  @override
  Widget build(BuildContext context) {
    final MssPalette p = palette;
    return Column(
      children: <Widget>[
        SizedBox(height: small ? 6 : 14),
        if (!small) ...<Widget>[
          _Seal(binding: binding),
          const SizedBox(height: 10),
        ],
        Text(
          AppConstants.appName,
          style: binding.display0(TextStyle(
            fontSize: small ? 21 : 30,
            fontWeight: FontWeight.w500,
            letterSpacing: (small ? 21 : 30) * 0.14,
            color: p.display,
          )),
        ),
        if (!small) ...<Widget>[
          const SizedBox(height: 7),
          Text(AppConstants.appTagline, style: p.label(binding.gold)),
        ],
      ],
    );
  }
}

class _Seal extends StatelessWidget {
  const _Seal({required this.binding});
  final ManuscriptBinding binding;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 54,
      height: 54,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: binding.accent, width: 1.5),
        gradient: RadialGradient(
          center: const Alignment(0, -0.24),
          radius: 0.7,
          colors: <Color>[Colors.white.withValues(alpha: 0.05), Colors.transparent],
        ),
        boxShadow: <BoxShadow>[
          BoxShadow(color: binding.accentSoft, blurRadius: 18),
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.25),
            blurRadius: 0,
            spreadRadius: -4,
          ),
        ],
      ),
      alignment: Alignment.center,
      child: MssIcon('quill', size: 26, color: binding.accent),
    );
  }
}
