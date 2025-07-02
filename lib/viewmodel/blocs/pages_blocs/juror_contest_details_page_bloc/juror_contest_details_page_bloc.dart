import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:swift_contest/model/bundles/contest_details_bundle.dart';
import 'package:swift_contest/model/bundles/voting_session_procedure_bundle.dart';
import 'package:swift_contest/model/repositories/generic_repository.dart';
import 'package:swift_contest/model/repositories/juror_repository.dart';
import 'package:swift_contest/viewmodel/enums/bloc_status.dart';

part 'juror_contest_details_page_event.dart';

part 'juror_contest_details_page_state.dart';

class JurorContestDetailsPageBloc
    extends Bloc<JurorContestDetailsPageEvent, JurorContestDetailsPageState> {
  final GenericRepository _genericRepository;
  final JurorRepository _jurorRepository;

  JurorContestDetailsPageBloc({
    required GenericRepository genericRepository,
    required JurorRepository jurorRepository,
  })  : _genericRepository = genericRepository,
        _jurorRepository = jurorRepository,
        super(JurorContestDetailsPageState(status: BlocStatus.initial)) {
    on<JurorContestDetailsPageInit>(_init);
    on<JurorContestDetailsPageRefresh>(_refresh);
    on<JurorContestDetailsPageLeaveContest>(_leaveContest);
  }

  FutureOr<void> _init(
    JurorContestDetailsPageInit event,
    Emitter<JurorContestDetailsPageState> emit,
  ) async {
    emit(state.copyWith(status: BlocStatus.loading, sourceEvent: event));

    late final ContestDetailsBundle contestDetailsBundle;
    final eitherContestDetails =
        await _genericRepository.getContestDetails(contestId: event.contestId);
    eitherContestDetails.fold(
      (failure) => emit(state.copyWith(status: BlocStatus.failure, message: failure.message)),
      (success) => contestDetailsBundle = success,
    );
    if (eitherContestDetails.isLeft()) {
      return;
    }

    if (contestDetailsBundle.liveVotingSession == null) {
      emit(state.copyWith(status: BlocStatus.success, contestDetailsBundle: contestDetailsBundle));
    }

    final eitherProcedureBundle = await _genericRepository.getVotingSessionProcedureBundle(
        votingSessionId: contestDetailsBundle.liveVotingSession!.id);
    eitherProcedureBundle.fold(
      (failure) => emit(state.copyWith(status: BlocStatus.failure, message: failure.message)),
      (success) => emit(state.copyWith(
          status: BlocStatus.success,
          contestDetailsBundle: contestDetailsBundle,
          votingSessionProcedureBundle: success)),
    );
  }

  FutureOr<void> _refresh(
    JurorContestDetailsPageRefresh event,
    Emitter<JurorContestDetailsPageState> emit,
  ) async {
    emit(state.copyWith(status: BlocStatus.loading, sourceEvent: event));

    late final ContestDetailsBundle contestDetailsBundle;
    final eitherContestDetails =
    await _genericRepository.getContestDetails(contestId: event.contestId);
    eitherContestDetails.fold(
          (failure) => emit(state.copyWith(status: BlocStatus.failure, message: failure.message)),
          (success) => contestDetailsBundle = success,
    );
    if (eitherContestDetails.isLeft()) {
      return;
    }

    if (contestDetailsBundle.liveVotingSession == null) {
      emit(state.copyWith(status: BlocStatus.success, contestDetailsBundle: contestDetailsBundle));
    }

    final eitherProcedureBundle = await _genericRepository.getVotingSessionProcedureBundle(
        votingSessionId: contestDetailsBundle.liveVotingSession!.id);
    eitherProcedureBundle.fold(
          (failure) => emit(state.copyWith(status: BlocStatus.failure, message: failure.message)),
          (success) => emit(state.copyWith(
          status: BlocStatus.success,
          contestDetailsBundle: contestDetailsBundle,
          votingSessionProcedureBundle: success)),
    );
    // emit(state.copyWith(status: BlocStatus.loading, sourceEvent: event));
    //
    // final eitherContestDetails =
    //     await _genericRepository.getContestDetails(contestId: event.contestId);
    // eitherContestDetails.fold(
    //   (failure) => emit(state.copyWith(status: BlocStatus.failure, message: failure.message)),
    //   (success) => emit(state.copyWith(status: BlocStatus.success, contestDetailsBundle: success)),
    // );
  }

  FutureOr<void> _leaveContest(
    JurorContestDetailsPageLeaveContest event,
    Emitter<JurorContestDetailsPageState> emit,
  ) async {
    emit(state.copyWith(status: BlocStatus.loading, sourceEvent: event));

    final eitherLeaveContest =
        await _jurorRepository.leaveContest(contestId: event.contestId, jurorId: event.jurorId);
    eitherLeaveContest.fold(
      (failure) => emit(state.copyWith(status: BlocStatus.failure, message: failure.message)),
      (success) => emit(state.copyWith(status: BlocStatus.success)),
    );
  }
}
