part of 'place_picker_field_bloc.dart';

@immutable
final class PlacePickerFieldState extends Equatable {
  final BlocStatus status;
  final String? message;
  final GooglePlace? googlePlace;
  final List<GooglePlaceSuggestion>? googlePlaceSuggestions;

  const PlacePickerFieldState({
    required this.status,
    this.message,
    this.googlePlace,
    this.googlePlaceSuggestions,
  });

  PlacePickerFieldState copyWith({
    required BlocStatus status,
    String? message,
    GooglePlace? googlePlace,
    List<GooglePlaceSuggestion>? googlePlaceSuggestions,
  }) {
    return PlacePickerFieldState(
      status: status,
      message: message,
      googlePlace: googlePlace ?? this.googlePlace,
      googlePlaceSuggestions: googlePlaceSuggestions ?? this.googlePlaceSuggestions,
    );
  }

  @override
  List<Object?> get props => [status, message, googlePlace, googlePlaceSuggestions];
}
