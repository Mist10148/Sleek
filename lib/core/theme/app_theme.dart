import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import 'manuscript_theme.dart';

/// Minimal dark [ThemeData]. The manuscript surface paints its own gradients
/// and ornaments on top; this just sets the deep surround, default text colors,
/// and a few component baselines so stray Material widgets stay on-theme.
class AppTheme {
  AppTheme._();

  static const SystemUiOverlayStyle overlayStyle = SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
    statusBarBrightness: Brightness.dark,
    systemNavigationBarColor: Mss.surround,
    systemNavigationBarIconBrightness: Brightness.light,
  );

  static ThemeData dark() {
    final ColorScheme scheme = const ColorScheme.dark(
      surface: Mss.surround,
      primary: Color(0xFFCC6A43),
    ).copyWith(onSurface: Mss.text);

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: scheme,
      scaffoldBackgroundColor: Mss.surround,
      textTheme: GoogleFonts.ebGaramondTextTheme(ThemeData.dark().textTheme)
          .apply(bodyColor: Mss.text, displayColor: Mss.display),
      splashFactory: NoSplash.splashFactory,
      highlightColor: Colors.transparent,
    );
  }
}
