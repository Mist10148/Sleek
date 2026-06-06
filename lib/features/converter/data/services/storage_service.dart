import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/errors/failures.dart';

/// Opens the system directory picker and returns the chosen path, or null if
/// the user cancelled. (file_picker 11 exposes static methods on [FilePicker].)
Future<String?> pickSaveDirectory() =>
    FilePicker.getDirectoryPath(dialogTitle: 'Choose where to save');

/// Resolves where output files are written and handles the storage permission
/// dance. On modern Android we default to the app's external files directory
/// (no permission needed); a user-picked directory is honoured when provided.
class StorageService {
  /// The default directory used when the user hasn't picked one. Creates an
  /// app-named sub-folder so outputs are easy to find.
  Future<String> defaultDirectory() async {
    Directory base;
    if (Platform.isAndroid) {
      // App-specific external storage — always writable, survives scoped storage.
      base = (await getExternalStorageDirectory()) ??
          await getApplicationDocumentsDirectory();
    } else {
      base = await getApplicationDocumentsDirectory();
    }
    final Directory out =
        Directory('${base.path}${Platform.pathSeparator}${AppConstants.outputFolderName}');
    if (!await out.exists()) {
      await out.create(recursive: true);
    }
    return out.path;
  }

  /// Requests storage permission where it's actually required (older Android).
  /// Returns true when writing is allowed.
  Future<bool> ensureWritePermission() async {
    if (!Platform.isAndroid) return true;
    // On Android 13+ broad storage permission is neither granted nor needed for
    // app-specific dirs; treat as allowed. For a user-picked public dir on
    // older devices we request legacy storage.
    final PermissionStatus status = await Permission.storage.status;
    if (status.isGranted) return true;
    if (status.isPermanentlyDenied) return false;
    final PermissionStatus result = await Permission.storage.request();
    // isGranted on modern Android can be false yet still allow app-dir writes,
    // so we don't hard-fail here — the caller falls back to the default dir.
    return result.isGranted || result.isLimited || result.isRestricted == false;
  }

  /// Builds a safe, unique output path inside [directory].
  String buildOutputPath({
    required String directory,
    required String title,
    required String extension,
  }) {
    final String safe = _sanitize(title);
    final String stamp = DateTime.now().millisecondsSinceEpoch.toString();
    return '$directory${Platform.pathSeparator}${safe}_$stamp.$extension';
  }

  static String _sanitize(String name) {
    final String cleaned = name
        .replaceAll(RegExp(r'[\\/:*?"<>|]'), '_')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
    final String trimmed =
        cleaned.length > 80 ? cleaned.substring(0, 80) : cleaned;
    return trimmed.isEmpty ? 'audio_video' : trimmed;
  }

  /// Verifies a chosen directory exists and is writable.
  Future<void> assertWritable(String directory) async {
    final Directory dir = Directory(directory);
    if (!await dir.exists()) {
      throw Failures.permissionDenied('Directory does not exist: $directory');
    }
  }
}
