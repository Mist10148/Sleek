import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import 'manuscript_theme.dart';

class AppTheme {
  AppTheme._();

  static const SystemUiOverlayStyle overlayStyle = SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
    statusBarBrightness: Brightness.dark,
    systemNavigationBarColor: Mss.surround,
    systemNavigationBarIconBrightness: Brightness.light,
  );

  static const SystemUiOverlayStyle overlayStyleLight = SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.dark,
    statusBarBrightness: Brightness.light,
    systemNavigationBarColor: Color(0xFFEDE6D0),
    systemNavigationBarIconBrightness: Brightness.dark,
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

  static ThemeData light() {
    const Color surface = Color(0xFFEDE6D0);
    const Color onSurface = Color(0xFF2C1F10);

    final ColorScheme scheme = const ColorScheme.light(
      surface: surface,
      primary: Color(0xFFCC6A43),
    ).copyWith(onSurface: onSurface);

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: scheme,
      scaffoldBackgroundColor: surface,
      textTheme: GoogleFonts.ebGaramondTextTheme(ThemeData.light().textTheme)
          .apply(bodyColor: onSurface, displayColor: const Color(0xFF1A1208)),
      splashFactory: NoSplash.splashFactory,
      highlightColor: Colors.transparent,
    );
  }
}
