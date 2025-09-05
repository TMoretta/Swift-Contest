import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:swift_contest/model/database/entities/work.dart';
import 'package:swift_contest/model/database/repositories/participant_repository.dart';
import 'package:swift_contest/viewmodel/types/bloc_status.dart';

part 'participant_work_submit_page_event.dart';
part 'participant_work_submit_page_state.dart';

class ParticipantWorkSubmitPageBloc
    extends Bloc<ParticipantWorkSubmitPageEvent, ParticipantWorkSubmitPageState> {
  final ParticipantRepository _participantRepository;

  ParticipantWorkSubmitPageBloc({
    required ParticipantRepository participantRepository,
  })  : _participantRepository = participantRepository,
        super(ParticipantWorkSubmitPageState(status: BlocStatus.initial)) {
    on<ParticipantWorkSubmitPageSubmitWork>(_submitWork);
  }

  Future<void> _submitWork(
    ParticipantWorkSubmitPageSubmitWork event,
    Emitter<ParticipantWorkSubmitPageState> emit,
  ) async {
    emit(ParticipantWorkSubmitPageState(status: BlocStatus.loading, sourceEvent: event));

    final eitherWork = await _participantRepository.submitWork(
      contestId: event.contestId,
      work: Work(
        id: null,
        createdAt: null,
        participationId: null,
        name: event.name,
        description: event.description,
        imagesPaths: [],
      ),
      images: event.images,
    );
    eitherWork.fold(
      (failure) => emit(state.copyWith(status: BlocStatus.failure, message: failure.message)),
      (success) => emit(state.copyWith(status: BlocStatus.success)),
    );
  }
}
