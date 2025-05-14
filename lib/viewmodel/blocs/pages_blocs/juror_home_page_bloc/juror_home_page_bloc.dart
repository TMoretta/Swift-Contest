import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:swift_contest/model/data_models/contest.dart';
import 'package:swift_contest/model/data_models/invitation.dart';
import 'package:swift_contest/model/data_models/juration.dart';
import 'package:swift_contest/model/data_models/simple_juror.dart';
import 'package:swift_contest/model/data_models/simple_juror_voting.dart';
import 'package:swift_contest/model/data_models/voting_session.dart';
import 'package:swift_contest/model/data_models/voting_session_participant.dart';
import 'package:swift_contest/model/data_models/voting_session_procedure.dart';
import 'package:swift_contest/model/data_models/voting_session_simple_juror.dart';
import 'package:swift_contest/model/enums/juror_status.dart';
import 'package:swift_contest/model/enums/member_role.dart';
import 'package:swift_contest/utils/functions/gen_uuid.dart';
import 'package:swift_contest/viewmodel/blocs/bloc_status.dart';
import 'package:swift_contest/viewmodel/repositories/contest_repository.dart';
import 'package:swift_contest/viewmodel/repositories/invitation_repository.dart';
import 'package:swift_contest/viewmodel/repositories/juration_repository.dart';
import 'package:swift_contest/viewmodel/repositories/place_repository.dart';
import 'package:swift_contest/viewmodel/repositories/simple_juror_repository.dart';
import 'package:swift_contest/viewmodel/repositories/simple_juror_voting_repository.dart';
import 'package:swift_contest/viewmodel/repositories/voting_session_participant_repository.dart';
import 'package:swift_contest/viewmodel/repositories/voting_session_procedure_repository.dart';
import 'package:swift_contest/viewmodel/repositories/voting_session_repository.dart';
import 'package:swift_contest/viewmodel/repositories/voting_session_simple_juror_repository.dart';
import 'package:swift_contest/model/data_models/place.dart';

part 'juror_home_page_event.dart';

part 'juror_home_page_state.dart';

class JurorHomePageBloc extends Bloc<JurorHomePageEvent, JurorHomePageState> {
  final JurationRepository _jurationRepository;
  final ContestRepository _contestRepository;
  final InvitationRepository _invitationRepository;
  final VotingSessionRepository _votingSessionRepository;
  final VotingSessionProcedureRepository _votingSessionProcedureRepository;
  final VotingSessionSimpleJurorRepository _votingSessionSimpleJurorRepository;
  final SimpleJurorVotingRepository _simpleJurorVotingRepository;
  final VotingSessionParticipantRepository _votingSessionParticipantRepository;
  final SimpleJurorRepository _simpleJurorRepository;
  final PlaceRepository _placeRepository;

  JurorHomePageBloc({
    required JurationRepository jurationRepository,
    required ContestRepository contestRepository,
    required InvitationRepository invitationRepository,
    required VotingSessionRepository votingSessionRepository,
    required VotingSessionProcedureRepository votingSessionProcedureRepository,
    required VotingSessionSimpleJurorRepository
        votingSessionSimpleJurorRepository,
    required SimpleJurorVotingRepository simpleJurorVotingRepository,
    required VotingSessionParticipantRepository
        votingSessionParticipantRepository,
    required SimpleJurorRepository simpleJurorRepository,
    required PlaceRepository placeRepository,
  })  : _jurationRepository = jurationRepository,
        _contestRepository = contestRepository,
        _invitationRepository = invitationRepository,
        _votingSessionRepository = votingSessionRepository,
        _votingSessionProcedureRepository = votingSessionProcedureRepository,
        _votingSessionSimpleJurorRepository =
            votingSessionSimpleJurorRepository,
        _simpleJurorVotingRepository = simpleJurorVotingRepository,
        _votingSessionParticipantRepository =
            votingSessionParticipantRepository,
        _simpleJurorRepository = simpleJurorRepository,
        _placeRepository = placeRepository,
        super(JurorHomePageState(status: BlocStatus.initial)) {
    on<JurorHomePageJoinContest>(_joinContest);
    on<JurorHomePageJoinVotingAsSimpleJuror>(_joinVotingAsSimpleJuror);
  }

