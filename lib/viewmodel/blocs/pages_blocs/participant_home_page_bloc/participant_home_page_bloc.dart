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

part 'participant_home_page_event.dart';
part 'participant_home_page_state.dart';

class ParticipantHomePageBloc extends Bloc<ParticipantHomePageEvent, ParticipantHomePageState> {
  final ContestRepository _contestRepository;
  final ParticipationRepository _participationRepository;
  final ProfileRepository _profileRepository;
  final JurationRepository _jurationRepository;

  ParticipantHomePageBloc({
    required ContestRepository contestRepository,
    required ParticipationRepository participationRepository,
    required ProfileRepository profileRepository,
    required JurationRepository jurationRepository,
  })  : _contestRepository = contestRepository,
        _participationRepository = participationRepository,
        _profileRepository = profileRepository,
        _jurationRepository = jurationRepository,
        super(ParticipantHomePageState(status: BlocStatus.initial)) {
    on<ParticipantHomePageJoinContest>(_joinContest);
    // on<ParticipantHomePageGetJoinedContestsExtended>(_getJoinedContestsExtended);
  }

  // Future<void> _getJoinedContestsExtended(
  //   ParticipantHomePageGetJoinedContestsExtended event,
  //   Emitter<ParticipantHomePageState> emit,
  // ) async {
  //   emit(ParticipantHomePageState(status: BlocStatus.loading));
  //
  //   late final List<Participation> ownParticipations;
  //   final List<Contest> contests = [];
  //   final List<Profile> organizers = [];
  //   final List<List<Participation>> participations = [];
  //   final List<List<Juration>> jurations = [];
  //
  //   //* Ottengo le proprie partecipazioni
  //   final resOwnParticipations = await _participationRepository.getParticipationsByParticipantId(
  //       participantId: event.participantId);
  //   resOwnParticipations.fold(
  //         (failure) => emit(ParticipantHomePageState(status: BlocStatus.failure, message: failure.message)),
  //     (success) => ownParticipations = success,
  //   );
  //   if (resOwnParticipations.isLeft()) return;
  //
  //   //* Ricavo i contest dalla lista di participations
  //   for (var ownParticipation in ownParticipations) {
  //     final contestId = ownParticipation.contestId;
  //     final resContest = await _contestRepository.getContestById(id: contestId);
  //     resContest.fold(
  //           (failure) => emit(ParticipantHomePageState(status: BlocStatus.failure, message: failure.message)),
  //       (success) => contests.add(success),
  //     );
  //     if (resContest.isLeft()) return;
  //   }
  //
  //   //* Ottengo l'organizer per ogni contest
  //   for (var contest in contests) {
  //     final resOrganizer = await _profileRepository.getProfileById(id: contest.organizerId);
  //     resOrganizer.fold(
  //           (failure) => emit(ParticipantHomePageState(status: BlocStatus.failure, message: failure.message)),
  //       (success) => organizers.add(success),
  //     );
  //
  //     if (resOrganizer.isLeft()) return;
  //   }
  //
  //   //* Ottengo le participations per ogni contest
  //   for (var contest in contests) {
  //     final resParticipations =
  //         await _participationRepository.getParticipationsByContestId(contestId: contest.id);
  //     resParticipations.fold(
  //           (failure) => emit(ParticipantHomePageState(status: BlocStatus.failure, message: failure.message)),
  //       (success) => participations.add(success),
  //     );
  //     if (resParticipations.isLeft()) return;
  //   }
  //
  //   //* Ottengo le jurations per ogni contest
  //   for (var contest in contests) {
  //     final resJurations = await _jurationRepository.getJurationsByContestId(contestId: contest.id);
  //     resJurations.fold(
  //           (failure) => emit(ParticipantHomePageState(status: BlocStatus.failure, message: failure.message)),
  //       (success) => jurations.add(success),
  //     );
  //
  //     if (resJurations.isLeft()) return;
  //   }
  //
  //   emit(ParticipantHomePageState(
  //     status: BlocStatus.success,
  //     contests: contests,
  //     organizers: organizers,
  //     participations: participations,
  //     jurations: jurations,
  //   ));
  // }

  Future<void> _joinContest(
    ParticipantHomePageJoinContest event,
    Emitter<ParticipantHomePageState> emit,
  ) async {
    emit(ParticipantHomePageState(status: BlocStatus.loading));
    final res = await _participationRepository.joinContestAsParticipant(
      participantId: event.participantId,
      contestToken: event.contestToken,
      participantToken: event.participantToken,
    );
    res.fold(
      (failure) => emit(ParticipantHomePageState(status: BlocStatus.failure, message: failure.message)),
      (success) => emit(ParticipantHomePageState(status: BlocStatus.success, participationJoin: success)),
    );
  }
}
