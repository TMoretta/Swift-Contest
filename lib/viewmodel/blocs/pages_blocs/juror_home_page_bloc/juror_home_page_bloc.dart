import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:swift_contest/model/database/bundles/home_contest_bundle.dart';
import 'package:swift_contest/model/database/entities/voting_session.dart';
import 'package:swift_contest/model/database/repositories/juror_repository.dart';
import 'package:swift_contest/viewmodel/types/bloc_status.dart';

part 'juror_home_page_event.dart';
part 'juror_home_page_state.dart';

class JurorHomePageBloc extends Bloc<JurorHomePageEvent, JurorHomePageState> {
  final JurorRepository _jurorRepository;

  JurorHomePageBloc({
    required JurorRepository jurorRepository,
  })  : _jurorRepository = jurorRepository,
        super(const JurorHomePageState(status: BlocStatus.initial)) {
    // on<JurorHomePageInit>(_init);
    on<JurorHomePageFetch>(_fetch);
    on<JurorHomePageFilterResults>(_filterResults);
    on<JurorHomePageJoinContest>(_joinContest);
    on<JurorHomePageAccessVotingAsSimpleJuror>(_accessVotingAsSimpleJuror);
  }

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
                e.contestBundle.contest.name.toLowerCase().contains(query) ||
                e.contestBundle.contest.description.toLowerCase().contains(query))
            .toList();

    emit(state.copyWith(
        status: BlocStatus.success, filteredContestsBundles: filteredContestsBundles));
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

  FutureOr<void> _accessVotingAsSimpleJuror(
    JurorHomePageAccessVotingAsSimpleJuror event,
    Emitter<JurorHomePageState> emit,
  ) async {
    emit(state.copyWith(status: BlocStatus.loading, sourceEvent: event));

    final res = await _jurorRepository.accessVotingAsSimpleJuror(token: event.token);
    res.fold(
          (failure) => emit(state.copyWith(status: BlocStatus.failure, message: failure.message)),
          (success) => emit(state.copyWith(status: BlocStatus.success, votingSession: success)),
    );
  }
}
