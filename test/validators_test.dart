import 'package:flutter_test/flutter_test.dart';
import 'package:yt_to_mp3/core/utils/validators.dart';

void main() {
  group('Validators.isValidYoutubeUrl', () {
    test('accepts common YouTube URL shapes', () {
      const valid = <String>[
        'https://www.youtube.com/watch?v=dQw4w9WgXcQ',
        'https://youtu.be/dQw4w9WgXcQ',
        'https://m.youtube.com/watch?v=dQw4w9WgXcQ',
        'https://www.youtube.com/shorts/dQw4w9WgXcQ',
        'https://www.youtube.com/embed/dQw4w9WgXcQ',
        'youtube.com/watch?v=dQw4w9WgXcQ',
      ];
      for (final url in valid) {
        expect(Validators.isValidYoutubeUrl(url), isTrue, reason: url);
      }
    });

    test('rejects non-YouTube / malformed URLs', () {
      const invalid = <String>[
        '',
        'not a url',
        'https://vimeo.com/123456',
        'https://www.youtube.com/watch?v=short', // id too short
        'https://example.com/watch?v=dQw4w9WgXcQ',
      ];
      for (final url in invalid) {
        expect(Validators.isValidYoutubeUrl(url), isFalse, reason: url);
      }
    });

    test('youtubeUrlError returns null only when valid', () {
      expect(Validators.youtubeUrlError(''), isNotNull);
      expect(Validators.youtubeUrlError('garbage'), isNotNull);
      expect(
        Validators.youtubeUrlError('https://youtu.be/dQw4w9WgXcQ'),
        isNull,
      );
    });
  });
}
