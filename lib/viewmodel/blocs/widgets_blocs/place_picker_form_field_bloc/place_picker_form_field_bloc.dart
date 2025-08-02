import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rxdart/rxdart.dart';
import 'package:swift_contest/model/google_place/entities/google_place.dart';
import 'package:swift_contest/model/google_place/entities/google_place_suggestion.dart';
import 'package:swift_contest/model/google_place/repositories/google_place_repository.dart';
import 'package:swift_contest/utils/logger/logger.dart';
import 'package:swift_contest/viewmodel/enums/bloc_status.dart';

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

  @override
  PlacePickerFormFieldState? fromJson(Map<String, dynamic> json) {
    try {
      return PlacePickerFormFieldState.fromJson(json);
    } catch (e) {
      Logger.error(e);
      return null;
    }
  }

  @override
  Map<String, dynamic>? toJson(PlacePickerFormFieldState state) {
    try {
      return state.toJson();
    } catch (e) {
      Logger.error(e);
      return null;
    }
  }

  Future<void> _fetchPlace(
      PlacePickerFormFieldFetchPlace event,
      Emitter<PlacePickerFormFieldState> emit,
      ) async {
    emit(state.copyWith(status: BlocStatus.loading, sourceEvent: event));
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
    emit(state.copyWith(status: BlocStatus.loading, sourceEvent: event));
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
