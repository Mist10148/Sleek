import 'dart:io';

import 'package:youtube_explode_dart/youtube_explode_dart.dart';

import '../../../../core/errors/failures.dart';
import '../../domain/entities/conversion_request.dart';
import '../../domain/entities/media_format.dart';
import '../models/download_task.dart';
import '../models/video_info.dart';
import '../services/conversion_service.dart';
import '../services/download_service.dart';
import '../services/storage_service.dart';
import '../services/youtube_service.dart';

/// Coordinates the services into the two public operations the UI needs:
/// fetching video info, and running a full conversion with progress.
class ConverterRepository {
  ConverterRepository({
    required YoutubeService youtube,
    required DownloadService download,
    required StorageService storage,
    required ConversionService conversion,
  })  : _youtube = youtube,
        _download = download,
        _storage = storage,
        _conversion = conversion;

  final YoutubeService _youtube;
  final DownloadService _download;
  final StorageService _storage;
  final ConversionService _conversion;

  Future<VideoInfo> fetchInfo(String url) => _youtube.fetchInfo(url);

  Future<String> defaultDirectory() => _storage.defaultDirectory();

  /// Runs the full pipeline: resolve stream → download (with progress) →
  /// for MP3, convert to a true `.mp3`. Returns the final [DownloadResult].
  Future<DownloadResult> convert({
    required ConversionRequest request,
    required VideoInfo info,
    required void Function(DownloadProgress progress) onProgress,
  }) async {
    await _storage.assertWritable(request.outputDirectoryPath);
    final Stopwatch total = Stopwatch()..start();

    final StreamInfo stream = await _youtube.resolveStream(
      videoId: info.id,
      format: request.format,
      quality: request.quality,
    );

    final String finalPath = _storage.buildOutputPath(
      directory: request.outputDirectoryPath,
      title: info.title,
      extension: request.format.fileExtension,
    );

    if (request.format == MediaFormat.mp4) {
      final int size = await _download.download(
        source: _youtube.openStream(stream),
        totalBytes: _youtube.sizeOf(stream),
        outputPath: finalPath,
        onProgress: onProgress,
      );
      return DownloadResult(
          filePath: finalPath, sizeBytes: size, elapsed: total.elapsed);
    }

    // MP3: download source audio to a temp file, then convert.
    final String tempPath =
        '$finalPath.${_youtube.containerOf(stream)}.part';
    await _download.download(
      source: _youtube.openStream(stream),
      totalBytes: _youtube.sizeOf(stream),
      outputPath: tempPath,
      onProgress: onProgress,
    );

    final String produced = await _conversion.convertToMp3(
      sourcePath: tempPath,
      outputPath: finalPath,
      targetBitrateKbps: request.quality.bitrateKbps ?? 192,
    );

    final int size = await File(produced).length();
    return DownloadResult(
        filePath: produced, sizeBytes: size, elapsed: total.elapsed);
  }
}

/// Maps unexpected errors to an [AppFailure] so the controller layer can rely
/// on a single error type.
Object toAppFailure(Object error) =>
    error is AppFailure ? error : Failures.unknown(error);
