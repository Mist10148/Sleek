import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/errors/failures.dart';
import '../../data/models/download_task.dart';
import '../../data/repositories/converter_repository.dart';
import '../../data/services/conversion_service.dart';
import '../../data/services/download_service.dart';
import '../../data/services/storage_service.dart';
import '../../data/services/youtube_service.dart';
import '../../domain/entities/conversion_request.dart';
import '../../domain/entities/media_format.dart';
import 'conversion_state.dart';

// ── Service / repository providers (easy to override in tests) ──────────────
final youtubeServiceProvider = Provider<YoutubeService>((ref) {
  final YoutubeService service = YoutubeService();
  ref.onDispose(service.dispose);
  return service;
});

final downloadServiceProvider =
    Provider<DownloadService>((ref) => DownloadService());

final storageServiceProvider =
    Provider<StorageService>((ref) => StorageService());

final conversionServiceProvider =
    Provider<ConversionService>((ref) => ConversionService());

final converterRepositoryProvider = Provider<ConverterRepository>((ref) {
  return ConverterRepository(
    youtube: ref.watch(youtubeServiceProvider),
    download: ref.watch(downloadServiceProvider),
    storage: ref.watch(storageServiceProvider),
    conversion: ref.watch(conversionServiceProvider),
  );
});

final converterControllerProvider =
    NotifierProvider<ConverterController, ConversionState>(
        ConverterController.new);

/// Orchestrates the converter screen: URL → info → choices → convert.
class ConverterController extends Notifier<ConversionState> {
  @override
  ConversionState build() => const ConversionState();

  ConverterRepository get _repo => ref.read(converterRepositoryProvider);

  void setUrl(String url) {
    state = state.copyWith(url: url);
  }

  /// Fetch metadata for the current URL and move to the `ready` stage.
  Future<void> loadInfo(String url) async {
    state = state.copyWith(
      url: url,
      stage: ConversionStage.loadingInfo,
      clearError: true,
      clearInfo: true,
      clearQuality: true,
      clearResult: true,
      clearProgress: true,
    );
    try {
      final info = await _repo.fetchInfo(url);
      final defaultDir =
          state.outputDirectory ?? await _repo.defaultDirectory();
      // Preselect the best quality for the current format.
      final options = info.qualitiesFor(state.format);
      state = state.copyWith(
        stage: ConversionStage.ready,
        info: info,
        outputDirectory: defaultDir,
        quality: options.isNotEmpty ? options.first : null,
      );
    } catch (e) {
      _fail(e);
    }
  }

  void selectFormat(MediaFormat format) {
    final info = state.info;
    final options = info?.qualitiesFor(format) ?? const [];
    state = state.copyWith(
      format: format,
      quality: options.isNotEmpty ? options.first : null,
      clearQuality: options.isEmpty,
      clearResult: true,
    );
  }

  void selectQuality(QualityOption quality) {
    state = state.copyWith(quality: quality, clearResult: true);
  }

  void setOutputDirectory(String path) {
    state = state.copyWith(outputDirectory: path);
  }

  /// Run the download/convert pipeline.
  Future<void> convert() async {
    final info = state.info;
    final quality = state.quality;
    final dir = state.outputDirectory;
    if (info == null || quality == null || dir == null) return;

    state = state.copyWith(
      stage: ConversionStage.converting,
      clearError: true,
      clearResult: true,
      progress: const DownloadProgress(
          receivedBytes: 0, totalBytes: 0, elapsed: Duration.zero),
    );

    try {
      final result = await _repo.convert(
        request: ConversionRequest(
          videoUrl: state.url,
          format: state.format,
          quality: quality,
          outputDirectoryPath: dir,
        ),
        info: info,
        onProgress: (p) => state = state.copyWith(progress: p),
      );
      state = state.copyWith(stage: ConversionStage.done, result: result);
    } catch (e) {
      _fail(e);
    }
  }

  /// Clear everything back to the initial screen.
  void reset() {
    final dir = state.outputDirectory;
    state = ConversionState(outputDirectory: dir);
  }

  void _fail(Object error) {
    final message =
        error is AppFailure ? error.message : Failures.unknown(error).message;
    state = state.copyWith(stage: ConversionStage.error, errorMessage: message);
  }
}
