import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/network/api_client.dart';
import '../../data/models/show.dart';
import '../../data/repositories/show_repository.dart';

part 'shows_event.dart';
part 'shows_state.dart';

/// Loads the home screen show list, one page at a time (pagination).
class ShowsBloc extends Bloc<ShowsEvent, ShowsState> {
  ShowsBloc(this._repository) : super(const ShowsState()) {
    // droppable(): while a page is loading, extra ShowsFetched events
    // (fired again and again while the user scrolls) are ignored.
    on<ShowsFetched>(_onFetched, transformer: droppable());
  }

  final ShowRepository _repository;

  Future<void> _onFetched(ShowsFetched event, Emitter<ShowsState> emit) async {
    if (state.hasReachedMax) return;

    emit(state.copyWith(status: ShowsStatus.loading));
    try {
      final shows = await _repository.getShows(state.nextPage);
      emit(state.copyWith(
        status: ShowsStatus.success,
        shows: [...state.shows, ...shows],
        nextPage: state.nextPage + 1,
        hasReachedMax: shows.isEmpty,
      ));
    } catch (error) {
      emit(state.copyWith(
        status: ShowsStatus.failure,
        errorMessage: ApiException.messageOf(error),
      ));
    }
  }
}
