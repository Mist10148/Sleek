import '../../domain/entities/media_format.dart';

/// Lightweight, UI-facing view of a YouTube video plus the quality options we
/// derived from its available streams. Decoupled from the youtube_explode types
/// so the rest of the app doesn't depend on that package directly.
class VideoInfo {
  const VideoInfo({
    required this.id,
    required this.title,
    required this.author,
    required this.duration,
    required this.thumbnailUrl,
    required this.videoQualities,
    required this.audioQualities,
  });

  final String id;
  final String title;
  final String author;
  final Duration? duration;
  final String thumbnailUrl;

  /// Concrete MP4 (muxed) resolutions available, best first, with real sizes.
  final List<QualityOption> videoQualities;

  /// MP3 bitrate tiers with size estimates derived from the clip duration.
  final List<QualityOption> audioQualities;

  List<QualityOption> qualitiesFor(MediaFormat format) =>
      format.isAudio ? audioQualities : videoQualities;
}
