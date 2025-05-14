import 'dart:async';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:swift_contest/model/data_models/participation.dart';
import 'package:swift_contest/model/data_models/place.dart';
import 'package:swift_contest/model/data_models/profile.dart';
import 'package:swift_contest/model/data_models/juror_vote.dart';
import 'package:swift_contest/model/data_models/juror_voting.dart';
import 'package:swift_contest/model/data_models/voting_form.dart';
import 'package:swift_contest/model/data_models/voting_form_field.dart';
import 'package:swift_contest/model/data_models/voting_session.dart';
import 'package:swift_contest/model/data_models/voting_session_juror.dart';
import 'package:swift_contest/model/data_models/voting_session_participant.dart';
import 'package:swift_contest/model/data_models/voting_session_procedure.dart';
import 'package:swift_contest/model/data_models/work.dart';
import 'package:swift_contest/utils/functions/gen_uuid.dart';
import 'package:swift_contest/viewmodel/blocs/bloc_status.dart';
import 'package:swift_contest/viewmodel/repositories/participation_repository.dart';
import 'package:swift_contest/viewmodel/repositories/place_repository.dart';
import 'package:swift_contest/viewmodel/repositories/profile_repository.dart';
import 'package:swift_contest/viewmodel/repositories/juror_vote_repository.dart';
import 'package:swift_contest/viewmodel/repositories/voting_form_field_repository.dart';
import 'package:swift_contest/viewmodel/repositories/voting_form_repository.dart';
import 'package:swift_contest/viewmodel/repositories/juror_voting_repository.dart';
import 'package:swift_contest/viewmodel/repositories/voting_session_juror_repository.dart';
import 'package:swift_contest/viewmodel/repositories/voting_session_participant_repository.dart';
import 'package:swift_contest/viewmodel/repositories/voting_session_procedure_repository.dart';
import 'package:swift_contest/viewmodel/repositories/voting_session_repository.dart';
import 'package:swift_contest/viewmodel/repositories/work_repository.dart';

part 'juror_voting_procedure_page_event.dart';

part 'juror_voting_procedure_page_state.dart';

