part of 'watchlist_bloc.dart';

sealed class WatchlistEvent extends Equatable {
  const WatchlistEvent();

  @override
  List<Object?> get props => [];
}

/// Load the saved watchlist when the app starts.
final class WatchlistStarted extends WatchlistEvent {
  const WatchlistStarted();
}

/// Add the show if it is not saved yet, otherwise remove it.
final class WatchlistShowToggled extends WatchlistEvent {
  const WatchlistShowToggled(this.show);

  final Show show;

  @override
  List<Object?> get props => [show];
}

/// Remove every show from the watchlist.
final class WatchlistCleared extends WatchlistEvent {
  const WatchlistCleared();
}
