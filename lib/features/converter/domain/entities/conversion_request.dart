import 'media_format.dart';

/// Everything needed to fulfil one conversion: which video, what format/quality,
/// and where to write the result.
class ConversionRequest {
  const ConversionRequest({
    required this.videoUrl,
    required this.format,
    required this.quality,
    required this.outputDirectoryPath,
  });

  final String videoUrl;
  final MediaFormat format;
  final QualityOption quality;
  final String outputDirectoryPath;
}
