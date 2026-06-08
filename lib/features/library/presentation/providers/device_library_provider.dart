import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:on_audio_query_pluse/on_audio_query.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../data/services/device_library_service.dart';
import '../../domain/entities/track.dart';

/// Where the on-device scan currently stands — surfaced so the Library tab
/// can show a permission prompt, a "scanning…" state, or the results.
enum DeviceLibraryStatus { unknown, denied, permanentlyDenied, scanning, ready }

class DeviceLibraryState {
  const DeviceLibraryState({
    required this.status,
    this.tracks = const <Track>[],
  });

  final DeviceLibraryStatus status;
  final List<Track> tracks;

  DeviceLibraryState copyWith({DeviceLibraryStatus? status, List<Track>? tracks}) =>
      DeviceLibraryState(status: status ?? this.status, tracks: tracks ?? this.tracks);
}

/// Scans the device's MediaStore for music — following the same "seed
/// synchronously, hydrate async" shape as [HistoryNotifier] — and exposes the
/// permission state so the Library tab can prompt for access when needed.
class DeviceLibraryNotifier extends Notifier<DeviceLibraryState> {
  late final DeviceLibraryService _service = DeviceLibraryService();

  /// Guards against overlapping permission checks: `requestAccess()` shows
  /// the system dialog (which pauses the host Activity, see [recheckOnResume])
  /// and a resume-triggered recheck can otherwise race its continuation and
  /// stomp the resulting state.
  bool _checking = false;

  @override
  DeviceLibraryState build() {
    Future.microtask(_checkAndLoad);
    return const DeviceLibraryState(status: DeviceLibraryStatus.unknown);
  }

  Future<void> _checkAndLoad() async {
    if (_checking) return;
    _checking = true;
    try {
      final PermissionStatus status = await _service.permissionStatus();
      if (status.isGranted) {
        await _scan();
      } else {
        state = state.copyWith(
          status: status.isPermanentlyDenied
              ? DeviceLibraryStatus.permanentlyDenied
              : DeviceLibraryStatus.denied,
        );
      }
    } finally {
      _checking = false;
    }
  }

  /// Re-reads the OS permission state — call this when the app returns to the
  /// foreground. The system permission dialog backgrounds the host Activity,
  /// and on some devices/Android versions the awaited `requestPermission()`
  /// Future never resolves (or resolves against a stale Activity) once it's
  /// paused or recreated, leaving the UI stuck on the "denied" prompt even
  /// though the OS now reports the permission as granted. Re-checking on
  /// resume guarantees the UI reflects reality regardless of whether that
  /// Future ever completes.
  Future<void> recheckOnResume() async {
    await _checkAndLoad();
  }

  /// Prompts the user for the audio permission, then scans on success.
  Future<void> requestAccess() async {
    if (_checking) return;
    _checking = true;
    try {
      final PermissionStatus current = await _service.permissionStatus();
      if (current.isPermanentlyDenied) {
        state = state.copyWith(status: DeviceLibraryStatus.permanentlyDenied);
        return;
      }
      final PermissionStatus result = await _service.requestPermission();
      if (result.isGranted) {
        await _scan();
      } else {
        state = state.copyWith(
          status: result.isPermanentlyDenied
              ? DeviceLibraryStatus.permanentlyDenied
              : DeviceLibraryStatus.denied,
        );
      }
    } finally {
      _checking = false;
    }
  }

  Future<void> _scan() async {
    state = state.copyWith(status: DeviceLibraryStatus.scanning);
    try {
      final List<SongModel> songs = await _service.querySongs();
      final List<Track> tracks = songs
          .where((SongModel s) => s.isMusic ?? true)
          .map(Track.fromDeviceSong)
          .toList(growable: false);
      state = state.copyWith(status: DeviceLibraryStatus.ready, tracks: tracks);
    } catch (_) {
      state = state.copyWith(status: DeviceLibraryStatus.ready, tracks: const <Track>[]);
    }
  }

  /// Re-scans — e.g. after the user adds music to their device and pulls to
  /// refresh.
  Future<void> rescan() => _scan();
}

final deviceLibraryProvider =
    NotifierProvider<DeviceLibraryNotifier, DeviceLibraryState>(DeviceLibraryNotifier.new);

final deviceLibraryServiceProvider = Provider<DeviceLibraryService>((ref) => DeviceLibraryService());
