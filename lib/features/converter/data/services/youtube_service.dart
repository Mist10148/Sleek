import 'package:youtube_explode_dart/youtube_explode_dart.dart';

import '../../../../core/errors/failures.dart';
import '../../domain/entities/media_format.dart';
import '../models/video_info.dart';

/// Thin wrapper around `youtube_explode_dart`. Owns the [YoutubeExplode] client
/// and translates its types into the app's [VideoInfo] / [StreamInfo] surface.
class YoutubeService {
  YoutubeService([YoutubeExplode? client]) : _yt = client ?? YoutubeExplode();

  final YoutubeExplode _yt;

  /// Fetches metadata + available video qualities for [url].
  Future<VideoInfo> fetchInfo(String url) async {
    try {
      final Video video = await _yt.videos.get(url);
      final StreamManifest manifest =
          await _yt.videos.streamsClient.getManifest(video.id);

      // Derive distinct MP4 (muxed) resolutions, best first.
      final Map<String, QualityOption> byLabel = <String, QualityOption>{};
      for (final MuxedStreamInfo s in manifest.muxed.sortByVideoQuality()) {
        byLabel.putIfAbsent(
          s.qualityLabel,
          () => QualityOption(
            tag: s.qualityLabel,
            q: _resolutionDigits(s.qualityLabel),
            meta: _videoClass(s.videoResolution.height, s.framerate.framesPerSecond),
            estimatedBytes: s.size.totalBytes,
          ),
        );
      }

      final int durationSec = video.duration?.inSeconds ?? 0;

      return VideoInfo(
        id: video.id.value,
        title: video.title,
        author: video.author,
        duration: video.duration,
        thumbnailUrl: video.thumbnails.highResUrl,
        videoQualities: byLabel.values.toList(growable: false),
        audioQualities: audioQualitiesFor(durationSec),
      );
    } on VideoUnavailableException catch (e) {
      throw Failures.videoUnavailable(e);
    } on VideoRequiresPurchaseException catch (e) {
      throw Failures.videoUnavailable(e);
    } catch (e) {
      throw Failures.network(e);
    }
  }

  /// Resolves the concrete stream to download for the given selection.
  Future<StreamInfo> resolveStream({
    required String videoId,
    required MediaFormat format,
    required QualityOption quality,
  }) async {
    final StreamManifest manifest =
        await _yt.videos.streamsClient.getManifest(videoId);

    if (format.isAudio) {
      if (manifest.audioOnly.isEmpty) throw Failures.noStream();
      return manifest.audioOnly.withHighestBitrate();
    }

    if (manifest.muxed.isEmpty) throw Failures.noStream();
    return manifest.muxed.firstWhere(
      (MuxedStreamInfo s) => s.qualityLabel == quality.tag,
      orElse: () => manifest.muxed.bestQuality,
    );
  }

  /// Opens a byte stream for the resolved [info].
  Stream<List<int>> openStream(StreamInfo info) =>
      _yt.videos.streamsClient.get(info);

  /// Total size in bytes of the resolved stream.
  int sizeOf(StreamInfo info) => info.size.totalBytes;

  /// Container extension of the resolved stream (e.g. `mp4`, `webm`, `m4a`).
  String containerOf(StreamInfo info) => info.container.name;

  void dispose() => _yt.close();
}

/// Leading digits of a quality label, e.g. `1080p60` → `1080`.
String _resolutionDigits(String qualityLabel) {
  final Match? m = RegExp(r'\d+').firstMatch(qualityLabel);
  return m?.group(0) ?? qualityLabel;
}

/// A resolution-class caption for the quality pill, e.g. `HD · 60`, `SD`.
String _videoClass(int height, num fps) {
  final String tier = height >= 2160
      ? '4K'
      : height >= 720
          ? 'HD'
          : 'SD';
  return fps >= 50 ? '$tier · 60' : tier;
}
