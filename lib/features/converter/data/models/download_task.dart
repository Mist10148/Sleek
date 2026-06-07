/// Which step of the MP3 pipeline a [DownloadProgress] snapshot belongs to.
/// MP4 only ever reports [downloading]; MP3 moves through both in order, so
/// the UI can show a distinct status for each instead of one long "0% → 100%"
/// that silently resets when the second phase begins.
enum ConversionPhase {
  /// Pulling the source bytes from YouTube.
  downloading,

  /// Re-encoding the downloaded source into a true MP3 with ffmpeg.
  converting,
}

/// Progress snapshot emitted while a download (and later, conversion) runs.
class DownloadProgress {
  const DownloadProgress({
    required this.receivedBytes,
    required this.totalBytes,
    required this.elapsed,
    this.phase = ConversionPhase.downloading,
    this.fractionOverride,
  });

  final int receivedBytes;
  final int totalBytes;
  final Duration elapsed;
  final ConversionPhase phase;

  /// Set when a phase reports its own ratio directly — e.g. ffmpeg's
  /// "time processed ÷ source duration" — rather than a byte count. When
  /// present, [fraction] uses it verbatim instead of dividing
  /// [receivedBytes] by [totalBytes], so phases with no meaningful byte
  /// counts never have to invent fake ones just to report a percentage.
  final double? fractionOverride;

  /// Builds a snapshot directly from a known ratio (0.0–1.0) — for phases
  /// such as ffmpeg re-encoding, which track progress by "time processed
  /// ÷ total duration," not bytes received. [receivedBytes]/[totalBytes]
  /// are left at 0 so UI code can tell at a glance that byte-based stats
  /// (file size, transfer speed, ETA) don't apply to this snapshot.
  factory DownloadProgress.fromFraction({
    required double fraction,
    required Duration elapsed,
    ConversionPhase phase = ConversionPhase.downloading,
  }) =>
      DownloadProgress(
        receivedBytes: 0,
        totalBytes: 0,
        elapsed: elapsed,
        phase: phase,
        fractionOverride: fraction.clamp(0.0, 1.0),
      );

  /// 0.0–1.0. Prefers [fractionOverride] when set; otherwise derives the
  /// ratio from byte counts, falling back to 0 when the total is unknown.
  double get fraction =>
      fractionOverride ??
      (totalBytes <= 0 ? 0 : (receivedBytes / totalBytes).clamp(0, 1));
}

/// The result of a completed conversion.
class DownloadResult {
  const DownloadResult({
    required this.filePath,
    required this.sizeBytes,
    required this.elapsed,
  });

  final String filePath;
  final int sizeBytes;
  final Duration elapsed;
}
