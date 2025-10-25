import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:swift_contest/model/database/bundles/voting_session_jury_result_bundle.dart';
import 'package:swift_contest/model/database/repositories/organizer_repository.dart';
import 'package:swift_contest/viewmodel/types/bloc_status.dart';

part 'organizer_jury_ranking_generation_page_event.dart';

part 'organizer_jury_ranking_generation_page_state.dart';

class OrganizerJuryRankingGenerationPageBloc
    extends Bloc<OrganizerJuryRankingGenerationPageEvent, OrganizerJuryRankingGenerationPageState> {
  final OrganizerRepository _organizerRepository;

  OrganizerJuryRankingGenerationPageBloc({required OrganizerRepository organizerRepository})
      : _organizerRepository = organizerRepository,
        super(const OrganizerJuryRankingGenerationPageState(status: BlocStatus.initial)) {
    on<OrganizerJuryRankingGenerationPageFetch>(_fetch);
  }

  FutureOr<void> _fetch(
    OrganizerJuryRankingGenerationPageFetch event,
    Emitter<OrganizerJuryRankingGenerationPageState> emit,
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
