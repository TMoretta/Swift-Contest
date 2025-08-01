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

  factory PlaceSearchPageState.fromJson(Map<String, dynamic> json) {
    return PlaceSearchPageState(
      status: BlocStatus.values.byName(json['status']),
      googlePlaceSuggestions: (json['google_place_suggestions'] as List<dynamic>?)
          ?.map((e) => GooglePlaceSuggestion.fromJson(e as Map<String, dynamic>))
          .toList(),
      googlePlace: json['google_place'] != null
          ? GooglePlace.fromJson(json['google_place'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'status': status.name,
      'google_place_suggestions': googlePlaceSuggestions?.map((e) => e.toJson()).toList(),
      'google_place': googlePlace?.toJson(),
    };
  }

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
