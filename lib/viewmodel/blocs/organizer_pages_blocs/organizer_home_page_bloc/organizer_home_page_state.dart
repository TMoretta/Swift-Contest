part of 'organizer_home_page_bloc.dart';

@immutable
sealed class OrganizerHomePageState {}

final class OrganizerHomePageInitial extends OrganizerHomePageState {}

final class OrganizerHomePageLoading extends OrganizerHomePageState {}

final class OrganizerHomePageSuccess extends OrganizerHomePageState {
  final List<Contest> contests;
  final List<Profile> organizers;
  final List<List<Participation>> participations;
  final List<List<Juration>> jurations;

  OrganizerHomePageSuccess({
    required this.contests,
    required this.organizers,
    required this.participations,
    required this.jurations,
  });
}

final class OrganizerHomePageFailure extends OrganizerHomePageState {
  final String message;

  OrganizerHomePageFailure({required this.message});
}

// final BlocStatus status;
// final String? message;
// final List<ExtendedContest>? extendedContests;
//
// const OrganizerHomePageState({
//   required this.status,
//   required this.message,
//   required this.extendedContests,
// });
//
// OrganizerHomePageState copyWith({
//   required BlocStatus status,
//   String? message,
//   List<ExtendedContest>? extendedContests,
// }) {
//   return OrganizerHomePageState(
//     status: status,
//     message: message,
//     extendedContests: extendedContests ?? this.extendedContests,
//   );
// }
