import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../domain/entities/media_format.dart';

const String _kHistoryKey = 'transcription_history';

/// How many finished jobs the shelf remembers before the oldest falls away.
const int _kHistoryCap = 12;

/// One finished transcription kept on the shelf — its title, the choices that
/// shaped it, where it came to rest, and when. Deliberately the same small
/// "receipt" shape `DoneScreen` already shows (see `qualityLabel` below), so
/// a history card and the screen it was born from always speak in one voice.
class HistoryEntry {
  const HistoryEntry({
    required this.title,
    required this.format,
    required this.qualityLabel,
    required this.filePath,
    required this.thumbnailUrl,
    required this.completedAt,
    this.author = '',
    this.duration,
  });

  final String title;
  final MediaFormat format;

  /// Pre-formatted exactly the way `DoneScreen` renders it — `"192 kbps"` for
  /// MP3 or `"720p"` for MP4 — captured once at completion so the shelf keeps
  /// reading true even if the live quality catalogue ever changes shape.
  final String qualityLabel;

  final String filePath;
  final String thumbnailUrl;
  final DateTime completedAt;

  /// The uploading channel/artist, shown as the "artist" line in the library.
  final String author;

  /// The source video's runtime, used for the scrubber's total duration.
  final Duration? duration;

  Map<String, Object?> toJson() => <String, Object?>{
        'title': title,
        'format': format.name,
        'qualityLabel': qualityLabel,
        'filePath': filePath,
        'thumbnailUrl': thumbnailUrl,
        'completedAt': completedAt.toIso8601String(),
        'author': author,
        'durationMs': duration?.inMilliseconds,
      };

  /// Returns `null` for anything malformed rather than throwing — one
  /// spoiled record shouldn't be able to sink the whole shelf.
  static HistoryEntry? tryFromJson(Object? json) {
    if (json is! Map) return null;
    try {
      final Object? durationMs = json['durationMs'];
      return HistoryEntry(
        title: json['title'] as String,
        format: MediaFormat.values.byName(json['format'] as String),
        qualityLabel: json['qualityLabel'] as String,
        filePath: json['filePath'] as String,
        thumbnailUrl: json['thumbnailUrl'] as String? ?? '',
        completedAt: DateTime.parse(json['completedAt'] as String),
        author: json['author'] as String? ?? '',
        duration: durationMs is int ? Duration(milliseconds: durationMs) : null,
      );
    } catch (_) {
      return null;
    }
  }
}

/// Keeps the dozen-most-recent finished transcriptions, persisted as JSON via
/// `SharedPreferences` — the exact package, and the same "seed a sensible
/// default synchronously, then hydrate from disk in a microtask" shape, that
/// `ThemeModeNotifier` already established (see `theme_provider.dart`).
class HistoryNotifier extends Notifier<List<HistoryEntry>> {
  @override
  List<HistoryEntry> build() {
    Future.microtask(_loadFromPrefs);
    return const <HistoryEntry>[];
  }

  Future<void> _loadFromPrefs() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? raw = prefs.getString(_kHistoryKey);
    if (raw == null || raw.isEmpty) return;
    try {
      final List<dynamic> decoded = jsonDecode(raw) as List<dynamic>;
      state = decoded
          .map(HistoryEntry.tryFromJson)
          .whereType<HistoryEntry>()
          .toList(growable: false);
    } catch (_) {
      // A corrupted shelf reads no worse than an empty one — start fresh.
    }
  }

  /// Sets a freshly finished transcription at the head of the shelf, trimming
  /// the oldest once it grows past [_kHistoryCap].
  Future<void> add(HistoryEntry entry) async {
    final List<HistoryEntry> next = <HistoryEntry>[entry, ...state];
    state = next.length > _kHistoryCap ? next.sublist(0, _kHistoryCap) : next;
    await _persist();
  }

  /// Wipes the shelf clean.
  Future<void> clear() async {
    state = const <HistoryEntry>[];
    await _persist();
  }

  Future<void> _persist() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _kHistoryKey,
      jsonEncode(state.map((HistoryEntry e) => e.toJson()).toList(growable: false)),
    );
  }
}

final historyProvider =
    NotifierProvider<HistoryNotifier, List<HistoryEntry>>(HistoryNotifier.new);
