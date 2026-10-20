import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/models/show.dart';
import '../../data/repositories/watchlist_repository.dart';

part 'watchlist_event.dart';
part 'watchlist_state.dart';

/// Keeps the list of saved shows and stores every change on the device.
/// One instance is shared by the whole app, so every screen sees the same list.
class WatchlistBloc extends Bloc<WatchlistEvent, WatchlistState> {
  WatchlistBloc(this._repository) : super(const WatchlistState()) {
    on<WatchlistStarted>(_onStarted);
    // sequential(): handle one change at a time, so two quick taps
    // can't save the list out of order.
    on<WatchlistShowToggled>(_onToggled, transformer: sequential());
    on<WatchlistCleared>(_onCleared, transformer: sequential());
  }

  final WatchlistRepository _repository;

  void _onStarted(WatchlistStarted event, Emitter<WatchlistState> emit) {
    emit(WatchlistState(shows: _repository.load(), isLoading: false));
  }

  Future<void> _onToggled(WatchlistShowToggled event, Emitter<WatchlistState> emit) {
    final shows = state.contains(event.show.id)
        ? state.shows.where((show) => show.id != event.show.id).toList()
        : [event.show, ...state.shows]; // newest first
    return _update(shows, emit);
  }

  Future<void> _onCleared(WatchlistCleared event, Emitter<WatchlistState> emit) {
    return _update(const [], emit);
  }

  /// Shows the change right away, then saves it.
  /// If saving fails, the old list comes back and an error is shown.
  Future<void> _update(List<Show> shows, Emitter<WatchlistState> emit) async {
    final previous = state.shows;
    emit(state.copyWith(shows: shows));
    try {
      await _repository.save(shows);
    } catch (_) {
      emit(state.copyWith(
        shows: previous,
        errorMessage: 'Could not update your watchlist. Please try again.',
      ));
    }
  }
}
