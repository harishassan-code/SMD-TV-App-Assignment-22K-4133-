part of 'show_details_bloc.dart';

sealed class ShowDetailsEvent extends Equatable {
  const ShowDetailsEvent();

  @override
  List<Object?> get props => [];
}

/// Load (or reload, after an error) the details of a show.
final class ShowDetailsRequested extends ShowDetailsEvent {
  const ShowDetailsRequested(this.showId);

  final int showId;

  @override
  List<Object?> get props => [showId];
}
