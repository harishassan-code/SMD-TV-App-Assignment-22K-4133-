import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tvmaze_app/bloc/shows/shows_bloc.dart';
import 'package:tvmaze_app/core/network/api_client.dart';
import 'package:tvmaze_app/data/models/show.dart';
import 'package:tvmaze_app/data/repositories/show_repository.dart';

class MockShowRepository extends Mock implements ShowRepository {}

void main() {
  late MockShowRepository repository;

  const page0 = [Show(id: 1, name: 'A'), Show(id: 2, name: 'B')];
  const page1 = [Show(id: 3, name: 'C')];

  setUp(() => repository = MockShowRepository());

  blocTest<ShowsBloc, ShowsState>(
    'loads the first page',
    setUp: () => when(() => repository.getShows(0)).thenAnswer((_) async => page0),
    build: () => ShowsBloc(repository),
    act: (bloc) => bloc.add(const ShowsFetched()),
    expect: () => const [
      ShowsState(status: ShowsStatus.loading),
      ShowsState(status: ShowsStatus.success, shows: page0, nextPage: 1),
    ],
  );

  blocTest<ShowsBloc, ShowsState>(
    'appends the next page to the shows already loaded',
    setUp: () => when(() => repository.getShows(1)).thenAnswer((_) async => page1),
    build: () => ShowsBloc(repository),
    seed: () => const ShowsState(status: ShowsStatus.success, shows: page0, nextPage: 1),
    act: (bloc) => bloc.add(const ShowsFetched()),
    expect: () => const [
      ShowsState(status: ShowsStatus.loading, shows: page0, nextPage: 1),
      ShowsState(status: ShowsStatus.success, shows: [...page0, ...page1], nextPage: 2),
    ],
  );

  blocTest<ShowsBloc, ShowsState>(
    'stops paginating when a page is empty',
    setUp: () => when(() => repository.getShows(1)).thenAnswer((_) async => []),
    build: () => ShowsBloc(repository),
    seed: () => const ShowsState(status: ShowsStatus.success, shows: page0, nextPage: 1),
    act: (bloc) => bloc
      ..add(const ShowsFetched())
      ..add(const ShowsFetched()), // dropped: a page is already loading
    expect: () => const [
      ShowsState(status: ShowsStatus.loading, shows: page0, nextPage: 1),
      ShowsState(status: ShowsStatus.success, shows: page0, nextPage: 2, hasReachedMax: true),
    ],
    verify: (_) => verify(() => repository.getShows(1)).called(1),
  );

  blocTest<ShowsBloc, ShowsState>(
    'emits failure with a readable message when the request fails',
    setUp: () => when(() => repository.getShows(0))
        .thenThrow(const ApiException('No internet connection.')),
    build: () => ShowsBloc(repository),
    act: (bloc) => bloc.add(const ShowsFetched()),
    expect: () => const [
      ShowsState(status: ShowsStatus.loading),
      ShowsState(status: ShowsStatus.failure, errorMessage: 'No internet connection.'),
    ],
  );

  test('topRated sorts by rating and skips unrated shows', () {
    const state = ShowsState(shows: [
      Show(id: 1, name: 'Low', rating: 5),
      Show(id: 2, name: 'None'),
      Show(id: 3, name: 'High', rating: 9),
    ]);

    expect(state.topRated.map((s) => s.name), ['High', 'Low']);
  });
}
