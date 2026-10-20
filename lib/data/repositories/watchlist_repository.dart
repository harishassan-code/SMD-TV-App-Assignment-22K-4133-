import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/show.dart';

/// Saves the watchlist on the device with SharedPreferences,
/// so it is still there after the app restarts.
class WatchlistRepository {
  WatchlistRepository(this._prefs);

  static const _key = 'watchlist';

  final SharedPreferences _prefs;

  List<Show> load() {
    final raw = _prefs.getString(_key);
    if (raw == null) return [];
    try {
      final list = jsonDecode(raw) as List;
      return list.map((json) => Show.fromJson(json as Map<String, dynamic>)).toList();
    } catch (_) {
      return []; // Corrupted data: start with an empty watchlist instead of crashing.
    }
  }

  Future<void> save(List<Show> shows) async {
    final raw = jsonEncode(shows.map((show) => show.toJson()).toList());
    final saved = await _prefs.setString(_key, raw);
    if (!saved) throw Exception('Could not save the watchlist.');
  }
}
