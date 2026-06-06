import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/responsive/responsive.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/manuscript_theme.dart';
import '../providers/conversion_state.dart';
import '../providers/converter_controller.dart';
import '../providers/theme_provider.dart';
import '../widgets/manuscript/manuscript_background.dart';
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

    // Surface failures as a SnackBar without leaving the current screen.
    ref.listen(converterControllerProvider, (ConversionState? prev, ConversionState next) {
      if (next.stage == ConversionStage.error && next.errorMessage != null) {
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(SnackBar(content: Text(next.errorMessage!)));
      }
    });

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: AppTheme.overlayStyle,
      child: Scaffold(
        body: ManuscriptBackground(
          child: SafeArea(
            child: ContentContainer(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 420),
                  switchInCurve: Curves.easeOutCubic,
                  transitionBuilder: (Widget child, Animation<double> a) {
                    return FadeTransition(
                      opacity: a,
                      child: SlideTransition(
                        position: Tween<Offset>(
                          begin: const Offset(0, 0.04),
                          end: Offset.zero,
                        ).animate(a),
                        child: child,
                      ),
                    );
                  },
                  child: KeyedSubtree(
                    key: ValueKey<String>('${state.stage}_${binding.key}'),
                    child: _phase(binding, state),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _phase(ManuscriptBinding binding, ConversionState state) {
    switch (state.stage) {
      case ConversionStage.idle:
        return InputScreen(binding: binding);
      case ConversionStage.loadingInfo:
        return LoadingScreen(binding: binding);
      case ConversionStage.ready:
        return PreviewScreen(binding: binding, state: state);
      case ConversionStage.converting:
        return DownloadingScreen(binding: binding, state: state);
      case ConversionStage.done:
        return DoneScreen(binding: binding, state: state);
      case ConversionStage.error:
        // Stay on the relevant screen; if we have video info, show preview.
        return state.info != null
            ? PreviewScreen(binding: binding, state: state)
            : InputScreen(binding: binding);
    }
  }
}