  Future<void> _joinContest(
    JurorHomePageJoinContest event,
    Emitter<JurorHomePageState> emit,
  ) async {
    emit(JurorHomePageState(status: BlocStatus.loading));

    final eitherContest =
        await _contestRepository.getContestByToken(token: event.contestToken);
    late final Contest contest;
    eitherContest.fold(
      (failure) => emit(JurorHomePageState(
          status: BlocStatus.failure, message: failure.message)),
      (success) => contest = success,
    );
    if (eitherContest.isLeft()) return;

    late final List<Invitation> invitations;
    final eitherInvitations =
        await _invitationRepository.getInvitationsByContestIdAndMemberRole(
            contestId: contest.id, memberRole: MemberRole.juror);
    eitherInvitations.fold(
      (failure) => emit(JurorHomePageState(
          status: BlocStatus.failure, message: failure.message)),
      (success) => invitations = success,
    );
    if (eitherInvitations.isLeft()) return;

    if (invitations.isEmpty) {
      emit(JurorHomePageState(
          status: BlocStatus.failure,
          message: 'No invitation found with these credentials'));
    }

    for (var invitation in invitations) {
      if (invitation.token == event.jurorToken) {
        late final Juration juration;
        final eitherJuration = await _jurationRepository.createJuration(
            juration: Juration(
          id: invitation.id,
          createdAt: DateTime.now(),
          contestId: contest.id,
          jurorId: event.jurorId,
          jurorStatus: JurorStatus.joined,
        ));
        eitherJuration.fold(
          (failure) => emit(JurorHomePageState(
              status: BlocStatus.failure, message: failure.message)),
          (success) => juration = success,
        );
        if (eitherJuration.isLeft()) return;

        final eitherDeleteInvitation =
            await _invitationRepository.deleteInvitationById(id: invitation.id);
        eitherDeleteInvitation.fold(
            (failure) => emit(JurorHomePageState(
                status: BlocStatus.failure, message: failure.message)),
            (success) => null);
        if (eitherDeleteInvitation.isLeft()) return;

        emit(JurorHomePageState(
            status: BlocStatus.success, jurationJoin: juration));
        break;
      }
    }

    emit(JurorHomePageState(
        status: BlocStatus.failure,
        message: 'No invitation found with these credentials'));
  }

