import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:swift_contest/model/google_place_models/google_place.dart';
import 'package:swift_contest/model/google_place_models/google_place_suggestion.dart';
import 'package:swift_contest/viewmodel/blocs/bloc_status.dart';
import 'package:swift_contest/viewmodel/repositories/google_place_repository.dart';

part 'place_picker_field_event.dart';

part 'place_picker_field_state.dart';

class PlacePickerFieldBloc extends Bloc<PlacePickerFieldEvent, PlacePickerFieldState> {
  final GooglePlaceRepository _googlePlaceRepository;

  PlacePickerFieldBloc({required GooglePlaceRepository googlePlaceRepository})
      : _googlePlaceRepository = googlePlaceRepository,
        super(PlacePickerFieldState(status: BlocStatus.initial)) {
    on<PlacePickerFieldFetchPlace>(_fetchPlace);
    on<PlacePickerFieldSearchPlaceSuggestions>(_searchPlaceSuggestions);
  }

  Future<void> _fetchPlace(
    PlacePickerFieldFetchPlace event,
    Emitter<PlacePickerFieldState> emit,
  ) async {
    emit(PlacePickerFieldState(status: BlocStatus.loading));
    final res = await _googlePlaceRepository.fetchPlace(id: event.id);
    res.fold(
      (failure) =>
          emit(PlacePickerFieldState(status: BlocStatus.failure, message: failure.message)),
      (success) => emit(PlacePickerFieldState(status: BlocStatus.success, googlePlace: success)),
    );
  }

  Future<void> _searchPlaceSuggestions(
    PlacePickerFieldSearchPlaceSuggestions event,
    Emitter<PlacePickerFieldState> emit,
  ) async {
    emit(PlacePickerFieldState(status: BlocStatus.loading));
    final res = await _googlePlaceRepository.searchPlaceSuggestions(query: event.query);
    res.fold(
      (failure) =>
          emit(PlacePickerFieldState(status: BlocStatus.failure, message: failure.message)),
      (success) =>
          emit(PlacePickerFieldState(status: BlocStatus.success, googlePlaceSuggestions: success)),
    );
  }
}
