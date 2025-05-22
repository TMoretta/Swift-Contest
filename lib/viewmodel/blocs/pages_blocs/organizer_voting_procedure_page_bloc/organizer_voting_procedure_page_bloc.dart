import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:swift_contest/model/data_models/participation.dart';
import 'package:swift_contest/model/data_models/profile.dart';
import 'package:swift_contest/model/data_models/voting_session.dart';
import 'package:swift_contest/model/data_models/voting_session_juror.dart';
import 'package:swift_contest/model/data_models/voting_session_participant.dart';
import 'package:swift_contest/model/data_models/voting_session_procedure.dart';
import 'package:swift_contest/model/data_models/work.dart';
import 'package:swift_contest/model/mixed_models/participant_and_juror.dart';
import 'package:swift_contest/viewmodel/enums/bloc_status.dart';
import 'package:swift_contest/viewmodel/repositories/participation_repository.dart';
import 'package:swift_contest/viewmodel/repositories/profile_repository.dart';
import 'package:swift_contest/viewmodel/repositories/voting_session_participant_repository.dart';
import 'package:swift_contest/viewmodel/repositories/voting_session_procedure_repository.dart';
import 'package:swift_contest/viewmodel/repositories/voting_session_repository.dart';
import 'package:swift_contest/viewmodel/repositories/work_repository.dart';

part 'organizer_voting_procedure_page_event.dart';
part 'organizer_voting_procedure_page_state.dart';

