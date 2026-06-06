import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/theme/manuscript_theme.dart';
import '../providers/theme_provider.dart';

/// A small in-aesthetic switcher for the three bindings — roman numerals
/// I · II · III, the active one filled in the current accent.
class BindingSwitcher extends ConsumerWidget {
  const BindingSwitcher({super.key});

  static const List<String> _numerals = <String>['I', 'II', 'III'];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ManuscriptBinding current = ref.watch(bindingProvider);
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        for (int i = 0; i < kBindings.length; i++) ...<Widget>[
          _chip(ref, kBindings[i], _numerals[i], current),
          if (i < kBindings.length - 1) const SizedBox(width: 8),
        ],
      ],
    );
  }

  Widget _chip(WidgetRef ref, ManuscriptBinding b, String numeral,
      ManuscriptBinding current) {
    final bool on = b.key == current.key;
    return GestureDetector(
      onTap: () => ref.read(bindingProvider.notifier).select(b),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 34,
        height: 28,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(4),
          color: on ? b.accentSoft : Colors.transparent,
          border: Border.all(color: on ? b.accent : Mss.rule(0.22)),
        ),
        child: Text(
          numeral,
          style: GoogleFonts.spectral(
              textStyle: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1,
                  color: on ? Mss.display : Mss.faint)),
        ),
      ),
    );
  }
}
