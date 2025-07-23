import 'dart:io';

import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:swift_contest/model/data_models/work.dart';
import 'package:swift_contest/model/repositories/participant_repository.dart';
import 'package:swift_contest/model/repositories/storage_repository.dart';
import 'package:swift_contest/viewmodel/enums/bloc_status.dart';

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
    final eitherImagesUrls = await _storageRepository.uploadImages(
        bucket: StorageBucket.worksImages, images: event.images);
    eitherImagesUrls.fold(
      (failure) => emit(
          ParticipantWorkSubmitPageState(status: BlocStatus.failure, message: failure.message)),
      (success) => imagesUrls = success,
    );
    if (eitherImagesUrls.isLeft()) {
      return;
    }

    late final String fileUrl;
    final eitherFileUrl = await _storageRepository.uploadFile(bucket: StorageBucket.worksFiles, file: event.file);
    eitherFileUrl.fold(
        (failure) => emit(state.copyWith(status: BlocStatus.failure, message: failure.message)),
        (success) => fileUrl = success,
    );


    final eitherWork = await _participantRepository.submitWork(
      contestId: event.contestId,
      name: event.name,
      description: event.description,
      imagesUrls: imagesUrls,
      fileUrl: fileUrl,
    );
    eitherWork.fold(
        (failure) => emit(state.copyWith(status: BlocStatus.failure, message: failure.message)),
        (success) => emit(state.copyWith(status: BlocStatus.success)),
    );
  }
}
