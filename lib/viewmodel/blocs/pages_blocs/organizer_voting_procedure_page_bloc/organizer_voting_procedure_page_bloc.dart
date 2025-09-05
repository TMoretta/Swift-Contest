import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:swift_contest/model/database/bundles/organizer_voting_session_procedure_bundle.dart';
import 'package:swift_contest/model/database/entities/voting_session.dart';
import 'package:swift_contest/model/database/repositories/organizer_repository.dart';
import 'package:swift_contest/viewmodel/types/bloc_status.dart';

part 'organizer_voting_procedure_page_event.dart';
part 'organizer_voting_procedure_page_state.dart';

class OrganizerVotingProcedurePageBloc
    extends Bloc<OrganizerVotingProcedurePageEvent, OrganizerVotingProcedurePageState> {
  final OrganizerRepository _organizerRepository;

  OrganizerVotingProcedurePageBloc({
    required OrganizerRepository organizerRepository,
  })  : _organizerRepository = organizerRepository,
        super(OrganizerVotingProcedurePageState(status: BlocStatus.initial)) {
    on<OrganizerVotingProcedurePageFetch>(_fetch);
    on<OrganizerVotingProcedurePageCancelVotingSessionProcedure>(_cancelVotingSessionProcedure);
    on<OrganizerVotingProcedurePageEndVotingSessionProcedure>(_endVotingSessionProcedure);
  }

  FutureOr<void> _fetch(
    OrganizerVotingProcedurePageFetch event,
    Emitter<OrganizerVotingProcedurePageState> emit,
  ) async {
    emit(state.copyWith(status: BlocStatus.loading, sourceEvent: event));

    //* Getting the voting session procedure bundle
    late final OrganizerVotingSessionProcedureBundle votingSessionProcedureBundle;
    final eitherVotingSessionBundle = await _organizerRepository.getVotingSessionProcedureBundle(
        votingSessionId: event.votingSessionId);
    eitherVotingSessionBundle.fold(
      (failure) => emit(state.copyWith(status: BlocStatus.failure, message: failure.message)),
      (success) => votingSessionProcedureBundle = success,
    );
    if(eitherVotingSessionBundle.isLeft()) {
      return;
    }

    emit(state.copyWith(
        status: BlocStatus.success,
        isInitialized: true,
        votingSessionProcedureBundle: votingSessionProcedureBundle));

    final eitherStream = await _organizerRepository.getVotingSessionStream(votingSessionId: event.votingSessionId);

    if (eitherStream.isLeft()) {
      emit(state.copyWith(
          status: BlocStatus.failure, message: eitherStream.getLeft().toNullable()!.message));
      return;
    }
    final Stream<VotingSession?> votingSessionStream = eitherStream.getRight().toNullable()!;

    await emit.forEach(
      votingSessionStream,
      onData: (newVotingSession) {
        if (newVotingSession == null) {
          return state;
        }

        final oldVotingSession =
            state.votingSessionProcedureBundle!.votingSessionBundle.votingSession;
        if (newVotingSession == oldVotingSession) {
          return state;
        }

        return state.copyWith(
          status: BlocStatus.success,
          isInitialized: true,
          votingSessionProcedureBundle: state.votingSessionProcedureBundle!.copyWith(
              votingSessionBundle: state.votingSessionProcedureBundle!.votingSessionBundle
                  .copyWith(votingSession: newVotingSession)),
        );
      },
      onError: (error, stackTrace) {
        return state.copyWith(status: BlocStatus.failure, message: 'An error occurred');
      },
    );
  }

  FutureOr<void> _cancelVotingSessionProcedure(
    OrganizerVotingProcedurePageCancelVotingSessionProcedure event,
    Emitter<OrganizerVotingProcedurePageState> emit,
  ) async {
    emit(state.copyWith(status: BlocStatus.loading, sourceEvent: event));

    final eitherCancelSession = await _organizerRepository.cancelVotingSession(votingSessionId: event.votingSessionId);
    eitherCancelSession.fold(
      (failure) => emit(state.copyWith(status: BlocStatus.failure, message: failure.message)),
      (success) =>

        emit(state.copyWith(status: BlocStatus.success))
      ,
    );
  }

  FutureOr<void> _endVotingSessionProcedure(
    OrganizerVotingProcedurePageEndVotingSessionProcedure event,
    Emitter<OrganizerVotingProcedurePageState> emit,
  ) async {
    emit(state.copyWith(status: BlocStatus.loading, sourceEvent: event));

    final eitherEndSession =
        await _organizerRepository.endVotingSession(votingSessionId: event.votingSessionId);
    eitherEndSession.fold(
      (failure) => emit(state.copyWith(status: BlocStatus.failure, message: failure.message)),
          (success) =>
        emit(state.copyWith(status: BlocStatus.success))
      ,
    );
  }
}
