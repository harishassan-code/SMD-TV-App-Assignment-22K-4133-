part of 'show_details_bloc.dart';

sealed class ShowDetailsState extends Equatable {
  const ShowDetailsState();

  @override
  List<Object?> get props => [];
}

final class ShowDetailsLoading extends ShowDetailsState {
  const ShowDetailsLoading();
}

final class ShowDetailsLoaded extends ShowDetailsState {
  const ShowDetailsLoaded({
    required this.show,
    required this.cast,
    required this.seasons,
  });

  final Show show;
  final List<CastMember> cast;

  /// Season number -> episodes of that season.
  final Map<int, List<Episode>> seasons;

  @override
  List<Object?> get props => [show, cast, seasons];
}

final class ShowDetailsFailure extends ShowDetailsState {
  const ShowDetailsFailure(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}
