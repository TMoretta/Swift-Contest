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
