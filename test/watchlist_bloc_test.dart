import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tvmaze_app/bloc/watchlist/watchlist_bloc.dart';
import 'package:tvmaze_app/data/models/show.dart';
import 'package:tvmaze_app/data/repositories/watchlist_repository.dart';

void main() {
  const breakingBad = Show(id: 169, name: 'Breaking Bad', genres: ['Drama'], rating: 9.2);
  const dark = Show(id: 17861, name: 'Dark');

  late WatchlistRepository repository;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    repository = WatchlistRepository(await SharedPreferences.getInstance());
  });

  blocTest<WatchlistBloc, WatchlistState>(
    'toggling adds a show (newest first) and toggling again removes it',
    build: () => WatchlistBloc(repository),
    act: (bloc) => bloc
      ..add(const WatchlistStarted())
      ..add(const WatchlistShowToggled(breakingBad))
      ..add(const WatchlistShowToggled(dark))
      ..add(const WatchlistShowToggled(breakingBad)),
    expect: () => const [
      WatchlistState(isLoading: false),
      WatchlistState(shows: [breakingBad], isLoading: false),
      WatchlistState(shows: [dark, breakingBad], isLoading: false),
      WatchlistState(shows: [dark], isLoading: false),
    ],
    verify: (_) => expect(repository.load(), [dark]),
  );

  test('the saved watchlist survives an app restart', () async {
    final firstRun = WatchlistBloc(repository)
      ..add(const WatchlistStarted())
      ..add(const WatchlistShowToggled(breakingBad));
    await Future<void>.delayed(Duration.zero);
    await firstRun.close();

    // A new BLoC + repository, like after restarting the app.
    final secondRun = WatchlistBloc(WatchlistRepository(await SharedPreferences.getInstance()))
      ..add(const WatchlistStarted());
    await Future<void>.delayed(Duration.zero);

    expect(secondRun.state.shows, [breakingBad]);
    expect(secondRun.state.shows.single.rating, 9.2);
    await secondRun.close();
  });

  blocTest<WatchlistBloc, WatchlistState>(
    'clearing removes every show',
    build: () => WatchlistBloc(repository),
    seed: () => const WatchlistState(shows: [breakingBad, dark], isLoading: false),
    act: (bloc) => bloc.add(const WatchlistCleared()),
    expect: () => const [WatchlistState(isLoading: false)],
    verify: (_) => expect(repository.load(), isEmpty),
  );

  test('corrupted saved data gives an empty watchlist instead of a crash', () async {
    SharedPreferences.setMockInitialValues({'watchlist': 'not json'});
    final corrupted = WatchlistRepository(await SharedPreferences.getInstance());
    expect(corrupted.load(), isEmpty);
  });
}
