/// Validation helpers for user input.
class Validators {
  Validators._();

  /// Matches the common YouTube URL shapes:
  ///   - https://www.youtube.com/watch?v=ID
  ///   - https://youtu.be/ID
  ///   - https://m.youtube.com/watch?v=ID
  ///   - https://www.youtube.com/shorts/ID
  ///   - https://www.youtube.com/embed/ID
  static final RegExp _youtubeRegExp = RegExp(
    r'^(https?://)?(www\.|m\.)?(youtube\.com/(watch\?v=|shorts/|embed/|live/)|youtu\.be/)[\w-]{11}',
    caseSensitive: false,
  );

  static bool isValidYoutubeUrl(String input) {
    final String trimmed = input.trim();
    if (trimmed.isEmpty) return false;
    return _youtubeRegExp.hasMatch(trimmed);
  }

  /// Returns an error message for a text field, or null if valid.
  static String? youtubeUrlError(String? input) {
    if (input == null || input.trim().isEmpty) {
      return 'Paste a YouTube link to begin';
    }
    if (!isValidYoutubeUrl(input)) {
      return 'That doesn\'t look like a YouTube link';
    }
    return null;
  }
}
