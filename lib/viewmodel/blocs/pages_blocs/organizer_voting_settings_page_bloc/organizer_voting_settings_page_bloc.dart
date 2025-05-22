import 'dart:async';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:swift_contest/model/data_models/place.dart';
import 'package:swift_contest/model/data_models/profile.dart';
import 'package:swift_contest/model/data_models/juror_voting.dart';
import 'package:swift_contest/model/data_models/voting_form.dart';
import 'package:swift_contest/model/data_models/voting_form_field.dart';
import 'package:swift_contest/model/data_models/voting_session.dart';
import 'package:swift_contest/model/data_models/voting_session_juror.dart';
import 'package:swift_contest/model/data_models/voting_session_participant.dart';
import 'package:swift_contest/model/data_models/voting_session_procedure.dart';
import 'package:swift_contest/model/mixed_models/participant_and_juror.dart';
import 'package:swift_contest/utils/functions/gen_uuid.dart';
import 'package:swift_contest/viewmodel/enums/bloc_status.dart';
import 'package:swift_contest/viewmodel/repositories/place_repository.dart';
import 'package:swift_contest/viewmodel/repositories/utils_repository.dart';
import 'package:swift_contest/viewmodel/repositories/voting_form_field_repository.dart';
import 'package:swift_contest/viewmodel/repositories/voting_form_repository.dart';
import 'package:swift_contest/viewmodel/repositories/juror_voting_repository.dart';
import 'package:swift_contest/viewmodel/repositories/voting_session_juror_repository.dart';
import 'package:swift_contest/viewmodel/repositories/voting_session_participant_repository.dart';
import 'package:swift_contest/viewmodel/repositories/voting_session_procedure_repository.dart';
import 'package:swift_contest/viewmodel/repositories/voting_session_repository.dart';

part 'organizer_voting_settings_page_event.dart';

part 'organizer_voting_settings_page_state.dart';

