import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:swift_contest/model/database/entities/contest.dart';
import 'package:swift_contest/model/database/entities/place.dart';
import 'package:swift_contest/model/database/repositories/organizer_repository.dart';
import 'package:swift_contest/utils/logger/logger.dart';
import 'package:swift_contest/viewmodel/types/bloc_status.dart';

part 'organizer_contest_creation_page_event.dart';

part 'organizer_contest_creation_page_state.dart';

class OrganizerContestCreationPageBloc
    extends Bloc<OrganizerContestCreationPageEvent, OrganizerContestCreationPageState> {
  final OrganizerRepository _organizerRepository;

  OrganizerContestCreationPageBloc({
    required OrganizerRepository organizerRepository,
  })  : _organizerRepository = organizerRepository,
        super(OrganizerContestCreationPageState(status: BlocStatus.initial)) {
    on<OrganizerContestCreationPageCreateContest>(_createContest);
  }

  @override
  OrganizerContestCreationPageState? fromJson(Map<String, dynamic> json) {
    try {
      return OrganizerContestCreationPageState.fromJson(json);
    } catch (e) {
      Logger.error(e);
      return null;
    }
  }

  @override
  Map<String, dynamic>? toJson(OrganizerContestCreationPageState state) {
    try {
      return state.toJson();
    } catch (e) {
      Logger.error(e);
      return null;
    }
  }

  FutureOr<void> _createContest(
    OrganizerContestCreationPageCreateContest event,
    Emitter<OrganizerContestCreationPageState> emit,
  ) async {
    emit(OrganizerContestCreationPageState(status: BlocStatus.loading, sourceEvent: event));

    // final String contestId = genUuid();
    //
    // late final List<String> imagesUrls;
    // final eitherImagesUrls = await _storageRepository.uploadImages(
    //     bucket: StorageBucket.contestsImages,pathPrefix: contestId, images: event.images);
    // eitherImagesUrls.fold(
    //       (failure) => emit(state.copyWith(status: BlocStatus.failure, message: failure.message)),
    //       (success) => imagesUrls = success,
    // );
    // if (eitherImagesUrls.isLeft()) {
    //   return;
    // }

    final Place place = Place(
      id: null,
      createdAt: null,
      address: event.placeAddress,
      lat: event.placeLat,
      lon: event.placeLon,
    );

    final Contest contest = Contest(
      id: null,
      createdAt: null,
      organizerId: null,
      placeId: null,
      name: event.name,
      description: event.description,
      dateTime: event.dateTime,
      worksSubmissionStart: event.worksSubmissionStart,
      worksSubmissionEnd: event.worksSubmissionEnd,
      imagesPaths: [],
    );

    final eitherCreateContest = await _organizerRepository.createContest(
        contest: contest, place: place, images: event.images);
    eitherCreateContest.fold(
      (failure) => emit(state.copyWith(status: BlocStatus.failure, message: failure.message)),
      (success) => emit(state.copyWith(status: BlocStatus.success)),
    );
  }
}
