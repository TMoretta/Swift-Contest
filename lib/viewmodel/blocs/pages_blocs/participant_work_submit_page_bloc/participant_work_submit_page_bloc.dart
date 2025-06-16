import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:swift_contest/model/data_models/participation.dart';
import 'package:swift_contest/model/data_models/work.dart';
import 'package:swift_contest/model/repositories/crud_repositories/participation_repository.dart';
import 'package:swift_contest/model/repositories/role_repositories/participant_repository.dart';
import 'package:swift_contest/model/repositories/storage_repository.dart';
import 'package:swift_contest/model/repositories/crud_repositories/work_repository.dart';
import 'package:swift_contest/utils/functions/gen_uuid.dart';
import 'package:swift_contest/utils/functions/now.dart';
import 'package:swift_contest/viewmodel/enums/bloc_status.dart';
import 'package:uuid/uuid.dart';

part 'participant_work_submit_page_event.dart';

part 'participant_work_submit_page_state.dart';

class ParticipantWorkSubmitPageBloc
    extends Bloc<ParticipantWorkSubmitPageEvent, ParticipantWorkSubmitPageState> {
  final StorageRepository _storageRepository;
  final ParticipantRepository _participantRepository;

  ParticipantWorkSubmitPageBloc({
    required StorageRepository storageRepository,
    required ParticipantRepository participantRepository,
  })  :
        _storageRepository = storageRepository,
        _participantRepository = participantRepository,
        super(ParticipantWorkSubmitPageState(status: BlocStatus.initial)) {
    on<ParticipantWorkSubmitPageSubmitWork>(_submitWork);
  }

  Future<void> _submitWork(
    ParticipantWorkSubmitPageSubmitWork event,
    Emitter<ParticipantWorkSubmitPageState> emit,
  ) async {
    emit(ParticipantWorkSubmitPageState(status: BlocStatus.loading, sourceEvent: event));

    late final List<String> imagesUrls;
    final imagesUrlsRes = await _storageRepository.uploadImages(
        bucket: StorageBucket.worksImages, images: event.images);
    imagesUrlsRes.fold(
      (failure) => emit(
          ParticipantWorkSubmitPageState(status: BlocStatus.failure, message: failure.message)),
      (success) => imagesUrls = success,
    );
    if (imagesUrlsRes.isLeft()) {
      return;
    }

    final eitherWork = await _participantRepository.submitWork(
      contestId: event.contestId,
      participantId: event.participantId,
      name: event.name,
      description: event.description,
      imagesUrls: imagesUrls,
    );
    eitherWork.fold(
        (failure) => emit(state.copyWith(status: BlocStatus.failure, message: failure.message)),
        (success) => emit(state.copyWith(status: BlocStatus.success)),
    );

    // late final Participation? participation;
    // final eitherParticipation =
    // await _participationRepository.getParticipationByContestIdAndParticipantId(
    //   contestId: event.contestId,
    //   participantId: event.participantId,
    // );
    // eitherParticipation.fold(
    //       (failure) => emit(
    //       ParticipantWorkSubmitPageState(status: BlocStatus.failure, message: failure.message)),
    //       (success) => participation = success,
    // );
    // if (eitherParticipation.isLeft()) {
    //   return;
    // }
    // if(participation == null) {
    //   emit(state.copyWith(status: BlocStatus.failure, message: 'Participation not found'));
    //   return;
    // }
    //
    // late final Work work;
    // final eitherWork = await _workRepository.createWork(
    //   work: Work(
    //     id: genUuid(),
    //     createdAt: now(),
    //     participationId: participation!.id,
    //     name: event.name,
    //     description: event.description,
    //     imagesUrls: imagesUrls,
    //   ),
    // );
    //
    // eitherWork.fold(
    //       (failure) => emit(
    //       ParticipantWorkSubmitPageState(status: BlocStatus.failure, message: failure.message)),
    //       (success) => work = success,
    // );
    // if (eitherWork.isLeft()) return;
    //
    // final eitherParticipationUpdate = await _participationRepository.updateParticipation(
    //   participation: participation!.copyWith(hasSubmitted: true),
    // );
    // eitherParticipationUpdate.fold(
    //       (failure) => emit(
    //       ParticipantWorkSubmitPageState(status: BlocStatus.failure, message: failure.message)),
    //       (success) => participation = success,
    // );
    // if (eitherParticipationUpdate.isLeft()) return;
    //
    // emit(ParticipantWorkSubmitPageState(status: BlocStatus.success, work: work));
  }
}
