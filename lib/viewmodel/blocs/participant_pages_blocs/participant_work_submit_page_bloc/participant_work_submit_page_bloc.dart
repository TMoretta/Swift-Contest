import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:swift_contest/model/data_models/work/work.dart';
import 'package:swift_contest/viewmodel/repositories/storage_repository.dart';
import 'package:swift_contest/viewmodel/repositories/work_repository.dart';

part 'participant_work_submit_page_event.dart';
part 'participant_work_submit_page_state.dart';

class ParticipantWorkSubmitPageBloc
    extends Bloc<ParticipantWorkSubmitPageEvent, ParticipantWorkSubmitPageState> {
  final WorkRepository _workRepository;
  final StorageRepository _storageRepository;

  ParticipantWorkSubmitPageBloc(
      {required WorkRepository workRepository, required StorageRepository storageRepository})
      : _workRepository = workRepository,
        _storageRepository = storageRepository,
        super(ParticipantWorkSubmitPageInitial()) {
    on<ParticipantWorkSubmitPageSubmitWork>(_submitWork);
  }

  Future<void> _submitWork(
    ParticipantWorkSubmitPageSubmitWork event,
    Emitter<ParticipantWorkSubmitPageState> emit,
  ) async {
    emit(ParticipantWorkSubmitPageLoading());
    final imagesUrlsRes = await _storageRepository.uploadImages(images: event.images);
    await imagesUrlsRes.fold(
      (failure) async => emit(ParticipantWorkSubmitPageFailure(message: failure.message)),
      (success) async {
        final imagesUrls = success;
        final workRes = await _workRepository.submitWork(
          contestId: event.contestId,
          participantId: event.participantId,
          name: event.name,
          description: event.description,
          imagesUrls: imagesUrls,
        );
        workRes.fold(
          (failure) => emit(ParticipantWorkSubmitPageFailure(message: failure.message)),
          (success) => emit(ParticipantWorkSubmitPageSuccess(work: success)),
        );
      },
    );
  }
}
