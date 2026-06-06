import 'package:flutter/material.dart';

/// Central color palette. The app uses a Material 3 [ColorScheme] seeded from
/// [seed], so most colors are derived automatically; the values here are the
/// brand anchors used for seeding and a few bespoke accents.
class AppColors {
  AppColors._();

  /// Primary brand seed — a warm YouTube-adjacent red.
  static const Color seed = Color(0xFFE53935);

  /// Accent used for success / completed states.
  static const Color success = Color(0xFF2E7D32);

  /// Gradient used on the hero header.
  static const List<Color> headerGradient = <Color>[
    Color(0xFFE53935),
    Color(0xFFB71C1C),
  ];
}
