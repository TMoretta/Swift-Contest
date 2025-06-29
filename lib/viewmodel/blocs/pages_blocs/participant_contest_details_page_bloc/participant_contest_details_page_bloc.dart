import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:swift_contest/model/bundles/contest_details_bundle.dart';
import 'package:swift_contest/model/data_models/participation.dart';
import 'package:swift_contest/model/data_models/work.dart';
import 'package:swift_contest/model/repositories/generic_repository.dart';
import 'package:swift_contest/model/repositories/participant_repository.dart';
import 'package:swift_contest/viewmodel/enums/bloc_status.dart';

part 'participant_contest_details_page_event.dart';

part 'participant_contest_details_page_state.dart';

class ParticipantContestDetailsPageBloc
    extends Bloc<ParticipantContestDetailsPageEvent, ParticipantContestDetailsPageState> {
  final GenericRepository _genericRepository;
  final ParticipantRepository _participantRepository;

  ParticipantContestDetailsPageBloc({
    required GenericRepository genericRepository,
    required ParticipantRepository participantRepository,
  })  : _genericRepository = genericRepository,
        _participantRepository = participantRepository,
        super(ParticipantContestDetailsPageState(status: BlocStatus.initial)) {
    on<ParticipantContestDetailsPageInit>(_init);
    on<ParticipantContestDetailsPageRefresh>(_refresh);
    on<ParticipantContestDetailsPageLeaveContest>(_leaveContest);
  }

  FutureOr<void> _init(
    ParticipantContestDetailsPageInit event,
    Emitter<ParticipantContestDetailsPageState> emit,
  ) async {
    emit(state.copyWith(status: BlocStatus.loading, sourceEvent: event));

    late final ContestDetailsBundle contestDetailsBundle;
    final eitherContestDetails =
        await _genericRepository.getContestDetails(contestId: event.contestId);
    eitherContestDetails.fold(
      (failure) => emit(state.copyWith(status: BlocStatus.failure, message: failure.message)),
      (success) => contestDetailsBundle = success,
    );

    late final Work? submittedWork;
    final eitherSubmittedWork = await _participantRepository.getSubmittedWork(
        contestId: event.contestId, participantId: event.participantId);
    eitherSubmittedWork.fold(
      (failure) => emit(state.copyWith(status: BlocStatus.failure, message: failure.message)),
      (success) => submittedWork = success,
    );

    emit(state.copyWith(
        status: BlocStatus.success,
        contestDetailsBundle: contestDetailsBundle,
        submittedWork: submittedWork));
  }

  FutureOr<void> _refresh(
    ParticipantContestDetailsPageRefresh event,
    Emitter<ParticipantContestDetailsPageState> emit,
  ) async {
    emit(state.copyWith(status: BlocStatus.loading, sourceEvent: event));

    late final ContestDetailsBundle contestDetailsBundle;
    final eitherContestDetails =
        await _genericRepository.getContestDetails(contestId: event.contestId);
    eitherContestDetails.fold(
      (failure) => emit(state.copyWith(status: BlocStatus.failure, message: failure.message)),
      (success) => contestDetailsBundle = success,
    );

    late final Work? submittedWork;
    final eitherSubmittedWork = await _participantRepository.getSubmittedWork(
        contestId: event.contestId, participantId: event.participantId);
    eitherSubmittedWork.fold(
      (failure) => emit(state.copyWith(status: BlocStatus.failure, message: failure.message)),
      (success) => submittedWork = success,
    );

    emit(state.copyWith(
        status: BlocStatus.success,
        contestDetailsBundle: contestDetailsBundle,
        submittedWork: submittedWork));
  }

  FutureOr<void> _leaveContest(
    ParticipantContestDetailsPageLeaveContest event,
    Emitter<ParticipantContestDetailsPageState> emit,
  ) async {
    emit(state.copyWith(status: BlocStatus.loading, sourceEvent: event));

    final eitherLeaveContest = await _participantRepository.leaveContest(
        contestId: event.contestId, participantId: event.participantId);
    eitherLeaveContest.fold(
      (failure) => emit(state.copyWith(status: BlocStatus.failure, message: failure.message)),
      (success) => emit(state.copyWith(status: BlocStatus.success)),
    );
  }
}
