part of 'place_picker_form_field_bloc.dart';

@immutable
final class PlacePickerFormFieldState extends Equatable {
  final BlocStatus status;
  final PlacePickerFormFieldEvent? sourceEvent;
  final String? message;
  final GooglePlace? googlePlace;
  final List<GooglePlaceSuggestion>? googlePlaceSuggestions;

  const PlacePickerFormFieldState({
    required this.status,
    this.sourceEvent,
    this.message,
    this.googlePlace,
    this.googlePlaceSuggestions,
  });

  factory PlacePickerFormFieldState.fromJson(Map<String, dynamic> json) {
    return PlacePickerFormFieldState(
      status: BlocStatus.values.byName(json['status']),
      googlePlace: json['google_place'] != null ? GooglePlace.fromJson(json['google_place']) : null,
      googlePlaceSuggestions: (json['google_place_suggestions'] as List<dynamic>?)
          ?.map((e) => GooglePlaceSuggestion.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'status': status.name,
      'google_place': googlePlace?.toJson(),
      'google_place_suggestions': googlePlaceSuggestions?.map((e) => e.toJson()).toList(),
    };
  }

  PlacePickerFormFieldState copyWith({
    required BlocStatus status,
    PlacePickerFormFieldEvent? sourceEvent,
    String? message,
    GooglePlace? googlePlace,
    List<GooglePlaceSuggestion>? googlePlaceSuggestions,
  }) {
    return PlacePickerFormFieldState(
      status: status,
      sourceEvent: sourceEvent ?? this.sourceEvent,
      message: message,
      googlePlace: googlePlace ?? this.googlePlace,
      googlePlaceSuggestions: googlePlaceSuggestions ?? this.googlePlaceSuggestions,
    );
  }

  @override
  List<Object?> get props => [status, sourceEvent, message, googlePlace, googlePlaceSuggestions];
}
