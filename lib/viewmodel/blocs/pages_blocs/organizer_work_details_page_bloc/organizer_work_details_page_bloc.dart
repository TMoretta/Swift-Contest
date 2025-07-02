import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:swift_contest/model/bundles/participation_bundle.dart';
import 'package:swift_contest/model/repositories/organizer_repository.dart';
import 'package:swift_contest/viewmodel/enums/bloc_status.dart';

part 'organizer_work_details_page_event.dart';

part 'organizer_work_details_page_state.dart';

class OrganizerWorkDetailsPageBloc
    extends Bloc<OrganizerWorkDetailsPageEvent, OrganizerWorkDetailsPageState> {
  final OrganizerRepository _organizerRepository;

  OrganizerWorkDetailsPageBloc({
    required OrganizerRepository organizerRepository,
  })  : _organizerRepository = organizerRepository,
        super(OrganizerWorkDetailsPageState(status: BlocStatus.initial)) {
    on<OrganizerWorkDetailsPageInit>(_init);
    on<OrganizerWorkDetailsPageRefresh>(_refresh);
  }

  FutureOr<void> _init(
    OrganizerWorkDetailsPageInit event,
    Emitter<OrganizerWorkDetailsPageState> emit,
  ) async {
    emit(state.copyWith(status: BlocStatus.loading, sourceEvent: event));

    final eitherParticipationBundle =
        await _organizerRepository.getParticipationBundle(participationId: event.participationId);
    eitherParticipationBundle.fold(
      (failure) => emit(state.copyWith(status: BlocStatus.failure, message: failure.message)),
      (success) => emit(state.copyWith(status: BlocStatus.success, participationBundle: success)),
    );
  }

  FutureOr<void> _refresh(
    OrganizerWorkDetailsPageRefresh event,
    Emitter<OrganizerWorkDetailsPageState> emit,
  ) async {
    emit(state.copyWith(status: BlocStatus.loading, sourceEvent: event));

    final eitherParticipationBundle =
        await _organizerRepository.getParticipationBundle(participationId: event.participationId);
    eitherParticipationBundle.fold(
      (failure) => emit(state.copyWith(status: BlocStatus.failure, message: failure.message)),
      (success) => emit(state.copyWith(status: BlocStatus.success, participationBundle: success)),
    );
  }
}
