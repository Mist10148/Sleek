import 'package:flutter/material.dart';
import 'package:on_audio_query_pluse/on_audio_query.dart';

import '../../../converter/data/services/history_service.dart';
import '../../../converter/domain/entities/media_format.dart';

/// Where a [Track] came from — the app's own conversions, or a scan of music
/// already on the device. Both flow through the same player and library UI.
enum TrackSource { downloaded, device }

/// The procedural cover palettes from the design's `LIBRARY_SEED` (`art`
/// color pairs + glyphs) — cycled deterministically by title so every track
/// gets a stable, varied "illuminated" cover without needing real artwork.
const List<List<Color>> _kCoverPalettes = <List<Color>>[
  <Color>[Color(0xFF6A4B2F), Color(0xFF2C1D12)],
  <Color>[Color(0xFF3F4D34), Color(0xFF1C2417)],
  <Color>[Color(0xFF5A3550), Color(0xFF241420)],
  <Color>[Color(0xFF4A3A22), Color(0xFF1F180E)],
];
const List<String> _kCoverGlyphs = <String>['❦', '✦', '❧', '♪'];

/// A unified track shape the library, mini-player, and now-playing screens all
/// read from — whether it was transcribed by this app ([TrackSource.downloaded],
/// sourced from [HistoryEntry]) or discovered already on the device
/// ([TrackSource.device], sourced from [SongModel] via `on_audio_query_pluse`).
class Track {
  const Track({
    required this.id,
    required this.title,
    required this.artist,
    required this.duration,
    required this.format,
    required this.filePath,
    required this.source,
    required this.coverColors,
    required this.glyph,
    this.qualityLabel = '',
    this.deviceSongId,
    this.added,
  });

  final String id;
  final String title;
  final String artist;
  final Duration duration;
  final MediaFormat format;
  final String filePath;
  final TrackSource source;

  /// Pre-formatted quality, e.g. `"192 kbps"` / `"720p"` — empty for device
  /// tracks, which carry no comparable concept.
  final String qualityLabel;

  /// Procedural radial-gradient stops for [AlbumArt] — every downloaded track
  /// has no real cover, so it wears one of these "illuminated" tints instead.
  final List<Color> coverColors;
  final String glyph;

  /// MediaStore song id, present only for [TrackSource.device] tracks — used
  /// to fetch real embedded artwork via `OnAudioQuery().queryArtwork(...)`.
  final int? deviceSongId;

  final DateTime? added;

  bool get hasRealArtwork => source == TrackSource.device && deviceSongId != null;

  factory Track.fromHistory(HistoryEntry entry) {
    final String id = 'h_${entry.completedAt.millisecondsSinceEpoch}_${entry.title.hashCode}';
    final int paletteIndex = entry.title.hashCode.abs() % _kCoverPalettes.length;
    return Track(
      id: id,
      title: entry.title,
      artist: entry.author.isNotEmpty ? entry.author : 'Unknown channel',
      duration: entry.duration ?? Duration.zero,
      format: entry.format,
      filePath: entry.filePath,
      source: TrackSource.downloaded,
      coverColors: _kCoverPalettes[paletteIndex],
      glyph: _kCoverGlyphs[paletteIndex],
      qualityLabel: entry.qualityLabel,
      added: entry.completedAt,
    );
  }

  factory Track.fromDeviceSong(SongModel song) {
    final int paletteIndex = song.id % _kCoverPalettes.length;
    final int? durationMs = song.duration;
    return Track(
      id: 'd_${song.id}',
      title: song.title,
      artist: (song.artist == null || song.artist == '<unknown>')
          ? 'Unknown artist'
          : song.artist!,
      duration: durationMs != null ? Duration(milliseconds: durationMs) : Duration.zero,
      format: MediaFormat.mp3,
      filePath: song.data,
      source: TrackSource.device,
      coverColors: _kCoverPalettes[paletteIndex],
      glyph: _kCoverGlyphs[paletteIndex],
      deviceSongId: song.id,
      added: song.dateAdded != null
          ? DateTime.fromMillisecondsSinceEpoch(song.dateAdded! * 1000)
          : null,
    );
  }
}
