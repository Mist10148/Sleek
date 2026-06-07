import 'dart:async';
import 'dart:math';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:just_audio/just_audio.dart' as ja;

import '../../domain/entities/track.dart';
import 'library_provider.dart';

/// off → loops nothing · all → loops the queue · one → loops the current track
/// (mirrors the design's `repeat` cycle: off → all → one → off).
enum PlaybackRepeat { off, all, one }

/// Mirrors `VellvmApp`'s player state shape (`currentId`, `playing`, `pos`,
/// `shuffle`, `repeat`, `order`, `npOpen`, `queueOpen`) — but backed by a real
/// `just_audio` engine instead of a `setInterval` simulation.
class PlaybackState {
  const PlaybackState({
    this.currentId,
    this.playing = false,
    this.position = Duration.zero,
    this.shuffle = false,
    this.repeat = PlaybackRepeat.off,
    this.order = const <String>[],
    this.nowPlayingOpen = false,
    this.queueOpen = false,
  });

  final String? currentId;
  final bool playing;
  final Duration position;
  final bool shuffle;
  final PlaybackRepeat repeat;
  final List<String> order;
  final bool nowPlayingOpen;
  final bool queueOpen;

  PlaybackState copyWith({
    String? currentId,
    bool? playing,
    Duration? position,
    bool? shuffle,
    PlaybackRepeat? repeat,
    List<String>? order,
    bool? nowPlayingOpen,
    bool? queueOpen,
  }) {
    return PlaybackState(
      currentId: currentId ?? this.currentId,
      playing: playing ?? this.playing,
      position: position ?? this.position,
      shuffle: shuffle ?? this.shuffle,
      repeat: repeat ?? this.repeat,
      order: order ?? this.order,
      nowPlayingOpen: nowPlayingOpen ?? this.nowPlayingOpen,
      queueOpen: queueOpen ?? this.queueOpen,
    );
  }
}

/// Wraps a single `just_audio` `AudioPlayer`, replacing the design's
/// `setInterval` playback simulation with a real engine while preserving its
/// exact shape: play/pause/seek/next/prev/shuffle/repeat(off|all|one)/queue.
class PlayerController extends Notifier<PlaybackState> {
  final ja.AudioPlayer _player = ja.AudioPlayer();
  StreamSubscription<Duration>? _posSub;
  StreamSubscription<ja.PlayerState>? _stateSub;
  ja.ProcessingState _lastProcessingState = ja.ProcessingState.idle;

  @override
  PlaybackState build() {
    _posSub = _player.positionStream.listen((Duration d) {
      state = state.copyWith(position: d);
    });
    _stateSub = _player.playerStateStream.listen((ja.PlayerState s) {
      state = state.copyWith(playing: s.playing);
      if (s.processingState == ja.ProcessingState.completed &&
          _lastProcessingState != ja.ProcessingState.completed) {
        _onTrackFinished();
      }
      _lastProcessingState = s.processingState;
    });
    ref.onDispose(() {
      _posSub?.cancel();
      _stateSub?.cancel();
      _player.dispose();
    });
    return const PlaybackState();
  }

  List<Track> get _library => ref.read(libraryProvider);

  Track? get current {
    final String? id = state.currentId;
    if (id == null) return null;
    for (final Track t in _library) {
      if (t.id == id) return t;
    }
    return null;
  }

  List<Track> get queue {
    final Map<String, Track> byId = <String, Track>{for (final Track t in _library) t.id: t};
    return state.order.map((String id) => byId[id]).whereType<Track>().toList(growable: false);
  }

  void playTrack(String id) {
    if (!state.order.contains(id)) _rebuildOrder(id, state.shuffle);
    state = state.copyWith(currentId: id, position: Duration.zero, playing: true);
    _load(id, autoplay: true);
  }

  void togglePlay() {
    if (current == null) {
      final List<Track> lib = _library;
      if (lib.isNotEmpty) playTrack(lib.first.id);
      return;
    }
    if (_player.playing) {
      _player.pause();
    } else {
      _player.play();
    }
  }

  void next() => _advance(1, auto: true);

  void prev() {
    if (state.position.inSeconds > 3) {
      seekTo(Duration.zero);
    } else {
      _advance(-1, auto: true);
    }
  }

  void seekTo(Duration position) {
    _player.seek(position);
    state = state.copyWith(position: position);
  }

  void seekFraction(double fraction) {
    final Track? t = current;
    if (t == null) return;
    final int ms = (fraction.clamp(0.0, 1.0) * t.duration.inMilliseconds).round();
    seekTo(Duration(milliseconds: ms));
  }

  void toggleShuffle() {
    final bool next = !state.shuffle;
    state = state.copyWith(shuffle: next);
    _rebuildOrder(state.currentId, next);
  }

  void cycleRepeat() {
    state = state.copyWith(
      repeat: switch (state.repeat) {
        PlaybackRepeat.off => PlaybackRepeat.all,
        PlaybackRepeat.all => PlaybackRepeat.one,
        PlaybackRepeat.one => PlaybackRepeat.off,
      },
    );
  }

  void openNowPlaying() => state = state.copyWith(nowPlayingOpen: true);
  void closeNowPlaying() => state = state.copyWith(nowPlayingOpen: false);
  void openQueue() => state = state.copyWith(queueOpen: true);
  void closeQueue() => state = state.copyWith(queueOpen: false);

  Future<void> _load(String id, {required bool autoplay}) async {
    final List<Track> lib = _library;
    Track? track;
    for (final Track t in lib) {
      if (t.id == id) {
        track = t;
        break;
      }
    }
    if (track == null) return;
    try {
      await _player.setFilePath(track.filePath);
      if (autoplay) await _player.play();
    } catch (_) {
      // A track that can't be opened is a shrug — the transport stays put.
    }
  }

  void _advance(int dir, {bool auto = false}) {
    final List<String> ids = state.order.isNotEmpty
        ? state.order
        : _library.map((Track t) => t.id).toList(growable: false);
    if (ids.isEmpty) return;
    final String? cur = state.currentId;
    final int i = cur == null ? -1 : ids.indexOf(cur);
    int ni = i + dir;
    if (ni >= ids.length) {
      if (state.repeat == PlaybackRepeat.all) {
        ni = 0;
      } else {
        state = state.copyWith(position: Duration.zero, playing: false);
        _player.pause();
        _player.seek(Duration.zero);
        return;
      }
    }
    if (ni < 0) ni = ids.length - 1;
    final String nextId = ids[ni];
    state = state.copyWith(currentId: nextId, position: Duration.zero);
    _load(nextId, autoplay: auto);
  }

  void _onTrackFinished() {
    if (state.repeat == PlaybackRepeat.one) {
      _player.seek(Duration.zero);
      _player.play();
      return;
    }
    _advance(1, auto: true);
  }

  void _rebuildOrder(String? startId, bool shuffle) {
    final List<String> ids = _library.map((Track t) => t.id).toList(growable: false);
    List<String> next = ids;
    if (shuffle) {
      final List<String> rest = ids.where((String id) => id != startId).toList()..shuffle(Random());
      next = startId != null ? <String>[startId, ...rest] : (List<String>.from(ids)..shuffle(Random()));
    }
    state = state.copyWith(order: next);
  }
}

final playerControllerProvider =
    NotifierProvider<PlayerController, PlaybackState>(PlayerController.new);
