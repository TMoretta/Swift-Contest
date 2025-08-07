import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:swift_contest/model/database/bundles/contest_details_bundle.dart';
import 'package:swift_contest/model/database/bundles/participation_bundle.dart';
import 'package:swift_contest/model/database/repositories/participant_repository.dart';
import 'package:swift_contest/utils/logger/logger.dart';
import 'package:swift_contest/viewmodel/types/bloc_status.dart';

part 'participant_contest_details_page_event.dart';
part 'participant_contest_details_page_state.dart';

class ParticipantContestDetailsPageBloc
    extends Bloc<ParticipantContestDetailsPageEvent, ParticipantContestDetailsPageState> {
  final ParticipantRepository _participantRepository;

  ParticipantContestDetailsPageBloc({
    required ParticipantRepository participantRepository,
  })  :
        _participantRepository = participantRepository,
        super(ParticipantContestDetailsPageState(status: BlocStatus.initial)) {
    // on<ParticipantContestDetailsPageInit>(_init);
    on<ParticipantContestDetailsPageFetch>(_fetch);
    on<ParticipantContestDetailsPageLeaveContest>(_leaveContest);
  }

  @override
  ParticipantContestDetailsPageState? fromJson(Map<String, dynamic> json) {
    try {
      return ParticipantContestDetailsPageState.fromJson(json);
    } catch (e) {
      Logger.error(e);
      return null;
    }
  }

  @override
  Map<String, dynamic>? toJson(ParticipantContestDetailsPageState state) {
    try {
      return state.toJson();
    } catch (e) {
      Logger.error(e);
      return null;
    }
  }

  FutureOr<void> _fetch(
    ParticipantContestDetailsPageFetch event,
    Emitter<ParticipantContestDetailsPageState> emit,
  ) async {
    emit(state.copyWith(status: BlocStatus.loading, sourceEvent: event));

    late final ContestDetailsBundle contestDetailsBundle;
    final eitherContestDetails =
        await _participantRepository.getContestDetails(contestId: event.contestId);
    eitherContestDetails.fold(
      (failure) => emit(state.copyWith(status: BlocStatus.failure, message: failure.message)),
      (success) => contestDetailsBundle = success,
    );

    final eitherParticipation = await _participantRepository.getParticipationBundle(contestId: event.contestId, participantId: event.participantId);
    if(eitherParticipation.isLeft()) {
      emit(state.copyWith(status: BlocStatus.failure, message: eitherParticipation.getLeft().toNullable()!.message));
      return;
    }
    final participationBundle = eitherParticipation.getRight().toNullable()!;

    // late final Work? submittedWork;
    // final eitherSubmittedWork = await _participantRepository.getSubmittedWork(
    //     contestId: event.contestId);
    // eitherSubmittedWork.fold(
    //   (failure) => emit(state.copyWith(status: BlocStatus.failure, message: failure.message)),
    //   (success) => submittedWork = success,
    // );

    emit(state.copyWith(
        status: BlocStatus.success,
        isInitialized: true,
        contestDetailsBundle: contestDetailsBundle,
        ownParticipationBundle: participationBundle));
  }

  FutureOr<void> _leaveContest(
    ParticipantContestDetailsPageLeaveContest event,
    Emitter<ParticipantContestDetailsPageState> emit,
  ) async {
    emit(state.copyWith(status: BlocStatus.loading, sourceEvent: event));

    final eitherLeaveContest = await _participantRepository.leaveContest(
        contestId: event.contestId);
    eitherLeaveContest.fold(
      (failure) => emit(state.copyWith(status: BlocStatus.failure, message: failure.message)),
      (success) => emit(state.copyWith(status: BlocStatus.success)),
    );
  }
}
