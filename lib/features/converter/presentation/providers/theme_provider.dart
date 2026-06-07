import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/theme/manuscript_theme.dart';

/// The currently selected binding (I · Codex / II · Folio / III · Illuminated).
class BindingController extends Notifier<ManuscriptBinding> {
  @override
  ManuscriptBinding build() => kIlluminated;

  void select(ManuscriptBinding binding) => state = binding;
}

final bindingProvider =
    NotifierProvider<BindingController, ManuscriptBinding>(BindingController.new);

// ── Theme mode (dark / light / system) with SharedPreferences persistence ──

const String _kThemeModeKey = 'theme_mode';

class ThemeModeNotifier extends Notifier<ThemeMode> {
  @override
  ThemeMode build() {
    Future.microtask(_loadFromPrefs);
    return ThemeMode.system;
  }

  Future<void> _loadFromPrefs() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? stored = prefs.getString(_kThemeModeKey);
    if (stored != null) state = _parse(stored);
  }

  Future<void> set(ThemeMode mode) async {
    state = mode;
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kThemeModeKey, _name(mode));
  }

  static ThemeMode _parse(String s) => switch (s) {
        'light' => ThemeMode.light,
        'dark' => ThemeMode.dark,
        _ => ThemeMode.system,
      };

  static String _name(ThemeMode m) => switch (m) {
        ThemeMode.light => 'light',
        ThemeMode.dark => 'dark',
        _ => 'system',
      };
}

final themeModeProvider =
    NotifierProvider<ThemeModeNotifier, ThemeMode>(ThemeModeNotifier.new);
