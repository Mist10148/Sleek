import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/responsive/responsive.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/manuscript_theme.dart';
import '../../../core/theme/mss_palette.dart';
import '../../converter/data/services/history_service.dart';
import '../../converter/presentation/providers/theme_provider.dart';
import '../../converter/presentation/widgets/manuscript/manuscript_background.dart';
import '../../converter/presentation/widgets/manuscript/mss_icons.dart';
import '../../converter/presentation/widgets/manuscript/ornaments.dart';
import '../../converter/presentation/widgets/manuscript/primitives.dart';

/// "The Study" — choose a binding (theme skin), light/dark mode (the design's
/// "Illumination"), and review the transcription shelf ("Provenance"). When
/// [embedded] (hosted as the shell's Study tab, matching `Settings.jsx` —
/// which has no back button, just the "The Study" / "Settings" header) it
/// renders bare; otherwise it wraps itself in its own scaffold + back button
/// for standalone pushes.
class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key, this.embedded = false});

  final bool embedded;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ManuscriptBinding binding = ref.watch(bindingProvider);
    final ThemeMode mode = ref.watch(themeModeProvider);
    final List<HistoryEntry> history = ref.watch(historyProvider);
    final MssPalette p = paletteOf(context);

    final Widget content = SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(26, 28, 26, 40),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          if (embedded) ...<Widget>[
            MssLabel('The Study', gold: binding.gold),
            const SizedBox(height: 6),
            Text(
              'Settings',
              style: binding.display0(TextStyle(fontSize: 25, letterSpacing: 0.6, color: p.display)),
            ),
          ] else
            Row(
              children: <Widget>[
                SizedBox(
                  width: 96,
                  child: MssGhostButton(
                    label: '‹  Back',
                    palette: p,
                    dense: true,
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
                Expanded(
                  child: Text(
                    'Settings',
                    textAlign: TextAlign.center,
                    style: binding.display0(
                        TextStyle(fontSize: 19, color: p.display)),
                  ),
                ),
                const SizedBox(width: 96),
              ],
            ),
          const SizedBox(height: 28),
          Fleuron(glyph: binding.ornament == 2 ? '❧' : '✦', gold: binding.gold),
          const SizedBox(height: 30),

          MssLabel('Illumination', gold: binding.gold),
          const SizedBox(height: 12),
          _ThemeModeToggle(
            binding: binding,
            palette: p,
            value: mode,
            onChanged: (ThemeMode m) =>
                ref.read(themeModeProvider.notifier).set(m),
          ),
          const SizedBox(height: 30),

          HairRule(palette: p, margin: const EdgeInsets.symmetric(vertical: 4)),
          const SizedBox(height: 26),

          MssLabel('Binding', gold: binding.gold),
          const SizedBox(height: 6),
          Text(
            'The manuscript skin — colours, type, and ornament.',
            style: p.serif(TextStyle(fontSize: 12.5, color: p.muted)),
          ),
          const SizedBox(height: 14),
          for (final ManuscriptBinding b in kBindings) ...<Widget>[
            _BindingCard(
              binding: b,
              palette: p,
              selected: b.key == binding.key,
              onTap: () => ref.read(bindingProvider.notifier).select(b),
            ),
            if (b.key != kBindings.last.key) const SizedBox(height: 12),
          ],
          const SizedBox(height: 30),

          HairRule(palette: p, margin: const EdgeInsets.symmetric(vertical: 4)),
          const SizedBox(height: 26),

          MssLabel('Provenance', gold: binding.gold),
          const SizedBox(height: 6),
          Text(
            'A shelf of your last dozen transcriptions, kept on this device.',
            style: p.serif(TextStyle(fontSize: 12.5, color: p.muted)),
          ),
          const SizedBox(height: 14),
          MssGhostButton(
            label: 'Clear history',
            palette: p,
            leading: MssIcon('x', size: 14, color: p.ghostLabel),
            onPressed: history.isEmpty
                ? null
                : () => ref.read(historyProvider.notifier).clear(),
          ),
        ],
      ),
    );

    if (embedded) {
      return ContentContainer(child: content);
    }

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: p.isDark ? AppTheme.overlayStyle : AppTheme.overlayStyleLight,
      child: Scaffold(
        body: ManuscriptBackground(
          child: SafeArea(
            child: ContentContainer(child: content),
          ),
        ),
      ),
    );
  }
}

