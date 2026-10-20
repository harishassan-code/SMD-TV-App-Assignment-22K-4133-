part of 'shows_bloc.dart';

sealed class ShowsEvent extends Equatable {
  const ShowsEvent();

  @override
  List<Object?> get props => [];
}

/// Load the next page of shows. Sent on start, when the user scrolls
/// near the bottom of the list, and when they tap "Retry".
final class ShowsFetched extends ShowsEvent {
  const ShowsFetched();
}