  FutureOr<void> _joinVotingAsSimpleJuror(
    JurorHomePageJoinVotingAsSimpleJuror event,
    Emitter<JurorHomePageState> emit,
  ) async {
    emit(state.copyWith(status: BlocStatus.loading));

    //* Controllo se è presente una voting session con il token fornito dall'utente
    late final VotingSession votingSession;
    final eitherVotingSessionToken = await _votingSessionRepository
        .getVotingSessionByToken(token: event.votingSessionToken);
    eitherVotingSessionToken.fold(
      (failure) => emit(
          state.copyWith(status: BlocStatus.failure, message: failure.message)),
      (success) => votingSession = success,
    );
    if (eitherVotingSessionToken.isLeft()) {
      return;
    }

    //* Controllo se la voting session associata al token è live e se accetta simple jurors
    late final VotingSessionProcedure votingSessionProcedure;
    final eitherVotingSessionProcedure = await _votingSessionProcedureRepository
        .getVotingSessionProcedureByVotingSessionId(
            votingSessionId: votingSession.id);
    eitherVotingSessionProcedure.fold(
      (failure) => emit(
          state.copyWith(status: BlocStatus.failure, message: failure.message)),
      (success) => votingSessionProcedure = success,
    );
    if (eitherVotingSessionProcedure.isLeft()) {
      return;
    }

    if (votingSessionProcedure.isLive == null ||
        !votingSessionProcedure.isLive!) {
      emit(state.copyWith(
          status: BlocStatus.failure, message: 'No live voting session found'));
      return;
    }

    if (!votingSession.areSimpleJurorsAllowed) {
      emit(state.copyWith(
          status: BlocStatus.failure,
          message: 'Simple jurors are not allowed in this voting session'));
      return;
    }

    if (votingSession.isGeoRestricted) {
      //* Ottengo la posizione attuale dell'utente
      final status = await Geolocator.checkPermission();
      if (status == LocationPermission.denied) {
        await Geolocator.requestPermission();
      }
      final currentPosition = await Geolocator.getCurrentPosition();

      late final Place geoRestrictionPlace;
      final eitherGeoRestrictionPlace = await _placeRepository.getPlaceById(
          id: votingSession.geoRestrictionPlaceId!);
      eitherGeoRestrictionPlace.fold(
        (failure) => emit(state.copyWith(
            status: BlocStatus.failure, message: failure.message)),
        (success) => geoRestrictionPlace = success,
      );
      if (eitherGeoRestrictionPlace.isLeft()) {
        return;
      }

      final distance = Geolocator.distanceBetween(
        geoRestrictionPlace.lat,
        geoRestrictionPlace.lon,
        currentPosition.latitude,
        currentPosition.longitude,
      );

      if (distance > votingSession.geoRestrictionRadius!) {
        emit(state.copyWith(
            status: BlocStatus.failure,
            message:
                'The voting is georestricted and you are not inside the area of voting:\n${geoRestrictionPlace.address}'));
        return;
      }
    }

    //* Creo un simple juror
    late final SimpleJuror simpleJuror;
    final eitherSimpleJuror = await _simpleJurorRepository.createSimpleJuror(
        simpleJuror: SimpleJuror(
      id: genUuid(),
      createdAt: DateTime.now(),
      fullName: event.fullName,
    ));
    eitherSimpleJuror.fold(
      (failure) => emit(
          state.copyWith(status: BlocStatus.failure, message: failure.message)),
      (success) => simpleJuror = success,
    );
    if (eitherSimpleJuror.isLeft()) {
      return;
    }

    //* Creo un votingSessionSimpleJuror
    late final VotingSessionSimpleJuror votingSessionSimpleJuror;
    final eitherVotingSessionSimpleJuror =
        await _votingSessionSimpleJurorRepository
            .createVotingSessionSimpleJuror(
                votingSessionSimpleJuror: VotingSessionSimpleJuror(
      id: genUuid(),
      createdAt: DateTime.now(),
      votingSessionId: votingSession.id,
      simpleJurorId: simpleJuror.id,
      hasSubmitted: false,
    ));
    eitherVotingSessionSimpleJuror.fold(
      (failure) => emit(
          state.copyWith(status: BlocStatus.failure, message: failure.message)),
      (success) => votingSessionSimpleJuror = success,
    );
    if (eitherVotingSessionSimpleJuror.isLeft()) {
      return;
    }

    late final List<VotingSessionParticipant> votingSessionParticipants;
    final eitherVotingSessionParticipants =
        await _votingSessionParticipantRepository
            .getVotingSessionParticipantsByVotingSessionId(
                votingSessionId: votingSession.id);
    eitherVotingSessionParticipants.fold(
      (failure) => emit(
          state.copyWith(status: BlocStatus.failure, message: failure.message)),
      (success) => votingSessionParticipants = success,
    );
    if (eitherVotingSessionParticipants.isLeft()) {
      return;
    }

    //* Predispongo già una istanza di voting per ogni participant che il simple juror utilizzerà
    final List<SimpleJurorVoting> simpleJurorVotings = [];
    for (var votingSessionParticipant in votingSessionParticipants) {
      final eitherSimpleJurorVoting =
          await _simpleJurorVotingRepository.createSimpleJurorVoting(
              simpleJurorVoting: SimpleJurorVoting(
        id: genUuid(),
        createdAt: DateTime.now(),
        votingSessionId: votingSession.id,
        votingSessionSimpleJurorId: votingSessionSimpleJuror.id,
        votingSessionParticipantId: votingSessionParticipant.id,
      ));
      eitherSimpleJurorVoting.fold(
        (failure) => emit(state.copyWith(
            status: BlocStatus.failure, message: failure.message)),
        (success) => simpleJurorVotings.add(success),
      );
      if (eitherSimpleJurorVoting.isLeft()) {
        return;
      }
    }

    emit(state.copyWith(
      status: BlocStatus.success,
      votingSession: votingSession,
      votingSessionSimpleJuror: votingSessionSimpleJuror,
    ));
  }
}
