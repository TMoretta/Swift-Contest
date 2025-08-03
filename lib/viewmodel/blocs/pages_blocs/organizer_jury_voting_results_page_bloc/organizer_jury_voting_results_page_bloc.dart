import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:swift_contest/model/database/bundles/voting_session_jury_result_bundle.dart';

import 'package:swift_contest/model/database/repositories/organizer_repository.dart';
import 'package:swift_contest/utils/logger/logger.dart';
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

  @override
  OrganizerJuryVotingResultsPageState? fromJson(Map<String, dynamic> json) {
    try {
      return OrganizerJuryVotingResultsPageState.fromJson(json);
    } catch (e) {
      Logger.error(e);
      return null;
    }
  }

  @override
  Map<String, dynamic>? toJson(OrganizerJuryVotingResultsPageState state) {
    try {
      return state.toJson();
    } catch (e) {
      Logger.error(e);
      return null;
    }
  }

  FutureOr<void> _fetch(
    OrganizerJuryVotingResultsPageFetch event,
    Emitter<OrganizerJuryVotingResultsPageState> emit,
  ) async {
    emit(state.copyWith(status: BlocStatus.loading, sourceEvent: event));

    final eitherVotingSessionBundle = await _organizerRepository.getVotingSessionJuryResultDetails(
      votingSessionJuryId: event.votingSessionJuryId,
    );
    eitherVotingSessionBundle.fold(
      (failure) => emit(state.copyWith(status: BlocStatus.failure, message: failure.message)),
      (success) => emit(state.copyWith(
          status: BlocStatus.success, isInitialized: true, votingSessionJuryResultBundle: success)),
    );
  }
}
