/// Pure formatting helpers used across the UI. Kept free of Flutter imports so
/// they're trivially unit-testable.
class Formatters {
  Formatters._();

  /// Human-readable byte size, e.g. `4.2 MB`.
  static String fileSize(int bytes) {
    if (bytes <= 0) return '0 B';
    const List<String> units = <String>['B', 'KB', 'MB', 'GB', 'TB'];
    double size = bytes.toDouble();
    int unit = 0;
    while (size >= 1024 && unit < units.length - 1) {
      size /= 1024;
      unit++;
    }
    final String value = unit == 0 ? size.toStringAsFixed(0) : size.toStringAsFixed(1);
    return '$value ${units[unit]}';
  }

  /// Transfer speed, e.g. `1.4 MB/s`, from bytes and elapsed time.
  static String speed(int bytes, Duration elapsed) {
    if (elapsed.inMilliseconds <= 0 || bytes <= 0) return '—';
    final double bytesPerSecond = bytes / (elapsed.inMilliseconds / 1000);
    return '${fileSize(bytesPerSecond.round())}/s';
  }

  /// Compact duration like `3:07` or `1:02:33`.
  static String duration(Duration d) {
    final int hours = d.inHours;
    final int minutes = d.inMinutes.remainder(60);
    final int seconds = d.inSeconds.remainder(60);
    final String two = seconds.toString().padLeft(2, '0');
    if (hours > 0) {
      return '$hours:${minutes.toString().padLeft(2, '0')}:$two';
    }
    return '$minutes:$two';
  }

  /// Estimated time remaining given bytes done/total and elapsed time.
  static String eta({
    required int received,
    required int total,
    required Duration elapsed,
  }) {
    if (received <= 0 || total <= 0 || elapsed.inMilliseconds <= 0) return '—';
    if (received >= total) return '0:00';
    final double bytesPerSecond = received / (elapsed.inMilliseconds / 1000);
    if (bytesPerSecond <= 0) return '—';
    final double remainingSeconds = (total - received) / bytesPerSecond;
    return duration(Duration(seconds: remainingSeconds.round()));
  }

  /// Percentage label, e.g. `73%`.
  static String percent(double fraction) =>
      '${(fraction.clamp(0, 1) * 100).round()}%';
}
