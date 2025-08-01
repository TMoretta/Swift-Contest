import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:swift_contest/model/database/entities/work.dart';
import 'package:swift_contest/model/database/repositories/participant_repository.dart';
import 'package:swift_contest/model/database/repositories/storage_repository.dart';
import 'package:swift_contest/utils/logger/logger.dart';
import 'package:swift_contest/viewmodel/enums/bloc_status.dart';
import 'package:swift_contest/model/utils/storage_bucket.dart';

part 'participant_work_submit_page_event.dart';
part 'participant_work_submit_page_state.dart';

class ParticipantWorkSubmitPageBloc
    extends HydratedBloc<ParticipantWorkSubmitPageEvent, ParticipantWorkSubmitPageState> {
  final StorageRepository _storageRepository;
  final ParticipantRepository _participantRepository;

  ParticipantWorkSubmitPageBloc({
    required StorageRepository storageRepository,
    required ParticipantRepository participantRepository,
  })  : _storageRepository = storageRepository,
        _participantRepository = participantRepository,
        super(ParticipantWorkSubmitPageState(status: BlocStatus.initial)) {
    on<ParticipantWorkSubmitPageSubmitWork>(_submitWork);
  }

  @override
  ParticipantWorkSubmitPageState? fromJson(Map<String, dynamic> json) {
    try {
      return ParticipantWorkSubmitPageState.fromJson(json);
    } catch (e) {
      Logger.error(e);
      return null;
    }
  }

  @override
  Map<String, dynamic>? toJson(ParticipantWorkSubmitPageState state) {
    try {
      return state.toJson();
    } catch (e) {
      Logger.error(e);
      return null;
    }
  }

  Future<void> _submitWork(
    ParticipantWorkSubmitPageSubmitWork event,
    Emitter<ParticipantWorkSubmitPageState> emit,
  ) async {
    emit(ParticipantWorkSubmitPageState(status: BlocStatus.loading, sourceEvent: event));

    late final List<String> imagesUrls;
    final eitherImagesUrls = await _storageRepository.uploadImages(
        bucket: StorageBucket.worksImages, pathPrefix: '', images: event.images);
    eitherImagesUrls.fold(
      (failure) => emit(
          ParticipantWorkSubmitPageState(status: BlocStatus.failure, message: failure.message)),
      (success) => imagesUrls = success,
    );
    if (eitherImagesUrls.isLeft()) {
      return;
    }

    // late final String fileUrl;
    // final eitherFileUrl = await _storageRepository.uploadFile(bucket: StorageBucket.worksFiles, pathPrefix: '', file: event.file);
    // eitherFileUrl.fold(
    //     (failure) => emit(state.copyWith(status: BlocStatus.failure, message: failure.message)),
    //     (success) => fileUrl = success,
    // );

    final eitherWork = await _participantRepository.submitWork(
      contestId: event.contestId,
      work: Work(
        id: null,
        createdAt: null,
        participationId: null,
        participantFullName: event.participantFullName,
        name: event.name,
        description: event.description,
        imagesUrls: imagesUrls,
      ),
    );
    eitherWork.fold(
      (failure) => emit(state.copyWith(status: BlocStatus.failure, message: failure.message)),
      (success) => emit(state.copyWith(status: BlocStatus.success)),
    );
  }
}
