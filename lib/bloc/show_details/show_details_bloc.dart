import 'dart:collection';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/network/api_client.dart';
import '../../data/models/cast_member.dart';
import '../../data/models/episode.dart';
import '../../data/models/show.dart';
import '../../data/repositories/show_repository.dart';

part 'show_details_event.dart';
part 'show_details_state.dart';

/// Loads everything the details screen needs: show info, cast and episodes.
/// A new instance is created for every details screen that is opened.
class ShowDetailsBloc extends Bloc<ShowDetailsEvent, ShowDetailsState> {
  ShowDetailsBloc(this._repository) : super(const ShowDetailsLoading()) {
    on<ShowDetailsRequested>(_onRequested);
  }

  final ShowRepository _repository;

  Future<void> _onRequested(ShowDetailsRequested event, Emitter<ShowDetailsState> emit) async {
    emit(const ShowDetailsLoading());
    try {
      // The three requests don't depend on each other, so run them in parallel.
      final results = await Future.wait([
        _repository.getShowDetails(event.showId),
        _repository.getCast(event.showId),
        _repository.getEpisodes(event.showId),
      ]);
      emit(ShowDetailsLoaded(
        show: results[0] as Show,
        cast: results[1] as List<CastMember>,
        seasons: groupBySeason(results[2] as List<Episode>),
      ));
    } catch (error) {
      emit(ShowDetailsFailure(ApiException.messageOf(error)));
    }
  }

  /// Groups episodes by season number, with seasons in ascending order.
  static Map<int, List<Episode>> groupBySeason(List<Episode> episodes) {
    final seasons = SplayTreeMap<int, List<Episode>>();
    for (final episode in episodes) {
      seasons.putIfAbsent(episode.season, () => []).add(episode);
    }
    return seasons;
  }
}
