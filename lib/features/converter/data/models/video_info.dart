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
  });

  final String id;
  final String title;
  final String author;
  final Duration? duration;
  final String thumbnailUrl;

  /// Concrete video resolutions available for MP4. Audio qualities are fixed
  /// tiers ([kAudioQualities]) since we always grab the best source audio.
  final List<QualityOption> videoQualities;

  List<QualityOption> qualitiesFor(MediaFormat format) =>
      format.isAudio ? kAudioQualities : videoQualities;
}
