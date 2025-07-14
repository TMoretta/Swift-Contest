import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:swift_contest/model/bundles/voting_session_result_bundle.dart';
import 'package:swift_contest/model/repositories/organizer_repository.dart';
import 'package:swift_contest/viewmodel/enums/bloc_status.dart';

part 'organizer_voting_result_details_page_event.dart';

part 'organizer_voting_result_details_page_state.dart';

class OrganizerVotingResultDetailsPageBloc
    extends Bloc<OrganizerVotingResultDetailsPageEvent, OrganizerVotingResultDetailsPageState> {
  final OrganizerRepository _organizerRepository;

  OrganizerVotingResultDetailsPageBloc({
    required OrganizerRepository organizerRepository,
  })  : _organizerRepository = organizerRepository,
        super(OrganizerVotingResultDetailsPageState(status: BlocStatus.initial)) {
    on<OrganizerVotingResultDetailsPageInit>(_init);
    on<OrganizerVotingResultDetailsPageRefresh>(_refresh);
    on<OrganizerVotingResultDetailsPageEditVotingSessionName>(_editVotingSessionName);
  }

  FutureOr<void> _init(
    OrganizerVotingResultDetailsPageInit event,
    Emitter<OrganizerVotingResultDetailsPageState> emit,
  ) async {
    emit(state.copyWith(status: BlocStatus.loading, sourceEvent: event));

    late final VotingSessionResultBundle votingSessionBundle;
    final eitherVotingSessionBundle = await _organizerRepository.getVotingSessionResultBundle(
        votingSessionId: event.votingSessionId);
    eitherVotingSessionBundle.fold(
      (failure) => emit(state.copyWith(status: BlocStatus.failure, message: failure.message)),
      (success) => votingSessionBundle = success,
    );

    emit(state.copyWith(
      status: BlocStatus.success,
      votingSessionResultBundle: votingSessionBundle,
    ));
  }

  FutureOr<void> _refresh(
    OrganizerVotingResultDetailsPageRefresh event,
    Emitter<OrganizerVotingResultDetailsPageState> emit,
  ) async {
    emit(state.copyWith(status: BlocStatus.loading, sourceEvent: event));

    late final VotingSessionResultBundle votingSessionBundle;
    final eitherVotingSessionBundle = await _organizerRepository.getVotingSessionResultBundle(
        votingSessionId: event.votingSessionId);
    eitherVotingSessionBundle.fold(
      (failure) => emit(state.copyWith(status: BlocStatus.failure, message: failure.message)),
      (success) => votingSessionBundle = success,
    );

    emit(state.copyWith(
      status: BlocStatus.success,
      votingSessionResultBundle: votingSessionBundle,
    ));
  }

  FutureOr<void> _editVotingSessionName(
    OrganizerVotingResultDetailsPageEditVotingSessionName event,
    Emitter<OrganizerVotingResultDetailsPageState> emit,
  ) async {
    emit(state.copyWith(status: BlocStatus.loading, sourceEvent: event));

    final eitherDeleteInvitation = await _organizerRepository.updateVotingSessionName(
        votingSessionId: event.votingSessionId, name: event.name);
    eitherDeleteInvitation.fold(
      (failure) => emit(state.copyWith(status: BlocStatus.failure, message: failure.message)),
      (success) => emit(state.copyWith(status: BlocStatus.success)),
    );
  }
}
