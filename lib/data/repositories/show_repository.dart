import '../../core/network/api_client.dart';
import '../models/cast_member.dart';
import '../models/episode.dart';
import '../models/show.dart';

/// The only place the BLoCs get TV show data from.
///
/// Calls [ApiClient] and converts the raw JSON into models,
/// so no other part of the app deals with JSON or URLs.
class ShowRepository {
  ShowRepository(this._api);

  final ApiClient _api;

  /// One page of shows (TVMaze returns up to 250 per page).
  /// Returns an empty list when the page doesn't exist,
  /// which means there are no more shows to load.
  Future<List<Show>> getShows(int page) async {
    try {
      final data = await _api.get('/shows', {'page': '$page'}) as List;
      return data.map((json) => Show.fromJson(json as Map<String, dynamic>)).toList();
    } on ApiException catch (e) {
      if (e.statusCode == 404) return []; // TVMaze answers 404 after the last page
      rethrow;
    }
  }

  Future<List<Show>> searchShows(String query) async {
    final data = await _api.get('/search/shows', {'q': query}) as List;
    // Each result looks like {"score": 0.9, "show": {...}}.
    return data
        .map((result) => Show.fromJson((result as Map<String, dynamic>)['show'] as Map<String, dynamic>))
        .toList();
  }

  Future<Show> getShowDetails(int showId) async {
    final data = await _api.get('/shows/$showId') as Map<String, dynamic>;
    return Show.fromJson(data);
  }

  Future<List<CastMember>> getCast(int showId) async {
    final data = await _api.get('/shows/$showId/cast') as List;
    return data.map((json) => CastMember.fromJson(json as Map<String, dynamic>)).toList();
  }

  Future<List<Episode>> getEpisodes(int showId) async {
    final data = await _api.get('/shows/$showId/episodes') as List;
    return data.map((json) => Episode.fromJson(json as Map<String, dynamic>)).toList();
  }
}
