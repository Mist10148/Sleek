import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../converter/data/services/history_service.dart';
import '../../domain/entities/track.dart';
import 'device_library_provider.dart';

/// "Your Shelf" — the app's own conversions merged with whatever's already on
/// the device, in one feed the player understands. Downloads lead (most
/// recent transcription first), device tracks follow.
final libraryProvider = Provider<List<Track>>((ref) {
  final List<HistoryEntry> history = ref.watch(historyProvider);
  final List<Track> deviceTracks = ref.watch(deviceLibraryProvider).tracks;

  return <Track>[
    ...history.map(Track.fromHistory),
    ...deviceTracks,
  ];
});
