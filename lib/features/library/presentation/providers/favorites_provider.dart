import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

const String _kFavoritesKey = 'library_favorites';

/// The set of favourited track ids — persisted via `SharedPreferences`,
/// following the same "seed synchronously, hydrate from disk in a microtask"
/// shape as [HistoryNotifier] / `ThemeModeNotifier`.
class FavoritesNotifier extends Notifier<Set<String>> {
  @override
  Set<String> build() {
    Future.microtask(_loadFromPrefs);
    return const <String>{};
  }

  Future<void> _loadFromPrefs() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final List<String>? stored = prefs.getStringList(_kFavoritesKey);
    if (stored != null) state = stored.toSet();
  }

  Future<void> toggle(String trackId) async {
    final Set<String> next = Set<String>.from(state);
    if (!next.remove(trackId)) next.add(trackId);
    state = next;
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_kFavoritesKey, next.toList(growable: false));
  }

  bool isFavorite(String trackId) => state.contains(trackId);
}

final favoritesProvider = NotifierProvider<FavoritesNotifier, Set<String>>(FavoritesNotifier.new);
