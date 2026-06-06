import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/manuscript_theme.dart';
import '../../../../core/utils/formatters.dart';
import '../../data/models/download_task.dart';
import '../../domain/entities/media_format.dart';
import '../providers/conversion_state.dart';
import '../providers/converter_controller.dart';
import '../widgets/manuscript/crest.dart';
import '../widgets/manuscript/mss_icons.dart';
import '../widgets/manuscript/primitives.dart';
import '../widgets/progress_meter.dart';

/// Phase 4 — the live transcription meter, fed by real [DownloadProgress].
class DownloadingScreen extends ConsumerWidget {
  const DownloadingScreen({super.key, required this.binding, required this.state});

  final ManuscriptBinding binding;
  final ConversionState state;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ManuscriptBinding b = binding;
    final ConverterController c = ref.read(converterControllerProvider.notifier);
    final DownloadProgress p = state.progress ??
        const DownloadProgress(receivedBytes: 0, totalBytes: 0, elapsed: Duration.zero);
    final QualityOption? q = state.quality;

    final double pct = p.fraction * 100;
    final String qLabel = q == null
        ? ''
        : (state.format == MediaFormat.mp4 ? '${q.q}p' : q.q);
    final String received = Formatters.fileSize(p.receivedBytes);
    final String total = p.totalBytes > 0 ? Formatters.fileSize(p.totalBytes) : '—';
    final String sizeLine =
        '$received of $total · ${state.format.label} $qLabel';

    final String speedRaw = Formatters.speed(p.receivedBytes, p.elapsed);
    // The meter's stat shows a bare number under an "MB / sec" label.
    final String speed = speedRaw.replaceAll(RegExp(r'\s*[A-Za-z/]+$'), '');

    return Padding(
      padding: const EdgeInsets.fromLTRB(26, 78, 26, 40),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Crest(binding: b, small: true),
          const SizedBox(height: 34),
          Center(child: MssLabel('Transcribing', gold: b.gold)),
          const SizedBox(height: 10),
          Text(
            state.info?.title ?? '',
            textAlign: TextAlign.center,
            style: b.display0(const TextStyle(
                fontSize: 16.5, height: 1.3, color: Mss.display)),
          ),
          const SizedBox(height: 36),
          ProgressMeter(
            binding: b,
            pct: pct,
            sizeLine: sizeLine,
            elapsed: Formatters.duration(p.elapsed),
            remaining: pct >= 100
                ? '0:00'
                : '~${Formatters.eta(received: p.receivedBytes, total: p.totalBytes, elapsed: p.elapsed)}',
            speed: speed.isEmpty ? '—' : speed,
          ),
          const SizedBox(height: 30),
          MssGhostButton(
            label: 'Abandon',
            leading: MssIcon('x', size: 15, color: const Color(0xFFC9B999)),
            onPressed: c.reset,
          ),
        ],
      ),
    );
  }
}
