import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:stream_transform/stream_transform.dart';

import '../../core/network/api_client.dart';
import '../../data/models/show.dart';
import '../../data/repositories/show_repository.dart';

part 'search_event.dart';
part 'search_state.dart';

const _debounceDuration = Duration(milliseconds: 500);

/// debounce: wait until the user stops typing for [duration] before searching.
/// switchMap: if a new query arrives, cancel the search that is still running,
/// so old results never replace newer ones.
EventTransformer<E> debounceRestartable<E>(Duration duration) {
  return (events, mapper) => events.debounce(duration).switchMap(mapper);
}

/// Searches shows by name as the user types.
class SearchBloc extends Bloc<SearchEvent, SearchState> {
  SearchBloc(this._repository) : super(const SearchInitial()) {
    on<SearchQueryChanged>(
      _onQueryChanged,
      transformer: debounceRestartable(_debounceDuration),
    );
  }

  final ShowRepository _repository;

  Future<void> _onQueryChanged(SearchQueryChanged event, Emitter<SearchState> emit) async {
    final query = event.query.trim();
    if (query.isEmpty) {
      emit(const SearchInitial());
      return;
    }

    emit(const SearchLoading());
    try {
      final shows = await _repository.searchShows(query);
      emit(shows.isEmpty ? SearchEmpty(query) : SearchSuccess(shows));
    } catch (error) {
      emit(SearchFailure(ApiException.messageOf(error)));
    }
  }
}
