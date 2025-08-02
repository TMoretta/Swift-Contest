import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:swift_contest/model/database/bundles/contest_details_bundle.dart';
import 'package:swift_contest/model/database/repositories/juror_repository.dart';
import 'package:swift_contest/utils/logger/logger.dart';
import 'package:swift_contest/viewmodel/enums/bloc_status.dart';

part 'juror_contest_details_page_event.dart';

part 'juror_contest_details_page_state.dart';

class JurorContestDetailsPageBloc
    extends Bloc<JurorContestDetailsPageEvent, JurorContestDetailsPageState> {
  final JurorRepository _jurorRepository;

  JurorContestDetailsPageBloc({
    required JurorRepository jurorRepository,
  })  : _jurorRepository = jurorRepository,
        super(JurorContestDetailsPageState(status: BlocStatus.initial)) {
    on<JurorContestDetailsPageFetch>(_fetch);
    on<JurorContestDetailsPageLeaveContest>(_leaveContest);
  }

  @override
  JurorContestDetailsPageState? fromJson(Map<String, dynamic> json) {
    try {
      return JurorContestDetailsPageState.fromJson(json);
    } catch (e) {
      Logger.error(e);
      return null;
    }
  }

  @override
  Map<String, dynamic>? toJson(JurorContestDetailsPageState state) {
    try {
      return state.toJson();
    } catch (e) {
      Logger.error(e);
      return null;
    }
  }

  FutureOr<void> _fetch(
    JurorContestDetailsPageFetch event,
    Emitter<JurorContestDetailsPageState> emit,
  ) async {
    emit(state.copyWith(status: BlocStatus.loading, sourceEvent: event));

    late final ContestDetailsBundle contestDetailsBundle;
    final eitherContestDetails =
        await _jurorRepository.getContestDetails(contestId: event.contestId);
    eitherContestDetails.fold(
      (failure) => emit(state.copyWith(status: BlocStatus.failure, message: failure.message)),
      (success) => contestDetailsBundle = success,
    );
    if (eitherContestDetails.isLeft()) {
      return;
    }

    emit(state.copyWith(
        status: BlocStatus.success,
        isInitialized: true,
        contestDetailsBundle: contestDetailsBundle)); //todo remove

    //TODO add
    // if (contestDetailsBundle.liveVotingSession == null) {
    //   emit(state.copyWith(status: BlocStatus.success, isInitialized: true, contestDetailsBundle: contestDetailsBundle));
    //   return;
    // }
    // final eitherProcedureBundle = await _jurorRepository.getVotingSessionProcedureBundle(
    //     votingSessionId: contestDetailsBundle.liveVotingSession!.id);
    // eitherProcedureBundle.fold(
    //   (failure) => emit(state.copyWith(status: BlocStatus.failure, message: failure.message)),
    //   (success) => emit(state.copyWith(
    //       status: BlocStatus.success,
    //       isInitialized: true,
    //       contestDetailsBundle: contestDetailsBundle,
    //       votingSessionProcedureBundle: success)),
    // );
  }

  FutureOr<void> _leaveContest(
    JurorContestDetailsPageLeaveContest event,
    Emitter<JurorContestDetailsPageState> emit,
  ) async {
    emit(state.copyWith(status: BlocStatus.loading, sourceEvent: event));

    final eitherLeaveContest = await _jurorRepository.leaveContest(contestId: event.contestId);
    eitherLeaveContest.fold(
      (failure) => emit(state.copyWith(status: BlocStatus.failure, message: failure.message)),
      (success) => emit(state.copyWith(status: BlocStatus.success)),
    );
  }
}