class JurorVotingProcedurePageBloc
    extends Bloc<JurorVotingProcedurePageEvent, JurorVotingProcedurePageState> {
  final VotingSessionRepository _votingSessionRepository;
  final VotingSessionProcedureRepository _votingSessionProcedureRepository;
  final VotingSessionParticipantRepository _votingSessionParticipantRepository;
  final WorkRepository _workRepository;
  final ParticipationRepository _participationRepository;
  final ProfileRepository _profileRepository;
  final VotingFormRepository _votingFormRepository;
  final VotingFormFieldRepository _votingFormFieldRepository;
  final VotingSessionJurorRepository _votingSessionJurorRepository;
  final JurorVotingRepository _jurorVotingRepository;
  final JurorVoteRepository _jurorVoteRepository;
  final PlaceRepository _placeRepository;

  JurorVotingProcedurePageBloc({
    required VotingSessionRepository votingSessionRepository,
    required VotingSessionProcedureRepository votingSessionProcedureRepository,
    required VotingSessionParticipantRepository
        votingSessionParticipantRepository,
    required WorkRepository workRepository,
    required ParticipationRepository participationRepository,
    required ProfileRepository profileRepository,
    required VotingFormRepository votingFormRepository,
    required VotingFormFieldRepository votingFormFieldRepository,
    required VotingSessionJurorRepository votingSessionJurorRepository,
    required JurorVotingRepository jurorVotingRepository,
    required JurorVoteRepository jurorVoteRepository,
    required PlaceRepository placeRepository,
  })  : _votingSessionRepository = votingSessionRepository,
        _votingSessionProcedureRepository = votingSessionProcedureRepository,
        _votingSessionParticipantRepository =
            votingSessionParticipantRepository,
        _workRepository = workRepository,
        _participationRepository = participationRepository,
        _votingFormRepository = votingFormRepository,
        _votingFormFieldRepository = votingFormFieldRepository,
        _profileRepository = profileRepository,
        _votingSessionJurorRepository = votingSessionJurorRepository,
        _jurorVotingRepository = jurorVotingRepository,
        _jurorVoteRepository = jurorVoteRepository,
        _placeRepository = placeRepository,
        super(JurorVotingProcedurePageState(status: BlocStatus.initial)) {
    on<JurorVotingProcedurePageSubscribeToVotingSessionProcedure>(
        _subscribeToVotingSessionProcedure);
    on<JurorVotingProcedurePageSubmitVotes>(_submitVotes);
  }

  FutureOr<void> _subscribeToVotingSessionProcedure(
    JurorVotingProcedurePageSubscribeToVotingSessionProcedure event,
    Emitter<JurorVotingProcedurePageState> emit,
  ) async {
    emit(state.copyWith(status: BlocStatus.loading));

    late final List<VotingSession> votingSessions;
    final eitherVotingSession = await _votingSessionRepository
        .getVotingSessionsByContestId(contestId: event.contestId);
    eitherVotingSession.fold(
      (failure) => emit(
          state.copyWith(status: BlocStatus.failure, message: failure.message)),
      (success) => votingSessions = success,
    );
    if (eitherVotingSession.isLeft()) {
      return;
    }

    VotingSession? votingSession;
    VotingSessionProcedure? liveVotingSessionProcedure;
    for (var session in votingSessions) {
      final eitherVotingProcedures = await _votingSessionProcedureRepository
          .getVotingSessionProcedureByVotingSessionId(
              votingSessionId: session.id);
      eitherVotingProcedures.fold(
        (failure) => emit(state.copyWith(
            status: BlocStatus.failure, message: failure.message)),
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
      emit(state.copyWith(
          status: BlocStatus.failure,
          message: 'No live voting session procedure'));
    }

    if (votingSession!.isGeoRestricted) {
      final status = await Geolocator.checkPermission();
      if (status == LocationPermission.denied) {
        await Geolocator.requestPermission();
      }
      final currentPosition = await Geolocator.getCurrentPosition();

      late final Place geoRestrictionPlace;
      final eitherGeoRestrictionPlace = await _placeRepository.getPlaceById(
          id: votingSession!.geoRestrictionPlaceId!);
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

      if (distance > votingSession!.geoRestrictionRadius!) {
        emit(state.copyWith(
            status: BlocStatus.failure,
            message:
            'The voting is georestricted and you are not inside the area of voting:\n${geoRestrictionPlace.address}'));
        return;
      }
    }

    late final List<VotingSessionParticipant> votingSessionParticipants;
    final eitherVotingSessionParticipants =
        await _votingSessionParticipantRepository
            .getVotingSessionParticipantsByVotingSessionId(
      votingSessionId: votingSession!.id,
    );
    eitherVotingSessionParticipants.fold(
      (failure) => emit(
          state.copyWith(status: BlocStatus.failure, message: failure.message)),
      (success) => votingSessionParticipants = success,
    );
    if (eitherVotingSessionParticipants.isLeft()) {
      return;
    }

    final List<Participant> participants = [];
    final List<Work> works = [];
    for (var votingSessionParticipant in votingSessionParticipants) {
      late final Participation participation;
      final eitherParticipation = await _participationRepository
          .getParticipationByContestIdAndParticipantId(
              contestId: event.contestId,
              participantId: votingSessionParticipant.participantId);
      eitherParticipation.fold(
        (failure) => emit(state.copyWith(
            status: BlocStatus.failure, message: failure.message)),
        (success) => participation = success,
      );
      if (eitherParticipation.isLeft()) {
        return;
      }

      final eitherParticipant = await _profileRepository.getProfileById(
          id: participation.participantId);
      eitherParticipant.fold(
        (failure) => emit(state.copyWith(
            status: BlocStatus.failure, message: failure.message)),
        (success) => participants.add(success),
      );
      if (eitherParticipant.isLeft()) {
        return;
      }

      final eitherWork = await _workRepository.getWorkByParticipationId(
          participationId: participation.id);
      eitherWork.fold(
        (failure) => emit(state.copyWith(
            status: BlocStatus.failure, message: failure.message)),
        (success) => works.add(success),
      );
      if (eitherWork.isLeft()) {
        return;
      }
    }

    late final VotingSessionJuror votingSessionJuror;
    final eitherVotingSessionJuror = await _votingSessionJurorRepository
        .getVotingSessionJurorByVotingSessionIdAndJurorId(
            votingSessionId: votingSession!.id, jurorId: event.jurorId);
    eitherVotingSessionJuror.fold(
      (failure) => emit(
          state.copyWith(status: BlocStatus.failure, message: failure.message)),
      (success) => votingSessionJuror = success,
    );
    if (eitherVotingSessionJuror.isLeft()) {
      return;
    }

    late final List<JurorVoting> votings;
    final eitherVotings =
        await _jurorVotingRepository.getJurorVotingsByVotingSessionJurorId(
            votingSessionJurorId: votingSessionJuror.id);
    eitherVotings.fold(
      (failure) => emit(
          state.copyWith(status: BlocStatus.failure, message: failure.message)),
      (success) => votings = success,
    );
    if (eitherVotings.isLeft()) {
      return;
    }

    final List<String> excludedVotingSessionParticipantsIds = votings
        .where((e) => e.isExcluded)
        .map((e) => e.votingSessionParticipantId)
        .toList(growable: false);
    final List<Participant> excludedFromParticipants =
        excludedVotingSessionParticipantsIds.map((votingSessionParticipantId) {
      final votingSessionParticipant = votingSessionParticipants
          .firstWhere((e) => e.id == votingSessionParticipantId);
      final participant = participants.firstWhere(
          (par) => par.id == votingSessionParticipant.participantId);
      return participant;
    }).toList(growable: false);

    late final VotingForm votingForm;
    final eitherVotingForm = await _votingFormRepository.getVotingFormById(
        id: votingSession!.votingFormId);
    eitherVotingForm.fold(
      (failure) => emit(
          state.copyWith(status: BlocStatus.failure, message: failure.message)),
      (success) => votingForm = success,
    );
    if (eitherVotingForm.isLeft()) {
      return;
    }

    late final List<VotingFormField> votingFormFields;
    final eitherVotingFormFields = await _votingFormFieldRepository
        .getVotingFormFieldsByVotingFormId(votingFormId: votingForm.id);
    eitherVotingFormFields.fold(
      (failure) => emit(
          state.copyWith(status: BlocStatus.failure, message: failure.message)),
      (success) => votingFormFields = success,
    );
    if (eitherVotingFormFields.isLeft()) {
      return;
    }

    votingFormFields.sort((a, b) => a.orderIndex.compareTo(b.orderIndex));

    emit(state.copyWith(
      status: BlocStatus.loading,
      votingSession: votingSession,
      votingSessionParticipants: votingSessionParticipants,
      participants: participants,
      works: works,
      excludedVotingSessionParticipantsIds:
          excludedVotingSessionParticipantsIds,
      votingForm: votingForm,
      votingFormFields: votingFormFields,
      excludedFromParticipants: excludedFromParticipants,
    ));

    late Stream<VotingSessionProcedure> votingSessionProcedureStream;
    final result =
        await _votingSessionProcedureRepository.getVotingSessionProcedureStream(
      votingSessionProcedureId: liveVotingSessionProcedure!.id,
    );
    result.fold(
      (failure) => emit(
          state.copyWith(status: BlocStatus.failure, message: failure.message)),
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
        return state.copyWith(
            status: BlocStatus.failure, message: error.toString());
      },
    );
  }

  FutureOr<void> _submitVotes(
    JurorVotingProcedurePageSubmitVotes event,
    Emitter<JurorVotingProcedurePageState> emit,
  ) async {
    emit(state.copyWith(status: BlocStatus.loading));

    late final VotingSession votingSession;
    final eitherVotingSession = await _votingSessionRepository.getVotingSessionById(id: event.votingSessionId);
    eitherVotingSession.fold(
        (failure) => emit(state.copyWith(status: BlocStatus.failure,message: failure.message)),
        (success) => votingSession = success,
    );
    if(eitherVotingSession.isLeft()) {
      return;
    }

    if (votingSession.isGeoRestricted) {
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

      if (distance > votingSession!.geoRestrictionRadius!) {
        emit(state.copyWith(
            status: BlocStatus.failure,
            message:
            'The voting is georestricted and you are not inside the area of voting:\n${geoRestrictionPlace.address}'));
        return;
      }
    }

    late final VotingSessionJuror votingSessionJuror;
    final eitherVotingSessionJuror = await _votingSessionJurorRepository
        .getVotingSessionJurorByVotingSessionIdAndJurorId(
            votingSessionId: event.votingSessionId, jurorId: event.jurorId);
    eitherVotingSessionJuror.fold(
      (failure) => emit(
          state.copyWith(status: BlocStatus.failure, message: failure.message)),
      (success) => votingSessionJuror = success,
    );
    if (eitherVotingSessionJuror.isLeft()) {
      return;
    }

    final votesPerParticipantList = event.votesPerParticipantMap.entries;
    for (var votesPerParticipant in votesPerParticipantList) {
      final VotingSessionParticipant votingSessionParticipant =
          votesPerParticipant.key;
      final votesList = votesPerParticipant.value.entries;

      late final JurorVoting voting;
      final eitherVoting = await _jurorVotingRepository
          .getJurorVotingByVotingSessionJurorIdAndVotingSessionParticipantId(
              votingSessionJurorId: votingSessionJuror.id,
              votingSessionParticipantId: votingSessionParticipant.id);
      eitherVoting.fold(
        (failure) => emit(state.copyWith(
            status: BlocStatus.failure, message: failure.message)),
        (success) => voting = success,
      );
      if (eitherVoting.isLeft()) {
        return;
      }

      for (var v in votesList) {
        final VotingFormField votingFormField = v.key;
        final String value = v.value;

        late final JurorVote vote;
        final eitherVote = await _jurorVoteRepository.createJurorVote(
          jurorVote: JurorVote(
            id: genUuid(),
            createdAt: DateTime.now(),
            jurorVotingId: voting.id,
            votingFormFieldId: votingFormField.id,
            value: value,
          ),
        );
        eitherVote.fold(
          (failure) => emit(state.copyWith(
              status: BlocStatus.failure, message: failure.message)),
          (success) => vote = success,
        );
        if (eitherVote.isLeft()) {
          return;
        }
      }
    }

    final eitherVotingSessionJurorUpdate =
        await _votingSessionJurorRepository.updateVotingSessionJurorById(
      id: votingSessionJuror.id,
      votingSessionJuror: votingSessionJuror.copyWith(hasSubmitted: true),
    );
    eitherVotingSessionJurorUpdate.fold(
      (failure) => emit(
          state.copyWith(status: BlocStatus.failure, message: failure.message)),
      (success) => null,
    );
    if (eitherVotingSessionJurorUpdate.isLeft()) {
      return;
    }

    emit(state.copyWith(status: BlocStatus.success));
  }
}
