import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:swift_contest/model/db/bundles/contest_details_bundle.dart';
import 'package:swift_contest/model/db/entities/contest.dart';
import 'package:swift_contest/model/db/entities/place.dart';
import 'package:swift_contest/model/db/repositories/organizer_repository.dart';
import 'package:swift_contest/model/db/repositories/storage_repository.dart';
import 'package:swift_contest/viewmodel/enums/bloc_status.dart';

part 'organizer_contest_edit_page_event.dart';
part 'organizer_contest_edit_page_state.dart';

class OrganizerContestEditPageBloc
    extends Bloc<OrganizerContestEditPageEvent, OrganizerContestEditPageState> {
  final OrganizerRepository _organizerRepository;
  final StorageRepository _storageRepository;

  OrganizerContestEditPageBloc(
      {required OrganizerRepository organizerRepository,
      required StorageRepository storageRepository})
      : _organizerRepository = organizerRepository,
        _storageRepository = storageRepository,
        super(OrganizerContestEditPageState(status: BlocStatus.initial)) {
    on<OrganizerContestEditPageFetch>(_fetch);
    on<OrganizerContestEditPageEditContest>(_edit);
  }

  FutureOr<void> _fetch(
    OrganizerContestEditPageFetch event,
    Emitter<OrganizerContestEditPageState> emit,
  ) async {
    emit(state.copyWith(status: BlocStatus.loading, sourceEvent: event));

    final eitherContestDetails =
        await _organizerRepository.getContestDetails(contestId: event.contestId);
    eitherContestDetails.fold(
      (failure) => emit(state.copyWith(status: BlocStatus.failure, message: failure.message)),
      (success) {
        emit(state.copyWith(
            status: BlocStatus.success, isInitialized: true, contestDetailsBundle: success));
      },
    );
  }

  FutureOr<void> _edit(
    OrganizerContestEditPageEditContest event,
    Emitter<OrganizerContestEditPageState> emit,
  ) async {
    emit(state.copyWith(status: BlocStatus.loading, sourceEvent: event));

    List<String>? newImagesUrls;
    if (event.images.isNotEmpty) {
      final eitherImagesUrls = await _storageRepository.uploadImages(
          bucket: StorageBucket.contestsImages,
          pathPrefix: event.contest.id!,
          images: event.images);
      eitherImagesUrls.fold(
        (failure) => emit(state.copyWith(status: BlocStatus.failure, message: failure.message)),
        (success) => newImagesUrls = success,
      );
      if (eitherImagesUrls.isLeft()) {
        return;
      }
    }

    final eitherEditContest = await _organizerRepository.updateContest(
      contest: event.contest.copyWith(imagesUrls: newImagesUrls),
      place: event.place,
    );
    eitherEditContest.fold(
        (failure) => emit(state.copyWith(status: BlocStatus.failure, message: failure.message)),
        (success) => emit(state.copyWith(status: BlocStatus.success)),
      );
  }
}
