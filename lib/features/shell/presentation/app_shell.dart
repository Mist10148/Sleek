import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/responsive/responsive.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/manuscript_theme.dart';
import '../../../core/theme/mss_palette.dart';
import '../../converter/presentation/providers/theme_provider.dart';
import '../../converter/presentation/screens/home_screen.dart';
import '../../converter/presentation/widgets/manuscript/manuscript_background.dart';
import '../../converter/presentation/widgets/manuscript/mss_icons.dart';
import '../../library/presentation/providers/library_provider.dart';
import '../../library/presentation/providers/player_controller.dart';
import '../../library/presentation/screens/library_screen.dart';
import '../../library/presentation/screens/now_playing_screen.dart';
import '../../library/presentation/widgets/mini_player.dart';
import '../../library/presentation/widgets/queue_sheet.dart';
import '../../settings/presentation/settings_screen.dart';

enum _ShellTab { download, library, study }

/// The app shell — ported from `Shell.jsx`'s `VellvmApp`: bottom navigation
/// (Download / Library / Study, `mss-nav`/`mss-navbtn`), a persistent
/// mini-player whenever a track is loaded, and a full-screen Now Playing /
/// queue-sheet overlay that takes over the whole shell when open.
class AppShell extends ConsumerStatefulWidget {
  const AppShell({super.key});

  @override
  ConsumerState<AppShell> createState() => _AppShellState();
}

class _AppShellState extends ConsumerState<AppShell> {
  _ShellTab _tab = _ShellTab.download;

  @override
  Widget build(BuildContext context) {
    final ManuscriptBinding binding = ref.watch(bindingProvider);
    final MssPalette p = paletteOf(context);
    final PlaybackState playback = ref.watch(playerControllerProvider);
    final int libraryCount = ref.watch(libraryProvider).length;
    final bool hasCurrent = ref.read(playerControllerProvider.notifier).current != null;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: p.isDark ? AppTheme.overlayStyle : AppTheme.overlayStyleLight,
      child: Scaffold(
        body: ManuscriptBackground(
          child: SafeArea(
            child: Stack(
              children: <Widget>[
                if (playback.nowPlayingOpen)
                  const NowPlayingScreen()
                else
                  Column(
                    children: <Widget>[
                      Expanded(
                        child: ContentContainer(
                          child: IndexedStack(
                            index: _tab.index,
                            children: const <Widget>[
                              _DownloadTab(),
                              LibraryScreen(),
                              _StudyTab(),
                            ],
                          ),
                        ),
                      ),
                      if (hasCurrent) const MiniPlayer(),
                      ContentContainer(
                        child: _BottomNav(
                          binding: binding,
                          palette: p,
                          tab: _tab,
                          libraryCount: libraryCount,
                          onSelect: (_ShellTab t) => setState(() => _tab = t),
                        ),
                      ),
                    ],
                  ),
                if (playback.queueOpen) const QueueSheet(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// The Download flow lives at `HomeScreen` — embedded here as a tab instead
/// of being the app's `home`, with its own settings-gear push removed in
/// favour of the shell's "Study" tab. Reusing `HomeScreen` wholesale keeps
/// its phase machinery (`AnimatedSwitcher` over `ConversionState.stage`)
/// intact; we simply strip the surrounding `Scaffold`/`ManuscriptBackground`
/// it no longer needs by letting it render at full size inside ours.
class _DownloadTab extends StatelessWidget {
  const _DownloadTab();

  @override
  Widget build(BuildContext context) => const HomeScreen();
}

/// The "Study" tab — the existing `SettingsScreen`, embedded rather than
/// pushed (its own `Scaffold`/back-button stay; they read fine as a tab root).
class _StudyTab extends StatelessWidget {
  const _StudyTab();

  @override
  Widget build(BuildContext context) => const SettingsScreen(embedded: true);
}

/// Bottom navigation bar — ported from `Shell.jsx`'s `mss-nav`/`mss-navbtn`:
/// three tabs with small-caps labels, a glowing dot over the active icon, and
/// a badge on Library showing how many recordings are on the shelf.
class _BottomNav extends StatelessWidget {
  const _BottomNav({
    required this.binding,
    required this.palette,
    required this.tab,
    required this.libraryCount,
    required this.onSelect,
  });

  final ManuscriptBinding binding;
  final MssPalette palette;
  final _ShellTab tab;
  final int libraryCount;
  final ValueChanged<_ShellTab> onSelect;

  static const List<(_ShellTab, String, String)> _items = <(_ShellTab, String, String)>[
    (_ShellTab.download, 'downloadTab', 'Download'),
    (_ShellTab.library, 'libraryTab', 'Library'),
    (_ShellTab.study, 'settingsTab', 'Study'),
  ];

  @override
  Widget build(BuildContext context) {
    final MssPalette p = palette;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: p.menuBg.withValues(alpha: 0.92),
        border: Border(top: BorderSide(color: p.rule(0.18))),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
          child: Row(
            children: <Widget>[
              for (final (_ShellTab key, String icon, String label) in _items)
                Expanded(
                  child: _NavButton(
                    icon: icon,
                    label: label,
                    on: tab == key,
                    accent: binding.accent,
                    color: p.faint,
                    badge: key == _ShellTab.library && libraryCount > 0 ? libraryCount : null,
                    onAccent: p.ink,
                    onTap: () {
                      HapticFeedback.lightImpact();
                      onSelect(key);
                    },
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavButton extends StatelessWidget {
  const _NavButton({
    required this.icon,
    required this.label,
    required this.on,
    required this.accent,
    required this.color,
    required this.onAccent,
    required this.onTap,
    this.badge,
  });

  final String icon;
  final String label;
  final bool on;
  final Color accent;
  final Color color;
  final Color onAccent;
  final int? badge;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final Color c = on ? accent : color;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            SizedBox(
              height: 14,
              child: on
                  ? Container(
                      width: 5,
                      height: 5,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: accent,
                        boxShadow: <BoxShadow>[BoxShadow(color: accent.withValues(alpha: 0.7), blurRadius: 8)],
                      ),
                    )
                  : null,
            ),
            Stack(
              clipBehavior: Clip.none,
              children: <Widget>[
                MssIcon(icon, size: 22, color: c),
                if (badge != null)
                  Positioned(
                    top: -4,
                    right: -7,
                    child: Container(
                      constraints: const BoxConstraints(minWidth: 15),
                      height: 15,
                      padding: const EdgeInsets.symmetric(horizontal: 3),
                      decoration: BoxDecoration(color: accent, borderRadius: BorderRadius.circular(8)),
                      child: Center(
                        child: Text(
                          '$badge',
                          style: GoogleFonts.jetBrainsMono(
                              textStyle: TextStyle(fontSize: 9, color: onAccent, height: 1)),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 5),
            Text(
              label.toUpperCase(),
              style: GoogleFonts.spectral(
                textStyle: TextStyle(fontSize: 9.5, letterSpacing: 1.6, fontWeight: FontWeight.w600, color: c),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
