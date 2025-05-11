import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:swift_contest/model/data_models/contest.dart';
import 'package:swift_contest/model/data_models/participation.dart';
import 'package:swift_contest/model/data_models/place.dart';
import 'package:swift_contest/model/data_models/profile.dart';
import 'package:swift_contest/model/data_models/work.dart';
import 'package:swift_contest/model/enums/work_status.dart';
import 'package:swift_contest/viewmodel/repositories/contest_repository.dart';
import 'package:swift_contest/viewmodel/repositories/participation_repository.dart';
import 'package:swift_contest/viewmodel/repositories/place_repository.dart';
import 'package:swift_contest/viewmodel/repositories/profile_repository.dart';
import 'package:swift_contest/viewmodel/repositories/work_repository.dart';
import 'package:swift_contest/viewmodel/blocs/bloc_status.dart';

part 'participant_contest_details_page_event.dart';

part 'participant_contest_details_page_state.dart';

class ParticipantContestDetailsPageBloc extends Bloc<
    ParticipantContestDetailsPageEvent, ParticipantContestDetailsPageState> {
  final WorkRepository _workRepository;
  final ContestRepository _contestRepository;
  final ProfileRepository _profileRepository;
  final ParticipationRepository _participationRepository;
  final PlaceRepository _placeRepository;

  ParticipantContestDetailsPageBloc({
    required WorkRepository workRepository,
    required ContestRepository contestRepository,
    required ProfileRepository profileRepository,
    required ParticipationRepository participationRepository,
    required PlaceRepository placeRepository,
  })  : _workRepository = workRepository,
        _contestRepository = contestRepository,
        _profileRepository = profileRepository,
        _participationRepository = participationRepository,
        _placeRepository = placeRepository,
        super(ParticipantContestDetailsPageState(status: BlocStatus.initial)) {
    on<ParticipantContestDetailsPageGetOwnWork>(_getOwnWork);
    on<ParticipantContestDetailsPageGetContestMainInfo>(_getContestMainInfo);
  }

  Future<void> _getContestMainInfo(
    ParticipantContestDetailsPageGetContestMainInfo event,
    Emitter<ParticipantContestDetailsPageState> emit,
  ) async {
    emit(state.copyWith(status: BlocStatus.loading));

    late final Contest contest;
    late final Profile organizer;
    late final Place place;

    //* Ottengo il contest
    final resContest =
        await _contestRepository.getContestById(id: event.contestId);
    resContest.fold(
      (failure) => emit(
          state.copyWith(status: BlocStatus.failure, message: failure.message)),
      (success) => contest = success,
    );
    if (resContest.isLeft()) return;

    //* Ottengo il place
    final resPlace = await _placeRepository.getPlaceById(id: contest.placeId);
    resPlace.fold(
      (failure) => emit(ParticipantContestDetailsPageState(
          status: BlocStatus.failure, message: failure.message)),
      (success) => place = success,
    );
    if (resPlace.isLeft()) return;

    //* Ottengo l'organizer
    final resOrganizer =
        await _profileRepository.getProfileById(id: contest.organizerId);
    resOrganizer.fold(
      (failure) => emit(
          state.copyWith(status: BlocStatus.failure, message: failure.message)),
      (success) => organizer = success,
    );
    if (resOrganizer.isLeft()) return;

    emit(state.copyWith(
      status: BlocStatus.success,
      contest: contest,
      organizer: organizer,
      place: place,
    ));
  }

  Future<void> _getOwnWork(
    ParticipantContestDetailsPageGetOwnWork event,
    Emitter<ParticipantContestDetailsPageState> emit,
  ) async {
    emit(state.copyWith(status: BlocStatus.loading));

    late final Participation ownParticipation;
    late final Work? ownWork;

    //* Ottengo la participation del participant
    final resParticipation = await _participationRepository
        .getParticipationByContestIdAndParticipantId(
      contestId: event.contestId,
      participantId: event.participantId,
    );
    resParticipation.fold(
      (failure) => emit(
          state.copyWith(status: BlocStatus.failure, message: failure.message)),
      (success) => ownParticipation = success,
    );
    if (resParticipation.isLeft()) return;

    //* Ottengo il work
    if (ownParticipation.workStatus == WorkStatus.submitted) {
      final resWork = await _workRepository.getWorkByParticipationId(
          participationId: ownParticipation.id);
      resWork.fold(
        (failure) => emit(state.copyWith(
            status: BlocStatus.failure, message: failure.message)),
        (success) => ownWork = success,
      );
      if (resWork.isLeft()) return;
    } else {
      ownWork = null;
    }

    emit(state.copyWith(
      status: BlocStatus.success,
      ownWork: ownWork,
      ownParticipation: ownParticipation,
    ));
  }
}
