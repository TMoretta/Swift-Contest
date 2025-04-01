import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:swift_contest/model/data_models/contest/contest.dart';
import 'package:swift_contest/model/data_models/juration/juration.dart';
import 'package:swift_contest/model/data_models/participation/participation.dart';
import 'package:swift_contest/model/data_models/profile/profile.dart';
import 'package:swift_contest/viewmodel/blocs/bloc_status.dart';
import 'package:swift_contest/viewmodel/repositories/contest_repository.dart';
import 'package:swift_contest/viewmodel/repositories/juration_repository.dart';
import 'package:swift_contest/viewmodel/repositories/participation_repository.dart';
import 'package:swift_contest/viewmodel/repositories/profile_repository.dart';

part 'juror_joined_contests_event.dart';
part 'juror_joined_contests_state.dart';

class JurorJoinedContestsBloc extends Bloc<JurorJoinedContestsEvent, JurorJoinedContestsState> {
  final ContestRepository _contestRepository;
  final ParticipationRepository _participationRepository;
  final ProfileRepository _profileRepository;
  final JurationRepository _jurationRepository;

  JurorJoinedContestsBloc({
    required ContestRepository contestRepository,
    required ParticipationRepository participationRepository,
    required ProfileRepository profileRepository,
    required JurationRepository jurationRepository,
  })  : _contestRepository = contestRepository,
        _participationRepository = participationRepository,
        _profileRepository = profileRepository,
        _jurationRepository = jurationRepository,
        super(JurorJoinedContestsState(status: BlocStatus.initial)) {
    on<JurorJoinedContestsGetJoinedContests>(_getJoinedContests);
  }

  FutureOr<void> _getJoinedContests(
    JurorJoinedContestsGetJoinedContests event,
    Emitter<JurorJoinedContestsState> emit,
  ) async {
    emit(JurorJoinedContestsState(status: BlocStatus.loading));

    late final List<Juration> ownJurations;
    final List<Contest> contests = [];
    final List<Profile> organizers = [];
    final List<List<Participation>> participations = [];
    final List<List<Juration>> jurations = [];

    //* Ottengo le proprie partecipazioni
    final resOwnJurations = await _jurationRepository.getJurationsByJurorId(jurorId: event.jurorId);
    resOwnJurations.fold(
      (failure) =>
          emit(JurorJoinedContestsState(status: BlocStatus.failure, message: failure.message)),
      (success) => ownJurations = success,
    );
    if (resOwnJurations.isLeft()) return;

    //* Ricavo i contest dalla lista di participations
    for (var ownJuration in ownJurations) {
      final contestId = ownJuration.contestId;
      final resContest = await _contestRepository.getContestById(id: contestId);
      resContest.fold(
        (failure) =>
            emit(JurorJoinedContestsState(status: BlocStatus.failure, message: failure.message)),
        (success) => contests.add(success),
      );
      if (resContest.isLeft()) return;
    }

    //* Ottengo l'organizer per ogni contest
    for (var contest in contests) {
      final resOrganizer = await _profileRepository.getProfileById(id: contest.organizerId);
      resOrganizer.fold(
        (failure) =>
            emit(JurorJoinedContestsState(status: BlocStatus.failure, message: failure.message)),
        (success) => organizers.add(success),
      );

      if (resOrganizer.isLeft()) return;
    }

    //* Ottengo le participations per ogni contest
    for (var contest in contests) {
      final resParticipations =
          await _participationRepository.getParticipationsByContestId(contestId: contest.id);
      resParticipations.fold(
        (failure) =>
            emit(JurorJoinedContestsState(status: BlocStatus.failure, message: failure.message)),
        (success) => participations.add(success),
      );
      if (resParticipations.isLeft()) return;
    }

    //* Ottengo le jurations per ogni contest
    for (var contest in contests) {
      final resJurations = await _jurationRepository.getJurationsByContestId(contestId: contest.id);
      resJurations.fold(
        (failure) =>
            emit(JurorJoinedContestsState(status: BlocStatus.failure, message: failure.message)),
        (success) => jurations.add(success),
      );

      if (resJurations.isLeft()) return;
    }

    emit(JurorJoinedContestsState(
      status: BlocStatus.success,
      contests: contests,
      organizers: organizers,
      participations: participations,
      jurations: jurations,
    ));
  }
}
