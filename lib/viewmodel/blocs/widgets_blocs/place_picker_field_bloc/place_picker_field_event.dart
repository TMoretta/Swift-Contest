part of 'place_picker_field_bloc.dart';

@immutable
sealed class PlacePickerFieldEvent extends Equatable{
  const PlacePickerFieldEvent();
}

final class PlacePickerFieldFetchPlace extends PlacePickerFieldEvent {
  final String id;

  const PlacePickerFieldFetchPlace({required this.id});

  @override
  List<Object?> get props => [id];
}

final class PlacePickerFieldSearchPlaceSuggestions extends PlacePickerFieldEvent {
  final String query;

  const PlacePickerFieldSearchPlaceSuggestions({required this.query});

  @override
  List<Object?> get props => [query];
}
