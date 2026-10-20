import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tvmaze_app/bloc/show_details/show_details_bloc.dart';
import 'package:tvmaze_app/core/network/api_client.dart';
import 'package:tvmaze_app/data/models/cast_member.dart';
import 'package:tvmaze_app/data/models/episode.dart';
import 'package:tvmaze_app/data/models/show.dart';
import 'package:tvmaze_app/data/repositories/show_repository.dart';

class MockShowRepository extends Mock implements ShowRepository {}

void main() {
  late MockShowRepository repository;

  const show = Show(id: 169, name: 'Breaking Bad');
  const cast = [CastMember(personId: 1, name: 'Bryan Cranston', character: 'Walter White')];
  const s1e1 = Episode(id: 1, name: 'Pilot', season: 1, number: 1);
  const s1e2 = Episode(id: 2, name: "Cat's in the Bag...", season: 1, number: 2);
  const s2e1 = Episode(id: 3, name: 'Seven Thirty-Seven', season: 2, number: 1);

  setUp(() {
    repository = MockShowRepository();
    when(() => repository.getShowDetails(169)).thenAnswer((_) async => show);
    when(() => repository.getCast(169)).thenAnswer((_) async => cast);
  });

  blocTest<ShowDetailsBloc, ShowDetailsState>(
    'loads details, cast and episodes grouped by season',
    setUp: () => when(() => repository.getEpisodes(169)).thenAnswer((_) async => [s2e1, s1e1, s1e2]),
    build: () => ShowDetailsBloc(repository),
    act: (bloc) => bloc.add(const ShowDetailsRequested(169)),
    expect: () => const [
      ShowDetailsLoading(),
      ShowDetailsLoaded(show: show, cast: cast, seasons: {1: [s1e1, s1e2], 2: [s2e1]}),
    ],
  );

  blocTest<ShowDetailsBloc, ShowDetailsState>(
    'emits failure if any request fails',
    setUp: () => when(() => repository.getEpisodes(169)).thenThrow(const ApiException('Not found.')),
    build: () => ShowDetailsBloc(repository),
    act: (bloc) => bloc.add(const ShowDetailsRequested(169)),
    expect: () => const [ShowDetailsLoading(), ShowDetailsFailure('Not found.')],
  );

  test('groupBySeason keeps seasons in ascending order', () {
    final seasons = ShowDetailsBloc.groupBySeason(const [s2e1, s1e1]);
    expect(seasons.keys, [1, 2]);
  });
}
