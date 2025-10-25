import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:swift_contest/model/database/bundles/participation_bundle.dart';
import 'package:swift_contest/model/database/repositories/organizer_repository.dart';
import 'package:swift_contest/model/database/repositories/storage_repository.dart';
import 'package:swift_contest/model/database/types/storage_bucket.dart';
import 'package:swift_contest/viewmodel/types/bloc_status.dart';

part 'organizer_work_details_page_event.dart';
part 'organizer_work_details_page_state.dart';

class OrganizerWorkDetailsPageBloc
    extends Bloc<OrganizerWorkDetailsPageEvent, OrganizerWorkDetailsPageState> {
  final OrganizerRepository _organizerRepository;
  final StorageRepository _storageRepository;


  OrganizerWorkDetailsPageBloc({
    required OrganizerRepository organizerRepository,
    required StorageRepository storageRepository,
  })  : _organizerRepository = organizerRepository,
        _storageRepository = storageRepository,
        super(const OrganizerWorkDetailsPageState(status: BlocStatus.initial)) {
    on<OrganizerWorkDetailsPageFetch>(_fetch);
    on<OrganizerWorkDetailsPageGetWorkFileUrl>(_getWorkFileUrl);
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
  FutureOr<void> _getWorkFileUrl(
    OrganizerWorkDetailsPageGetWorkFileUrl event,
    Emitter<OrganizerWorkDetailsPageState> emit,
  ) async {
    emit(state.copyWith(status: BlocStatus.loading, sourceEvent: event));

    final res =
    await _storageRepository.getSignedUrl(bucket: StorageBucket.worksFiles, path: event.filePath);
    res.fold(
          (failure) => emit(state.copyWith(status: BlocStatus.failure, message: failure.message)),
          (success) => emit(state.copyWith(status: BlocStatus.success, workFileUrl: success)),
    );
  }


}
