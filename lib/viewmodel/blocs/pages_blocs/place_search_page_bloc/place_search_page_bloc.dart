import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';
import 'package:swift_contest/model/google_place/entities/google_place.dart';
import 'package:swift_contest/model/google_place/entities/google_place_suggestion.dart';
import 'package:swift_contest/model/google_place/repositories/google_place_repository.dart';
import 'package:swift_contest/viewmodel/enums/bloc_status.dart';

part 'place_search_page_event.dart';

part 'place_search_page_state.dart';

class PlaceSearchPageBloc extends Bloc<PlaceSearchPageEvent, PlaceSearchPageState> {
  final GooglePlaceRepository _googlePlaceRepository;

  PlaceSearchPageBloc({
    required GooglePlaceRepository googlePlaceRepository,
  })  : _googlePlaceRepository = googlePlaceRepository,
        super(PlaceSearchPageState(status: BlocStatus.initial)) {
    on<PlaceSearchPageSearchPlaceSuggestions>(
      _searchPlaceSuggestion,
      transformer: debounce(const Duration(milliseconds: 500)),
    );
    on<PlaceSearchPageFetchPlace>(_fetchPlace);
  }

  FutureOr<void> _searchPlaceSuggestion(
    PlaceSearchPageSearchPlaceSuggestions event,
    Emitter<PlaceSearchPageState> emit,
  ) async {
    emit(state.copyWith(status: BlocStatus.loading, sourceEvent: event));
    final res = await _googlePlaceRepository.searchPlaceSuggestions(query: event.query);
    res.fold(
      (failure) => emit(state.copyWith(status: BlocStatus.failure, message: failure.message)),
      (success) =>
          emit(state.copyWith(status: BlocStatus.success, googlePlaceSuggestions: success)),
    );
  }

  FutureOr<void> _fetchPlace(
    PlaceSearchPageFetchPlace event,
    Emitter<PlaceSearchPageState> emit,
  ) async {
    emit(state.copyWith(status: BlocStatus.loading, sourceEvent: event));
    final res = await _googlePlaceRepository.fetchPlace(id: event.id);
    res.fold(
      (failure) => emit(state.copyWith(status: BlocStatus.failure, message: failure.message)),
      (success) => emit(state.copyWith(status: BlocStatus.success, googlePlace: success)),
    );
  }
}

EventTransformer<T> debounce<T>(Duration duration) {
  return (events, mapper) => events.debounceTime(duration).switchMap(mapper);
}
