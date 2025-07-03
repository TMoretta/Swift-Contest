part of 'place_search_page_bloc.dart';

@immutable
final class PlaceSearchPageState extends Equatable {
  final BlocStatus status;
  final PlaceSearchPageEvent? sourceEvent;
  final String? message;
  final List<GooglePlaceSuggestion>? googlePlaceSuggestions;
  final GooglePlace? googlePlace;

  const PlaceSearchPageState({
    required this.status,
    this.sourceEvent,
    this.message,
    this.googlePlaceSuggestions,
    this.googlePlace,
  });

  PlaceSearchPageState copyWith({
    required BlocStatus status,
    PlaceSearchPageEvent? sourceEvent,
    String? message,
    List<GooglePlaceSuggestion>? googlePlaceSuggestions,
    GooglePlace? googlePlace,
  }) {
    return PlaceSearchPageState(
      status: status,
      sourceEvent: sourceEvent ?? this.sourceEvent,
      message: message,
      googlePlaceSuggestions: googlePlaceSuggestions ?? this.googlePlaceSuggestions,
      googlePlace: googlePlace ?? this.googlePlace,
    );
  }

  @override
  List<Object?> get props => [
        status,
        sourceEvent,
        message,
        googlePlaceSuggestions,
        googlePlace,
      ];
}
