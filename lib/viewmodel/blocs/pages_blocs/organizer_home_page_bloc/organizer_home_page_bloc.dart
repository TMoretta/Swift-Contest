import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:swift_contest/model/db/bundles/home_contest_bundle.dart';
import 'package:swift_contest/model/db/entities/message.dart';
import 'package:swift_contest/model/db/repositories/organizer_repository.dart';
import 'package:swift_contest/viewmodel/enums/bloc_status.dart';

part 'organizer_home_page_event.dart';
part 'organizer_home_page_state.dart';

class OrganizerHomePageBloc extends Bloc<OrganizerHomePageEvent, OrganizerHomePageState> {
  final OrganizerRepository _organizerRepository;

  OrganizerHomePageBloc({
    required OrganizerRepository organizerRepository,
  })  : _organizerRepository = organizerRepository,
        super(OrganizerHomePageState(status: BlocStatus.initial)) {
    on<OrganizerHomePageFetch>(_fetch);
    on<OrganizerHomePageFilterResults>(_filterResults);
  }

  FutureOr<void> _fetch(
    OrganizerHomePageFetch event,
    Emitter<OrganizerHomePageState> emit,
  ) async {
    emit(state.copyWith(status: BlocStatus.loading, sourceEvent: event));

    final eitherContests =
        await _organizerRepository.getCreatedContests();
    eitherContests.fold(
      (failure) => emit(state.copyWith(status: BlocStatus.failure, message: failure.message)),
      (success) => emit(state.copyWith(
          status: BlocStatus.success,
          isInitialized: true,
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
            .where((e) => e.contestBundle.contest.name.toLowerCase().contains(query) ||
                e.contestBundle.contest.description.toLowerCase().contains(query))
            .toList();

    emit(state.copyWith(
        status: BlocStatus.success, filteredContestsBundles: filteredContestsBundles));
  }
}
