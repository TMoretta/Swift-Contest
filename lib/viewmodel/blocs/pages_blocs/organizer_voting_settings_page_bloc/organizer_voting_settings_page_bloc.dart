import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:swift_contest/model/database/bundles/juration_bundle.dart';
import 'package:swift_contest/model/database/bundles/jury_bundle.dart';
import 'package:swift_contest/model/database/bundles/organizer_contest_details_bundle.dart';
import 'package:swift_contest/model/database/bundles/participation_bundle.dart';
import 'package:swift_contest/model/database/entities/place.dart';
import 'package:swift_contest/model/database/entities/voting_session.dart';
import 'package:swift_contest/model/database/repositories/organizer_repository.dart';
import 'package:swift_contest/viewmodel/types/bloc_status.dart';

part 'organizer_voting_settings_page_event.dart';
part 'organizer_voting_settings_page_state.dart';

class OrganizerVotingSettingsPageBloc
    extends Bloc<OrganizerVotingSettingsPageEvent, OrganizerVotingSettingsPageState> {
  final OrganizerRepository _organizerRepository;

  OrganizerVotingSettingsPageBloc({
    required OrganizerRepository organizerRepository,
  })  : _organizerRepository = organizerRepository,
        super(const OrganizerVotingSettingsPageState(status: BlocStatus.initial)) {
    on<OrganizerVotingSettingsPageFetch>(_fetch);
    on<OrganizerVotingSettingsPageStartVotingSession>(_startVotingSession);
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
  }
}
