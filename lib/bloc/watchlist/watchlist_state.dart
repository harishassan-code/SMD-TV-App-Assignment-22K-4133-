part of 'watchlist_bloc.dart';

final class WatchlistState extends Equatable {
  const WatchlistState({
    this.shows = const [],
    this.isLoading = true,
    this.errorMessage,
  });

  final List<Show> shows;
  final bool isLoading;
  final String? errorMessage; // shown once as a SnackBar

  bool get isEmpty => shows.isEmpty;

  bool contains(int showId) => shows.any((show) => show.id == showId);

  WatchlistState copyWith({List<Show>? shows, String? errorMessage}) {
    return WatchlistState(
      shows: shows ?? this.shows,
      isLoading: false,
      errorMessage: errorMessage, // cleared unless a new error is given
    );
  }

  @override
  List<Object?> get props => [shows, isLoading, errorMessage];
}