class OrganizerVotingSettingsPageBloc extends Bloc<
    OrganizerVotingSettingsPageEvent, OrganizerVotingSettingsPageState> {
  final VotingFormRepository _votingFormRepository;
  final VotingSessionRepository _votingSessionRepository;
  final VotingFormFieldRepository _votingFormFieldRepository;
  final VotingSessionParticipantRepository _votingSessionParticipantRepository;
  final VotingSessionJurorRepository _votingSessionJurorRepository;
  final VotingSessionProcedureRepository _votingSessionProcedureRepository;
  final JurorVotingRepository _jurorVotingRepository;
  final UtilsRepository _utilsRepository;
  final PlaceRepository _placeRepository;

  OrganizerVotingSettingsPageBloc({
    required VotingFormRepository votingFormRepository,
    required VotingSessionRepository votingSessionRepository,
    required VotingFormFieldRepository votingFormFieldRepository,
    required VotingSessionParticipantRepository
        votingSessionParticipantRepository,
    required VotingSessionJurorRepository votingSessionJurorRepository,
    required VotingSessionProcedureRepository votingSessionProcedureRepository,
    required JurorVotingRepository jurorVotingRepository,
    required UtilsRepository utilsRepository,
    required PlaceRepository placeRepository,
  })  : _votingFormRepository = votingFormRepository,
        _votingSessionRepository = votingSessionRepository,
        _votingFormFieldRepository = votingFormFieldRepository,
        _votingSessionParticipantRepository =
            votingSessionParticipantRepository,
        _votingSessionJurorRepository = votingSessionJurorRepository,
        _votingSessionProcedureRepository = votingSessionProcedureRepository,
        _jurorVotingRepository = jurorVotingRepository,
        _utilsRepository = utilsRepository,
        _placeRepository = placeRepository,
        super(OrganizerVotingSettingsPageState(status: BlocStatus.initial)) {
    on<OrganizerVotingSettingsPageCreateVotingSessionAndBeginProcedure>(
        _createVotingSessionAndBeginProcedure);
  }

  FutureOr<void> _createVotingSessionAndBeginProcedure(
    OrganizerVotingSettingsPageCreateVotingSessionAndBeginProcedure event,
    Emitter<OrganizerVotingSettingsPageState> emit,
  ) async {
    emit(state.copyWith(status: BlocStatus.loading));

    late final VotingForm oldVotingForm;
    final eitherOldVotingForm =
        await _votingFormRepository.getVotingFormById(id: event.votingFormId);
    eitherOldVotingForm.fold(
      (failure) => emit(
          state.copyWith(status: BlocStatus.failure, message: failure.message)),
      (success) => oldVotingForm = success,
    );
    if (eitherOldVotingForm.isLeft()) {
      return;
    }

    late final List<VotingFormField> oldVotingFormFields;
    final eitherOldVotingFormFields = await _votingFormFieldRepository
        .getVotingFormFieldsByVotingFormId(votingFormId: oldVotingForm.id);
    eitherOldVotingFormFields.fold(
      (failure) => emit(
          state.copyWith(status: BlocStatus.failure, message: failure.message)),
      (success) => oldVotingFormFields = success,
    );
    if (eitherOldVotingFormFields.isLeft()) {
      return;
    }

    late final VotingForm votingForm;
    final eitherVotingForm = await _votingFormRepository.createVotingForm(
        votingForm: VotingForm(
      id: genUuid(),
      createdAt: DateTime.now(),
    ));
    eitherVotingForm.fold(
      (failure) => emit(
          state.copyWith(status: BlocStatus.failure, message: failure.message)),
      (success) => votingForm = success,
    );
    if (eitherVotingForm.isLeft()) {
      return;
    }

    final List<VotingFormField> votingFormFields = [];
    for (var vff in oldVotingFormFields) {
      final eitherVotingFormField =
          await _votingFormFieldRepository.createVotingFormField(
        votingFormField: VotingFormField(
          id: genUuid(),
          createdAt: DateTime.now(),
          votingFormId: votingForm.id,
          name: vff.name,
          orderIndex: vff.orderIndex,
          minValue: vff.minValue,
          maxValue: vff.maxValue,
        ),
      );
      eitherVotingFormField.fold(
        (failure) => emit(state.copyWith(
            status: BlocStatus.failure, message: failure.message)),
        (success) => votingFormFields.add(success),
      );
      if (eitherVotingFormField.isLeft()) {
        return;
      }
    }

    //* Create a new voting session
    late final String token;
    final eitherToken = await _utilsRepository.genUniqueToken(
        tableName: 'voting_sessions', columnName: 'token', length: 8);
    eitherToken.fold(
      (failure) => emit(
          state.copyWith(status: BlocStatus.failure, message: failure.message)),
      (success) => token = success,
    );
    if (eitherToken.isLeft()) {
      return;
    }

    //* Creo un nuovo place da associare alla voting session
    Place? geoRestrictionPlace;
    if (event.isGeoRestricted) {
      final eitherGeoRestrictionPlace = await _placeRepository.createPlace(
          place: Place(
        id: genUuid(),
        createdAt: DateTime.now(),
        address: event.geoRestrictionPlaceAddress!,
        lat: event.geoRestrictionPlaceLat!,
        lon: event.geoRestrictionPlaceLon!,
      ));
      eitherGeoRestrictionPlace.fold(
        (failure) => emit(state.copyWith(
            status: BlocStatus.failure, message: failure.message)),
          (success) => geoRestrictionPlace = success,
      );
      if (eitherGeoRestrictionPlace.isLeft()) {
        return;
      }
    }

    late final VotingSession votingSession;
    // final DateTime? currentStepDeadline = (event.workTimer != null) ? DateTime.now().add(event.workTimer!) : null;
    final createdAt = DateTime.now();
    final eitherVotingSession =
        await _votingSessionRepository.createVotingSession(
            votingSession: VotingSession(
      id: genUuid(),
      createdAt: createdAt,
      name:
          'Voting ${createdAt.day.toString().padLeft(2, '0')}.${createdAt.month.toString().padLeft(2, '0')}.${createdAt.year}',
      contestId: event.contestId,
      areSimpleJurorsAllowed: event.areSimpleJurorsAllowed,
      votingFormId: votingForm.id,
      workTimer: event.workTimer,
      intermissionTimer: event.intermissionTimer,
      reviewTimer: event.reviewTimer,
      isEnded: false,
      token: token,
      isGeoRestricted: event.isGeoRestricted,
      geoRestrictionPlaceId: (event.isGeoRestricted) ? geoRestrictionPlace!.id : null,
      geoRestrictionRadius: (event.isGeoRestricted) ? event.geoRestrictionRadius : null,
    ));
    eitherVotingSession.fold(
      (failure) => emit(
          state.copyWith(status: BlocStatus.failure, message: failure.message)),
      (success) => votingSession = success,
    );
    if (eitherVotingSession.isLeft()) {
      return;
    }

    //* Create voting session participants
    for (var i = 0; i < event.votingParticipants.length; i++) {
      final participant = event.votingParticipants[i];
      final eitherVotingSessionParticipant =
          await _votingSessionParticipantRepository
              .createVotingSessionParticipant(
                  votingSessionParticipant: VotingSessionParticipant(
        id: genUuid(),
        createdAt: DateTime.now(),
        votingSessionId: votingSession.id,
        participantId: participant.id,
        orderIndex: i,
      ));
      eitherVotingSessionParticipant.fold(
          (failure) => emit(state.copyWith(
              status: BlocStatus.failure, message: failure.message)),
          (success) => null);
    }
    if (eitherVotingSession.isLeft()) {
      return;
    }

    //* Create voting session jurors
    for (var juror in event.votingJurors) {
      final eitherVotingSessionJuror =
          await _votingSessionJurorRepository.createVotingSessionJuror(
              votingSessionJuror: VotingSessionJuror(
        id: genUuid(),
        createdAt: DateTime.now(),
        votingSessionId: votingSession.id,
        jurorId: juror.id,
        hasSubmitted: false,
      ));
      eitherVotingSessionJuror.fold(
          (failure) => emit(state.copyWith(
              status: BlocStatus.failure, message: failure.message)),
          (success) => null);
      if (eitherVotingSession.isLeft()) {
        return;
      }
    }

    for (var votingJuror in event.votingJurors) {
      for (var votingParticipant in event.votingParticipants) {
        bool isExcluded = false;
        if (event.votingExclusions.contains(ParticipantAndJuror(
            participant: votingParticipant, juror: votingJuror))) {
          isExcluded = true;
        }

        late final VotingSessionJuror votingSessionJuror;
        final eitherVotingSessionJuror = await _votingSessionJurorRepository
            .getVotingSessionJurorByVotingSessionIdAndJurorId(
          votingSessionId: votingSession.id,
          jurorId: votingJuror.id,
        );
        eitherVotingSessionJuror.fold(
          (failure) => emit(state.copyWith(
              status: BlocStatus.failure, message: failure.message)),
          (success) => votingSessionJuror = success,
        );
        if (eitherVotingSessionJuror.isLeft()) {
          return;
        }

        late final VotingSessionParticipant votingSessionParticipant;
        final eitherVotingSessionParticipant =
            await _votingSessionParticipantRepository
                .getVotingSessionParticipantByVotingSessionIdAndParticipantId(
          votingSessionId: votingSession.id,
          participantId: votingParticipant.id,
        );
        eitherVotingSessionParticipant.fold(
          (failure) => emit(state.copyWith(
              status: BlocStatus.failure, message: failure.message)),
          (success) => votingSessionParticipant = success,
        );
        if (eitherVotingSessionParticipant.isLeft()) {
          return;
        }

        late final JurorVoting voting;
        final eitherVoting = await _jurorVotingRepository.createJurorVoting(
          jurorVoting: JurorVoting(
            id: genUuid(),
            createdAt: DateTime.now(),
            votingSessionId: votingSession.id,
            votingSessionJurorId: votingSessionJuror.id,
            votingSessionParticipantId: votingSessionParticipant.id,
            isExcluded: isExcluded,
          ),
        );
        eitherVoting.fold(
            (failure) => emit(state.copyWith(
                status: BlocStatus.failure, message: failure.message)),
            (success) => voting = success);
      }
    }

    late final VotingSessionProcedure votingSessionProcedure;
    final eitherVotingSessionProcedure =
        await _votingSessionProcedureRepository.createVotingSessionProcedure(
            votingSessionProcedure: VotingSessionProcedure(
      id: genUuid(),
      createdAt: DateTime.now(),
      votingSessionId: votingSession.id,
    ));
    eitherVotingSessionProcedure.fold(
      (failure) {
        emit(state.copyWith(
            status: BlocStatus.failure, message: failure.message));
        return;
      },
      (success) => votingSessionProcedure = success,
    );

    final eitherBeginVotingSessionProcedure =
        await _votingSessionProcedureRepository.beginVotingSessionProcedureById(
            id: votingSessionProcedure.id);
    eitherBeginVotingSessionProcedure.fold(
      (failure) {
        emit(state.copyWith(
            status: BlocStatus.failure, message: failure.message));
        return;
      },
      (success) => null,
    );

    emit(state.copyWith(
      status: BlocStatus.success,
      votingSession: votingSession,
    ));
  }
}
