import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:swift_contest/model/database/bundles/voting_session_result_bundle.dart';
import 'package:swift_contest/model/database/repositories/organizer_repository.dart';
import 'package:swift_contest/viewmodel/types/bloc_status.dart';

part 'organizer_voting_results_page_event.dart';
part 'organizer_voting_results_page_state.dart';

class OrganizerVotingResultsPageBloc
    extends Bloc<OrganizerVotingResultsPageEvent, OrganizerVotingResultsPageState> {
  final OrganizerRepository _organizerRepository;

  OrganizerVotingResultsPageBloc({
    required OrganizerRepository organizerRepository,
  })  : _organizerRepository = organizerRepository,
        super(const OrganizerVotingResultsPageState(status: BlocStatus.initial)) {
    on<OrganizerVotingResultsPageFetch>(_fetch);
    on<OrganizerVotingResultsPageEditVotingSessionName>(_editVotingSessionName);
    on<OrganizerVotingResultsPageDeleteVotingSession>(_deleteVotingSession);
  }

  FutureOr<void> _fetch(
    OrganizerVotingResultsPageFetch event,
    Emitter<OrganizerVotingResultsPageState> emit,
  ) async {
    emit(state.copyWith(status: BlocStatus.loading, sourceEvent: event));

    late final VotingSessionResultBundle votingSessionBundle;
    final eitherVotingSessionBundle = await _organizerRepository.getVotingSessionResultDetails(
        votingSessionId: event.votingSessionId);
    eitherVotingSessionBundle.fold(
      (failure) => emit(state.copyWith(status: BlocStatus.failure, message: failure.message)),
      (success) => votingSessionBundle = success,
    );

    emit(state.copyWith(
      status: BlocStatus.success,
      isInitialized: true,
      votingSessionResultBundle: votingSessionBundle,
    ));
  }

  FutureOr<void> _editVotingSessionName(
    OrganizerVotingResultsPageEditVotingSessionName event,
    Emitter<OrganizerVotingResultsPageState> emit,
  ) async {
    emit(state.copyWith(status: BlocStatus.loading, sourceEvent: event));

    final eitherDeleteInvitation = await _organizerRepository.updateVotingSessionName(
        votingSessionId: event.votingSessionId, name: event.name);
    eitherDeleteInvitation.fold(
      (failure) => emit(state.copyWith(status: BlocStatus.failure, message: failure.message)),
      (success) => emit(state.copyWith(status: BlocStatus.success)),
    );
  }

  FutureOr<void> _deleteVotingSession(
      OrganizerVotingResultsPageDeleteVotingSession event,
      Emitter<OrganizerVotingResultsPageState> emit,
      ) async {
    emit(state.copyWith(status: BlocStatus.loading, sourceEvent: event));

    final eitherDelete =
    await _organizerRepository.deleteVotingSession(votingSessionId: event.votingSessionId);

    eitherDelete.fold(
          (failure) => emit(state.copyWith(status: BlocStatus.failure, message: failure.message)),
          (success) => emit(state.copyWith(status: BlocStatus.success, sourceEvent: event)),
    );
  }
}
