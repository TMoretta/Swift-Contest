import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:swift_contest/model/data_models/participation.dart';
import 'package:swift_contest/model/data_models/work.dart';
import 'package:swift_contest/model/enums/work_status.dart';
import 'package:swift_contest/model/services/storage_service.dart';
import 'package:swift_contest/viewmodel/blocs/bloc_status.dart';
import 'package:swift_contest/viewmodel/repositories/participation_repository.dart';
import 'package:swift_contest/viewmodel/repositories/storage_repository.dart';
import 'package:swift_contest/viewmodel/repositories/work_repository.dart';
import 'package:uuid/uuid.dart';

part 'participant_work_submit_page_event.dart';

part 'participant_work_submit_page_state.dart';

class ParticipantWorkSubmitPageBloc
    extends Bloc<ParticipantWorkSubmitPageEvent, ParticipantWorkSubmitPageState> {
  final WorkRepository _workRepository;
  final StorageRepository _storageRepository;
  final ParticipationRepository _participationRepository;

  ParticipantWorkSubmitPageBloc({
    required WorkRepository workRepository,
    required StorageRepository storageRepository,
    required ParticipationRepository participationRepository,
  })  : _workRepository = workRepository,
        _storageRepository = storageRepository,
        _participationRepository = participationRepository,
        super(ParticipantWorkSubmitPageState(status: BlocStatus.initial)) {
    on<ParticipantWorkSubmitPageSubmitWork>(_submitWork);
  }

  Future<void> _submitWork(
    ParticipantWorkSubmitPageSubmitWork event,
    Emitter<ParticipantWorkSubmitPageState> emit,
  ) async {
    emit(ParticipantWorkSubmitPageState(status: BlocStatus.loading));

    late final List<String> imagesUrls;
    final imagesUrlsRes = await _storageRepository.uploadImages(
        bucket: StorageBucket.worksImages, images: event.images);
    imagesUrlsRes.fold(
      (failure) => emit(
          ParticipantWorkSubmitPageState(status: BlocStatus.failure, message: failure.message)),
      (success) => imagesUrls = success,
    );
    if (imagesUrlsRes.isLeft()) return;

    late final Participation participation;
    final eitherParticipation =
        await _participationRepository.getParticipationByContestIdAndParticipantId(
      contestId: event.contestId,
      participantId: event.participantId,
    );
    eitherParticipation.fold(
      (failure) => emit(
          ParticipantWorkSubmitPageState(status: BlocStatus.failure, message: failure.message)),
      (success) => participation = success,
    );
    if (eitherParticipation.isLeft()) return;

    late final Work work;
    final eitherWork = await _workRepository.createWork(
      work: Work(
        id: Uuid().v4(),
        createdAt: DateTime.now(),
        participationId: participation.id,
        name: event.name,
        description: event.description,
        imagesUrls: imagesUrls,
      ),
    );

    eitherWork.fold(
          (failure) => emit(
          ParticipantWorkSubmitPageState(status: BlocStatus.failure, message: failure.message)),
          (success) => work = success,
    );
    if (eitherWork.isLeft()) return;

    final eitherParticipationUpdate = await _participationRepository.updateParticipationById(
      id: participation.id,
      participation: participation.copyWith(workStatus: WorkStatus.submitted),
    );
    eitherParticipationUpdate.fold(
      (failure) => emit(
          ParticipantWorkSubmitPageState(status: BlocStatus.failure, message: failure.message)),
      (success) => participation = success,
    );
    if (eitherParticipationUpdate.isLeft()) return;

    emit(ParticipantWorkSubmitPageState(status: BlocStatus.success, work: work));
  }
}