/// Three-way Dark | System | Light segmented toggle, styled like FormatSegmented.
class _ThemeModeToggle extends StatelessWidget {
  const _ThemeModeToggle({
    required this.binding,
    required this.palette,
    required this.value,
    required this.onChanged,
  });

  final ManuscriptBinding binding;
  final MssPalette palette;
  final ThemeMode value;
  final ValueChanged<ThemeMode> onChanged;

  static const List<ThemeMode> _modes = <ThemeMode>[
    ThemeMode.dark,
    ThemeMode.system,
    ThemeMode.light,
  ];
  static const List<String> _labels = <String>['Dark', 'System', 'Light'];
  static const List<String> _icons = <String>['moon', 'gear', 'sun'];

  @override
  Widget build(BuildContext context) {
    final MssPalette p = palette;
    final int index = _modes.indexOf(value).clamp(0, _modes.length - 1);
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: p.overlay50,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: p.rule(0.2)),
      ),
      child: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints c) {
          // Clamp against transient near-zero `maxWidth` layout passes (e.g.
          // the first frame) — otherwise this goes negative and Flutter
          // throws a "BoxConstraints has a negative minimum width" assertion.
          final double w = ((c.maxWidth - 8) / _modes.length).clamp(0.0, double.infinity);
          return Stack(
            children: <Widget>[
              AnimatedAlign(
                duration: const Duration(milliseconds: 280),
                curve: Curves.easeOutCubic,
                alignment: Alignment(-1 + (2 * index) / (_modes.length - 1), 0),
                child: Container(
                  width: w,
                  height: 52,
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
                  for (int i = 0; i < _modes.length; i++)
                    _opt(p, i, _modes[i] == value),
                ],
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _opt(MssPalette p, int i, bool on) {
    final Color c = on ? p.ink : p.muted;
    return Expanded(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          // A small tactile click on choosing Dark / System / Light — the
          // same restrained `lightImpact` touch as the binding cards below
          // and the format/quality pickers on the input screen.
          HapticFeedback.lightImpact();
          onChanged(_modes[i]);
        },
        child: SizedBox(
          height: 52,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              MssIcon(_icons[i], size: 16, color: c),
              const SizedBox(height: 6),
              Text(
                _labels[i],
                style: GoogleFonts.spectral(
                    textStyle: TextStyle(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.6,
                        color: c)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// One selectable binding card — name, blurb, and an accent swatch.
class _BindingCard extends StatelessWidget {
  const _BindingCard({
    required this.binding,
    required this.palette,
    required this.selected,
    required this.onTap,
  });

  final ManuscriptBinding binding;
  final MssPalette palette;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final MssPalette p = palette;
    final ManuscriptBinding b = binding;
    return GestureDetector(
      onTap: () {
        // Choosing a binding is the most consequential selection in this
        // screen — the same light tactile touch as the theme toggle confirms
        // the tap landed, restrained as the existing `_Pressable` press.
        HapticFeedback.lightImpact();
        onTap();
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: selected ? b.accentSoft : p.cardBg,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: selected ? b.accent : p.rule(0.24)),
        ),
        child: Row(
          children: <Widget>[
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  center: const Alignment(0, -0.3),
                  colors: <Color>[b.accent, b.accentDeep],
                ),
                border: Border.all(color: b.accentDeep, width: 1.2),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(b.name,
                      style: b.display0(TextStyle(
                          fontSize: 15.5,
                          fontWeight: FontWeight.w500,
                          color: p.display))),
                  const SizedBox(height: 4),
                  Text(b.blurb,
                      style: p.serif(TextStyle(fontSize: 12, height: 1.35, color: p.muted))),
                ],
              ),
            ),
            const SizedBox(width: 10),
            if (selected) MssIcon('check', size: 18, color: b.accent),
          ],
        ),
      ),
    );
  }
}
