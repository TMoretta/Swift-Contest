import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:swift_contest/model/bundles/juration_bundle.dart';
import 'package:swift_contest/model/bundles/participation_bundle.dart';
import 'package:swift_contest/model/bundles/voting_exclusion_bundle.dart';
import 'package:swift_contest/model/bundles/voting_form_bundle.dart';
import 'package:swift_contest/model/bundles/organizer_voting_session_bundle.dart';
import 'package:swift_contest/model/bundles/voting_session_exclusion_bundle.dart';
import 'package:swift_contest/model/bundles/voting_session_juration_bundle.dart';
import 'package:swift_contest/model/bundles/voting_session_participation_bundle.dart';
import 'package:swift_contest/model/data_models/place.dart';
import 'package:swift_contest/model/data_models/voting_form.dart';
import 'package:swift_contest/model/data_models/voting_form_field.dart';
import 'package:swift_contest/model/data_models/voting_session.dart';
import 'package:swift_contest/model/data_models/voting_session_exclusion.dart';
import 'package:swift_contest/model/data_models/voting_session_juration.dart';
import 'package:swift_contest/model/data_models/voting_session_participation.dart';
import 'package:swift_contest/model/data_models/voting_session_procedure.dart';
import 'package:swift_contest/model/enums/voting_session_procedure_step.dart';
import 'package:swift_contest/model/enums/voting_session_status.dart';
import 'package:swift_contest/model/repositories/crud_repositories/juror_voting_repository.dart';
import 'package:swift_contest/model/repositories/role_repositories/organizer_repository.dart';
import 'package:swift_contest/model/repositories/crud_repositories/place_repository.dart';
import 'package:swift_contest/model/repositories/utils_repository.dart';
import 'package:swift_contest/model/repositories/crud_repositories/voting_form_field_repository.dart';
import 'package:swift_contest/model/repositories/crud_repositories/voting_form_repository.dart';
import 'package:swift_contest/model/repositories/crud_repositories/voting_session_exclusion_repository.dart';
import 'package:swift_contest/model/repositories/crud_repositories/voting_session_juration_repository.dart';
import 'package:swift_contest/model/repositories/crud_repositories/voting_session_participation_repository.dart';
import 'package:swift_contest/model/repositories/crud_repositories/voting_session_procedure_repository.dart';
import 'package:swift_contest/model/repositories/crud_repositories/voting_session_repository.dart';
import 'package:swift_contest/utils/functions/gen_uuid.dart';
import 'package:swift_contest/utils/functions/now.dart';
import 'package:swift_contest/viewmodel/enums/bloc_status.dart';

part 'organizer_voting_settings_page_event.dart';

part 'organizer_voting_settings_page_state.dart';

