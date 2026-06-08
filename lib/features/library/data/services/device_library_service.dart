import 'dart:typed_data';

import 'package:on_audio_query_pluse/on_audio_query.dart';
import 'package:permission_handler/permission_handler.dart';

/// Thin wrapper around `OnAudioQuery` — scans the device's MediaStore for
/// audio files and fetches embedded artwork, gated behind the runtime
/// `READ_MEDIA_AUDIO` (Android 13+) / storage permission.
///
/// `Permission.audio` maps to the right *audio* permission for every Android
/// version, but `on_audio_query`'s own Android backend additionally checks
/// for `READ_MEDIA_IMAGES` on Android 13+ (it surfaces embedded artwork via
/// `MediaStore.Images` too) before it'll honour any query — and crashes the
/// whole app via a double platform-channel reply if that internal check
/// fails (see `AndroidManifest.xml` for the full story). So we request and
/// gate on `Permission.photos` as well, even though our own Dart-side code
/// never touches photos directly — it's purely to satisfy the plugin.
class DeviceLibraryService {
  DeviceLibraryService() : _query = OnAudioQuery();

  static const List<Permission> _permissions = <Permission>[Permission.audio, Permission.photos];

  final OnAudioQuery _query;

  Future<PermissionStatus> permissionStatus() async {
    final List<PermissionStatus> statuses =
        await Future.wait(_permissions.map((Permission p) => p.status));
    return _combine(statuses);
  }

  Future<PermissionStatus> requestPermission() async {
    final Map<Permission, PermissionStatus> results = await _permissions.request();
    return _combine(results.values.toList(growable: false));
  }

  /// Folds several permission statuses into one: granted only when every one
  /// of them is granted, permanently-denied if any is (so the UI offers the
  /// Settings route), denied otherwise.
  static PermissionStatus _combine(List<PermissionStatus> statuses) {
    if (statuses.every((PermissionStatus s) => s.isGranted)) return PermissionStatus.granted;
    if (statuses.any((PermissionStatus s) => s.isPermanentlyDenied)) {
      return PermissionStatus.permanentlyDenied;
    }
    return PermissionStatus.denied;
  }

  Future<List<SongModel>> querySongs() {
    return _query.querySongs(
      sortType: SongSortType.DATE_ADDED,
      orderType: OrderType.DESC_OR_GREATER,
      uriType: UriType.EXTERNAL,
      ignoreCase: true,
    );
  }

  Future<Uint8List?> queryArtwork(int songId) {
    return _query.queryArtwork(songId, ArtworkType.AUDIO, format: ArtworkFormat.JPEG, size: 300);
  }
}
