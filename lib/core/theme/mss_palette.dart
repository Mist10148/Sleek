import 'package:flutter/material.dart';

import 'manuscript_theme.dart';

/// Resolves the right [MssPalette] for the current [BuildContext] by reading
/// the active [ThemeData.brightness]. This is reactive — Flutter rebuilds
/// widgets when the theme switches (dark ↔ light ↔ system).
MssPalette paletteOf(BuildContext context) {
  return Theme.of(context).brightness == Brightness.dark
      ? const MssDark()
      : const MssLight();
}

/// The full color + typography surface that every widget reads from instead of
/// using [Mss] static constants directly. Two concrete implementations:
/// [MssDark] (current aged-paper dark) and [MssLight] (warm parchment light).
abstract class MssPalette {
  const MssPalette();

  // ── Background gradient stops ──────────────────────────────────────────
  Color get bg0;
  Color get bg1;
  Color get bg2;

  /// Deep surround behind the manuscript column.
  Color get surround;

  // ── Text colors ────────────────────────────────────────────────────────
  Color get text;
  Color get display;
  Color get muted;
  Color get faint;

  /// Text/icon color on top of accent-colored fills (buttons, seals).
  Color get ink;

  // ── UI element backgrounds (with transparency baked in) ────────────────
  /// Card / receipt / skeleton bg (~60 % overlay).
  Color get cardBg;

  /// Opaque floating-menu / popup bg.
  Color get menuBg;

  /// Text-field bg (~80 % overlay).
  Color get fieldBg;

  /// Unselected quality pill bg (~40 % overlay).
  Color get pillBg;

  /// Progress bar track bg (~60 % overlay).
  Color get barBg;

  /// Format-segmented and save-select button bg (~50 % overlay).
  Color get overlay50;

  // ── Component-specific text / icon colors ──────────────────────────────
  /// Ghost-button label text and leading icons.
  Color get ghostLabel;

  /// Unselected quality pill text.
  Color get pillLabel;

  /// Menu-row text and folder icons.
  Color get menuItem;

  /// Hint text inside text fields.
  Color get hintColor;

  // ── Dynamic methods ────────────────────────────────────────────────────
  /// Gold hairline / border at the given opacity.
  Color rule(double a);

  TextStyle serif([TextStyle? base]);
  TextStyle mono([TextStyle? base]);

  /// Small-caps gold label style (same font in both modes; color via [gold]).
  TextStyle label(Color gold);

  bool get isDark;
}

// ── Dark palette (current "aged page" dark) ────────────────────────────────

class MssDark extends MssPalette {
  const MssDark();

  @override Color get bg0 => Mss.bg0;
  @override Color get bg1 => Mss.bg1;
  @override Color get bg2 => Mss.bg2;
  @override Color get surround => Mss.surround;
  @override Color get text => Mss.text;
  @override Color get display => Mss.display;
  @override Color get muted => Mss.muted;
  @override Color get faint => Mss.faint;
  @override Color get ink => Mss.ink;

  @override Color get cardBg => const Color(0x99140F0A);
  @override Color get menuBg => const Color(0xFF1D1710);
  @override Color get fieldBg => const Color(0xCC0C0906);
  @override Color get pillBg => const Color(0x660C0906);
  @override Color get barBg => const Color(0x990C0906);
  @override Color get overlay50 => const Color(0x800C0906);

  @override Color get ghostLabel => const Color(0xFFC9B999);
  @override Color get pillLabel => const Color(0xFFB6A688);
  @override Color get menuItem => const Color(0xFFD7C8AC);
  @override Color get hintColor => const Color(0xFF6F6450);

  @override Color rule(double a) => Mss.rule(a);
  @override TextStyle serif([TextStyle? base]) => Mss.serif(base);
  @override TextStyle mono([TextStyle? base]) => Mss.mono(base);
  @override TextStyle label(Color gold) => Mss.label(gold);

  @override bool get isDark => true;
}

// ── Light palette (warm parchment) ────────────────────────────────────────

class MssLight extends MssPalette {
  const MssLight();

  @override Color get bg0 => const Color(0xFFF9F3E5);
  @override Color get bg1 => const Color(0xFFF2ECD8);
  @override Color get bg2 => const Color(0xFFEBE4CE);
  @override Color get surround => const Color(0xFFEDE6D0);
  @override Color get text => const Color(0xFF2C1F10);
  @override Color get display => const Color(0xFF1A1208);
  @override Color get muted => const Color(0xFF6B5240);
  @override Color get faint => const Color(0xFF9C8366);
  @override Color get ink => const Color(0xFF1A120C);

  @override Color get cardBg => const Color(0x99EDE5CC);
  @override Color get menuBg => const Color(0xFFF5EDD8);
  @override Color get fieldBg => const Color(0xCCEDE5CC);
  @override Color get pillBg => const Color(0x66EDE5CC);
  @override Color get barBg => const Color(0x99EDE5CC);
  @override Color get overlay50 => const Color(0x80EDE5CC);

  @override Color get ghostLabel => const Color(0xFF6B5240);
  @override Color get pillLabel => const Color(0xFF8B6A3A);
  @override Color get menuItem => const Color(0xFF3B2515);
  @override Color get hintColor => const Color(0xFF9C8366);

  @override Color rule(double a) =>
      const Color(0xFF8B6A3A).withValues(alpha: a);
  @override TextStyle serif([TextStyle? base]) => Mss.serif(base);
  @override TextStyle mono([TextStyle? base]) => Mss.mono(base);
  @override TextStyle label(Color gold) => Mss.label(gold);

  @override bool get isDark => false;
}
