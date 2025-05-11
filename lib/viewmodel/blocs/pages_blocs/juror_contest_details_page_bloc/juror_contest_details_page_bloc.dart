import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:swift_contest/model/data_models/contest.dart';
import 'package:swift_contest/model/data_models/place.dart';
import 'package:swift_contest/model/data_models/profile.dart';
import 'package:swift_contest/model/data_models/voting_session.dart';
import 'package:swift_contest/model/data_models/voting_session_procedure.dart';
import 'package:swift_contest/viewmodel/blocs/bloc_status.dart';
import 'package:swift_contest/viewmodel/repositories/contest_repository.dart';
import 'package:swift_contest/viewmodel/repositories/participation_repository.dart';
import 'package:swift_contest/viewmodel/repositories/place_repository.dart';
import 'package:swift_contest/viewmodel/repositories/profile_repository.dart';
import 'package:swift_contest/viewmodel/repositories/voting_session_procedure_repository.dart';
import 'package:swift_contest/viewmodel/repositories/voting_session_repository.dart';
import 'package:swift_contest/viewmodel/repositories/work_repository.dart';

part 'juror_contest_details_page_event.dart';

part 'juror_contest_details_page_state.dart';

class JurorContestDetailsPageBloc
    extends Bloc<JurorContestDetailsPageEvent, JurorContestDetailsPageState> {
  final WorkRepository _workRepository;
  final ContestRepository _contestRepository;
  final ProfileRepository _profileRepository;
  final ParticipationRepository _participationRepository;
  final PlaceRepository _placeRepository;
  final VotingSessionRepository _votingSessionRepository;
  final VotingSessionProcedureRepository _votingSessionProcedureRepository;

  JurorContestDetailsPageBloc({
    required WorkRepository workRepository,
    required ContestRepository contestRepository,
    required ProfileRepository profileRepository,
    required ParticipationRepository participationRepository,
    required PlaceRepository placeRepository,
    required VotingSessionRepository votingSessionRepository,
    required VotingSessionProcedureRepository votingSessionProcedureRepository,
  })  : _workRepository = workRepository,
        _contestRepository = contestRepository,
        _profileRepository = profileRepository,
        _participationRepository = participationRepository,
        _placeRepository = placeRepository,
        _votingSessionRepository = votingSessionRepository,
        _votingSessionProcedureRepository = votingSessionProcedureRepository,
        super(JurorContestDetailsPageState(status: BlocStatus.initial)) {
    on<JurorContestDetailsPageGetContestMainInfo>(_getContestMainInfo);
    on<JurorContestDetailsPageGetVotingTabInfo>(_getVotingTabInfo);
  }

  FutureOr<void> _getContestMainInfo(
    JurorContestDetailsPageGetContestMainInfo event,
    Emitter<JurorContestDetailsPageState> emit,
  ) async {
    emit(state.copyWith(status: BlocStatus.loading));

    late final Contest contest;
    late final Profile organizer;
    late final Place place;

    //* Ottengo il contest
    final resContest = await _contestRepository.getContestById(id: event.contestId);
    resContest.fold(
      (failure) => emit(state.copyWith(status: BlocStatus.failure, message: failure.message)),
      (success) => contest = success,
    );
    if (resContest.isLeft()) return;

    //* Ottengo il place
    final resPlace = await _placeRepository.getPlaceById(id: contest.placeId);
    resPlace.fold(
      (failure) =>
          emit(JurorContestDetailsPageState(status: BlocStatus.failure, message: failure.message)),
      (success) => place = success,
    );
    if (resPlace.isLeft()) return;

    //* Ottengo l'organizer
    final resOrganizer = await _profileRepository.getProfileById(id: contest.organizerId);
    resOrganizer.fold(
      (failure) => emit(state.copyWith(status: BlocStatus.failure, message: failure.message)),
      (success) => organizer = success,
    );
    if (resOrganizer.isLeft()) return;

    emit(state.copyWith(
      status: BlocStatus.success,
      contest: contest,
      organizer: organizer,
      place: place,
    ));
  }

  FutureOr<void> _getVotingTabInfo(
    JurorContestDetailsPageGetVotingTabInfo event,
    Emitter<JurorContestDetailsPageState> emit,
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

    VotingSessionProcedure? liveVotingSessionProcedure;
    for (var session in votingSessions) {
      late final List<VotingSessionProcedure> votingSessionProcedures;
      final eitherVotingProcedure = await _votingSessionProcedureRepository.getVotingSessionProcedureByVotingSessionId(votingSessionId: session.id);
      eitherVotingProcedure.fold(
            (failure) => emit(state.copyWith(status: BlocStatus.failure, message: failure.message)),
            (success) {
              if(success.isLive == true) {
                liveVotingSessionProcedure = success;
              }
            }
      );
      if (eitherVotingProcedure.isLeft()) {
        return;
      }

      if (liveVotingSessionProcedure != null) {
        break;
      }
    }
    if (liveVotingSessionProcedure == null) {
      emit(state.copyWith(status: BlocStatus.success, isVotingSessionProcedureLive: false));
      return;
    }

    emit(state.copyWith(
      status: BlocStatus.success,
      isVotingSessionProcedureLive: true,
    ));
  }
}
