import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:swift_contest/model/bundles/home_contest_bundle.dart';
import 'package:swift_contest/model/repositories/participant_repository.dart';
import 'package:swift_contest/viewmodel/enums/bloc_status.dart';

part 'participant_home_page_event.dart';

part 'participant_home_page_state.dart';

class ParticipantHomePageBloc extends Bloc<ParticipantHomePageEvent, ParticipantHomePageState> {
  final ParticipantRepository _participantRepository;

  ParticipantHomePageBloc({
    required ParticipantRepository participantRepository,
  })  : _participantRepository = participantRepository,
        super(ParticipantHomePageState(status: BlocStatus.initial)) {
    on<ParticipantHomePageInit>(_init);
    on<ParticipantHomePageRefresh>(_refresh);
    on<ParticipantHomePageFilterResults>(_filterResults);
    on<ParticipantHomePageJoinContest>(_joinContest);
  }

  FutureOr<void> _init(
    ParticipantHomePageInit event,
    Emitter<ParticipantHomePageState> emit,
  ) async {
    emit(ParticipantHomePageState(status: BlocStatus.loading, sourceEvent: event));

    final eitherContests =
        await _participantRepository.getJoinedContests();
    eitherContests.fold(
      (failure) => emit(state.copyWith(status: BlocStatus.failure, message: failure.message)),
      (success) => emit(state.copyWith(
          status: BlocStatus.success,
          joinedContestsBundles: success,
          filteredContestsBundles: success)),
    );
  }

  FutureOr<void> _refresh(
    ParticipantHomePageRefresh event,
    Emitter<ParticipantHomePageState> emit,
  ) async {
    emit(state.copyWith(status: BlocStatus.loading, sourceEvent: event));

    final eitherContests =
        await _participantRepository.getJoinedContests();
    eitherContests.fold(
      (failure) => emit(state.copyWith(status: BlocStatus.failure, message: failure.message)),
      (success) => emit(state.copyWith(
          status: BlocStatus.success,
          joinedContestsBundles: success,
          filteredContestsBundles: success)),
    );
  }

  //* Join contest
  FutureOr<void> _joinContest(
    ParticipantHomePageJoinContest event,
    Emitter<ParticipantHomePageState> emit,
  ) async {
    emit(state.copyWith(status: BlocStatus.loading, sourceEvent: event));

    final eitherJoinContest = await _participantRepository.joinContest(token: event.token);
    eitherJoinContest.fold(
      (failure) => emit(state.copyWith(status: BlocStatus.failure, message: failure.message)),
      (success) => emit(state.copyWith(status: BlocStatus.success)),
    );
  }

  FutureOr<void> _filterResults(
    ParticipantHomePageFilterResults event,
    Emitter<ParticipantHomePageState> emit,
  ) async {
    emit(state.copyWith(status: BlocStatus.loading, sourceEvent: event));

    final query = event.query.toLowerCase();
    final allContestsBundles = state.joinedContestsBundles;
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
