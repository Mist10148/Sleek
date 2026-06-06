import '../../data/models/download_task.dart';
import '../../data/models/video_info.dart';
import '../../domain/entities/media_format.dart';

/// Where the user is in the flow. Drives which UI sections are shown.
enum ConversionStage {
  idle, // nothing entered yet
  loadingInfo, // fetching metadata for the pasted URL
  ready, // info loaded, awaiting format/quality/location choices
  converting, // download/convert in progress
  done, // finished successfully
  error, // something failed
}

/// Immutable snapshot of the converter screen.
class ConversionState {
  const ConversionState({
    this.stage = ConversionStage.idle,
    this.url = '',
    this.info,
    this.format = MediaFormat.mp4,
    this.quality,
    this.outputDirectory,
    this.progress,
    this.result,
    this.errorMessage,
  });

  final ConversionStage stage;
  final String url;
  final VideoInfo? info;
  final MediaFormat format;
  final QualityOption? quality;
  final String? outputDirectory;
  final DownloadProgress? progress;
  final DownloadResult? result;
  final String? errorMessage;

  bool get canConvert =>
      info != null &&
      quality != null &&
      outputDirectory != null &&
      stage != ConversionStage.converting &&
      stage != ConversionStage.loadingInfo;

  ConversionState copyWith({
    ConversionStage? stage,
    String? url,
    VideoInfo? info,
    MediaFormat? format,
    QualityOption? quality,
    String? outputDirectory,
    DownloadProgress? progress,
    DownloadResult? result,
    String? errorMessage,
    bool clearInfo = false,
    bool clearQuality = false,
    bool clearProgress = false,
    bool clearResult = false,
    bool clearError = false,
  }) {
    return ConversionState(
      stage: stage ?? this.stage,
      url: url ?? this.url,
      info: clearInfo ? null : (info ?? this.info),
      format: format ?? this.format,
      quality: clearQuality ? null : (quality ?? this.quality),
      outputDirectory: outputDirectory ?? this.outputDirectory,
      progress: clearProgress ? null : (progress ?? this.progress),
      result: clearResult ? null : (result ?? this.result),
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}
