import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:swift_contest/model/bundles/home_contest_bundle.dart';
import 'package:swift_contest/model/data_models/message.dart';
import 'package:swift_contest/model/repositories/role_repositories/organizer_repository.dart';
import 'package:swift_contest/viewmodel/enums/bloc_status.dart';

part 'organizer_home_page_event.dart';
part 'organizer_home_page_state.dart';

class OrganizerHomePageBloc extends Bloc<OrganizerHomePageEvent, OrganizerHomePageState> {
  final OrganizerRepository _organizerRepository;

  OrganizerHomePageBloc({
    required OrganizerRepository organizerRepository,
  })  : _organizerRepository = organizerRepository,
        super(OrganizerHomePageState(status: BlocStatus.initial)) {
    on<OrganizerHomePageInit>(_init);
    on<OrganizerHomePageRefresh>(_refresh);
  }

  FutureOr<void> _init(
    OrganizerHomePageInit event,
    Emitter<OrganizerHomePageState> emit,
  ) async {
    emit(OrganizerHomePageState(status: BlocStatus.loading, sourceEvent: event));

    final eitherContests = await _organizerRepository.getCreatedContests(organizerId: event.userId);
    eitherContests.fold(
      (failure) => emit(state.copyWith(status: BlocStatus.failure, message: failure.message)),
      (success) =>
          emit(state.copyWith(status: BlocStatus.success, createdContestsBundles: success)),
    );
  }

  FutureOr<void> _refresh(
    OrganizerHomePageRefresh event,
    Emitter<OrganizerHomePageState> emit,
  ) async {
    emit(OrganizerHomePageState(status: BlocStatus.loading, sourceEvent: event));

    final eitherContests = await _organizerRepository.getCreatedContests(organizerId: event.userId);
    eitherContests.fold(
      (failure) => emit(state.copyWith(status: BlocStatus.failure, message: failure.message)),
      (success) =>
          emit(state.copyWith(status: BlocStatus.success, createdContestsBundles: success)),
    );
  }
}
