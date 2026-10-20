part of 'shows_bloc.dart';

enum ShowsStatus { initial, loading, success, failure }

/// One state class with a [status] field, because the list must keep the
/// shows already loaded while the next page is loading or has failed.
final class ShowsState extends Equatable {
  const ShowsState({
    this.status = ShowsStatus.initial,
    this.shows = const [],
    this.nextPage = 0,
    this.hasReachedMax = false,
    this.errorMessage,
  });

  final ShowsStatus status;
  final List<Show> shows;
  final int nextPage;
  final bool hasReachedMax; // true when the API has no more pages
  final String? errorMessage;

  /// The 10 highest rated shows loaded so far, for the "Top Rated" row.
  List<Show> get topRated {
    final rated = shows.where((show) => show.rating != null).toList()
      ..sort((a, b) => b.rating!.compareTo(a.rating!));
    return rated.take(10).toList();
  }

  ShowsState copyWith({
    ShowsStatus? status,
    List<Show>? shows,
    int? nextPage,
    bool? hasReachedMax,
    String? errorMessage,
  }) {
    return ShowsState(
      status: status ?? this.status,
      shows: shows ?? this.shows,
      nextPage: nextPage ?? this.nextPage,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
      errorMessage: errorMessage, // cleared unless a new error is given
    );
  }

  @override
  List<Object?> get props => [status, shows, nextPage, hasReachedMax, errorMessage];
}
