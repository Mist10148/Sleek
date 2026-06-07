import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/manuscript_theme.dart';
import '../../../../core/theme/mss_palette.dart';
import '../../../../core/utils/formatters.dart';
import '../../data/services/storage_service.dart';
import '../../domain/entities/media_format.dart';
import '../providers/conversion_state.dart';
import '../providers/converter_controller.dart';
import '../widgets/format_segmented.dart';
import '../widgets/manuscript/mss_icons.dart';
import '../widgets/manuscript/ornaments.dart';
import '../widgets/manuscript/primitives.dart';
import '../widgets/preview_card.dart';
import '../widgets/quality_pills.dart';
import '../widgets/save_select.dart';

/// Phase 3 — the record preview plus format / quality / destination options.
class PreviewScreen extends ConsumerWidget {
  const PreviewScreen({super.key, required this.binding, required this.palette, required this.state});

  final ManuscriptBinding binding;
  final MssPalette palette;
  final ConversionState state;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ManuscriptBinding b = binding;
    final MssPalette p = palette;
    final ConverterController c = ref.read(converterControllerProvider.notifier);
    final info = state.info!;
    final List<QualityOption> options = info.qualitiesFor(state.format);
    final QualityOption? q = state.quality;

    final int? estBytes = q?.estimatedBytes;
    final String estimate = estBytes != null ? '≈ ${Formatters.fileSize(estBytes)}' : '—';

    final SaveLocation current = SaveLocation(
      name: _folderName(state.outputDirectory),
      path: state.outputDirectory ?? 'Default app folder',
    );

    return Padding(
      padding: const EdgeInsets.fromLTRB(26, 40, 26, 34),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          // top bar
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              SizedBox(
                width: 96,
                child: MssGhostButton(
                  label: '‹  Anew',
                  palette: p,
                  dense: true,
                  onPressed: c.reset,
                ),
              ),
              MssLabel('The Record', gold: b.gold),
              const SizedBox(width: 64),
            ],
          ),
          const SizedBox(height: 18),
          PreviewCard(binding: b, palette: p, info: info),
          const SizedBox(height: 24),
          if (b.ornament == 2)
            Fleuron(glyph: '⁂', gold: b.gold)
          else
            DoubleRule(palette: p),
          const SizedBox(height: 24),

          MssLabel('Format', gold: b.gold),
          const SizedBox(height: 11),
          FormatSegmented(
            binding: b,
            palette: p,
            value: state.format,
            onChanged: c.selectFormat,
          ),
          const SizedBox(height: 22),

          MssLabel('Quality', gold: b.gold),
          const SizedBox(height: 11),
          QualityPills(
            binding: b,
            palette: p,
            format: state.format,
            options: options,
            selected: q,
            onChanged: c.selectQuality,
          ),
          const SizedBox(height: 22),

          MssLabel('Save To', gold: b.gold),
          const SizedBox(height: 11),
          SaveSelect(
            binding: b,
            palette: p,
            current: current,
            presets: <SaveLocation>[current],
            onSelect: (SaveLocation l) => c.setOutputDirectory(l.path),
            onBrowse: () => _browse(ref),
          ),

          HairRule(palette: p, margin: const EdgeInsets.fromLTRB(0, 24, 0, 16)),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Text('Estimated weight',
                  style: p.serif(TextStyle(fontSize: 13.5, color: p.muted))),
              Text(estimate,
                  style: p.mono(TextStyle(fontSize: 14, color: b.accent))),
            ],
          ),
          const SizedBox(height: 15),
          MssPrimaryButton(
            binding: b,
            palette: p,
            label: 'Transcribe ${state.format.label}',
            leading: MssIcon('download', size: 17, color: p.ink),
            onPressed: state.canConvert ? c.convert : null,
          ),
        ],
      ),
    );
  }

  Future<void> _browse(WidgetRef ref) async {
    final String? path = await pickSaveDirectory();
    if (path != null) {
      ref.read(converterControllerProvider.notifier).setOutputDirectory(path);
    }
  }

  String _folderName(String? path) {
    if (path == null) return 'Default app folder';
    final List<String> parts =
        path.split(RegExp(r'[\\/]')).where((String s) => s.isNotEmpty).toList();
    return parts.isEmpty ? path : parts.last;
  }
}
