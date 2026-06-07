import 'dart:async';
import 'dart:io';

import 'package:ffmpeg_kit_flutter_new/ffmpeg_kit.dart';
import 'package:ffmpeg_kit_flutter_new/ffmpeg_session.dart';
import 'package:ffmpeg_kit_flutter_new/return_code.dart';
import 'package:ffmpeg_kit_flutter_new/statistics.dart';

import '../../../../core/errors/failures.dart';

/// How long we'll wait for ffmpeg to finish before giving up. Re-encoding a
/// typical song takes seconds to a couple of minutes; this is a generous
/// ceiling so a wedged native session can never freeze the UI forever — the
/// user gets a clear error instead of an endless spinner.
const Duration _kConversionTimeout = Duration(minutes: 10);

/// Converts a downloaded audio stream into a true `.mp3` at a target bitrate,
/// using ffmpeg (`ffmpeg_kit_flutter_new`). The downloaded source is whatever
/// container YouTube served (m4a/webm/opus); ffmpeg re-encodes it to MP3.
class ConversionService {
  /// Re-encodes [sourcePath] to a real MP3 at [targetBitrateKbps] written to
  /// [outputPath], then deletes the source. Returns the output path.
  ///
  /// When [sourceDuration] is known, [onProgress] is fed real-time encode
  /// progress (0.0–1.0) derived from ffmpeg's own statistics — comparing how
  /// much of the source it has processed against the source's total length —
  /// so the UI can show genuine movement instead of sitting frozen during
  /// what used to be a silent, unbounded step.
  Future<String> convertToMp3({
    required String sourcePath,
    required String outputPath,
    required int targetBitrateKbps,
    Duration? sourceDuration,
    void Function(double fraction)? onProgress,
  }) async {
    // -y overwrite · -vn drop any video · -ac 2 stereo · libmp3lame at the
    // chosen CBR bitrate. Paths are quoted to survive spaces.
    final String cmd = '-y -i "$sourcePath" -vn -acodec libmp3lame '
        '-ac 2 -b:a ${targetBitrateKbps}k "$outputPath"';

    final int totalMs = sourceDuration?.inMilliseconds ?? 0;
    final Completer<FFmpegSession> done = Completer<FFmpegSession>();

    final FFmpegSession session = await FFmpegKit.executeAsync(
      cmd,
      (FFmpegSession s) {
        if (!done.isCompleted) done.complete(s);
      },
      null,
      totalMs > 0
          ? (Statistics stats) {
              final double fraction = (stats.getTime() / totalMs).clamp(0.0, 1.0);
              onProgress?.call(fraction);
            }
          : null,
    );

    await done.future.timeout(_kConversionTimeout, onTimeout: () async {
      await FFmpegKit.cancel(session.getSessionId());
      throw Failures.unknown('Conversion timed out after '
          '${_kConversionTimeout.inMinutes} minutes. The file may be unusually '
          'long, or the device may be under heavy load — please try again.');
    });

    final ReturnCode? rc = await session.getReturnCode();

    if (!ReturnCode.isSuccess(rc)) {
      final String? logs = await session.getAllLogsAsString();
      // Clean up a half-written output if ffmpeg failed.
      final File out = File(outputPath);
      if (await out.exists()) await out.delete();
      throw Failures.unknown('ffmpeg exited ${rc?.getValue()}: $logs');
    }

    onProgress?.call(1.0);

    // Encode succeeded — drop the intermediate source file.
    final File src = File(sourcePath);
    if (await src.exists()) await src.delete();
    return outputPath;
  }
}
