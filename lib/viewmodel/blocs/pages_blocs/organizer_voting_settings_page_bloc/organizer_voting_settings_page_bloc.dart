import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:swift_contest/model/database/bundles/contest_details_bundle.dart';
import 'package:swift_contest/model/database/bundles/juration_bundle.dart';
import 'package:swift_contest/model/database/bundles/jury_bundle.dart';
import 'package:swift_contest/model/database/bundles/participation_bundle.dart';
import 'package:swift_contest/model/database/entities/place.dart';
import 'package:swift_contest/model/database/entities/voting_session.dart';
import 'package:swift_contest/model/database/repositories/organizer_repository.dart';
import 'package:swift_contest/utils/logger/logger.dart';
import 'package:swift_contest/viewmodel/types/bloc_status.dart';

part 'organizer_voting_settings_page_event.dart';
part 'organizer_voting_settings_page_state.dart';

class OrganizerVotingSettingsPageBloc
    extends Bloc<OrganizerVotingSettingsPageEvent, OrganizerVotingSettingsPageState> {
  final OrganizerRepository _organizerRepository;

  OrganizerVotingSettingsPageBloc({
    required OrganizerRepository organizerRepository,
  })  : _organizerRepository = organizerRepository,
        super(OrganizerVotingSettingsPageState(status: BlocStatus.initial)) {
    on<OrganizerVotingSettingsPageFetch>(_fetch);
    on<OrganizerVotingSettingsPageStartVotingSession>(_startVotingSession);
  }

  @override
  OrganizerVotingSettingsPageState? fromJson(Map<String, dynamic> json) {
    try {
      return OrganizerVotingSettingsPageState.fromJson(json);
    } catch (e) {
      Logger.error(e);
      return null;
    }
  }

  @override
  Map<String, dynamic>? toJson(OrganizerVotingSettingsPageState state) {
    try {
      return state.toJson();
    } catch (e) {
      Logger.error(e);
      return null;
    }
  }

  FutureOr<void> _fetch(
    OrganizerVotingSettingsPageFetch event,
    Emitter<OrganizerVotingSettingsPageState> emit,
  ) async {
    emit(state.copyWith(status: BlocStatus.loading, sourceEvent: event));

    final eitherContestDetailsBundle =
        await _organizerRepository.getContestDetails(contestId: event.contestId);
    eitherContestDetailsBundle.fold(
      (failure) => emit(state.copyWith(status: BlocStatus.failure, message: failure.message)),
      (success) => emit(state.copyWith(
          status: BlocStatus.success, isInitialized: true, contestDetailsBundle: success)),
    );
  }

  FutureOr<void> _startVotingSession(
    OrganizerVotingSettingsPageStartVotingSession event,
    Emitter<OrganizerVotingSettingsPageState> emit,
  ) async {
    emit(state.copyWith(status: BlocStatus.loading, sourceEvent: event));

    final eitherStartVotingSession = await _organizerRepository.startVotingSession(
      participations: event.participationsBundles.map((e) => e.participation).toList(growable: false),
      exclusions: event.votingExclusions.map((e) => (juration: e.jurationBundle.juration , participation: e.participationBundle.participation)).toList(growable: false),
      votingSession: event.votingSession,
      geoResPlace: event.geoResPlace,
    );

    eitherStartVotingSession.fold(
      (failure) => emit(state.copyWith(status: BlocStatus.failure, message: failure.message)),
      (success) => emit(state.copyWith(status: BlocStatus.success, votingSessionId: success.id)),
    );

    // final List<VotingFormField> votingFormFields = event.votingFormFields
    //
    // //* Create a new place for the session only if georestricted
    // final geoRestrictionPlace = (event.isGeoRestricted)
    //     ? PlaceModel(
    //         address: event.geoRestrictionPlaceAddress,
    //         lat: event.geoRestrictionPlaceLat,
    //         lon: event.geoRestrictionPlaceLon,
    //       )
    //     : null;
    //
    // final createdAt = now();
    // final VotingSessionModel votingSession = VotingSessionModel(
    //   name:
    //       'Voting ${createdAt.day.toString().padLeft(2, '0')}-${createdAt.month.toString().padLeft(2, '0')}-${createdAt.year}',
    //   contestId: event.contestId,
    //   areSimpleJurorsAllowed: event.areSimpleJurorsAllowed,
    //   workTimer: event.workTimer,
    //   intermissionTimer: event.intermissionTimer,
    //   reviewTimer: event.reviewTimer,
    //   sessionStatus: VotingSessionStatus.initialized,
    //   isGeoRestricted: event.isGeoRestricted,
    //   geoResRadius: (event.isGeoRestricted) ? event.geoRestrictionRadius : null,
    // );
    //
    // //* Create voting session participations
    // final List<VotingSessionParticipationModel> votingSessionParticipations = [];
    // for (int i = 0; i < event.participationsBundles.length; i++) {
    //   final participation = event.participationsBundles[i].participation;
    //   final votingSessionParticipation = VotingSessionParticipationModel(
    //       id: genUuid(), participationId: participation.id, orderIndex: i, isExcluded: false);
    //   votingSessionParticipations.add(votingSessionParticipation);
    // }
    // for (int i = 0; i < event.excludedParticipationsBundles.length; i++) {
    //   final participation = event.excludedParticipationsBundles[i].participation;
    //   final votingSessionParticipation = VotingSessionParticipationModel(
    //       id: genUuid(), participationId: participation.id, orderIndex: i, isExcluded: true);
    //   votingSessionParticipations.add(votingSessionParticipation);
    // }
    //
    // //* Create voting session jurations
    // final List<VotingSessionJurationModel> votingSessionJurations = [];
    // for (var jurationBundle in event.jurationsBundles) {
    //   final juration = jurationBundle.juration;
    //   final votingSessionJuration = VotingSessionJurationModel(
    //     id: genUuid(),
    //     jurationId: juration.id,
    //     isExcluded: false,
    //   );
    //   votingSessionJurations.add(votingSessionJuration);
    // }
    // for (var jurationBundle in event.excludedJurationsBundles) {
    //   final juration = jurationBundle.juration;
    //   final votingSessionJuration = VotingSessionJurationModel(
    //     id: genUuid(),
    //     jurationId: juration.id,
    //     isExcluded: true,
    //   );
    //   votingSessionJurations.add(votingSessionJuration);
    // }
    //
    // //* Create voting session exclusions
    // final List<VotingSessionExclusionModel> votingSessionExclusions = [];
    // for (var votingExclusionBundle in event.votingExclusions) {
    //   final votingSessionJuration = votingSessionJurations
    //       .firstWhere((e) => e.jurationId == votingExclusionBundle.jurationBundle.juration.id);
    //   final votingSessionParticipation = votingSessionParticipations.firstWhere(
    //       (e) => e.participationId == votingExclusionBundle.participationBundle.participation.id);
    //   votingSessionExclusions.add(
    //     VotingSessionExclusionModel(
    //         votingSessionJurationId: votingSessionJuration.id,
    //         votingSessionParticipationId: votingSessionParticipation.id),
    //   );
    // }
    //
    // final eitherInitVotingSession = await _organizerRepository.initVotingSession(
    //   votingFormFields: votingFormFields,
    //   geoRestrictionPlace: geoRestrictionPlace,
    //   votingSession: votingSession,
    //   votingSessionParticipations: votingSessionParticipations,
    //   votingSessionJurations: votingSessionJurations,
    //   votingSessionExclusions: votingSessionExclusions,
    // );
    // eitherInitVotingSession.fold(
    //   (failure) => emit(state.copyWith(status: BlocStatus.failure, message: failure.message)),
    //   (success) => emit(state.copyWith(status: BlocStatus.success, votingSessionId: success.id)),
    // );
  }
}
