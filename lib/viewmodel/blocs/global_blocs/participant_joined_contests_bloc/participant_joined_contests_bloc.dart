import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/cupertino.dart';
import 'package:swift_contest/model/data_models/contest.dart';
import 'package:swift_contest/model/data_models/juration.dart';
import 'package:swift_contest/model/data_models/participation.dart';
import 'package:swift_contest/model/data_models/place.dart';
import 'package:swift_contest/model/data_models/profile.dart';
import 'package:swift_contest/viewmodel/blocs/bloc_status.dart';
import 'package:swift_contest/viewmodel/repositories/contest_repository.dart';
import 'package:swift_contest/viewmodel/repositories/juration_repository.dart';
import 'package:swift_contest/viewmodel/repositories/participation_repository.dart';
import 'package:swift_contest/viewmodel/repositories/place_repository.dart';
import 'package:swift_contest/viewmodel/repositories/profile_repository.dart';

part 'participant_joined_contests_event.dart';

part 'participant_joined_contests_state.dart';

class ParticipantJoinedContestsBloc extends Bloc<ParticipantJoinedContestsEvent,
    ParticipantJoinedContestsState> {
  final ContestRepository _contestRepository;
  final ParticipationRepository _participationRepository;
  final ProfileRepository _profileRepository;
  final JurationRepository _jurationRepository;
  final PlaceRepository _placeRepository;

  ParticipantJoinedContestsBloc({
    required ContestRepository contestRepository,
    required ParticipationRepository participationRepository,
    required ProfileRepository profileRepository,
    required JurationRepository jurationRepository,
    required PlaceRepository placeRepository,
  })  : _contestRepository = contestRepository,
        _participationRepository = participationRepository,
        _profileRepository = profileRepository,
        _jurationRepository = jurationRepository,
        _placeRepository = placeRepository,
        super(ParticipantJoinedContestsState(status: BlocStatus.initial)) {
    on<ParticipantJoinedContestsGetJoinedContests>(_getJoinedContests);
    on<ParticipantJoinedContestsClear>(_clear);
  }

  Future<void> _getJoinedContests(
    ParticipantJoinedContestsGetJoinedContests event,
    Emitter<ParticipantJoinedContestsState> emit,
  ) async {
    emit(ParticipantJoinedContestsState(status: BlocStatus.loading));

    late final List<Participation> ownParticipations;
    final List<Contest> contests = [];
    final List<Place> places = [];
    final List<Profile> organizers = [];
    final List<List<Participation>> participations = [];
    final List<List<Juration>> jurations = [];

    //* Ottengo le proprie partecipazioni
    final resOwnParticipations = await _participationRepository
        .getParticipationsByParticipantId(participantId: event.participantId);
    resOwnParticipations.fold(
      (failure) => emit(ParticipantJoinedContestsState(
          status: BlocStatus.failure, message: failure.message)),
      (success) => ownParticipations = success,
    );
    if (resOwnParticipations.isLeft()) return;

    //* Ricavo i contest dalla lista di participations
    for (var ownParticipation in ownParticipations) {
      final contestId = ownParticipation.contestId;
      final resContest = await _contestRepository.getContestById(id: contestId);
      resContest.fold(
        (failure) => emit(ParticipantJoinedContestsState(
            status: BlocStatus.failure, message: failure.message)),
        (success) => contests.add(success),
      );
      if (resContest.isLeft()) return;
    }

    //* Ottengo l'organizer per ogni contest
    for (var contest in contests) {
      final resOrganizer =
          await _profileRepository.getProfileById(id: contest.organizerId);
      resOrganizer.fold(
        (failure) => emit(ParticipantJoinedContestsState(
            status: BlocStatus.failure, message: failure.message)),
        (success) => organizers.add(success),
      );

      if (resOrganizer.isLeft()) return;
    }

    //* Ottengo il place per ogni contest
    for (var contest in contests) {
      final resPlace = await _placeRepository.getPlaceById(id: contest.placeId);
      resPlace.fold(
            (failure) => emit(
            ParticipantJoinedContestsState(status: BlocStatus.failure, message: failure.message)),
            (success) => places.add(success),
      );

      if (resPlace.isLeft()) return;
    }

    //* Ottengo le participations per ogni contest
    for (var contest in contests) {
      final resParticipations = await _participationRepository
          .getParticipationsByContestId(contestId: contest.id);
      resParticipations.fold(
        (failure) => emit(ParticipantJoinedContestsState(
            status: BlocStatus.failure, message: failure.message)),
        (success) => participations.add(success),
      );
      if (resParticipations.isLeft()) return;
    }

    //* Ottengo le jurations per ogni contest
    for (var contest in contests) {
      final resJurations = await _jurationRepository.getJurationsByContestId(
          contestId: contest.id);
      resJurations.fold(
        (failure) => emit(ParticipantJoinedContestsState(
            status: BlocStatus.failure, message: failure.message)),
        (success) => jurations.add(success),
      );

      if (resJurations.isLeft()) return;
    }

    emit(ParticipantJoinedContestsState(
      status: BlocStatus.success,
      contests: contests.reversed.toList(growable: false),
      organizers: organizers.reversed.toList(growable: false),
      participations: participations.reversed.toList(growable: false),
      jurations: jurations.reversed.toList(growable: false),
      places: places.reversed.toList(growable: false),
    ));
  }

  void _clear(
    ParticipantJoinedContestsClear event,
    Emitter<ParticipantJoinedContestsState> emit,
  ) {
    emit(ParticipantJoinedContestsState(status: BlocStatus.initial));
  }
}
