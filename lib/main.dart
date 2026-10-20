import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app.dart';
import 'core/network/api_client.dart';
import 'data/repositories/show_repository.dart';
import 'data/repositories/watchlist_repository.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();

  runApp(
    TvMazeApp(
      showRepository: ShowRepository(ApiClient()),
      watchlistRepository: WatchlistRepository(prefs),
    ),
  );
}
