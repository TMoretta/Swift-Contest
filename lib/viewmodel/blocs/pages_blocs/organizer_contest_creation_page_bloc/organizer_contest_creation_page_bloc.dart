import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:swift_contest/model/data_models/contest.dart';
import 'package:swift_contest/model/data_models/place.dart';
import 'package:swift_contest/model/data_models/voting_form.dart';
import 'package:swift_contest/model/enums/contest_status.dart';
import 'package:swift_contest/model/services/storage_service.dart';
import 'package:swift_contest/viewmodel/enums/bloc_status.dart';
import 'package:swift_contest/viewmodel/repositories/contest_repository.dart';
import 'package:swift_contest/viewmodel/repositories/place_repository.dart';
import 'package:swift_contest/viewmodel/repositories/storage_repository.dart';
import 'package:swift_contest/viewmodel/repositories/utils_repository.dart';
import 'package:swift_contest/viewmodel/repositories/voting_form_repository.dart';
import 'package:uuid/uuid.dart';

part 'organizer_contest_creation_page_event.dart';

part 'organizer_contest_creation_page_state.dart';

class OrganizerContestCreationPageBloc
    extends Bloc<OrganizerContestCreationPageEvent, OrganizerContestCreationPageState> {
  final ContestRepository _contestRepository;
  final StorageRepository _storageRepository;
  final PlaceRepository _placeRepository;
  final UtilsRepository _utilsRepository;
  final VotingFormRepository _votingFormRepository;

  OrganizerContestCreationPageBloc({
    required ContestRepository contestRepository,
    required StorageRepository storageRepository,
    required PlaceRepository placeRepository,
    required UtilsRepository utilsRepository,
    required VotingFormRepository votingFormRepository,
  })  : _contestRepository = contestRepository,
        _storageRepository = storageRepository,
        _utilsRepository = utilsRepository,
        _placeRepository = placeRepository,
        _votingFormRepository = votingFormRepository,
        super(OrganizerContestCreationPageState(status: BlocStatus.initial)) {
    on<OrganizerContestCreationPageCreateContest>(_createContest);
  }

  Future<void> _createContest(
    OrganizerContestCreationPageCreateContest event,
    Emitter<OrganizerContestCreationPageState> emit,
  ) async {
    emit(OrganizerContestCreationPageState(status: BlocStatus.loading));

    late final Place place;
    final eitherPlace = await _placeRepository.createPlace(
        place: Place(
            id: Uuid().v4(),
            createdAt: DateTime.now(),
            address: event.placeAddress,
            lat: event.placeLat,
            lon: event.placeLon));
    eitherPlace.fold(
      (failure) => emit(
          OrganizerContestCreationPageState(status: BlocStatus.failure, message: failure.message)),
      (success) => place = success,
    );
    if (eitherPlace.isLeft()) return;

    late final List<String> imagesUrls;
    final eitherImagesUrls = await _storageRepository.uploadImages(
        bucket: StorageBucket.contestsImages, images: event.images);
    eitherImagesUrls.fold(
      (failure) => emit(
          OrganizerContestCreationPageState(status: BlocStatus.failure, message: failure.message)),
      (success) => imagesUrls = success,
    );
    if (eitherImagesUrls.isLeft()) return;

    late final String token;
    final eitherToken = await _utilsRepository.genUniqueToken(
        tableName: 'contests', columnName: 'token', length: 8);
    eitherToken.fold(
      (failure) => emit(
          OrganizerContestCreationPageState(status: BlocStatus.failure, message: failure.message)),
      (success) => token = success,
    );
    if (eitherToken.isLeft()) return;

    late final VotingForm votingForm;
    final eitherVotingForm = await _votingFormRepository.createVotingForm(
        votingForm: VotingForm(id: Uuid().v4(), createdAt: DateTime.now()));

    eitherVotingForm.fold(
      (failure) => emit(
          OrganizerContestCreationPageState(status: BlocStatus.failure, message: failure.message)),
      (success) => votingForm = success,
    );
    if (eitherVotingForm.isLeft()) return;

    // late final VotingConfiguration votingConfiguration;
    // final eitherVotingConfiguration =
    //     await _votingConfigurationRepository.createVotingConfiguration(
    //   votingConfiguration: VotingConfiguration(
    //     id: Uuid().v4(),
    //     createdAt: DateTime.now(),
    //     votingFormId: votingForm.id,
    //   ),
    // );
    //
    // eitherVotingConfiguration.fold(
    //   (failure) => emit(
    //       OrganizerContestCreationPageState(status: BlocStatus.failure, message: failure.message)),
    //   (success) => votingConfiguration = success,
    // );
    // if (eitherVotingConfiguration.isLeft()) return;

    late final ContestStatus contestStatus;
    final now = DateTime.now();
    if (now.isBefore(event.worksSubmissionFrom)) {
      contestStatus = ContestStatus.preparationPhase;
    } else if (now.isBefore(event.worksSubmissionTo)) {
      contestStatus = ContestStatus.preparationPhase;
    } else {
      contestStatus = ContestStatus.votingPhase;
    }

    late final Contest contest;
    final eitherContest = await _contestRepository.createContest(
        contest: Contest(
      id: Uuid().v4(),
      createdAt: DateTime.now(),
      organizerId: event.organizerId,
      name: event.name,
      description: event.description,
      dateTime: event.dateTime,
      worksSubmissionFrom: event.worksSubmissionFrom,
      worksSubmissionTo: event.worksSubmissionTo,
      placeId: place.id,
      contestStatus: contestStatus,
      imagesUrls: imagesUrls,
      token: token,
      votingFormId: votingForm.id,
      isDeleted: false,
    ));
    eitherContest.fold(
      (failure) => emit(
          OrganizerContestCreationPageState(status: BlocStatus.failure, message: failure.message)),
      (success) => contest = success,
    );
    if (eitherContest.isLeft()) return;

    emit(OrganizerContestCreationPageState(status: BlocStatus.success, contest: contest));
  }
}
