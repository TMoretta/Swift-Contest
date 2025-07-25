import 'dart:async';

import 'package:fpdart/fpdart.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:swift_contest/model/bundles/voting_session_procedure_bundle.dart';
import 'package:swift_contest/model/data_models/voting_session.dart';
import 'package:swift_contest/model/repositories/organizer_repository.dart';
import 'package:swift_contest/utils/failures/failures.dart';
import 'package:swift_contest/viewmodel/enums/bloc_status.dart';

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
    on<OrganizerVotingProcedurePageStartVotingSessionProcedure>(_startVotingProcedure);
    on<OrganizerVotingProcedurePageCancelVotingSessionProcedure>(_cancelVotingSessionProcedure);
    on<OrganizerVotingProcedurePageEndVotingSessionProcedure>(_endVotingSessionProcedure);
  }

  FutureOr<void> _fetch(
    OrganizerVotingProcedurePageFetch event,
    Emitter<OrganizerVotingProcedurePageState> emit,
  ) async {
    emit(state.copyWith(status: BlocStatus.loading, sourceEvent: event));

    //* Getting the voting session bundle
    late final VotingSessionProcedureBundle votingSessionBundle;
    final eitherVotingSessionBundle = await _organizerRepository.getVotingSessionProcedureBundle(
        votingSessionId: event.votingSessionId);
    eitherVotingSessionBundle.fold(
      (failure) => emit(state.copyWith(status: BlocStatus.failure, message: failure.message)),
      (success) => votingSessionBundle = success,
    );

    //* Getting the stream
    late final Stream<Either<Failure, VotingSession?>> votingSessionStream;
    final eitherVotingSessionStream =
        await _organizerRepository.getVotingSessionStream(votingSessionId: event.votingSessionId);
    eitherVotingSessionStream.fold(
      (failure) => emit(state.copyWith(status: BlocStatus.failure, message: failure.message)),
      (success) => votingSessionStream = success,
    );
    if (eitherVotingSessionStream.isLeft()) {
      return;
    }

    emit(state.copyWith(
        status: BlocStatus.success, isInitialized: true, votingSessionProcedureBundle: votingSessionBundle));

    await emit.forEach(
      votingSessionStream,
      onData: (eitherNewVotingSession) {
        late VotingSession? newVotingSession;

        eitherNewVotingSession.fold(
          (failure) => null,
          (success) => newVotingSession = success,
        );
        if (eitherNewVotingSession.isLeft()) {
          return state.copyWith(status: BlocStatus.failure, message: 'No data received');
        }

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

  Future<void> _startVotingProcedure(
      OrganizerVotingProcedurePageStartVotingSessionProcedure event,
      Emitter<OrganizerVotingProcedurePageState> emit,
      ) async {
    emit(state.copyWith(status: BlocStatus.loading, sourceEvent: event));

    final eitherStartSession =
    await _organizerRepository.startVotingSession(votingSessionId: event.votingSessionId);
    eitherStartSession.fold(
          (failure) => emit(state.copyWith(status: BlocStatus.failure, message: failure.message)),
          (success) => emit(state.copyWith(status: BlocStatus.success)),
    );
  }

  FutureOr<void> _cancelVotingSessionProcedure(
    OrganizerVotingProcedurePageCancelVotingSessionProcedure event,
    Emitter<OrganizerVotingProcedurePageState> emit,
  ) async {
    emit(state.copyWith(status: BlocStatus.loading, sourceEvent: event));

    final eitherStartSession =
        await _organizerRepository.cancelVotingSession(votingSessionId: event.votingSessionId);
    eitherStartSession.fold(
      (failure) => emit(state.copyWith(status: BlocStatus.failure, message: failure.message)),
      (success) => emit(state.copyWith(status: BlocStatus.success)),
    );
  }

  FutureOr<void> _endVotingSessionProcedure(
    OrganizerVotingProcedurePageEndVotingSessionProcedure event,
    Emitter<OrganizerVotingProcedurePageState> emit,
  ) async {
    emit(state.copyWith(status: BlocStatus.loading, sourceEvent: event));

    final eitherStartSession =
        await _organizerRepository.endVotingSession(votingSessionId: event.votingSessionId);
    eitherStartSession.fold(
      (failure) => emit(state.copyWith(status: BlocStatus.failure, message: failure.message)),
      (success) => emit(state.copyWith(status: BlocStatus.success)),
    );
  }
}
