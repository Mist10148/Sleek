/// Progress snapshot emitted while a download (and later, conversion) runs.
class DownloadProgress {
  const DownloadProgress({
    required this.receivedBytes,
    required this.totalBytes,
    required this.elapsed,
  });

  final int receivedBytes;
  final int totalBytes;
  final Duration elapsed;

  /// 0.0–1.0. Falls back to 0 when total size is unknown.
  double get fraction =>
      totalBytes <= 0 ? 0 : (receivedBytes / totalBytes).clamp(0, 1);
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
