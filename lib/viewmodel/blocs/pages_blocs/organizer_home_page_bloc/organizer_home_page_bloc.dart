// import 'dart:async';
//
// import 'package:equatable/equatable.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:swift_contest/model/data_models/contest/contest.dart';
// import 'package:swift_contest/model/data_models/juration/juration.dart';
// import 'package:swift_contest/model/data_models/participation/participation.dart';
// import 'package:swift_contest/model/data_models/profile/profile.dart';
// import 'package:swift_contest/viewmodel/blocs/bloc_status.dart';
// import 'package:swift_contest/viewmodel/repositories/contest_repository.dart';
// import 'package:swift_contest/viewmodel/repositories/juration_repository.dart';
// import 'package:swift_contest/viewmodel/repositories/participation_repository.dart';
// import 'package:swift_contest/viewmodel/repositories/profile_repository.dart';
//
// part 'organizer_home_page_event.dart';
//
// part 'organizer_home_page_state.dart';
//
// class OrganizerHomePageBloc extends Bloc<OrganizerHomePageEvent, OrganizerHomePageState> {
//   final ContestRepository _contestRepository;
//   final ProfileRepository _profileRepository;
//   final ParticipationRepository _participationRepository;
//   final JurationRepository _jurationRepository;
//
//   OrganizerHomePageBloc({
//     required ContestRepository contestRepository,
//     required ProfileRepository profileRepository,
//     required ParticipationRepository participationRepository,
//     required JurationRepository jurationRepository,
//   })  : _contestRepository = contestRepository,
//         _profileRepository = profileRepository,
//         _participationRepository = participationRepository,
//         _jurationRepository = jurationRepository,
//         super(OrganizerHomePageState(status: BlocStatus.initial)) {
//     on<OrganizerHomePageGetCreatedContestsExtended>(_getCreatedContestsExtended);
//   }
//
//   Future<void> _getCreatedContestsExtended(
//     OrganizerHomePageGetCreatedContestsExtended event,
//     Emitter<OrganizerHomePageState> emit,
//   ) async {
//     emit(OrganizerHomePageState(status: BlocStatus.loading));
//
//     final List<Contest> contests = [];
//     final List<Profile> organizers = [];
//     final List<List<Participation>> participations = [];
//     final List<List<Juration>> jurations = [];
//
//     //* Ottengo i contest
//     final resContest =
//         await _contestRepository.getContestsByOrganizerId(organizerId: event.organizerId);
//     resContest.fold(
//       (failure) =>
//           emit(OrganizerHomePageState(status: BlocStatus.failure, message: failure.message)),
//       (success) => contests.addAll(success),
//     );
//
//     if (resContest.isLeft()) return;
//
//     //* Ottengo l'organizer per ogni contest
//     for (var contest in contests) {
//       final resOrganizer = await _profileRepository.getProfileById(id: contest.organizerId);
//       resOrganizer.fold(
//         (failure) =>
//             emit(OrganizerHomePageState(status: BlocStatus.failure, message: failure.message)),
//         (success) => organizers.add(success),
//       );
//
//       if (resOrganizer.isLeft()) return;
//     }
//
//     //* Ottengo le participations per ogni contest
//     for (var contest in contests) {
//       final resParticipations =
//           await _participationRepository.getParticipationsByContestId(contestId: contest.id);
//       resParticipations.fold(
//         (failure) =>
//             emit(OrganizerHomePageState(status: BlocStatus.failure, message: failure.message)),
//         (success) => participations.add(success),
//       );
//
//       if (resParticipations.isLeft()) return;
//     }
//
//     //* Ottengo le jurations per ogni contest
//     for (var contest in contests) {
//       final resJurations = await _jurationRepository.getJurationsByContestId(contestId: contest.id);
//       resJurations.fold(
//         (failure) =>
//             emit(OrganizerHomePageState(status: BlocStatus.failure, message: failure.message)),
//         (success) => jurations.add(success),
//       );
//
//       if (resJurations.isLeft()) return;
//     }
//
//     emit(OrganizerHomePageState(
//       status: BlocStatus.success,
//       contests: contests.reversed.toList(growable: false),
//       organizers: organizers.reversed.toList(growable: false),
//       participations: participations.reversed.toList(growable: false),
//       jurations: jurations.reversed.toList(growable: false),
//     ));
//   }
// }
