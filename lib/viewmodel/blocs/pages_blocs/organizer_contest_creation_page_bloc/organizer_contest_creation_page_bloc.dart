import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:swift_contest/model/data_models/contest.dart';
import 'package:swift_contest/model/data_models/place.dart';
import 'package:swift_contest/model/enums/contest_status.dart';
import 'package:swift_contest/model/repositories/organizer_repository.dart';
import 'package:swift_contest/model/repositories/storage_repository.dart';
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

    final PlaceNullable place = PlaceNullable(
      address: event.placeAddress,
      lat: event.placeLat,
      lon: event.placeLon,
    );

    late final List<String> imagesUrls;
    final eitherImagesUrls = await _storageRepository.uploadImages(
        bucket: StorageBucket.contestsImages, images: event.images);
    eitherImagesUrls.fold(
          (failure) => emit(state.copyWith(status: BlocStatus.failure, message: failure.message)),
          (success) => imagesUrls = success,
    );
    if (eitherImagesUrls.isLeft()) {
      return;
    }

    // final Place place = Place(
    //   id: genUuid(),
    //   createdAt: now(),
    //   address: event.placeAddress,
    //   lat: event.placeLat,
    //   lon: event.placeLon,
    // );

    // final VotingForm votingForm = VotingForm(
    //   id: genUuid(),
    //   createdAt: now(),
    // );


    // late final String token;
    // final eitherToken = await _utilsRepository.genUniqueToken(
    //     tableName: 'contests', columnName: 'token', length: 14);
    // eitherToken.fold(
    //   (failure) => emit(state.copyWith(status: BlocStatus.failure, message: failure.message)),
    //   (success) => token = success,
    // );
    // if (eitherToken.isLeft()) {
    //   return;
    // }

    late final ContestStatus contestStatus;
    final nowt = DateTime.now();
    if (nowt.isBefore(event.worksSubmissionStart)) {
      contestStatus = ContestStatus.preparationPhase;
    } else if (nowt.isBefore(event.worksSubmissionEnd)) {
      contestStatus = ContestStatus.preparationPhase;
    } else {
      contestStatus = ContestStatus.votingPhase;
    }

    final ContestNullable contest = ContestNullable(
      organizerId: event.organizerId,
      name: event.name,
      description: event.description,
      dateTime: event.dateTime,
      worksSubmissionStart: event.worksSubmissionStart,
      worksSubmissionEnd: event.worksSubmissionEnd,
      imagesUrls: imagesUrls,
      contestStatus: contestStatus,
    );

    // final Contest contest = Contest(
    //   id: genUuid(),
    //   createdAt: now(),
    //   organizerId: event.organizerId,
    //   name: event.name,
    //   description: event.description,
    //   dateTime: event.dateTime,
    //   worksSubmissionStart: event.worksSubmissionStart,
    //   worksSubmissionEnd: event.worksSubmissionEnd,
    //   imagesUrls: imagesUrls,
    //   placeId: place.id,
    //   contestStatus: contestStatus,
    //   token: token,
    //   votingFormId: votingForm.id,
    // );

    final eitherCreateContest = await _organizerRepository.createContest(
        contest: contest, place: place);
    eitherCreateContest.fold(
      (failure) => emit(state.copyWith(status: BlocStatus.failure, message: failure.message)),
      (success) => emit(state.copyWith(status: BlocStatus.success)),
    );
  }
}
