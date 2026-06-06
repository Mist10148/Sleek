import 'dart:io';

/// Converts a downloaded audio file into a true `.mp3` at a target bitrate.
///
/// PHASE 3 (see docs/PHASE_TASKS.md): real conversion is done with ffmpeg via
/// the `ffmpeg_kit_flutter_new` package. The wiring is intentionally isolated
/// here so the rest of the app already calls a stable interface.
///
/// Until ffmpeg is added, [convertToMp3] performs a no-op "passthrough": it
/// renames the source audio (m4a/webm) to the requested `.mp3` output path so
/// the end-to-end flow works on a device. The container is technically still
/// the source codec; swap in the ffmpeg call below to produce real MP3 audio.
class ConversionService {
  /// Returns the path to the produced `.mp3` (passthrough until Phase 3).
  Future<String> convertToMp3({
    required String sourcePath,
    required String outputPath,
    required int targetBitrateKbps,
  }) async {
    // ── Phase 3: replace the passthrough below with ────────────────────────
    // final session = await FFmpegKit.execute(
    //   '-y -i "$sourcePath" -vn -ac 2 -b:a ${targetBitrateKbps}k "$outputPath"',
    // );
    // final rc = await session.getReturnCode();
    // if (!ReturnCode.isSuccess(rc)) throw Failures.unknown('ffmpeg failed');
    // await File(sourcePath).delete();
    // return outputPath;
    // ────────────────────────────────────────────────────────────────────────

    final File src = File(sourcePath);
    if (sourcePath == outputPath) return outputPath;
    await src.rename(outputPath);
    return outputPath;
  }
}
