import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/responsive/responsive.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/formatters.dart';
import '../providers/conversion_state.dart';
import '../providers/converter_controller.dart';
import '../widgets/format_selector.dart';
import '../widgets/progress_card.dart';
import '../widgets/quality_selector.dart';
import '../widgets/save_location_picker.dart';
import '../widgets/url_input_field.dart';
import '../widgets/video_preview_card.dart';
import 'settings_screen.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(converterControllerProvider);
    final controller = ref.read(converterControllerProvider.notifier);

    // Surface errors as a SnackBar without leaving the screen state.
    ref.listen(converterControllerProvider, (prev, next) {
      if (next.stage == ConversionStage.error && next.errorMessage != null) {
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(SnackBar(content: Text(next.errorMessage!)));
      }
    });

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          _Header(
            onSettings: () => Navigator.of(context).push(
              MaterialPageRoute<void>(builder: (_) => const SettingsScreen()),
            ),
          ),
          SliverPadding(
            padding: Responsive.pagePadding(context),
            sliver: SliverToBoxAdapter(
              child: ContentContainer(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    UrlInputField(
                      initialValue: state.url,
                      isLoading: state.stage == ConversionStage.loadingInfo,
                      onSubmit: controller.loadInfo,
                    ),
                    const SizedBox(height: 20),
                    _Body(state: state, controller: controller),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.onSettings});
  final VoidCallback onSettings;

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      pinned: true,
      expandedHeight: 130,
      actions: [
        IconButton(
          onPressed: onSettings,
          icon: const Icon(Icons.settings_rounded, color: Colors.white),
        ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        titlePadding: const EdgeInsets.only(left: 20, bottom: 16, right: 56),
        title: const Text(
          AppConstants.appName,
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800),
        ),
        background: DecoratedBox(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: AppColors.headerGradient,
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Align(
            alignment: Alignment.bottomRight,
            child: Padding(
              padding: const EdgeInsets.only(right: 16, bottom: 14),
              child: Icon(
                Icons.music_video_rounded,
                size: 56,
                color: Colors.white.withValues(alpha: 0.25),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Switches between the idle hint, the choices form, the progress card and the
/// success card based on the current [ConversionStage].
class _Body extends StatelessWidget {
  const _Body({required this.state, required this.controller});

  final ConversionState state;
  final ConverterController controller;

  @override
  Widget build(BuildContext context) {
    switch (state.stage) {
      case ConversionStage.idle:
      case ConversionStage.loadingInfo:
        return const _IdleHint();
      case ConversionStage.error:
        return state.info == null
            ? const _IdleHint()
            : _ChoicesForm(state: state, controller: controller);
      case ConversionStage.ready:
        return _ChoicesForm(state: state, controller: controller);
      case ConversionStage.converting:
        return ProgressCard(
          progress: state.progress!,
          label:
              'Downloading ${state.format.label}${state.quality != null ? ' · ${state.quality!.label}' : ''}',
        );
      case ConversionStage.done:
        return _DoneCard(state: state, controller: controller);
    }
  }
}

class _IdleHint extends StatelessWidget {
  const _IdleHint();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 48),
      child: Column(
        children: [
          Icon(Icons.cloud_download_rounded,
              size: 64, color: theme.colorScheme.primary.withValues(alpha: 0.5)),
          const SizedBox(height: 16),
          Text('Paste a link to get started',
              style: theme.textTheme.titleMedium),
          const SizedBox(height: 4),
          Text(
            AppConstants.appTagline,
            style: theme.textTheme.bodyMedium
                ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
          ),
        ],
      ),
    );
  }
}

class _ChoicesForm extends StatelessWidget {
  const _ChoicesForm({required this.state, required this.controller});

  final ConversionState state;
  final ConverterController controller;

  @override
  Widget build(BuildContext context) {
    final info = state.info!;
    final options = info.qualitiesFor(state.format);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        VideoPreviewCard(info: info),
        const SizedBox(height: 24),
        _SectionLabel('Format'),
        const SizedBox(height: 12),
        FormatSelector(
            selected: state.format, onChanged: controller.selectFormat),
        const SizedBox(height: 24),
        _SectionLabel('Quality'),
        const SizedBox(height: 12),
        QualitySelector(
          options: options,
          selected: state.quality,
          onChanged: controller.selectQuality,
        ),
        const SizedBox(height: 24),
        _SectionLabel('Destination'),
        const SizedBox(height: 12),
        SaveLocationPicker(
          directory: state.outputDirectory,
          onChanged: controller.setOutputDirectory,
        ),
        const SizedBox(height: 28),
        FilledButton.icon(
          onPressed: state.canConvert ? controller.convert : null,
          icon: const Icon(Icons.bolt_rounded),
          label: Text('Convert to ${state.format.label}'),
        ),
      ],
    );
  }
}

class _DoneCard extends StatelessWidget {
  const _DoneCard({required this.state, required this.controller});

  final ConversionState state;
  final ConverterController controller;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final result = state.result!;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Icon(Icons.check_circle_rounded,
                size: 56, color: AppColors.success),
            const SizedBox(height: 12),
            Center(
              child: Text('Done!',
                  style: theme.textTheme.titleLarge
                      ?.copyWith(fontWeight: FontWeight.w800)),
            ),
            const SizedBox(height: 16),
            _ResultRow(
                icon: Icons.insert_drive_file_rounded,
                label: 'Size',
                value: Formatters.fileSize(result.sizeBytes)),
            _ResultRow(
                icon: Icons.timer_outlined,
                label: 'Took',
                value: Formatters.duration(result.elapsed)),
            const SizedBox(height: 8),
            Text(
              result.filePath,
              style: theme.textTheme.bodySmall
                  ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
            ),
            const SizedBox(height: 20),
            FilledButton.tonalIcon(
              onPressed: controller.reset,
              icon: const Icon(Icons.add_rounded),
              label: const Text('Convert another'),
            ),
          ],
        ),
      ),
    );
  }
}

class _ResultRow extends StatelessWidget {
  const _ResultRow(
      {required this.icon, required this.label, required this.value});
  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 18, color: theme.colorScheme.onSurfaceVariant),
          const SizedBox(width: 8),
          Text('$label: ',
              style: theme.textTheme.bodyMedium
                  ?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
          Text(value,
              style: theme.textTheme.bodyMedium
                  ?.copyWith(fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text.toUpperCase(),
      style: Theme.of(context).textTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.w800,
            letterSpacing: 0.8,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
    );
  }
}
