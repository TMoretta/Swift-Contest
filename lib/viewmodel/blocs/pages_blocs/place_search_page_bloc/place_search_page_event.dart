part of 'place_search_page_bloc.dart';

sealed class PlaceSearchPageEvent extends Equatable {
  const PlaceSearchPageEvent();
}

final class PlaceSearchPageSearchPlaceSuggestions extends PlaceSearchPageEvent {
  final String query;

  const PlaceSearchPageSearchPlaceSuggestions({required this.query});

  @override
  List<Object?> get props => [query];
}

final class PlaceSearchPageFetchPlace extends PlaceSearchPageEvent {
  final String id;

  const PlaceSearchPageFetchPlace({required this.id});

  @override
  List<Object?> get props => [id];
}
