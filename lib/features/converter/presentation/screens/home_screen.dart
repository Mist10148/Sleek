import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/responsive/responsive.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/manuscript_theme.dart';
import '../../../../core/theme/mss_palette.dart';
import '../../../settings/presentation/settings_screen.dart';
import '../providers/conversion_state.dart';
import '../providers/converter_controller.dart';
import '../providers/theme_provider.dart';
import '../widgets/manuscript/manuscript_background.dart';
import '../widgets/manuscript/mss_icons.dart';
import 'done_screen.dart';
import 'downloading_screen.dart';
import 'input_screen.dart';
import 'loading_screen.dart';
import 'preview_screen.dart';

/// Hosts the whole flow: the manuscript surface + a phase that swaps with the
/// `mss-in` entrance animation as [ConversionState.stage] advances.
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ManuscriptBinding binding = ref.watch(bindingProvider);
    final ConversionState state = ref.watch(converterControllerProvider);
    final MssPalette palette = paletteOf(context);

    // Surface failures as a SnackBar without leaving the current screen.
    ref.listen(converterControllerProvider, (ConversionState? prev, ConversionState next) {
      if (next.stage == ConversionStage.error && next.errorMessage != null) {
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(SnackBar(content: Text(next.errorMessage!)));
      }
      // The moment the manuscript is finished and the Done screen first
      // takes the stage — one small landing cue, gated on the *transition*
      // (not every rebuild while it's showing) so it fires exactly once,
      // the same restrained `lightImpact` touch as the selection taps.
      if (next.stage == ConversionStage.done && prev?.stage != ConversionStage.done) {
        HapticFeedback.lightImpact();
      }
    });

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: palette.isDark ? AppTheme.overlayStyle : AppTheme.overlayStyleLight,
      child: Scaffold(
        body: ManuscriptBackground(
          child: SafeArea(
            child: Stack(
              children: <Widget>[
                ContentContainer(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 460),
                      switchInCurve: Curves.easeOutCubic,
                      switchOutCurve: Curves.easeInCubic,
                      // A leaf of vellum settling onto the desk: the
                      // outgoing phase eases down and away while the
                      // incoming one rises softly into place, brightening
                      // and growing to rest — a quiet "turn of the page"
                      // rather than a flat cross-fade.
                      transitionBuilder: (Widget child, Animation<double> a) {
                        return FadeTransition(
                          opacity: a,
                          child: SlideTransition(
                            position: Tween<Offset>(
                              begin: const Offset(0, 0.045),
                              end: Offset.zero,
                            ).animate(a),
                            child: ScaleTransition(
                              scale: Tween<double>(begin: 0.982, end: 1.0).animate(a),
                              child: child,
                            ),
                          ),
                        );
                      },
                      child: KeyedSubtree(
                        key: ValueKey<String>('${state.stage}_${binding.key}'),
                        child: _phase(binding, palette, state),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: 6,
                  right: 6,
                  child: Material(
                    color: Colors.transparent,
                    shape: const CircleBorder(),
                    clipBehavior: Clip.antiAlias,
                    child: InkWell(
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute<void>(
                            builder: (_) => const SettingsScreen()),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(10),
                        child: MssIcon('gear', size: 20, color: palette.faint),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _phase(ManuscriptBinding binding, MssPalette palette, ConversionState state) {
    switch (state.stage) {
      case ConversionStage.idle:
        return InputScreen(binding: binding, palette: palette);
      case ConversionStage.loadingInfo:
        return LoadingScreen(binding: binding, palette: palette);
      case ConversionStage.ready:
        return PreviewScreen(binding: binding, palette: palette, state: state);
      case ConversionStage.converting:
        return DownloadingScreen(binding: binding, palette: palette, state: state);
      case ConversionStage.done:
        return DoneScreen(binding: binding, palette: palette, state: state);
      case ConversionStage.error:
        // Stay on the relevant screen; if we have video info, show preview.
        return state.info != null
            ? PreviewScreen(binding: binding, palette: palette, state: state)
            : InputScreen(binding: binding, palette: palette);
    }
  }
}
