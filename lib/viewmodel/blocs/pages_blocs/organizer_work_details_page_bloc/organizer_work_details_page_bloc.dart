import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

import 'package:swift_contest/model/database/bundles/participation_bundle.dart';
import 'package:swift_contest/model/database/repositories/organizer_repository.dart';
import 'package:swift_contest/model/database/repositories/organizer_repository_.dart';
import 'package:swift_contest/utils/logger/logger.dart';
import 'package:swift_contest/viewmodel/types/bloc_status.dart';

part 'organizer_work_details_page_event.dart';

part 'organizer_work_details_page_state.dart';

class OrganizerWorkDetailsPageBloc
    extends Bloc<OrganizerWorkDetailsPageEvent, OrganizerWorkDetailsPageState> {
  final OrganizerRepository _organizerRepository;

  OrganizerWorkDetailsPageBloc({
    required OrganizerRepository organizerRepository,
  })  : _organizerRepository = organizerRepository,
        super(OrganizerWorkDetailsPageState(status: BlocStatus.initial)) {
    on<OrganizerWorkDetailsPageFetch>(_fetch);
  }

  @override
  OrganizerWorkDetailsPageState? fromJson(Map<String, dynamic> json) {
    try {
      return OrganizerWorkDetailsPageState.fromJson(json);
    } catch (e) {
      Logger.error(e);
      return null;
    }
  }

  @override
  Map<String, dynamic>? toJson(OrganizerWorkDetailsPageState state) {
    try {
      return state.toJson();
    } catch (e) {
      Logger.error(e);
      return null;
    }
  }

  FutureOr<void> _fetch(
    OrganizerWorkDetailsPageFetch event,
    Emitter<OrganizerWorkDetailsPageState> emit,
  ) async {
    emit(state.copyWith(status: BlocStatus.loading, sourceEvent: event));

    final eitherParticipationBundle =
        await _organizerRepository.getParticipationBundle(participationId: event.participationId);
    eitherParticipationBundle.fold(
      (failure) => emit(state.copyWith(status: BlocStatus.failure, message: failure.message)),
      (success) => emit(state.copyWith(status: BlocStatus.success, isInitialized: true, participationBundle: success)),
    );
  }
}
