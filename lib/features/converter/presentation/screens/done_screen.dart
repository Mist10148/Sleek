import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:open_filex/open_filex.dart';

import '../../../../core/theme/manuscript_theme.dart';
import '../../../../core/utils/formatters.dart';
import '../../domain/entities/media_format.dart';
import '../providers/conversion_state.dart';
import '../providers/converter_controller.dart';
import '../widgets/done_receipt.dart';
import '../widgets/manuscript/mss_icons.dart';
import '../widgets/manuscript/ornaments.dart';
import '../widgets/manuscript/primitives.dart';

/// Phase 5 — the receipt for a finished, real download.
class DoneScreen extends ConsumerWidget {
  const DoneScreen({super.key, required this.binding, required this.state});

  final ManuscriptBinding binding;
  final ConversionState state;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ManuscriptBinding b = binding;
    final ConverterController c = ref.read(converterControllerProvider.notifier);
    final result = state.result;
    final QualityOption? q = state.quality;

    final String path = result?.filePath ?? '';
    final String fileName =
        path.split(RegExp(r'[\\/]')).where((String s) => s.isNotEmpty).isEmpty
            ? path
            : path.split(RegExp(r'[\\/]')).last;
    final String dir = path.isEmpty
        ? (state.outputDirectory ?? '')
        : path.substring(0, path.length - fileName.length);
    final String qualityLabel = q == null
        ? ''
        : (state.format == MediaFormat.mp4 ? '${q.q}p' : '${q.q} kbps');
    final String sizeLabel =
        result != null ? Formatters.fileSize(result.sizeBytes) : '';

    return Padding(
      padding: const EdgeInsets.fromLTRB(26, 88, 26, 40),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Center(child: DoneSeal(binding: b)),
          const SizedBox(height: 22),
          Text('Transcribed.',
              textAlign: TextAlign.center,
              style: b.display0(const TextStyle(
                  fontSize: 27, letterSpacing: 1, color: Mss.display))),
          const SizedBox(height: 8),
          Text('A faithful copy now rests upon your shelf.',
              textAlign: TextAlign.center,
              style: Mss.serif(const TextStyle(fontSize: 13.5, color: Mss.muted))),
          const SizedBox(height: 30),
          Fleuron(glyph: b.ornament == 2 ? '❦' : '✦', gold: b.gold),
          const SizedBox(height: 30),
          ReceiptCard(
            binding: b,
            fileName: fileName,
            format: state.format,
            qualityLabel: qualityLabel,
            sizeLabel: sizeLabel,
            savedPath: dir.isEmpty ? (state.outputDirectory ?? '') : dir,
          ),
          const SizedBox(height: 28),
          MssGhostButton(
            label: 'Reveal in folder',
            leading: MssIcon('open', size: 16, color: const Color(0xFFC9B999)),
            onPressed: path.isEmpty ? null : () => OpenFilex.open(path),
          ),
          const SizedBox(height: 11),
          MssPrimaryButton(
            binding: b,
            label: 'Transcribe another',
            trailing: MssIcon('arrow', size: 18, color: Mss.ink),
            onPressed: c.reset,
          ),
        ],
      ),
    );
  }
}
