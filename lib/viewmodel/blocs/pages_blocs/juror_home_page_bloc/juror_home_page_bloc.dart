import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:swift_contest/model/bundles/home_contest_bundle.dart';
import 'package:swift_contest/model/bundles/simple_juror_and_voting_session_bundle.dart';
import 'package:swift_contest/model/repositories/juror_repository.dart';
import 'package:swift_contest/viewmodel/enums/bloc_status.dart';

part 'juror_home_page_event.dart';

part 'juror_home_page_state.dart';

class JurorHomePageBloc extends Bloc<JurorHomePageEvent, JurorHomePageState> {
  final JurorRepository _jurorRepository;

  JurorHomePageBloc({
    required JurorRepository jurorRepository,
  })  : _jurorRepository = jurorRepository,
        super(JurorHomePageState(status: BlocStatus.initial)) {
    // on<JurorHomePageInit>(_init);
    on<JurorHomePageFetch>(_fetch);
    on<JurorHomePageFilterResults>(_filterResults);
    on<JurorHomePageJoinContest>(_joinContest);
    on<JurorHomePageVoteAsSimpleJuror>(_voteAsAuthenticatedSimpleJuror);
  }

  // FutureOr<void> _init(
  //   JurorHomePageInit event,
  //   Emitter<JurorHomePageState> emit,
  // ) async {
  //   emit(JurorHomePageState(status: BlocStatus.loading, sourceEvent: event));
  //
  //   final eitherContests = await _jurorRepository.getJoinedContests();
  //   eitherContests.fold(
  //     (failure) => emit(state.copyWith(status: BlocStatus.failure, message: failure.message)),
  //     (success) => emit(state.copyWith(
  //         status: BlocStatus.success,
  //         joinedContestsBundles: success,
  //         filteredContestsBundles: success)),
  //   );
  // }

  FutureOr<void> _fetch(
    JurorHomePageFetch event,
    Emitter<JurorHomePageState> emit,
  ) async {
    emit(state.copyWith(status: BlocStatus.loading, sourceEvent: event));

    final eitherContests = await _jurorRepository.getJoinedContests();
    eitherContests.fold(
      (failure) => emit(state.copyWith(status: BlocStatus.failure, message: failure.message)),
      (success) => emit(state.copyWith(
          status: BlocStatus.success,
          isInitialized: true,
          joinedContestsBundles: success,
          filteredContestsBundles: success)),
    );
  }

  //* Join contest
  FutureOr<void> _joinContest(
    JurorHomePageJoinContest event,
    Emitter<JurorHomePageState> emit,
  ) async {
    emit(state.copyWith(status: BlocStatus.loading, sourceEvent: event));

    final eitherJoinContest = await _jurorRepository.joinContest(token: event.token);
    eitherJoinContest.fold(
      (failure) => emit(state.copyWith(status: BlocStatus.failure, message: failure.message)),
      (success) => emit(state.copyWith(status: BlocStatus.success)),
    );
  }

  //* Vote as simple juror
  FutureOr<void> _voteAsAuthenticatedSimpleJuror(
    JurorHomePageVoteAsSimpleJuror event,
    Emitter<JurorHomePageState> emit,
  ) async {
    emit(state.copyWith(status: BlocStatus.loading, sourceEvent: event));

    final eitherJoinContest = await _jurorRepository.accessVotingAsSimpleJuror(
        fullName: event.fullName, token: event.token);
    eitherJoinContest.fold(
      (failure) => emit(state.copyWith(status: BlocStatus.failure, message: failure.message)),
      (success) => emit(
          state.copyWith(status: BlocStatus.success, simpleJurorAndVotingSessionBundle: success)),
    );
  }

  FutureOr<void> _filterResults(
    JurorHomePageFilterResults event,
    Emitter<JurorHomePageState> emit,
  ) async {
    emit(state.copyWith(status: BlocStatus.loading, sourceEvent: event));

    final query = event.query.toLowerCase();
    final allContestsBundles = state.joinedContestsBundles;
    if (allContestsBundles == null) {
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
