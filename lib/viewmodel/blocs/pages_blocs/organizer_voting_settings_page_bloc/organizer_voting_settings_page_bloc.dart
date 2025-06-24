import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:swift_contest/model/bundles/juration_bundle.dart';
import 'package:swift_contest/model/bundles/participation_bundle.dart';
import 'package:swift_contest/model/bundles/voting_exclusion_bundle.dart';
import 'package:swift_contest/model/data_models/place.dart';
import 'package:swift_contest/model/data_models/voting_form.dart';
import 'package:swift_contest/model/data_models/voting_form_field.dart';
import 'package:swift_contest/model/data_models/voting_session.dart';
import 'package:swift_contest/model/data_models/voting_session_exclusion.dart';
import 'package:swift_contest/model/data_models/voting_session_juration.dart';
import 'package:swift_contest/model/data_models/voting_session_participation.dart';
import 'package:swift_contest/model/enums/voting_session_status.dart';
import 'package:swift_contest/model/repositories/role_repositories/organizer_repository.dart';
import 'package:swift_contest/model/repositories/utils_repository.dart';
import 'package:swift_contest/utils/functions/gen_uuid.dart';
import 'package:swift_contest/utils/functions/now.dart';
import 'package:swift_contest/viewmodel/enums/bloc_status.dart';

part 'organizer_voting_settings_page_event.dart';
part 'organizer_voting_settings_page_state.dart';

class OrganizerVotingSettingsPageBloc
    extends Bloc<OrganizerVotingSettingsPageEvent, OrganizerVotingSettingsPageState> {
  final UtilsRepository _utilsRepository;
  final OrganizerRepository _organizerRepository;

  OrganizerVotingSettingsPageBloc({
    required UtilsRepository utilsRepository,
    required OrganizerRepository organizerRepository,
  })  :
        _utilsRepository = utilsRepository,
        _organizerRepository = organizerRepository,
        super(OrganizerVotingSettingsPageState(status: BlocStatus.initial)) {
    on<OrganizerVotingSettingsPageInitVotingProcedure>(_initVotingProcedure);
  }

  FutureOr<void> _initVotingProcedure(
    OrganizerVotingSettingsPageInitVotingProcedure event,
    Emitter<OrganizerVotingSettingsPageState> emit,
  ) async {
    emit(state.copyWith(status: BlocStatus.loading, sourceEvent: event));

    final VotingForm votingForm = VotingForm(
      id: genUuid(),
      createdAt: now(),
    );

    final List<VotingFormField> votingFormFields = event.votingFormFields
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
    for (int i=0; i<event.participationsBundles.length; i++) {
      final participation = event.participationsBundles[i].participation;
      final votingSessionParticipation = VotingSessionParticipation(
        id: genUuid(),
        createdAt: now(),
        votingSessionId: votingSession.id,
        participationId: participation.id,
        orderIndex: i,
        isExcluded: false
      );
      votingSessionParticipations.add(votingSessionParticipation);
    }
    for (int i=0; i<event.excludedParticipationsBundles.length; i++) {
      final participation = event.excludedParticipationsBundles[i].participation;
      final votingSessionParticipation = VotingSessionParticipation(
          id: genUuid(),
          createdAt: now(),
          votingSessionId: votingSession.id,
          participationId: participation.id,
          orderIndex: i,
          isExcluded: true
      );
      votingSessionParticipations.add(votingSessionParticipation);
    }

    //* Create voting session jurations
    final List<VotingSessionJuration> votingSessionJurations = [];
    for (var jurationBundle in event.jurationsBundles) {
      final juration = jurationBundle.juration;
      final votingSessionJuration = VotingSessionJuration(
        id: genUuid(),
        createdAt: now(),
        votingSessionId: votingSession.id,
        jurationId: juration.id,
        hasSubmitted: false,
        isExcluded: false,
      );
      votingSessionJurations.add(votingSessionJuration);
    }
    for (var jurationBundle in event.excludedJurationsBundles) {
      final juration = jurationBundle.juration;
      final votingSessionJuration = VotingSessionJuration(
        id: genUuid(),
        createdAt: now(),
        votingSessionId: votingSession.id,
        jurationId: juration.id,
        hasSubmitted: false,
        isExcluded: true,
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
            votingSessionId: votingSession.id,
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
        (success) => emit(state.copyWith(status: BlocStatus.success,votingSessionId: votingSession.id)),
    );
  }
}
