part of 'search_bloc.dart';

/// One class per state. Being `sealed`, the UI can `switch` over them
/// and the compiler checks that every state is handled.
sealed class SearchState extends Equatable {
  const SearchState();

  @override
  List<Object?> get props => [];
}

/// Nothing typed yet.
final class SearchInitial extends SearchState {
  const SearchInitial();
}

final class SearchLoading extends SearchState {
  const SearchLoading();
}

final class SearchSuccess extends SearchState {
  const SearchSuccess(this.shows);

  final List<Show> shows;

  @override
  List<Object?> get props => [shows];
}

/// The search worked but found no shows.
final class SearchEmpty extends SearchState {
  const SearchEmpty(this.query);

  final String query;

  @override
  List<Object?> get props => [query];
}

final class SearchFailure extends SearchState {
  const SearchFailure(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}
