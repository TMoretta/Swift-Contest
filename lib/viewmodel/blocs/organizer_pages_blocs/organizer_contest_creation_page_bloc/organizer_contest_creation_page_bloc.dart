import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:swift_contest/model/data_models/contest/contest.dart';
import 'package:swift_contest/model/data_models/contest/place.dart';
import 'package:swift_contest/viewmodel/repositories/contest_repository.dart';
import 'package:swift_contest/viewmodel/repositories/storage_repository.dart';

part 'organizer_contest_creation_page_event.dart';

part 'organizer_contest_creation_page_state.dart';

class OrganizerContestCreationPageBloc
    extends Bloc<OrganizerContestCreationPageEvent, OrganizerContestCreationPageState> {
  final ContestRepository _contestRepository;
  final StorageRepository _storageRepository;

  OrganizerContestCreationPageBloc({
    required ContestRepository contestRepository,
    required StorageRepository storageRepository,
  })  : _contestRepository = contestRepository,
        _storageRepository = storageRepository,
        super(OrganizerContestCreationPageInitial()) {
    on<OrganizerContestCreationPageCreateContest>(_createContest);
  }

  Future<void> _createContest(
    OrganizerContestCreationPageCreateContest event,
    Emitter<OrganizerContestCreationPageState> emit,
  ) async {
    emit(OrganizerContestCreationPageLoading());

    final imagesUrlsRes = await _storageRepository.uploadImages(images: event.images);
    await imagesUrlsRes.fold(
      (failure) async => emit(OrganizerContestCreationPageFailure(message: failure.message)),
      (success) async {
        final imagesUrls = success;
        final contestRes = await _contestRepository.createContest(
          name: event.name,
          description: event.description,
          organizerId: event.organizerId,
          place: event.place,
          worksPreviewJurors: event.worksPreviewJurors,
          dateTime: event.dateTime,
          worksDateTimeFrom: event.worksDateTimeFrom,
          worksDateTimeTo: event.worksDateTimeTo,
          imagesUrls: imagesUrls,
        );
        contestRes.fold(
          (failure) => emit(OrganizerContestCreationPageFailure(message: failure.message)),
          (success) => emit(
            OrganizerContestCreationPageSuccess(contest: success),
          ),
        );
      },
    );
  }
}
