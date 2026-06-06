import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Which display typeface a binding uses for headings.
enum DisplayFace { spectral, newsreader }

/// A "binding" — one of the three scholarly directions over a shared dark
/// aged-page palette. The Dart equivalent of the `THEMES` object + CSS vars in
/// the design's `kit.jsx`.
class ManuscriptBinding {
  const ManuscriptBinding({
    required this.key,
    required this.name,
    required this.blurb,
    required this.accent,
    required this.accentDeep,
    required this.gold,
    required this.ornament,
    required this.display,
    this.dropcap = false,
    this.catalog = false,
  });

  /// Stable id ('codex' | 'folio' | 'illuminated').
  final String key;

  /// Roman-numeral name, e.g. "I · Codex".
  final String name;
  final String blurb;

  final Color accent;
  final Color accentDeep;
  final Color gold;

  /// 1 = ruled lines · 2 = illuminated (flourishes, fleurons).
  final int ornament;
  final DisplayFace display;

  /// Drop-cap on the preview title (illuminated only).
  final bool dropcap;

  /// Archival catalogue treatment — adds the "REF" ink stamp (folio only).
  final bool catalog;

  Color get accentSoft => accent.withValues(alpha: 0.14);

  /// Display typeface as a [TextStyle] base.
  TextStyle display0([TextStyle? base]) => switch (display) {
        DisplayFace.spectral => GoogleFonts.spectral(textStyle: base),
        DisplayFace.newsreader => GoogleFonts.newsreader(textStyle: base),
      };
}

/// Shared dark "aged page" palette (binding-independent).
class Mss {
  Mss._();

  // Background gradient stops.
  static const Color bg0 = Color(0xFF241D15);
  static const Color bg1 = Color(0xFF1B1610);
  static const Color bg2 = Color(0xFF15110C);

  /// Deep surround behind the manuscript column (the design artboard bg).
  static const Color surround = Color(0xFF16110C);

  static const Color text = Color(0xFFECE0CB);
  static const Color display = Color(0xFFF1E7D4);
  static const Color muted = Color(0xFFA2937A);
  static const Color faint = Color(0xFF7C6F58);

  /// Ink used inside accent fills (button text on terracotta).
  static const Color ink = Color(0xFF1A120C);

  // Common hairline / border tints derived from gold.
  static Color rule(double a) => const Color(0xFFC2A36B).withValues(alpha: a);

  /// Prose face — EB Garamond.
  static TextStyle serif([TextStyle? base]) =>
      GoogleFonts.ebGaramond(textStyle: base);

  /// Mono / numerals — JetBrains Mono.
  static TextStyle mono([TextStyle? base]) =>
      GoogleFonts.jetBrainsMono(textStyle: base);

  /// Small-caps label — Spectral, uppercase, wide tracking, gold.
  static TextStyle label(Color gold) => GoogleFonts.spectral(
        textStyle: TextStyle(
          fontSize: 10.5,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.32 * 10.5,
          color: gold,
          height: 1.2,
        ),
      );
}

const ManuscriptBinding kCodex = ManuscriptBinding(
  key: 'codex',
  name: 'I · Codex',
  blurb: 'Restrained. Ruled lines, small-caps labels, a single terracotta seal.',
  accent: Color(0xFFD98A63),
  accentDeep: Color(0xFFC26B45),
  gold: Color(0xFFC2A36B),
  ornament: 1,
  display: DisplayFace.spectral,
);

const ManuscriptBinding kFolio = ManuscriptBinding(
  key: 'folio',
  name: 'II · Folio',
  blurb: 'Archival card-catalogue. Brass call-numbers, ruled index lines, ink stamps.',
  accent: Color(0xFFC8A86A),
  accentDeep: Color(0xFFA9854A),
  gold: Color(0xFFC8A86A),
  ornament: 1,
  display: DisplayFace.newsreader,
  catalog: true,
);

const ManuscriptBinding kIlluminated = ManuscriptBinding(
  key: 'illuminated',
  name: 'III · Illuminated',
  blurb: 'Richest. Gilded frames, corner flourishes, a drop-cap and fleurons.',
  accent: Color(0xFFCC6A43),
  accentDeep: Color(0xFFB0532F),
  gold: Color(0xFFCBA86A),
  ornament: 2,
  display: DisplayFace.spectral,
  dropcap: true,
);

const List<ManuscriptBinding> kBindings = <ManuscriptBinding>[
  kCodex,
  kFolio,
  kIlluminated,
];
