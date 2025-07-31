import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:swift_contest/model/db/bundles/voting_session_jury_result_bundle.dart';
import 'package:swift_contest/model/db/repositories/organizer_repository.dart';
import 'package:swift_contest/viewmodel/enums/bloc_status.dart';

part 'organizer_jury_voting_results_page_event.dart';
part 'organizer_jury_voting_results_page_state.dart';

class OrganizerJuryVotingResultsPageBloc
    extends Bloc<OrganizerJuryVotingResultsPageEvent, OrganizerJuryVotingResultsPageState> {
  final OrganizerRepository _organizerRepository;

  OrganizerJuryVotingResultsPageBloc({required OrganizerRepository organizerRepository})
      : _organizerRepository = organizerRepository,
        super(OrganizerJuryVotingResultsPageState(status: BlocStatus.initial)) {
    on<OrganizerJuryVotingResultsPageFetch>(_fetch);
  }

  FutureOr<void> _fetch(
    OrganizerJuryVotingResultsPageFetch event,
    Emitter<OrganizerJuryVotingResultsPageState> emit,
  ) async {
    emit(state.copyWith(status: BlocStatus.loading, sourceEvent: event));

    // final eitherVotingSessionBundle = await _organizerRepository.getJuryVotingSessionResultDetails(
    //   votingSessionJuryId: event.votingSessionJuryId,
    // );
    // eitherVotingSessionBundle.fold(
    //   (failure) => emit(state.copyWith(status: BlocStatus.failure, message: failure.message)),
    //   (success) => emit(state.copyWith(
    //       status: BlocStatus.success, isInitialized: true, votingSessionJuryResultBundle: success)),
    // );
  }
}
