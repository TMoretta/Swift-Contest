import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:swift_contest/model/bundles/home_contest_bundle.dart';
import 'package:swift_contest/model/data_models/message.dart';
import 'package:swift_contest/model/repositories/organizer_repository.dart';
import 'package:swift_contest/viewmodel/enums/bloc_status.dart';

part 'organizer_home_page_event.dart';

part 'organizer_home_page_state.dart';

class OrganizerHomePageBloc extends Bloc<OrganizerHomePageEvent, OrganizerHomePageState> {
  final OrganizerRepository _organizerRepository;

  OrganizerHomePageBloc({
    required OrganizerRepository organizerRepository,
  })  : _organizerRepository = organizerRepository,
        super(OrganizerHomePageState(status: BlocStatus.initial)) {
    on<OrganizerHomePageInit>(_init);
    on<OrganizerHomePageRefresh>(_refresh);
    on<OrganizerHomePageFilterResults>(_filterResults);
  }

  FutureOr<void> _init(
    OrganizerHomePageInit event,
    Emitter<OrganizerHomePageState> emit,
  ) async {
    emit(OrganizerHomePageState(status: BlocStatus.loading, sourceEvent: event));

    final eitherContests =
        await _organizerRepository.getCreatedContests();
    eitherContests.fold(
      (failure) => emit(state.copyWith(status: BlocStatus.failure, message: failure.message)),
      (success) => emit(state.copyWith(
          status: BlocStatus.success,
          createdContestsBundles: success,
          filteredContestsBundles: success)),
    );
  }

  FutureOr<void> _refresh(
    OrganizerHomePageRefresh event,
    Emitter<OrganizerHomePageState> emit,
  ) async {
    emit(state.copyWith(status: BlocStatus.loading, sourceEvent: event));

    final eitherContests =
        await _organizerRepository.getCreatedContests();
    eitherContests.fold(
      (failure) => emit(state.copyWith(status: BlocStatus.failure, message: failure.message)),
      (success) => emit(state.copyWith(
          status: BlocStatus.success,
          createdContestsBundles: success,
          filteredContestsBundles: success)),
    );
  }

  FutureOr<void> _filterResults(
    OrganizerHomePageFilterResults event,
    Emitter<OrganizerHomePageState> emit,
  ) async {
    emit(state.copyWith(status: BlocStatus.loading, sourceEvent: event));

    final query = event.query.toLowerCase();
    final allContestsBundles = state.createdContestsBundles;
    if(allContestsBundles == null) {
      emit(state.copyWith(status: BlocStatus.failure, message: 'No contest to filter'));
      return;
    }
    final List<HomeContestBundle> filteredContestsBundles = query.isEmpty
        ? allContestsBundles
        : allContestsBundles
            .where((e) =>
                e.contest.name.toLowerCase().contains(query) ||
                e.contest.description.toLowerCase().contains(query))
            .toList();

    emit(state.copyWith(
        status: BlocStatus.success, filteredContestsBundles: filteredContestsBundles));
  }
}