class OrganizerVotingSettingsPageBloc
    extends Bloc<OrganizerVotingSettingsPageEvent, OrganizerVotingSettingsPageState> {
  final VotingFormRepository _votingFormRepository;
  final VotingSessionRepository _votingSessionRepository;
  final VotingFormFieldRepository _votingFormFieldRepository;
  final VotingSessionParticipationRepository _votingSessionParticipationRepository;
  final VotingSessionJurationRepository _votingSessionJurationRepository;
  final UtilsRepository _utilsRepository;
  final PlaceRepository _placeRepository;
  final VotingSessionExclusionRepository _votingSessionExclusionRepository;
  final OrganizerRepository _organizerRepository;

  OrganizerVotingSettingsPageBloc({
    required VotingFormRepository votingFormRepository,
    required VotingSessionRepository votingSessionRepository,
    required VotingFormFieldRepository votingFormFieldRepository,
    required VotingSessionParticipationRepository votingSessionParticipationRepository,
    required VotingSessionJurationRepository votingSessionJurationRepository,
    required UtilsRepository utilsRepository,
    required PlaceRepository placeRepository,
    required VotingSessionExclusionRepository votingSessionExclusionRepository,
    required OrganizerRepository organizerRepository,
  })  : _votingFormRepository = votingFormRepository,
        _votingSessionRepository = votingSessionRepository,
        _votingFormFieldRepository = votingFormFieldRepository,
        _votingSessionParticipationRepository = votingSessionParticipationRepository,
        _votingSessionJurationRepository = votingSessionJurationRepository,
        _utilsRepository = utilsRepository,
        _placeRepository = placeRepository,
        _votingSessionExclusionRepository = votingSessionExclusionRepository,
        _organizerRepository = organizerRepository,
        super(OrganizerVotingSettingsPageState(status: BlocStatus.initial)) {
    on<OrganizerVotingSettingsPageBeginVotingProcedure>(_createVotingSessionAndBeginProcedure);
  }

  FutureOr<void> _createVotingSessionAndBeginProcedure(
    OrganizerVotingSettingsPageBeginVotingProcedure event,
    Emitter<OrganizerVotingSettingsPageState> emit,
  ) async {
    emit(state.copyWith(status: BlocStatus.loading, sourceEvent: event));

    late final List<VotingFormField> contestVotingFormFields;
    final eitherOldVotingFormFields = await _votingFormFieldRepository
        .getVotingFormFieldsByVotingFormId(votingFormId: event.votingFormId);
    eitherOldVotingFormFields.fold(
      (failure) => emit(state.copyWith(status: BlocStatus.failure, message: failure.message)),
      (success) => contestVotingFormFields = success,
    );
    if (eitherOldVotingFormFields.isLeft()) {
      return;
    }

    final VotingForm votingForm = VotingForm(
      id: genUuid(),
      createdAt: now(),
    );

    final List<VotingFormField> votingFormFields = contestVotingFormFields
        .map((e) => e.copyWith(id: genUuid(), createdAt: now(), votingFormId: votingForm.id))
        .toList(growable: false);

    //* Generate an unique token for the session
    late final String token;
    final eitherToken = await _utilsRepository.genUniqueToken(
        tableName: 'voting_sessions', columnName: 'token', length: 14);
    eitherToken.fold(
      (failure) => emit(state.copyWith(status: BlocStatus.failure, message: failure.message)),
      (success) => token = success,
    );
    if (eitherToken.isLeft()) {
      return;
    }

    //* Create a new place for the session only if georestricted
    Place? geoRestrictionPlace = (event.isGeoRestricted)
        ? Place(
            id: genUuid(),
            createdAt: now(),
            address: event.geoRestrictionPlaceAddress!,
            lat: event.geoRestrictionPlaceLat!,
            lon: event.geoRestrictionPlaceLon!,
          )
        : null;

    final createdAt = now();
    final VotingSession votingSession = VotingSession(
      id: genUuid(),
      createdAt: createdAt,
      name:
          'Voting ${createdAt.day.toString().padLeft(2, '0')}.${createdAt.month.toString().padLeft(2, '0')}.${createdAt.year}.${createdAt.hour.toString().padLeft(2, '0')}.${createdAt.minute.toString().padLeft(2, '0')}.${createdAt.second.toString().padLeft(2, '0')}',
      contestId: event.contestId,
      areSimpleJurorsAllowed: event.areSimpleJurorsAllowed,
      votingFormId: votingForm.id,
      workTimer: event.workTimer,
      intermissionTimer: event.intermissionTimer,
      reviewTimer: event.reviewTimer,
      sessionStatus: VotingSessionStatus.initialized,
      token: token,
      isGeoRestricted: event.isGeoRestricted,
      geoRestrictionPlaceId: (event.isGeoRestricted) ? geoRestrictionPlace!.id : null,
      geoRestrictionRadius: (event.isGeoRestricted) ? event.geoRestrictionRadius : null,
    );

    //* Create voting session participations
    final List<VotingSessionParticipation> votingSessionParticipations = [];
    for (int i = 0; i < event.votingParticipationsBundles.length; i++) {
      final participation = event.votingParticipationsBundles[i].participation;
      final votingSessionParticipation = VotingSessionParticipation(
        id: genUuid(),
        createdAt: now(),
        votingSessionId: votingSession.id,
        participationId: participation.id,
        orderIndex: i,
      );
      votingSessionParticipations.add(votingSessionParticipation);
    }

    //* Create voting session jurations
    final List<VotingSessionJuration> votingSessionJurations = [];
    for (int i = 0; i < event.votingJurationsBundles.length; i++) {
      final juration = event.votingJurationsBundles[i].juration;
      final votingSessionJuration = VotingSessionJuration(
        id: genUuid(),
        createdAt: now(),
        votingSessionId: votingSession.id,
        jurationId: juration.id,
        hasSubmitted: false,
      );
      votingSessionJurations.add(votingSessionJuration);
    }

    //* Create voting session exclusions
    final List<VotingSessionExclusion> votingSessionExclusions = [];
    for (var votingExclusionBundle in event.votingExclusionsBundles) {
      final votingSessionJuration = votingSessionJurations
          .firstWhere((e) => e.jurationId == votingExclusionBundle.jurationBundle.juration.id);
      final votingSessionParticipation = votingSessionParticipations.firstWhere(
          (e) => e.participationId == votingExclusionBundle.participationBundle.participation.id);
      votingSessionExclusions.add(
        VotingSessionExclusion(
            id: genUuid(),
            createdAt: now(),
            votingSessionJurationId: votingSessionJuration.id,
            votingSessionParticipationId: votingSessionParticipation.id),
      );
    }

    final eitherInitVotingSession = await _organizerRepository.initVotingSession(
      votingForm: votingForm,
      votingFormFields: votingFormFields,
      geoRestrictionPlace: geoRestrictionPlace,
      votingSession: votingSession,
      votingSessionParticipations: votingSessionParticipations,
      votingSessionJurations: votingSessionJurations,
      votingSessionExclusions: votingSessionExclusions,
    );
    eitherInitVotingSession.fold(
        (failure) => emit(state.copyWith(status: BlocStatus.failure,message: failure.message)),
        (success) => null,
    );
    if(eitherInitVotingSession.isLeft()) {
      return;
    }

    //* Merging all into the voting session bundle
    final List<VotingSessionParticipationBundle> votingSessionParticipationsBundles = [];
    for (var votingSessionParticipation in votingSessionParticipations) {
      final votingSessionParticipationBundle = VotingSessionParticipationBundle(
        votingSessionParticipation: votingSessionParticipation,
        participationBundle: event.votingParticipationsBundles
            .firstWhere((e) => e.participation.id == votingSessionParticipation.participationId),
      );
      votingSessionParticipationsBundles.add(votingSessionParticipationBundle);
    }

    final List<VotingSessionJurationBundle> votingSessionJurationsBundles = [];
    for (var votingSessionJuration in votingSessionJurations) {
      final votingSessionJurationBundle = VotingSessionJurationBundle(
        votingSessionJuration: votingSessionJuration,
        jurationBundle: event.votingJurationsBundles
            .firstWhere((e) => e.juration.id == votingSessionJuration.jurationId),
      );
      votingSessionJurationsBundles.add(votingSessionJurationBundle);
    }

    final List<VotingSessionExclusionBundle> votingSessionExclusionsBundles = [];
    for (var votingSessionExclusion in votingSessionExclusions) {
      final votingSessionParticipation = votingSessionParticipations
          .firstWhere((e) => e.id == votingSessionExclusion.votingSessionParticipationId);
      final votingSessionJuration = votingSessionJurations
          .firstWhere((e) => e.id == votingSessionExclusion.votingSessionJurationId);

      final VotingSessionExclusionBundle votingSessionExclusionBundle =
      VotingSessionExclusionBundle(
        votingSessionParticipation: votingSessionParticipation,
        votingSessionJuration: votingSessionJuration,
      );
      votingSessionExclusionsBundles.add(votingSessionExclusionBundle);
    }

    final votingFormBundle =
    VotingFormBundle(votingForm: votingForm, votingFormFields: votingFormFields);

    final votingSessionBundle = OrganizerVotingSessionBundle(
      votingSession: votingSession,
      votingFormBundle: votingFormBundle,
      votingSessionParticipationsBundles: votingSessionParticipationsBundles,
      votingSessionJurationsBundles: votingSessionJurationsBundles,
      votingSessionExclusionsBundles: votingSessionExclusionsBundles,
    );

    emit(state.copyWith(
      status: BlocStatus.success,
      votingSessionBundle: votingSessionBundle,
    ));

    // emit(state.copyWith(status: BlocStatus.loading, sourceEvent: event));
    //
    // late final VotingForm? contestVotingForm;
    // final eitherOldVotingForm =
    //     await _votingFormRepository.getVotingFormById(id: event.votingFormId);
    // eitherOldVotingForm.fold(
    //   (failure) => emit(state.copyWith(status: BlocStatus.failure, message: failure.message)),
    //   (success) => contestVotingForm = success,
    // );
    // if (eitherOldVotingForm.isLeft()) {
    //   return;
    // }
    // if (contestVotingForm == null) {
    //   emit(state.copyWith(status: BlocStatus.failure, message: 'Voting form not found'));
    //   return;
    // }
    //
    // late final List<VotingFormField> contestVotingFormFields;
    // final eitherOldVotingFormFields = await _votingFormFieldRepository
    //     .getVotingFormFieldsByVotingFormId(votingFormId: contestVotingForm!.id);
    // eitherOldVotingFormFields.fold(
    //   (failure) => emit(state.copyWith(status: BlocStatus.failure, message: failure.message)),
    //   (success) => contestVotingFormFields = success,
    // );
    // if (eitherOldVotingFormFields.isLeft()) {
    //   return;
    // }
    //
    // //* Create the voting form for the session
    // late final VotingForm votingForm;
    // final eitherVotingForm = await _votingFormRepository.createVotingForm(
    //     votingForm: VotingForm(
    //   id: genUuid(),
    //   createdAt: now(),
    // ));
    // eitherVotingForm.fold(
    //   (failure) => emit(state.copyWith(status: BlocStatus.failure, message: failure.message)),
    //   (success) => votingForm = success,
    // );
    // if (eitherVotingForm.isLeft()) {
    //   return;
    // }
    //
    // //* Create voting form fields for the session
    // final List<VotingFormField> votingFormFields = [];
    // for (var vff in contestVotingFormFields) {
    //   final eitherVotingFormField = await _votingFormFieldRepository.createVotingFormField(
    //     votingFormField: VotingFormField(
    //       id: genUuid(),
    //       createdAt: now(),
    //       votingFormId: votingForm.id,
    //       name: vff.name,
    //       orderIndex: vff.orderIndex,
    //       minValue: vff.minValue,
    //       maxValue: vff.maxValue,
    //     ),
    //   );
    //   eitherVotingFormField.fold(
    //     (failure) => emit(state.copyWith(status: BlocStatus.failure, message: failure.message)),
    //     (success) => votingFormFields.add(success),
    //   );
    //   if (eitherVotingFormField.isLeft()) {
    //     return;
    //   }
    // }
    //
    // //* Generate an unique token for the session
    // late final String token;
    // final eitherToken = await _utilsRepository.genUniqueToken(
    //     tableName: 'voting_sessions', columnName: 'token', length: 8);
    // eitherToken.fold(
    //   (failure) => emit(state.copyWith(status: BlocStatus.failure, message: failure.message)),
    //   (success) => token = success,
    // );
    // if (eitherToken.isLeft()) {
    //   return;
    // }
    //
    // //* Create a new place for the session only if georestricted
    // Place? geoRestrictionPlace;
    // if (event.isGeoRestricted) {
    //   final eitherGeoRestrictionPlace = await _placeRepository.createPlace(
    //       place: Place(
    //     id: genUuid(),
    //     createdAt: now(),
    //     address: event.geoRestrictionPlaceAddress!,
    //     lat: event.geoRestrictionPlaceLat!,
    //     lon: event.geoRestrictionPlaceLon!,
    //   ));
    //   eitherGeoRestrictionPlace.fold(
    //     (failure) => emit(state.copyWith(status: BlocStatus.failure, message: failure.message)),
    //     (success) => geoRestrictionPlace = success,
    //   );
    //   if (eitherGeoRestrictionPlace.isLeft()) {
    //     return;
    //   }
    // }
    //
    // //* Create a voting session
    // late final VotingSession votingSession;
    // final createdAt = now();
    // final eitherVotingSession = await _votingSessionRepository.createVotingSession(
    //     votingSession: VotingSession(
    //   id: genUuid(),
    //   createdAt: createdAt,
    //   name:
    //       'Voting ${createdAt.day.toString().padLeft(2, '0')}.${createdAt.month.toString().padLeft(2, '0')}.${createdAt.year}.${createdAt.hour.toString().padLeft(2, '0')}.${createdAt.minute.toString().padLeft(2, '0')}.${createdAt.second.toString().padLeft(2, '0')}',
    //   contestId: event.contestId,
    //   areSimpleJurorsAllowed: event.areSimpleJurorsAllowed,
    //   votingFormId: votingForm.id,
    //   workTimer: event.workTimer,
    //   intermissionTimer: event.intermissionTimer,
    //   reviewTimer: event.reviewTimer,
    //   sessionStatus: VotingSessionStatus.initialized,
    //   token: token,
    //   isGeoRestricted: event.isGeoRestricted,
    //   geoRestrictionPlaceId: (event.isGeoRestricted) ? geoRestrictionPlace!.id : null,
    //   geoRestrictionRadius: (event.isGeoRestricted) ? event.geoRestrictionRadius : null,
    // ));
    // eitherVotingSession.fold(
    //   (failure) => emit(state.copyWith(status: BlocStatus.failure, message: failure.message)),
    //   (success) => votingSession = success,
    // );
    // if (eitherVotingSession.isLeft()) {
    //   return;
    // }
    //
    // //* Create voting session participations
    // final List<VotingSessionParticipation> votingSessionParticipations = [];
    // for (int i = 0; i < event.votingParticipationsBundles.length; i++) {
    //   final participation = event.votingParticipationsBundles[i].participation;
    //   final eitherVotingSessionParticipation =
    //       await _votingSessionParticipationRepository.createVotingSessionParticipation(
    //           votingSessionParticipation: VotingSessionParticipation(
    //     id: genUuid(),
    //     createdAt: DateTime.now(),
    //     votingSessionId: votingSession.id,
    //     participationId: participation.id,
    //     orderIndex: i,
    //   ));
    //   eitherVotingSessionParticipation.fold(
    //     (failure) => emit(state.copyWith(status: BlocStatus.failure, message: failure.message)),
    //     (success) => votingSessionParticipations.add(success),
    //   );
    //   if (eitherVotingSession.isLeft()) {
    //     return;
    //   }
    // }
    //
    // //* Create voting session jurations
    // final List<VotingSessionJuration> votingSessionJurations = [];
    // for (var jurationBundle in event.votingJurationsBundles) {
    //   final eitherVotingSessionJuror =
    //       await _votingSessionJurationRepository.createVotingSessionJuration(
    //           votingSessionJuration: VotingSessionJuration(
    //     id: genUuid(),
    //     createdAt: now(),
    //     votingSessionId: votingSession.id,
    //     jurationId: jurationBundle.juration.id,
    //     hasSubmitted: false,
    //   ));
    //   eitherVotingSessionJuror.fold(
    //     (failure) => emit(state.copyWith(status: BlocStatus.failure, message: failure.message)),
    //     (success) => votingSessionJurations.add(success),
    //   );
    //   if (eitherVotingSession.isLeft()) {
    //     return;
    //   }
    // }
    //
    // //* Create voting session exclusions
    // final List<VotingSessionExclusion> votingSessionExclusions = [];
    // for (var votingExclusionBundle in event.votingExclusionsBundles) {
    //   final votingSessionJuration = votingSessionJurations
    //       .firstWhere((e) => e.jurationId == votingExclusionBundle.jurationBundle.juration.id);
    //   final votingSessionParticipation = votingSessionParticipations.firstWhere(
    //       (e) => e.participationId == votingExclusionBundle.participationBundle.participation.id);
    //   final eitherVotingSessionExclusion =
    //       await _votingSessionExclusionRepository.createVotingSessionExclusion(
    //     votingSessionExclusion: VotingSessionExclusion(
    //         id: genUuid(),
    //         createdAt: now(),
    //         votingSessionJurationId: votingSessionJuration.id,
    //         votingSessionParticipationId: votingSessionParticipation.id),
    //   );
    //   eitherVotingSessionExclusion.fold(
    //     (failure) => emit(state.copyWith(status: BlocStatus.failure, message: failure.message)),
    //     (success) => votingSessionExclusions.add(success),
    //   );
    // }

    // late final VotingSessionProcedure votingSessionProcedure;
    // final eitherVotingSessionProcedure =
    //     await _votingSessionProcedureRepository.createVotingSessionProcedure(
    //         votingSessionProcedure: VotingSessionProcedure(
    //   id: genUuid(),
    //   createdAt: now(),
    //   votingSessionId: votingSession.id,
    // ));
    // eitherVotingSessionProcedure.fold(
    //   (failure) => emit(state.copyWith(status: BlocStatus.failure, message: failure.message)),
    //   (success) => votingSessionProcedure = success,
    // );
    // if (eitherVotingSessionProcedure.isLeft()) {
    //   return;
    // }
    //
    // final eitherBeginVotingSessionProcedure = await _votingSessionProcedureRepository
    //     .beginVotingSessionProcedureById(id: votingSessionProcedure.id);
    // eitherBeginVotingSessionProcedure.fold(
    //   (failure) {
    //     emit(state.copyWith(status: BlocStatus.failure, message: failure.message));
    //     return;
    //   },
    //   (success) => null,
    // );
    //
    // final List<VotingSessionParticipationBundle> votingSessionParticipationsBundles = [];
    // for (var votingSessionParticipation in votingSessionParticipations) {
    //   final votingSessionParticipationBundle = VotingSessionParticipationBundle(
    //     votingSessionParticipation: votingSessionParticipation,
    //     participationBundle: event.votingParticipationsBundles
    //         .firstWhere((e) => e.participation.id == votingSessionParticipation.participationId),
    //   );
    //   votingSessionParticipationsBundles.add(votingSessionParticipationBundle);
    // }
    //
    // final List<VotingSessionJurationBundle> votingSessionJurationsBundles = [];
    // for (var votingSessionJuration in votingSessionJurations) {
    //   final votingSessionJurationBundle = VotingSessionJurationBundle(
    //     votingSessionJuration: votingSessionJuration,
    //     jurationBundle: event.votingJurationsBundles
    //         .firstWhere((e) => e.juration.id == votingSessionJuration.jurationId),
    //   );
    //   votingSessionJurationsBundles.add(votingSessionJurationBundle);
    // }
    //
    // final List<VotingSessionExclusionBundle> votingSessionExclusionsBundles = [];
    // for (var votingSessionExclusion in votingSessionExclusions) {
    //   final votingSessionParticipation = votingSessionParticipations
    //       .firstWhere((e) => e.id == votingSessionExclusion.votingSessionParticipationId);
    //   final votingSessionJuration = votingSessionJurations
    //       .firstWhere((e) => e.id == votingSessionExclusion.votingSessionJurationId);
    //
    //   final VotingSessionExclusionBundle votingSessionExclusionBundle =
    //       VotingSessionExclusionBundle(
    //     votingSessionParticipation: votingSessionParticipation,
    //     votingSessionJuration: votingSessionJuration,
    //   );
    //   votingSessionExclusionsBundles.add(votingSessionExclusionBundle);
    // }
    //
    // final votingFormBundle =
    //     VotingFormBundle(votingForm: votingForm, votingFormFields: votingFormFields);
    //
    // final votingSessionBundle = OrganizerVotingSessionBundle(
    //   votingSession: votingSession,
    //   votingSessionProcedure: votingSessionProcedure,
    //   votingFormBundle: votingFormBundle,
    //   votingSessionParticipationsBundles: votingSessionParticipationsBundles,
    //   votingSessionJurationsBundles: votingSessionJurationsBundles,
    //   votingSessionExclusionsBundles: votingSessionExclusionsBundles,
    // );
    //
    // emit(state.copyWith(
    //   status: BlocStatus.success,
    //   votingSessionBundle: votingSessionBundle,
    // ));
  }
}
