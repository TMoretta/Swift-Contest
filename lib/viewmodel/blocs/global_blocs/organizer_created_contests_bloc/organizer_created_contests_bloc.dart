import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:swift_contest/model/data_models/contest.dart';
import 'package:swift_contest/model/data_models/juration.dart';
import 'package:swift_contest/model/data_models/participation.dart';
import 'package:swift_contest/model/data_models/place.dart';
import 'package:swift_contest/model/data_models/profile.dart';
import 'package:swift_contest/viewmodel/enums/bloc_status.dart';
import 'package:swift_contest/viewmodel/repositories/contest_repository.dart';
import 'package:swift_contest/viewmodel/repositories/juration_repository.dart';
import 'package:swift_contest/viewmodel/repositories/participation_repository.dart';
import 'package:swift_contest/viewmodel/repositories/place_repository.dart';
import 'package:swift_contest/viewmodel/repositories/profile_repository.dart';

part 'organizer_created_contests_event.dart';
part 'organizer_created_contests_state.dart';

class OrganizerCreatedContestsBloc
    extends Bloc<OrganizerCreatedContestsEvent, OrganizerCreatedContestsState> {
  final ContestRepository _contestRepository;
  final ProfileRepository _profileRepository;
  final ParticipationRepository _participationRepository;
  final JurationRepository _jurationRepository;
  final PlaceRepository _placeRepository;

  OrganizerCreatedContestsBloc({
    required ContestRepository contestRepository,
    required ProfileRepository profileRepository,
    required ParticipationRepository participationRepository,
    required JurationRepository jurationRepository,
    required PlaceRepository placeRepository,
  })  : _contestRepository = contestRepository,
        _profileRepository = profileRepository,
        _participationRepository = participationRepository,
        _jurationRepository = jurationRepository,
  _placeRepository = placeRepository,
        super(OrganizerCreatedContestsState(status: BlocStatus.initial)) {
    on<OrganizerCreatedContestsGetCreatedContests>(_getCreatedContests);
    on<OrganizerCreatedContestsClear>(_clear);
  }

  Future<void> _getCreatedContests(
    OrganizerCreatedContestsGetCreatedContests event,
    Emitter<OrganizerCreatedContestsState> emit,
  ) async {
    emit(OrganizerCreatedContestsState(status: BlocStatus.loading));

    final List<Contest> contests = [];
    final List<Place> places = [];
    final List<Profile> organizers = [];
    final List<List<Participation>> participations = [];
    final List<List<Juration>> jurations = [];

    //* Ottengo i contest
    final resContest =
        await _contestRepository.getContestsByOrganizerId(organizerId: event.organizerId);
    resContest.fold(
      (failure) =>
          emit(state.copyWith(status: BlocStatus.failure, message: failure.message)),
      (success) => contests.addAll(success),
    );
    if (resContest.isLeft()) {
      return;
    }

    //* Ordino i contest per data di creazione
    contests.sort((a, b) => a.createdAt.compareTo(b.createdAt));

    //* Ottengo l'organizer per ogni contest
    for (var contest in contests) {
      final resOrganizer = await _profileRepository.getProfileById(id: contest.organizerId);
      resOrganizer.fold(
        (failure) => emit(
            state.copyWith(status: BlocStatus.failure, message: failure.message)),
        (success) => organizers.add(success),
      );

      if (resOrganizer.isLeft()) {
        return;
      }
    }

    //* Ottengo il place per ogni contest
    for (var contest in contests) {
      final resPlace = await _placeRepository.getPlaceById(id: contest.placeId);
      resPlace.fold(
            (failure) => emit(
                state.copyWith(status: BlocStatus.failure, message: failure.message)),
            (success) => places.add(success),
      );

      if (resPlace.isLeft()) {
        return;
      }
    }

    //* Ottengo le participations per ogni contest
    for (var contest in contests) {
      final resParticipations =
          await _participationRepository.getParticipationsByContestId(contestId: contest.id);
      resParticipations.fold(
        (failure) => emit(
            state.copyWith(status: BlocStatus.failure, message: failure.message)),
        (success) => participations.add(success),
      );

      if (resParticipations.isLeft()) {
        return;
      }
    }

    //* Ottengo le jurations per ogni contest
    for (var contest in contests) {
      final resJurations = await _jurationRepository.getJurationsByContestId(contestId: contest.id);
      resJurations.fold(
        (failure) => emit(
            state.copyWith(status: BlocStatus.failure, message: failure.message)),
        (success) => jurations.add(success),
      );

      if (resJurations.isLeft()) {
        return;
      }
    }

    emit(state.copyWith(
      status: BlocStatus.success,
      contests: contests,
      organizers: organizers,
      participations: participations,
      jurations: jurations,
      places: places,
    ));
  }

  void _clear(OrganizerCreatedContestsClear event, Emitter<OrganizerCreatedContestsState> emit,) {
    emit(OrganizerCreatedContestsState(status: BlocStatus.initial));
  }
}
