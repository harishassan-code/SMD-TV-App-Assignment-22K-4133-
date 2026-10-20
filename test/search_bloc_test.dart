import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tvmaze_app/bloc/search/search_bloc.dart';
import 'package:tvmaze_app/core/network/api_client.dart';
import 'package:tvmaze_app/data/models/show.dart';
import 'package:tvmaze_app/data/repositories/show_repository.dart';

class MockShowRepository extends Mock implements ShowRepository {}

void main() {
  late MockShowRepository repository;

  const results = [Show(id: 169, name: 'Breaking Bad')];
  const debounceWait = Duration(milliseconds: 600);

  setUp(() => repository = MockShowRepository());

  blocTest<SearchBloc, SearchState>(
    'debounces typing and only searches for the last query',
    setUp: () => when(() => repository.searchShows(any())).thenAnswer((_) async => results),
    build: () => SearchBloc(repository),
    act: (bloc) => bloc
      ..add(const SearchQueryChanged('b'))
      ..add(const SearchQueryChanged('brea'))
      ..add(const SearchQueryChanged('breaking')),
    wait: debounceWait,
    expect: () => const [SearchLoading(), SearchSuccess(results)],
    verify: (_) {
      verify(() => repository.searchShows('breaking')).called(1);
      verifyNoMoreInteractions(repository);
    },
  );

  blocTest<SearchBloc, SearchState>(
    'emits SearchEmpty when nothing matches',
    setUp: () => when(() => repository.searchShows('zzzz')).thenAnswer((_) async => []),
    build: () => SearchBloc(repository),
    act: (bloc) => bloc.add(const SearchQueryChanged('zzzz')),
    wait: debounceWait,
    expect: () => const [SearchLoading(), SearchEmpty('zzzz')],
  );

  blocTest<SearchBloc, SearchState>(
    'goes back to the initial state when the query is cleared',
    build: () => SearchBloc(repository),
    seed: () => const SearchSuccess(results),
    act: (bloc) => bloc.add(const SearchQueryChanged('   ')),
    wait: debounceWait,
    expect: () => const [SearchInitial()],
    verify: (_) => verifyZeroInteractions(repository),
  );

  blocTest<SearchBloc, SearchState>(
    'emits SearchFailure when the API fails',
    setUp: () => when(() => repository.searchShows('dark'))
        .thenThrow(const ApiException('Server error (500). Please try again later.')),
    build: () => SearchBloc(repository),
    act: (bloc) => bloc.add(const SearchQueryChanged('dark')),
    wait: debounceWait,
    expect: () => const [
      SearchLoading(),
      SearchFailure('Server error (500). Please try again later.'),
    ],
  );
}
