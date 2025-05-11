import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:swift_contest/model/google_place_models/google_place.dart';
import 'package:swift_contest/model/google_place_models/google_place_suggestion.dart';
import 'package:swift_contest/viewmodel/blocs/bloc_status.dart';
import 'package:swift_contest/viewmodel/repositories/google_place_repository.dart';
import 'package:rxdart/rxdart.dart';

part 'place_picker_form_field_event.dart';

part 'place_picker_form_field_state.dart';

class PlacePickerFormFieldBloc extends Bloc<PlacePickerFormFieldEvent, PlacePickerFormFieldState> {
  final GooglePlaceRepository _googlePlaceRepository;

  PlacePickerFormFieldBloc({required GooglePlaceRepository googlePlaceRepository})
      : _googlePlaceRepository = googlePlaceRepository,
        super(PlacePickerFormFieldState(status: BlocStatus.initial)) {
    on<PlacePickerFormFieldFetchPlace>(_fetchPlace);
    on<PlacePickerFormFieldSearchPlaceSuggestions>(
      _searchPlaceSuggestions,
      transformer: debounce(const Duration(milliseconds: 500)),
    );
  }

  Future<void> _fetchPlace(
    PlacePickerFormFieldFetchPlace event,
    Emitter<PlacePickerFormFieldState> emit,
  ) async {
    emit(state.copyWith(status: BlocStatus.loading));
    final res = await _googlePlaceRepository.fetchPlace(id: event.id);
    res.fold(
      (failure) =>
          emit(state.copyWith(status: BlocStatus.failure, message: failure.message)),
      (success) => emit(state.copyWith(status: BlocStatus.success, googlePlace: success)),
    );
  }

  Future<void> _searchPlaceSuggestions(
    PlacePickerFormFieldSearchPlaceSuggestions event,
    Emitter<PlacePickerFormFieldState> emit,
  ) async {
    emit(state.copyWith(status: BlocStatus.loading));
    final res = await _googlePlaceRepository.searchPlaceSuggestions(query: event.query);
    res.fold(
      (failure) =>
          emit(state.copyWith(status: BlocStatus.failure, message: failure.message)),
      (success) =>
          emit(state.copyWith(status: BlocStatus.success, googlePlaceSuggestions: success)),
    );
  }
}

EventTransformer<T> debounce<T>(Duration duration) {
  return (events, mapper) => events.debounceTime(duration).switchMap(mapper);
}
