import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fpdart/fpdart.dart';

import 'package:swift_contest/model/database/bundles/voting_session_procedure_bundle.dart';
import 'package:swift_contest/model/database/entities/voting_session.dart';
import 'package:swift_contest/model/database/repositories/organizer_repository.dart';
import 'package:swift_contest/utils/failures/failures.dart';
import 'package:swift_contest/utils/logger/logger.dart';
import 'package:swift_contest/viewmodel/types/bloc_status.dart';

part 'organizer_voting_procedure_page_event.dart';
part 'organizer_voting_procedure_page_state.dart';

class OrganizerVotingProcedurePageBloc
    extends Bloc<OrganizerVotingProcedurePageEvent, OrganizerVotingProcedurePageState> {
  final OrganizerRepository _organizerRepository;
  StreamSubscription<Either<Failure, VotingSession?>>? _votingSessionSubscription;

  OrganizerVotingProcedurePageBloc({
    required OrganizerRepository organizerRepository,
  })  : _organizerRepository = organizerRepository,
        super(OrganizerVotingProcedurePageState(status: BlocStatus.initial)) {
    on<OrganizerVotingProcedurePageFetch>(_fetch);
    // on<OrganizerVotingProcedurePageStartVotingSession>(_startVotingSession);
    // on<OrganizerVotingProcedurePageAdvanceSession>(_advanceSession);
    on<OrganizerVotingProcedurePageCancelVotingSessionProcedure>(_cancelVotingSessionProcedure);
    on<OrganizerVotingProcedurePageEndVotingSessionProcedure>(_endVotingSessionProcedure);
  }

  @override
  Future<void> close() {
    // Cancella la sottoscrizione quando il BLoC viene distrutto.
    _votingSessionSubscription?.cancel();
    return super.close();
  }

  @override
  OrganizerVotingProcedurePageState? fromJson(Map<String, dynamic> json) {
    try {
      return OrganizerVotingProcedurePageState.fromJson(json);
    } catch (e) {
      Logger.error(e);
      return null;
    }
  }

  @override
  Map<String, dynamic>? toJson(OrganizerVotingProcedurePageState state) {
    try {
      return state.toJson();
    } catch (e) {
      Logger.error(e);
      return null;
    }
  }

  FutureOr<void> _fetch(
    OrganizerVotingProcedurePageFetch event,
    Emitter<OrganizerVotingProcedurePageState> emit,
  ) async {
    emit(state.copyWith(status: BlocStatus.loading, sourceEvent: event));

    await _votingSessionSubscription?.cancel();

    //* Getting the voting session procedure bundle
    late final VotingSessionProcedureBundle votingSessionProcedureBundle;
    final eitherVotingSessionBundle = await _organizerRepository.getVotingSessionProcedureBundle(
        votingSessionId: event.votingSessionId);
    eitherVotingSessionBundle.fold(
      (failure) => emit(state.copyWith(status: BlocStatus.failure, message: failure.message)),
      (success) => votingSessionProcedureBundle = success,
    );

    emit(state.copyWith(
        status: BlocStatus.success,
        isInitialized: true,
        votingSessionProcedureBundle: votingSessionProcedureBundle));

    final eitherStream =
        await _organizerRepository.getVotingSessionStream(votingSessionId: event.votingSessionId);

    if (eitherStream.isLeft()) {
      emit(state.copyWith(
          status: BlocStatus.failure, message: eitherStream.getLeft().toNullable()!.message));
    }
    final Stream<Either<Failure, VotingSession?>> votingSessionStream =
        eitherStream.getRight().toNullable()!;

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

    // _votingSessionSubscription = votingSessionStream.listen((eitherNewVotingSession) {
    //   if (eitherNewVotingSession.isLeft()) {
    //     emit(state.copyWith(status: BlocStatus.failure, message: 'No data received'));
    //   }
    //   final newVotingSession = eitherNewVotingSession.getRight().toNullable();
    //
    //   final oldVotingSession =
    //       state.votingSessionProcedureBundle!.votingSessionBundle.votingSession;
    //   if (newVotingSession != oldVotingSession) {
    //     emit(state.copyWith(
    //       status: BlocStatus.success,
    //       isInitialized: true,
    //       votingSessionProcedureBundle: state.votingSessionProcedureBundle!.copyWith(
    //           votingSessionBundle: state.votingSessionProcedureBundle!.votingSessionBundle
    //               .copyWith(votingSession: newVotingSession)),
    //     ));
    //   }
    // }, onError: (error) {
    //   emit(state.copyWith(status: BlocStatus.failure, message: error));
    // });
  }

  // Future<void> _startVotingSession(
  //   OrganizerVotingProcedurePageStartVotingSession event,
  //   Emitter<OrganizerVotingProcedurePageState> emit,
  // ) async {
  //   emit(state.copyWith(status: BlocStatus.loading, sourceEvent: event));
  //
  //   final eitherStartSession =
  //       await _organizerRepository.startVotingSession(votingSessionId: event.votingSessionId);
  //   eitherStartSession.fold(
  //     (failure) => emit(state.copyWith(status: BlocStatus.failure, message: failure.message)),
  //     (success) => emit(state.copyWith(status: BlocStatus.success)),
  //   );
  // }

  // FutureOr<void> _advanceSession(
  //     OrganizerVotingProcedurePageAdvanceSession event,
  //     Emitter<OrganizerVotingProcedurePageState> emit,
  //     ) async {
  //   // Non è necessario emettere uno stato di loading,
  //   // perché la chiamata è "fire-and-forget".
  //   // La UI si aggiornerà da sola grazie allo stream realtime.
  //   await _organizerRepository.advanceVotingSession(
  //     votingSessionId: state.votingSessionProcedureBundle!.votingSessionBundle.votingSession.id!,
  //   );
  //   // Non facciamo nulla dopo la chiamata. Lo stream farà il suo lavoro.
  // }

  FutureOr<void> _cancelVotingSessionProcedure(
    OrganizerVotingProcedurePageCancelVotingSessionProcedure event,
    Emitter<OrganizerVotingProcedurePageState> emit,
  ) async {
    emit(state.copyWith(status: BlocStatus.loading, sourceEvent: event));

    final eitherCancelSession = await _organizerRepository.cancelVotingSession(votingSessionId: event.votingSessionId);
    eitherCancelSession.fold(
      (failure) => emit(state.copyWith(status: BlocStatus.failure, message: failure.message)),
      (success) {
        _votingSessionSubscription?.cancel();
        emit(state.copyWith(status: BlocStatus.success));
      },
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
          (success) {
        _votingSessionSubscription?.cancel();
        emit(state.copyWith(status: BlocStatus.success));
      },
    );
  }
}
