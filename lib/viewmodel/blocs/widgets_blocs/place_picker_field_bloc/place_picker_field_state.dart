part of 'place_picker_field_bloc.dart';

@immutable
sealed class PlacePickerFieldState {}

final class PlacePickerFieldInitial extends PlacePickerFieldState {}

final class PlacePickerFieldLoading extends PlacePickerFieldState {}

final class PlacePickerFieldSuccess extends PlacePickerFieldState {
  final GooglePlace? googlePlace;
  final List<GooglePlaceSuggestion>? googlePlaceSuggestions;

  PlacePickerFieldSuccess({
    this.googlePlace,
    this.googlePlaceSuggestions,
  });
}

final class PlacePickerFieldFailure extends PlacePickerFieldState {
  final String message;

  PlacePickerFieldFailure({required this.message});
}
