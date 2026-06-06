/// The output container the user wants.
enum MediaFormat {
  mp3,
  mp4;

  String get label => switch (this) {
        MediaFormat.mp3 => 'MP3',
        MediaFormat.mp4 => 'MP4',
      };

  String get description => switch (this) {
        MediaFormat.mp3 => 'Audio only',
        MediaFormat.mp4 => 'Video + audio',
      };

  String get fileExtension => switch (this) {
        MediaFormat.mp3 => 'mp3',
        MediaFormat.mp4 => 'mp4',
      };

  bool get isAudio => this == MediaFormat.mp3;
}

/// A selectable quality option for a given [MediaFormat].
///
/// For video this maps to a resolution label (e.g. `720p`); for audio it maps
/// to a target bitrate label (e.g. `192 kbps`). The [tag] uniquely identifies
/// the option so the service layer can resolve it back to a concrete stream.
class QualityOption {
  const QualityOption({
    required this.tag,
    required this.label,
    this.subtitle,
    this.bitrateKbps,
  });

  final String tag;
  final String label;
  final String? subtitle;

  /// For audio formats only: the target bitrate used by the MP3 encoder.
  final int? bitrateKbps;

  @override
  bool operator ==(Object other) =>
      other is QualityOption && other.tag == tag;

  @override
  int get hashCode => tag.hashCode;
}

/// Standard MP3 bitrate tiers offered to the user. The actual source audio is
/// downloaded at the best available quality and then (Phase 3) re-encoded to
/// the chosen bitrate with ffmpeg.
const List<QualityOption> kAudioQualities = <QualityOption>[
  QualityOption(tag: 'mp3_320', label: '320 kbps', subtitle: 'Best', bitrateKbps: 320),
  QualityOption(tag: 'mp3_192', label: '192 kbps', subtitle: 'High', bitrateKbps: 192),
  QualityOption(tag: 'mp3_128', label: '128 kbps', subtitle: 'Standard', bitrateKbps: 128),
];
