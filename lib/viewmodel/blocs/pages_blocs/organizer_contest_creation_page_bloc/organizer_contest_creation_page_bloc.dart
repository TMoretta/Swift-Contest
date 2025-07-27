import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:swift_contest/model/db/entities/contest.dart';
import 'package:swift_contest/model/db/entities/place.dart';
import 'package:swift_contest/model/db/repositories/organizer_repository.dart';
import 'package:swift_contest/model/db/repositories/storage_repository.dart';
import 'package:swift_contest/utils/functions/gen_uuid.dart';
import 'package:swift_contest/viewmodel/enums/bloc_status.dart';

part 'organizer_contest_creation_page_event.dart';
part 'organizer_contest_creation_page_state.dart';

class OrganizerContestCreationPageBloc
    extends Bloc<OrganizerContestCreationPageEvent, OrganizerContestCreationPageState> {
  final StorageRepository _storageRepository;
  final OrganizerRepository _organizerRepository;

  OrganizerContestCreationPageBloc({
    required StorageRepository storageRepository,
    required OrganizerRepository organizerRepository,
  })  :
        _storageRepository = storageRepository,
        _organizerRepository = organizerRepository,
        super(OrganizerContestCreationPageState(status: BlocStatus.initial)) {
    on<OrganizerContestCreationPageCreateContest>(_createContest);
  }

  FutureOr<void> _createContest(
    OrganizerContestCreationPageCreateContest event,
    Emitter<OrganizerContestCreationPageState> emit,
  ) async {
    emit(OrganizerContestCreationPageState(status: BlocStatus.loading, sourceEvent: event));

    final String contestId = genUuid();

    late final List<String> imagesUrls;
    final eitherImagesUrls = await _storageRepository.uploadImages(
        bucket: StorageBucket.contestsImages,pathPrefix: contestId, images: event.images);
    eitherImagesUrls.fold(
          (failure) => emit(state.copyWith(status: BlocStatus.failure, message: failure.message)),
          (success) => imagesUrls = success,
    );
    if (eitherImagesUrls.isLeft()) {
      return;
    }

    final Place place = Place(
      id: null,
      createdAt: null,
      address: event.placeAddress,
      lat: event.placeLat,
      lon: event.placeLon,
    );

    final Contest contest = Contest(
      id: contestId,
      createdAt: null,
      organizerFullName: event.organizerFullName,
      organizerId: null,
      placeId: null,
      name: event.name,
      description: event.description,
      dateTime: event.dateTime,
      worksSubmissionStart: event.worksSubmissionStart,
      worksSubmissionEnd: event.worksSubmissionEnd,
      imagesUrls: imagesUrls,
      token: null,
    );

    final eitherCreateContest = await _organizerRepository.createContest(
        contest: contest, place: place);
    eitherCreateContest.fold(
      (failure) => emit(state.copyWith(status: BlocStatus.failure, message: failure.message)),
      (success) => emit(state.copyWith(status: BlocStatus.success)),
    );
  }
}
