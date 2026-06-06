import 'package:flutter_test/flutter_test.dart';
import 'package:yt_to_mp3/core/utils/formatters.dart';

void main() {
  group('Formatters.fileSize', () {
    test('formats bytes through gigabytes', () {
      expect(Formatters.fileSize(0), '0 B');
      expect(Formatters.fileSize(512), '512 B');
      expect(Formatters.fileSize(1024), '1.0 KB');
      expect(Formatters.fileSize(1024 * 1024), '1.0 MB');
      expect(Formatters.fileSize(1024 * 1024 * 1024), '1.0 GB');
    });
  });

  group('Formatters.duration', () {
    test('formats minutes and hours', () {
      expect(Formatters.duration(const Duration(seconds: 7)), '0:07');
      expect(Formatters.duration(const Duration(minutes: 3, seconds: 7)), '3:07');
      expect(
        Formatters.duration(const Duration(hours: 1, minutes: 2, seconds: 33)),
        '1:02:33',
      );
    });
  });

  group('Formatters.percent', () {
    test('clamps and rounds', () {
      expect(Formatters.percent(0), '0%');
      expect(Formatters.percent(0.731), '73%');
      expect(Formatters.percent(1.5), '100%');
    });
  });

  group('Formatters.eta', () {
    test('returns placeholder when nothing transferred', () {
      expect(
        Formatters.eta(received: 0, total: 100, elapsed: Duration.zero),
        '—',
      );
    });

    test('estimates remaining time from rate', () {
      // 50 of 100 bytes in 1s → ~1s remaining.
      final eta = Formatters.eta(
        received: 50,
        total: 100,
        elapsed: const Duration(seconds: 1),
      );
      expect(eta, '0:01');
    });
  });
}
