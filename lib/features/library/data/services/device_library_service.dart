import 'dart:typed_data';

import 'package:on_audio_query_pluse/on_audio_query.dart';
import 'package:permission_handler/permission_handler.dart';

/// Thin wrapper around `OnAudioQuery` — scans the device's MediaStore for
/// audio files and fetches embedded artwork, gated behind the runtime
/// `READ_MEDIA_AUDIO` (Android 13+) / storage permission.
///
/// `Permission.audio` already maps to the right platform permission for every
/// supported Android version (granular media permission on 13+, legacy
/// storage read on older releases) — the same pattern the manifest already
/// layers by `maxSdkVersion`.
class DeviceLibraryService {
  DeviceLibraryService() : _query = OnAudioQuery();

  final OnAudioQuery _query;

  Future<PermissionStatus> permissionStatus() => Permission.audio.status;

  Future<PermissionStatus> requestPermission() => Permission.audio.request();

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
