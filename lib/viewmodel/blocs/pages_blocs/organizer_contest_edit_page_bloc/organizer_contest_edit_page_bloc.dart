import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:swift_contest/model/bundles/contest_details_bundle.dart';
import 'package:swift_contest/model/data_models/place.dart';
import 'package:swift_contest/model/repositories/organizer_repository.dart';
import 'package:swift_contest/model/repositories/storage_repository.dart';
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
    on<OrganizerContestEditPageInit>(_init);
    on<OrganizerContestEditPageRefresh>(_refresh);
    on<OrganizerContestEditPageEditContest>(_edit);
  }

  FutureOr<void> _init(
    OrganizerContestEditPageInit event,
    Emitter<OrganizerContestEditPageState> emit,
  ) async {
    emit(state.copyWith(status: BlocStatus.loading, sourceEvent: event));

    final eitherContestDetails =
        await _organizerRepository.getContestDetails(contestId: event.contestId);
    eitherContestDetails.fold(
      (failure) => emit(state.copyWith(status: BlocStatus.failure, message: failure.message)),
      (success) {
        emit(state.copyWith(status: BlocStatus.success, contestDetailsBundle: success));
      },
    );
  }

  FutureOr<void> _refresh(
    OrganizerContestEditPageRefresh event,
    Emitter<OrganizerContestEditPageState> emit,
  ) async {
    emit(state.copyWith(status: BlocStatus.loading, sourceEvent: event));

    final eitherContestDetails =
        await _organizerRepository.getContestDetails(contestId: event.contestId);
    eitherContestDetails.fold(
      (failure) => emit(state.copyWith(status: BlocStatus.failure, message: failure.message)),
      (success) {
        emit(state.copyWith(status: BlocStatus.success, contestDetailsBundle: success));
      },
    );
  }

  FutureOr<void> _edit(
    OrganizerContestEditPageEditContest event,
    Emitter<OrganizerContestEditPageState> emit,
  ) async {
    emit(state.copyWith(status: BlocStatus.loading, sourceEvent: event));

    List<String>? newImagesUrls;
    if (event.images != null) {
      final eitherImagesUrls = await _storageRepository.uploadImages(
          bucket: StorageBucket.contestsImages, images: event.images!);
      eitherImagesUrls.fold(
        (failure) => emit(state.copyWith(status: BlocStatus.failure, message: failure.message)),
        (success) => newImagesUrls = success,
      );
      if (eitherImagesUrls.isLeft()) {
        return;
      }
    }

    final eitherEditContest = await _organizerRepository.editContest(
      contestId: event.contestId,
      name: event.name,
      description: event.description,
      dateTime: event.dateTime,
      place: event.place,
      worksSubmissionStart: event.worksSubmissionStart,
      worksSubmissionEnd: event.worksSubmissionEnd,
      imagesUrls: (newImagesUrls != null && newImagesUrls!.isNotEmpty)
          ? newImagesUrls!
          : event.oldImagesUrls,
    );
    eitherEditContest.fold(
      (failure) => emit(state.copyWith(status: BlocStatus.failure, message: failure.message)),
      (success) => emit(state.copyWith(status: BlocStatus.success)),
    );
  }
}
