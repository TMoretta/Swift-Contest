import 'dart:io';

import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:image_picker/image_picker.dart';
import 'package:swift_contest/model/database/entities/work.dart';
import 'package:swift_contest/model/database/repositories/participant_repository.dart';
import 'package:swift_contest/model/database/repositories/storage_repository.dart';
import 'package:swift_contest/utils/logger/logger.dart';
import 'package:swift_contest/viewmodel/types/bloc_status.dart';
import 'package:swift_contest/model/database/types/storage_bucket.dart';

part 'participant_work_submit_page_event.dart';
part 'participant_work_submit_page_state.dart';

class ParticipantWorkSubmitPageBloc
    extends Bloc<ParticipantWorkSubmitPageEvent, ParticipantWorkSubmitPageState> {
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

    final List<File> images = [];
    for(var image in event.images) {
      images.add(File(image.path));
    }

    final eitherWork = await _participantRepository.submitWork(
      contestId: event.contestId,
      work: Work(
        id: null,
        createdAt: null,
        participationId: null,
        participantFullName: event.participantFullName,
        name: event.name,
        description: event.description,
        imagesUrls: [],
      ),
      images: images,
    );
    eitherWork.fold(
      (failure) => emit(state.copyWith(status: BlocStatus.failure, message: failure.message)),
      (success) => emit(state.copyWith(status: BlocStatus.success)),
    );
  }
}
