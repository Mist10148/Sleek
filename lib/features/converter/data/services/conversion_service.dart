import 'dart:io';

import 'package:ffmpeg_kit_flutter_new/ffmpeg_kit.dart';
import 'package:ffmpeg_kit_flutter_new/return_code.dart';

import '../../../../core/errors/failures.dart';

/// Converts a downloaded audio stream into a true `.mp3` at a target bitrate,
/// using ffmpeg (`ffmpeg_kit_flutter_new`). The downloaded source is whatever
/// container YouTube served (m4a/webm/opus); ffmpeg re-encodes it to MP3.
class ConversionService {
  /// Re-encodes [sourcePath] to a real MP3 at [targetBitrateKbps] written to
  /// [outputPath], then deletes the source. Returns the output path.
  Future<String> convertToMp3({
    required String sourcePath,
    required String outputPath,
    required int targetBitrateKbps,
  }) async {
    // -y overwrite · -vn drop any video · -ac 2 stereo · libmp3lame at the
    // chosen CBR bitrate. Paths are quoted to survive spaces.
    final String cmd = '-y -i "$sourcePath" -vn -acodec libmp3lame '
        '-ac 2 -b:a ${targetBitrateKbps}k "$outputPath"';

    final session = await FFmpegKit.execute(cmd);
    final ReturnCode? rc = await session.getReturnCode();

    if (!ReturnCode.isSuccess(rc)) {
      final String? logs = await session.getAllLogsAsString();
      // Clean up a half-written output if ffmpeg failed.
      final File out = File(outputPath);
      if (await out.exists()) await out.delete();
      throw Failures.unknown('ffmpeg exited ${rc?.getValue()}: $logs');
    }

    // Encode succeeded — drop the intermediate source file.
    final File src = File(sourcePath);
    if (await src.exists()) await src.delete();
    return outputPath;
  }
}
