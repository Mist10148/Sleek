import 'package:flutter_test/flutter_test.dart';
import 'package:yt_to_mp3/features/converter/domain/entities/media_format.dart';

void main() {
  group('audioQualitiesFor', () {
    test('produces the four design tiers', () {
      final List<QualityOption> q = audioQualitiesFor(60);
      expect(q.map((QualityOption o) => o.q).toList(),
          <String>['320', '256', '192', '128']);
      expect(q.every((QualityOption o) => o.meta == 'kbps'), isTrue);
    });

    test('estimates size from bitrate × duration', () {
      final List<QualityOption> q = audioQualitiesFor(60);
      // 320 kbps for 60s ≈ 320_000/8 * 60 = 2_400_000 bytes.
      expect(q.first.estimatedBytes, (320 * 1000 ~/ 8) * 60);
      // Higher bitrate ⇒ larger estimate.
      expect(q.first.estimatedBytes! > q.last.estimatedBytes!, isTrue);
    });

    test('zero duration yields zero-byte estimates', () {
      final List<QualityOption> q = audioQualitiesFor(0);
      expect(q.every((QualityOption o) => o.estimatedBytes == 0), isTrue);
    });
  });

  group('MediaFormat', () {
    test('extensions and audio flag', () {
      expect(MediaFormat.mp3.fileExtension, 'mp3');
      expect(MediaFormat.mp4.fileExtension, 'mp4');
      expect(MediaFormat.mp3.isAudio, isTrue);
      expect(MediaFormat.mp4.isAudio, isFalse);
    });
  });
}
