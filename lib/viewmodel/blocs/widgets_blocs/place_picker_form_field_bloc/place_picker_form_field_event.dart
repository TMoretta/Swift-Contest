part of 'place_picker_form_field_bloc.dart';

@immutable
sealed class PlacePickerFormFieldEvent extends Equatable{
  const PlacePickerFormFieldEvent();
}

final class PlacePickerFormFieldFetchPlace extends PlacePickerFormFieldEvent {
  final String id;

  const PlacePickerFormFieldFetchPlace({required this.id});

  @override
  List<Object?> get props => [id];
}

final class PlacePickerFormFieldSearchPlaceSuggestions extends PlacePickerFormFieldEvent {
  final String query;

  const PlacePickerFormFieldSearchPlaceSuggestions({required this.query});

  @override
  List<Object?> get props => [query];
}
