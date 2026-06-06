/// The output container the user wants.
enum MediaFormat {
  mp3,
  mp4;

  String get label => switch (this) {
        MediaFormat.mp3 => 'MP3',
        MediaFormat.mp4 => 'MP4',
      };

  String get description => switch (this) {
        MediaFormat.mp3 => 'Audio',
        MediaFormat.mp4 => 'Video',
      };

  String get fileExtension => switch (this) {
        MediaFormat.mp3 => 'mp3',
        MediaFormat.mp4 => 'mp4',
      };

  bool get isAudio => this == MediaFormat.mp3;
}

/// A selectable quality option for a given [MediaFormat].
///
/// [q] is the large pill numeral (resolution like `720`, or bitrate like `320`);
/// [meta] is the small mono caption (`HD · 60`, `SD`, `kbps`). [tag] uniquely
/// identifies the option so the service layer can resolve it back to a stream.
class QualityOption {
  const QualityOption({
    required this.tag,
    required this.q,
    required this.meta,
    this.bitrateKbps,
    this.estimatedBytes,
  });

  final String tag;
  final String q;
  final String meta;

  /// For audio formats only: the target bitrate used by the MP3 encoder.
  final int? bitrateKbps;

  /// Best-known size estimate in bytes (real stream size for video; derived
  /// from bitrate × duration for audio). Null when unknown.
  final int? estimatedBytes;

  QualityOption withEstimate(int bytes) => QualityOption(
        tag: tag,
        q: q,
        meta: meta,
        bitrateKbps: bitrateKbps,
        estimatedBytes: bytes,
      );

  @override
  bool operator ==(Object other) => other is QualityOption && other.tag == tag;

  @override
  int get hashCode => tag.hashCode;
}

/// The four MP3 bitrate tiers from the design. The source audio is downloaded
/// at the best available quality and re-encoded to the chosen bitrate (Phase 3).
const List<QualityOption> kAudioQualities = <QualityOption>[
  QualityOption(tag: 'mp3_320', q: '320', meta: 'kbps', bitrateKbps: 320),
  QualityOption(tag: 'mp3_256', q: '256', meta: 'kbps', bitrateKbps: 256),
  QualityOption(tag: 'mp3_192', q: '192', meta: 'kbps', bitrateKbps: 192),
  QualityOption(tag: 'mp3_128', q: '128', meta: 'kbps', bitrateKbps: 128),
];

/// Audio tiers with size estimates filled in for a clip of [durationSec].
List<QualityOption> audioQualitiesFor(int durationSec) => kAudioQualities
    .map((QualityOption o) => o.withEstimate(
        ((o.bitrateKbps ?? 128) * 1000 ~/ 8) * durationSec))
    .toList(growable: false);
