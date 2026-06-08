/// App-wide constant values.
class AppConstants {
  AppConstants._();

  /// Wordmark shown in the crest.
  static const String appName = 'Sleek';
  static const String appTagline = 'Films & Recordings, Transcribed';

  /// Layout breakpoint (logical px) above which we treat the device as a tablet.
  static const double tabletBreakpoint = 600;

  /// The manuscript column width — matches the design's mobile artboard. On
  /// wider screens the column is centered on the dark surround.
  static const double maxContentWidth = 440;

  /// Column width on tablets — wide enough that the app doesn't read as a
  /// phone window stranded in a sea of empty surround, while still keeping
  /// the manuscript's comfortable reading measure.
  static const double maxContentWidthTablet = 760;

  /// Default sub-folder created inside the chosen directory for outputs.
  static const String outputFolderName = 'Sleek';
}
