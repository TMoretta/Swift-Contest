import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:swift_contest/model/database/bundles/voting_session_juror_result_bundle.dart';
import 'package:swift_contest/model/database/repositories/organizer_repository.dart';
import 'package:swift_contest/viewmodel/types/bloc_status.dart';

part 'organizer_juror_voting_results_page_event.dart';

part 'organizer_juror_voting_results_page_state.dart';

class OrganizerJurorVotingResultsPageBloc
    extends Bloc<OrganizerJurorVotingResultsPageEvent, OrganizerJurorVotingResultsPageState> {
  final OrganizerRepository _organizerRepository;

  OrganizerJurorVotingResultsPageBloc({required OrganizerRepository organizerRepository})
      : _organizerRepository = organizerRepository,
        super(OrganizerJurorVotingResultsPageState(status: BlocStatus.initial)) {
    on<OrganizerJurorVotingResultsPageFetch>(_fetch);
  }

  FutureOr<void> _fetch(
    OrganizerJurorVotingResultsPageFetch event,
    Emitter<OrganizerJurorVotingResultsPageState> emit,
  ) async {
    emit(state.copyWith(status: BlocStatus.loading));

    final eitherRes = await _organizerRepository.getVotingSessionJurorResultDetails(
        votingSessionJurorId: event.votingSessionJurorId);
    eitherRes.fold(
      (failure) => emit(state.copyWith(status: BlocStatus.failure, message: failure.message)),
      (success) => emit(state.copyWith(
          status: BlocStatus.success,
          isInitialized: true,
          votingSessionJurorResultBundle: success)),
    );
  }
}