class OrganizerVotingProcedurePageBloc
    extends Bloc<OrganizerVotingProcedurePageEvent, OrganizerVotingProcedurePageState> {
  final VotingSessionRepository _votingSessionRepository;
  final VotingSessionProcedureRepository _votingSessionProcedureRepository;
  final VotingSessionParticipantRepository _votingSessionParticipantRepository;
  final WorkRepository _workRepository;
  final ParticipationRepository _participationRepository;
  final ProfileRepository _profileRepository;

  OrganizerVotingProcedurePageBloc({
    required VotingSessionRepository votingSessionRepository,
    required VotingSessionProcedureRepository votingSessionProcedureRepository,
    required VotingSessionParticipantRepository votingSessionParticipantRepository,
    required WorkRepository workRepository,
    required ParticipationRepository participationRepository,
    required ProfileRepository profileRepository,
  })  : _votingSessionRepository = votingSessionRepository,
        _votingSessionProcedureRepository = votingSessionProcedureRepository,
        _votingSessionParticipantRepository = votingSessionParticipantRepository,
        _workRepository = workRepository,
        _participationRepository = participationRepository,
        _profileRepository = profileRepository,
        super(OrganizerVotingProcedurePageState(status: BlocStatus.initial)) {
    on<OrganizerVotingProcedurePageStartVotingSessionProcedure>(_startVotingSessionProcedure);
    on<OrganizerVotingProcedurePageSubscribeToVotingSessionProcedure>(
        _subscribeToVotingSessionProcedure);
    on<OrganizerVotingProcedurePageCancelVotingSessionProcedure>(_cancelVotingSessionProcedure);
  }

  FutureOr<void> _startVotingSessionProcedure(
    OrganizerVotingProcedurePageStartVotingSessionProcedure event,
    Emitter<OrganizerVotingProcedurePageState> emit,
  ) async {
    late final List<VotingSession> votingSessions;
    final eitherVotingSession =
        await _votingSessionRepository.getVotingSessionsByContestId(contestId: event.contestId);
    eitherVotingSession.fold(
      (failure) => emit(state.copyWith(status: BlocStatus.failure, message: failure.message)),
      (success) => votingSessions = success,
    );
    if (eitherVotingSession.isLeft()) {
      return;
    }

    VotingSession? votingSession;
    VotingSessionProcedure? liveVotingSessionProcedure;
    for (var session in votingSessions) {
      final eitherVotingProcedure = await _votingSessionProcedureRepository
          .getVotingSessionProcedureByVotingSessionId(votingSessionId: session.id);
      eitherVotingProcedure.fold(
        (failure) => emit(state.copyWith(status: BlocStatus.failure, message: failure.message)),
        (success) {
          if (success.isLive == true) {
            liveVotingSessionProcedure = success;
            votingSession = session;
          }
        },
      );
      if (eitherVotingProcedure.isLeft()) {
        return;
      }
      if (liveVotingSessionProcedure != null) {
        break;
      }
    }
    if (liveVotingSessionProcedure == null) {
      emit(state.copyWith(status: BlocStatus.failure, message: 'No live voting session procedure'));
    }

    final eitherStartProcedure = await _votingSessionProcedureRepository
        .startVotingSessionProcedureById(id: liveVotingSessionProcedure!.id);
    eitherStartProcedure.fold(
      (failure) => emit(state.copyWith(status: BlocStatus.failure, message: failure.message)),
      (success) => emit(state.copyWith(
          status: BlocStatus.success,
          votingSession: votingSession,
          votingSessionProcedure: liveVotingSessionProcedure)),
    );
  }

  FutureOr<void> _subscribeToVotingSessionProcedure(
    OrganizerVotingProcedurePageSubscribeToVotingSessionProcedure event,
    Emitter<OrganizerVotingProcedurePageState> emit,
  ) async {
    emit(state.copyWith(status: BlocStatus.loading));

    late final List<VotingSession> votingSessions;
    final eitherVotingSession =
        await _votingSessionRepository.getVotingSessionsByContestId(contestId: event.contestId);
    eitherVotingSession.fold(
      (failure) => emit(state.copyWith(status: BlocStatus.failure, message: failure.message)),
      (success) => votingSessions = success,
    );
    if (eitherVotingSession.isLeft()) {
      return;
    }

    VotingSession? votingSession;
    VotingSessionProcedure? liveVotingSessionProcedure;
    for (var session in votingSessions) {
      final eitherVotingProcedures = await _votingSessionProcedureRepository
          .getVotingSessionProcedureByVotingSessionId(votingSessionId: session.id);
      eitherVotingProcedures.fold(
        (failure) => emit(state.copyWith(status: BlocStatus.failure, message: failure.message)),
        (success) {
          if (success.isLive == true) {
            liveVotingSessionProcedure = success;
            votingSession = session;
          }
        },
      );
      if (eitherVotingProcedures.isLeft()) {
        return;
      }

      if (liveVotingSessionProcedure != null) {
        break;
      }
    }
    if (liveVotingSessionProcedure == null) {
      emit(state.copyWith(status: BlocStatus.failure, message: 'No live voting session procedure'));
    }

    late final List<VotingSessionParticipant> votingSessionParticipants;
    final eitherVotingSessionParticipants =
        await _votingSessionParticipantRepository.getVotingSessionParticipantsByVotingSessionId(
      votingSessionId: votingSession!.id,
    );
    eitherVotingSessionParticipants.fold(
      (failure) => emit(state.copyWith(status: BlocStatus.failure, message: failure.message)),
      (success) => votingSessionParticipants = success,
    );
    if (eitherVotingSessionParticipants.isLeft()) {
      return;
    }

    final List<Participant> participants = [];
    final List<Work> works = [];
    for (var votingSessionParticipant in votingSessionParticipants) {
      late final Participation participation;
      final eitherParticipation =
          await _participationRepository.getParticipationByContestIdAndParticipantId(
              contestId: event.contestId, participantId: votingSessionParticipant.participantId);
      eitherParticipation.fold(
        (failure) => emit(state.copyWith(status: BlocStatus.failure, message: failure.message)),
        (success) => participation = success,
      );
      if (eitherParticipation.isLeft()) {
        return;
      }

      final eitherParticipant =
          await _profileRepository.getProfileById(id: participation.participantId);
      eitherParticipant.fold(
        (failure) => emit(state.copyWith(status: BlocStatus.failure, message: failure.message)),
        (success) => participants.add(success),
      );
      if (eitherParticipant.isLeft()) {
        return;
      }

      final eitherWork =
          await _workRepository.getWorkByParticipationId(participationId: participation.id);
      eitherWork.fold(
        (failure) => emit(state.copyWith(status: BlocStatus.failure, message: failure.message)),
        (success) => works.add(success),
      );
      if (eitherWork.isLeft()) {
        return;
      }
    }

    emit(state.copyWith(
      status: BlocStatus.loading,
      votingSession: votingSession,
      votingSessionParticipants: votingSessionParticipants,
      participants: participants,
      works: works,
    ));

    late Stream<VotingSessionProcedure> votingSessionProcedureStream;
    final result = await _votingSessionProcedureRepository.getVotingSessionProcedureStream(
      votingSessionProcedureId: liveVotingSessionProcedure!.id,
    );
    result.fold(
      (failure) => emit(state.copyWith(status: BlocStatus.failure, message: failure.message)),
      (success) => votingSessionProcedureStream = success,
    );
    if (result.isLeft()) {
      return;
    }

    await emit.forEach(
      votingSessionProcedureStream,
      onData: (newVotingSessionProcedure) {
        final oldVotingSessionProcedure = state.votingSessionProcedure;
        if (newVotingSessionProcedure == oldVotingSessionProcedure) {
          return state;
        }

        return state.copyWith(
          status: BlocStatus.success,
          votingSessionProcedure: newVotingSessionProcedure,
        );
      },
      onError: (error, stackTrace) {
        return state.copyWith(status: BlocStatus.failure, message: error.toString());
      },
    );
  }

  FutureOr<void> _cancelVotingSessionProcedure(
    OrganizerVotingProcedurePageCancelVotingSessionProcedure event,
    Emitter<OrganizerVotingProcedurePageState> emit,
  ) async {
    emit(state.copyWith(status: BlocStatus.loading));
    final eitherCancelProcedure = await _votingSessionProcedureRepository
        .cancelVotingSessionProcedureById(id: event.votingSessionProcedureId);
    eitherCancelProcedure.fold(
      (failure) => emit(state.copyWith(status: BlocStatus.failure, message: failure.message)),
      (success) => emit(state.copyWith(status: BlocStatus.success)),
    );
  }
}
