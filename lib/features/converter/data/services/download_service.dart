import 'dart:io';

import '../../../../core/errors/failures.dart';
import '../models/download_task.dart';

/// Streams bytes from a source [Stream] to a file on disk, emitting
/// [DownloadProgress] as it goes. Pure I/O — it knows nothing about YouTube,
/// which keeps it easy to test with a synthetic byte stream.
class DownloadService {
  /// Writes [source] (whose total size is [totalBytes]) to [outputPath],
  /// invoking [onProgress] periodically. Returns the final file size.
  Future<int> download({
    required Stream<List<int>> source,
    required int totalBytes,
    required String outputPath,
    required void Function(DownloadProgress progress) onProgress,
  }) async {
    final File file = File(outputPath);
    await file.parent.create(recursive: true);
    final IOSink sink = file.openWrite();
    final Stopwatch stopwatch = Stopwatch()..start();

    int received = 0;
    DateTime lastEmit = DateTime.fromMillisecondsSinceEpoch(0);

    try {
      await for (final List<int> chunk in source) {
        sink.add(chunk);
        received += chunk.length;

        // Throttle UI updates to ~15/sec to avoid rebuild spam.
        final DateTime now = DateTime.now();
        if (now.difference(lastEmit).inMilliseconds >= 66) {
          lastEmit = now;
          onProgress(DownloadProgress(
            receivedBytes: received,
            totalBytes: totalBytes,
            elapsed: stopwatch.elapsed,
          ));
        }
      }
      await sink.flush();
      await sink.close();

      // Final 100% emit.
      onProgress(DownloadProgress(
        receivedBytes: received,
        totalBytes: totalBytes <= 0 ? received : totalBytes,
        elapsed: stopwatch.elapsed,
      ));
      return received;
    } catch (e) {
      await sink.close();
      // Clean up the partial file so we don't leave junk behind.
      if (await file.exists()) {
        await file.delete();
      }
      throw Failures.network(e);
    }
  }
}
