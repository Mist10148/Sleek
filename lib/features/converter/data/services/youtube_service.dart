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
      // MP3 source audio always comes from a muxed (progressive) stream —
      // the exact same kind of stream the MP4 path already downloads
      // reliably, every time. Adaptive audio-only streams are a notorious
      // trouble spot: they require YouTube signature deciphering AND are
      // throttled server-side to roughly real-time playback speed as an
      // anti-scraping measure (a 4-minute song can take ~4 real-time minutes
      // to trickle in — which looks exactly like a stuck/frozen download).
      // `ConversionService` already passes ffmpeg `-vn`, which discards the
      // video track during re-encoding, so only the audio survives — there's
      // no real downside to sourcing from a muxed stream here.
      if (manifest.muxed.isEmpty) throw Failures.noStream();

      // Smallest muxed stream — we only keep its audio track, so there is no
      // reason to download a large high-resolution video alongside it.
      return manifest.muxed.sortByVideoQuality().last;
    }

    if (manifest.muxed.isEmpty) throw Failures.noStream();
    return manifest.muxed.firstWhere(
      (MuxedStreamInfo s) => s.qualityLabel == quality.tag,
      orElse: () => manifest.muxed.bestQuality,
    );
  }

  /// Resolves a muxed stream other than [excludeTag] for the MP3 pipeline to
  /// retry with, in the rare case the first pick's URL turns out to be dead
  /// at download time. Prefers the next-smallest available quality. Returns
  /// `null` if there's no other muxed stream to try.
  Future<StreamInfo?> alternateMuxedStream(String videoId, {required int excludeTag}) async {
    try {
      final StreamManifest manifest =
          await _yt.videos.streamsClient.getManifest(videoId);
      final List<MuxedStreamInfo> candidates = manifest.muxed
          .sortByVideoQuality()
          .where((MuxedStreamInfo s) => s.tag != excludeTag)
          .toList();
      if (candidates.isEmpty) return null;
      // Smallest of the remaining options — again, only its audio matters.
      return candidates.last;
    } catch (_) {
      return null;
    }
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
