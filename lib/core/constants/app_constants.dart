/// App-wide constant values.
class AppConstants {
  AppConstants._();

  static const String appName = 'YT Converter';
  static const String appTagline = 'Download YouTube as MP3 or MP4';

  /// Layout breakpoint (logical px) above which we treat the device as a tablet.
  static const double tabletBreakpoint = 600;

  /// Maximum content width on large screens so the UI doesn't stretch edge-to-edge.
  static const double maxContentWidth = 720;

  /// Default sub-folder created inside the chosen directory for outputs.
  static const String outputFolderName = 'YT Converter';
}
