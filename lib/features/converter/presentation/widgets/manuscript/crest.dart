import 'package:flutter/material.dart';

import '../../../../../core/constants/app_constants.dart';
import '../../../../../core/theme/manuscript_theme.dart';
import 'mss_icons.dart';

/// The masthead: a quill seal, the SLEEK wordmark, and a small-caps subtitle.
/// `small` drops the seal + subtitle (used on loading/downloading screens).
/// Equivalent to the `Crest` component in the design's `Downloader.jsx`.
class Crest extends StatelessWidget {
  const Crest({super.key, required this.binding, this.small = false});

  final ManuscriptBinding binding;
  final bool small;

  @override
  Widget build(BuildContext context) {
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
            color: Mss.display,
          )),
        ),
        if (!small) ...<Widget>[
          const SizedBox(height: 7),
          Text(AppConstants.appTagline, style: Mss.label(binding.gold)),
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
