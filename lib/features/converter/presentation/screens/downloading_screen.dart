import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/manuscript_theme.dart';
import '../../../../core/theme/mss_palette.dart';
import '../../../../core/utils/formatters.dart';
import '../../data/models/download_task.dart';
import '../../domain/entities/media_format.dart';
import '../providers/conversion_state.dart';
import '../providers/converter_controller.dart';
import '../widgets/manuscript/crest.dart';
import '../widgets/manuscript/mss_icons.dart';
import '../widgets/manuscript/mss_spinner.dart';
import '../widgets/manuscript/primitives.dart';
import '../widgets/progress_meter.dart';

/// Phase 4 — the live transcription meter, fed by real [DownloadProgress].
class DownloadingScreen extends ConsumerWidget {
  const DownloadingScreen({super.key, required this.binding, required this.palette, required this.state});

  final ManuscriptBinding binding;
  final MssPalette palette;
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

    // MP4 only ever downloads. MP3 moves through two distinct phases that,
    // shown through one undifferentiated meter, would look like the
    // percentage inexplicably resets midway — name whichever phase is
    // actually live, and report stats that are honest for *that* phase, so
    // the user always knows what's happening (and that nothing has stalled).
    final bool converting = p.phase == ConversionPhase.converting;
    final String phaseCaption =
        converting ? 'Setting it to verse…' : 'Gathering the recording…';

    final String sizeLine;
    final String remaining;
    final String speed;
    final String speedLabel;

    if (converting) {
      // ffmpeg reports progress as time-encoded ÷ source length, not bytes —
      // translate that into a duration-based detail line (echoing the
      // download phase's "X of Y" shape, just in time rather than size) and
      // a "× realtime" throughput figure, instead of faking byte stats.
      final Duration sourceDuration = state.info?.duration ?? Duration.zero;
      final Duration processed = Duration(
          milliseconds: (p.fraction * sourceDuration.inMilliseconds).round());
      sizeLine = '${Formatters.duration(processed)} of '
          '${Formatters.duration(sourceDuration)} · re-encoding to '
          '${state.format.label} $qLabel';
      remaining = pct >= 100
          ? '0:00'
          : '~${Formatters.etaFromFraction(p.fraction, p.elapsed)}';
      final double processedSecs = processed.inMilliseconds / 1000;
      final double elapsedSecs = p.elapsed.inMilliseconds / 1000;
      speed = elapsedSecs > 0 && processedSecs > 0
          ? '${(processedSecs / elapsedSecs).toStringAsFixed(1)}×'
          : '—';
      speedLabel = '× Realtime';
    } else {
      final String received = Formatters.fileSize(p.receivedBytes);
      final String total =
          p.totalBytes > 0 ? Formatters.fileSize(p.totalBytes) : '—';
      sizeLine = '$received of $total · ${state.format.label} $qLabel';
      remaining = pct >= 100
          ? '0:00'
          : '~${Formatters.eta(received: p.receivedBytes, total: p.totalBytes, elapsed: p.elapsed)}';
      final String speedRaw = Formatters.speed(p.receivedBytes, p.elapsed);
      // The meter's stat shows a bare number under an "MB / sec" label.
      speed = speedRaw.replaceAll(RegExp(r'\s*[A-Za-z/]+$'), '');
      speedLabel = 'MB / sec';
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(26, 78, 26, 40),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Crest(binding: b, palette: palette, small: true),
          const SizedBox(height: 34),
          Center(child: MssLabel('Transcribing', gold: b.gold)),
          const SizedBox(height: 10),
          Text(
            state.info?.title ?? '',
            textAlign: TextAlign.center,
            style: b.display0(TextStyle(
                fontSize: 16.5, height: 1.3, color: palette.display)),
          ),
          const SizedBox(height: 12),
          Center(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                // The quill only comes out once ffmpeg actually starts
                // composing — a small, lively cue that something is now
                // *actively being written*, distinct from the marching-stripe
                // bar that already speaks for the byte-shuffling phase.
                if (converting) ...<Widget>[
                  MssQuill(color: b.accent, size: 22),
                  const SizedBox(width: 10),
                ],
                Flexible(
                  child: Text(
                    phaseCaption,
                    textAlign: TextAlign.center,
                    style: palette.serif(TextStyle(
                        fontSize: 12.5,
                        fontStyle: FontStyle.italic,
                        color: converting ? b.accent : palette.muted)),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 28),
          ProgressMeter(
            binding: b,
            palette: palette,
            pct: pct,
            sizeLine: sizeLine,
            elapsed: Formatters.duration(p.elapsed),
            remaining: remaining,
            speed: speed.isEmpty ? '—' : speed,
            speedLabel: speedLabel,
          ),
          const SizedBox(height: 30),
          MssGhostButton(
            label: 'Abandon',
            palette: palette,
            leading: MssIcon('x', size: 15, color: palette.ghostLabel),
            onPressed: c.reset,
          ),
        ],
      ),
    );
  }
}
