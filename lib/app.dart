import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'bloc/search/search_bloc.dart';
import 'bloc/shows/shows_bloc.dart';
import 'bloc/watchlist/watchlist_bloc.dart';
import 'core/theme/app_theme.dart';
import 'data/repositories/show_repository.dart';
import 'data/repositories/watchlist_repository.dart';
import 'ui/screens/main_shell.dart';

final _messengerKey = GlobalKey<ScaffoldMessengerState>();

/// Provides the repository and the app-wide BLoCs to every screen.
class TvMazeApp extends StatelessWidget {
  const TvMazeApp({
    super.key,
    required this.showRepository,
    required this.watchlistRepository,
  });

  final ShowRepository showRepository;
  final WatchlistRepository watchlistRepository;

  @override
  Widget build(BuildContext context) {
    return RepositoryProvider.value(
      value: showRepository,
      child: MultiBlocProvider(
        providers: [
          BlocProvider(create: (_) => ShowsBloc(showRepository)..add(const ShowsFetched())),
          BlocProvider(create: (_) => SearchBloc(showRepository)),
          BlocProvider(create: (_) => WatchlistBloc(watchlistRepository)..add(const WatchlistStarted())),
        ],
        // Shows watchlist save errors from any screen.
        child: BlocListener<WatchlistBloc, WatchlistState>(
          listenWhen: (previous, current) => current.errorMessage != null,
          listener: (context, state) => _messengerKey.currentState
              ?.showSnackBar(SnackBar(content: Text(state.errorMessage!))),
          child: MaterialApp(
            title: 'TVMaze',
            debugShowCheckedModeBanner: false,
            scaffoldMessengerKey: _messengerKey,
            theme: AppTheme.dark,
            home: const MainShell(),
          ),
        ),
      ),
    );
  }
}
