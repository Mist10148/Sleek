/// A user-presentable failure. Services throw these so the UI can show a clean
/// message instead of a raw exception/stack trace.
class AppFailure implements Exception {
  const AppFailure(this.message, {this.cause});

  /// Human-readable, safe to show in a SnackBar/dialog.
  final String message;

  /// Underlying error, kept for logging/debugging.
  final Object? cause;

  @override
  String toString() => 'AppFailure: $message';
}

/// Convenience constructors for common cases.
class Failures {
  Failures._();

  static AppFailure network([Object? cause]) => AppFailure(
      'Network problem. Check your connection and try again.${_causeDetail(cause)}',
      cause: cause);

  static AppFailure videoUnavailable([Object? cause]) => AppFailure(
      'This video is unavailable or restricted.',
      cause: cause);

  static AppFailure permissionDenied([Object? cause]) => AppFailure(
      'Storage permission is required to save the file.',
      cause: cause);

  static AppFailure noStream([Object? cause]) => AppFailure(
      'No matching stream was found for the selected quality.',
      cause: cause);

  static AppFailure unknown([Object? cause]) => AppFailure(
      'Something went wrong. Please try again.${_causeDetail(cause)}',
      cause: cause);

  static String _causeDetail(Object? cause) {
    if (cause == null) return '';
    final String s = cause.toString();
    final String trimmed = s.length > 120 ? '${s.substring(0, 120)}…' : s;
    return '\n($trimmed)';
  }
}
