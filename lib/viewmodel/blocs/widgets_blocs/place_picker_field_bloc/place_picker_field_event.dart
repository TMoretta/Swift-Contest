part of 'place_picker_field_bloc.dart';

@immutable
sealed class PlacePickerFieldEvent {}

final class PlacePickerFieldFetchPlace extends PlacePickerFieldEvent {
  final String id;

  PlacePickerFieldFetchPlace({required this.id});
}

final class PlacePickerFieldSearchPlaceSuggestions extends PlacePickerFieldEvent {
  final String query;

  PlacePickerFieldSearchPlaceSuggestions({required this.query});
}
