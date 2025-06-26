import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:swift_contest/model/bundles/juration_bundle.dart';
import 'package:swift_contest/model/bundles/participation_bundle.dart';
import 'package:swift_contest/model/bundles/voting_exclusion_bundle.dart';
import 'package:swift_contest/model/data_models/place.dart';
import 'package:swift_contest/model/data_models/voting_form_field.dart';
import 'package:swift_contest/model/data_models/voting_session.dart';
import 'package:swift_contest/model/data_models/voting_session_exclusion.dart';
import 'package:swift_contest/model/data_models/voting_session_juration.dart';
import 'package:swift_contest/model/data_models/voting_session_participation.dart';
import 'package:swift_contest/model/enums/voting_session_status.dart';
import 'package:swift_contest/model/repositories/organizer_repository.dart';
import 'package:swift_contest/utils/functions/gen_uuid.dart';
import 'package:swift_contest/utils/functions/now.dart';
import 'package:swift_contest/viewmodel/enums/bloc_status.dart';

part 'organizer_voting_settings_page_event.dart';

part 'organizer_voting_settings_page_state.dart';

class OrganizerVotingSettingsPageBloc
    extends Bloc<OrganizerVotingSettingsPageEvent, OrganizerVotingSettingsPageState> {
  final OrganizerRepository _organizerRepository;

  OrganizerVotingSettingsPageBloc({
    required OrganizerRepository organizerRepository,
  })  : _organizerRepository = organizerRepository,
        super(OrganizerVotingSettingsPageState(status: BlocStatus.initial)) {
    on<OrganizerVotingSettingsPageInitVotingProcedure>(_initVotingProcedure);
  }

  FutureOr<void> _initVotingProcedure(
    OrganizerVotingSettingsPageInitVotingProcedure event,
    Emitter<OrganizerVotingSettingsPageState> emit,
  ) async {
    emit(state.copyWith(status: BlocStatus.loading, sourceEvent: event));

    final List<VotingFormFieldNullable> votingFormFields = event.votingFormFields
        .map((e) => VotingFormFieldNullable(
            name: e.name, minValue: e.minValue, maxValue: e.maxValue, orderIndex: e.orderIndex))
        .toList(growable: false);

    //* Create a new place for the session only if georestricted
    final geoRestrictionPlace = (event.isGeoRestricted)
        ? PlaceNullable(
            address: event.geoRestrictionPlaceAddress,
            lat: event.geoRestrictionPlaceLat,
            lon: event.geoRestrictionPlaceLon,
          )
        : null;

    final createdAt = now();
    final VotingSessionNullable votingSession = VotingSessionNullable(
      name:
          'Voting ${createdAt.day.toString().padLeft(2, '0')}_${createdAt.month.toString().padLeft(2, '0')}_${createdAt.year}',
      contestId: event.contestId,
      areSimpleJurorsAllowed: event.areSimpleJurorsAllowed,
      workTimer: event.workTimer,
      intermissionTimer: event.intermissionTimer,
      reviewTimer: event.reviewTimer,
      sessionStatus: VotingSessionStatus.initialized,
      isGeoRestricted: event.isGeoRestricted,
      geoResRadius: (event.isGeoRestricted) ? event.geoRestrictionRadius : null,
    );

    //* Create voting session participations
    final List<VotingSessionParticipationNullable> votingSessionParticipations = [];
    for (int i = 0; i < event.participationsBundles.length; i++) {
      final participation = event.participationsBundles[i].participation;
      final votingSessionParticipation = VotingSessionParticipationNullable(
        id: genUuid(),
          participationId: participation.id, orderIndex: i, isExcluded: false);
      votingSessionParticipations.add(votingSessionParticipation);
    }
    for (int i = 0; i < event.excludedParticipationsBundles.length; i++) {
      final participation = event.excludedParticipationsBundles[i].participation;
      final votingSessionParticipation = VotingSessionParticipationNullable( id: genUuid(),
          participationId: participation.id, orderIndex: i, isExcluded: true);
      votingSessionParticipations.add(votingSessionParticipation);
    }

    //* Create voting session jurations
    final List<VotingSessionJurationNullable> votingSessionJurations = [];
    for (var jurationBundle in event.jurationsBundles) {
      final juration = jurationBundle.juration;
      final votingSessionJuration = VotingSessionJurationNullable(
        id: genUuid(),
        jurationId: juration.id,
        isExcluded: false,
      );
      votingSessionJurations.add(votingSessionJuration);
    }
    for (var jurationBundle in event.excludedJurationsBundles) {
      final juration = jurationBundle.juration;
      final votingSessionJuration = VotingSessionJurationNullable(
        id: genUuid(),
        jurationId: juration.id,
        isExcluded: true,
      );
      votingSessionJurations.add(votingSessionJuration);
    }

    //* Create voting session exclusions
    final List<VotingSessionExclusionNullable> votingSessionExclusions = [];
    for (var votingExclusionBundle in event.votingExclusionsBundles) {
      final votingSessionJuration = votingSessionJurations
          .firstWhere((e) => e.jurationId == votingExclusionBundle.jurationBundle.juration.id);
      final votingSessionParticipation = votingSessionParticipations.firstWhere(
          (e) => e.participationId == votingExclusionBundle.participationBundle.participation.id);
      votingSessionExclusions.add(
        VotingSessionExclusionNullable(
            votingSessionJurationId: votingSessionJuration.id,
            votingSessionParticipationId: votingSessionParticipation.id),
      );
    }

    final eitherInitVotingSession = await _organizerRepository.initVotingSession(
      votingFormFields: votingFormFields,
      geoRestrictionPlace: geoRestrictionPlace,
      votingSession: votingSession,
      votingSessionParticipations: votingSessionParticipations,
      votingSessionJurations: votingSessionJurations,
      votingSessionExclusions: votingSessionExclusions,
    );
    eitherInitVotingSession.fold(
      (failure) => emit(state.copyWith(status: BlocStatus.failure, message: failure.message)),
      (success) => emit(state.copyWith(status: BlocStatus.success, votingSessionId: success.id)),
    );
  }
}
