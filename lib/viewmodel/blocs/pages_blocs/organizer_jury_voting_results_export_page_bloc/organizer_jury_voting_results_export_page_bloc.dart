import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:swift_contest/model/database/bundles/voting_session_jury_result_bundle.dart';
import 'package:swift_contest/model/database/repositories/organizer_repository.dart';
import 'package:swift_contest/viewmodel/types/bloc_status.dart';

part 'organizer_jury_voting_results_export_page_event.dart';
part 'organizer_jury_voting_results_export_page_state.dart';

class OrganizerJuryVotingResultsExportPageBloc extends Bloc<OrganizerJuryVotingResultsExportPageEvent, OrganizerJuryVotingResultsExportPageState> {
  final OrganizerRepository _organizerRepository;

  OrganizerJuryVotingResultsExportPageBloc({required OrganizerRepository organizerRepository})
      : _organizerRepository = organizerRepository,
        super(OrganizerJuryVotingResultsExportPageState(status: BlocStatus.initial)) {
    on<OrganizerJuryVotingResultsExportPageFetch>(_fetch);
  }

  FutureOr<void> _fetch(
      OrganizerJuryVotingResultsExportPageFetch event,
      Emitter<OrganizerJuryVotingResultsExportPageState> emit,
      ) async {
    emit(state.copyWith(status: BlocStatus.loading, sourceEvent: event));

    final either = await _organizerRepository.getVotingSessionJuryResultDetails(
        votingSessionJuryId: event.votingSessionJuryId);
    either.fold(
          (failure) => emit(state.copyWith(status: BlocStatus.failure, message: failure.message)),
          (success) =>
          emit(state.copyWith(status: BlocStatus.success, isInitialized: true, votingSessionJuryResultBundle: success)),
    );
  }
}
