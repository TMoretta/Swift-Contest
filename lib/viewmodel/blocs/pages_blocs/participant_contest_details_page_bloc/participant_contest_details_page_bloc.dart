import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:swift_contest/model/data_models/contest/contest.dart';
import 'package:swift_contest/model/data_models/participation/participation.dart';
import 'package:swift_contest/model/data_models/profile/profile.dart';
import 'package:swift_contest/model/data_models/work/work.dart';
import 'package:swift_contest/viewmodel/repositories/contest_repository.dart';
import 'package:swift_contest/viewmodel/repositories/participation_repository.dart';
import 'package:swift_contest/viewmodel/repositories/profile_repository.dart';
import 'package:swift_contest/viewmodel/repositories/work_repository.dart';
import 'package:swift_contest/viewmodel/blocs/bloc_status.dart';

part 'participant_contest_details_page_event.dart';
part 'participant_contest_details_page_state.dart';

class ParticipantContestDetailsPageBloc
    extends Bloc<ParticipantContestDetailsPageEvent, ParticipantContestDetailsPageState> {
  final WorkRepository _workRepository;
  final ContestRepository _contestRepository;
  final ProfileRepository _profileRepository;
  final ParticipationRepository _participationRepository;

  ParticipantContestDetailsPageBloc({
    required WorkRepository workRepository,
    required ContestRepository contestRepository,
    required ProfileRepository profileRepository,
    required ParticipationRepository participationRepository,
  })
      : _workRepository = workRepository,
        _contestRepository = contestRepository,
        _profileRepository = profileRepository,
        _participationRepository = participationRepository,
        super(ParticipantContestDetailsPageState(status: BlocStatus.initial)) {
    on<ParticipantContestDetailsPageGetOwnWork>(_getOwnWork);
    on<ParticipantContestDetailsPageGetExtendedContest>(_getExtendedContest);
  }

  Future<void> _getOwnWork(ParticipantContestDetailsPageGetOwnWork event,
      Emitter<ParticipantContestDetailsPageState> emit,) async {
    emit(state.copyWith(status: BlocStatus.loading));

    late final Participation ownParticipation;
    late final Work? ownWork;

    //* Ottengo la participation del participant
    final resParticipation =
    await _participationRepository.getParticipationByContestIdAndParticipantId(
      contestId: event.contestId,
      participantId: event.participantId,
    );
    resParticipation.fold(
          (failure) => emit(state.copyWith(status: BlocStatus.failure,message: failure.message)),
          (success) => ownParticipation = success,
    );
    if (resParticipation.isLeft()) return;

    //* Ottengo il work
    if (ownParticipation.workId != null) {
      final resWork = await _workRepository.getWorkById(id: ownParticipation.workId!);
      resWork.fold(
            (failure) => emit(state.copyWith(status: BlocStatus.failure,message: failure.message)),
            (success) => ownWork = success,
      );
      if (resWork.isLeft()) return;
    } else {
      ownWork = null;
    }

    emit(state.copyWith(status: BlocStatus.success,ownWork: ownWork,ownParticipation: ownParticipation));
  }

  Future<void> _getExtendedContest(ParticipantContestDetailsPageGetExtendedContest event,
      Emitter<ParticipantContestDetailsPageState> emit,) async {
    emit(state.copyWith(status: BlocStatus.loading));

    late final Contest contest;
    late final Profile organizer;

    //* Ottengo il contest
    final resContest = await _contestRepository.getContestById(id: event.contestId);
    resContest.fold(
          (failure) => emit(state.copyWith(status: BlocStatus.failure,message: failure.message)),
          (success) => contest = success,
    );
    if (resContest.isLeft()) return;

    //* Ottengo l'organizer
    final resOrganizer = await _profileRepository.getProfileById(id: contest.organizerId);
    resOrganizer.fold(
          (failure) => emit(state.copyWith(status: BlocStatus.failure,message: failure.message)),
          (success) => organizer = success,
    );
    if (resOrganizer.isLeft()) return;

    emit(state.copyWith(status: BlocStatus.success,contest: contest,organizer: organizer));
  }
}
