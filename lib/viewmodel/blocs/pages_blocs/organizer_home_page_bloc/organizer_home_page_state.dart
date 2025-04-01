// part of 'organizer_home_page_bloc.dart';
//
// @immutable
// final class OrganizerHomePageState extends Equatable {
//   final BlocStatus status;
//   final String? message;
//   final List<Contest>? contests;
//   final List<Profile>? organizers;
//   final List<List<Participation>>? participations;
//   final List<List<Juration>>? jurations;
//
//   const OrganizerHomePageState({
//     required this.status,
//     this.message,
//     this.contests,
//     this.organizers,
//     this.participations,
//     this.jurations,
//   });
//
//   OrganizerHomePageState copyWith({
//     required BlocStatus status,
//     String? message,
//     List<Contest>? contests,
//     List<Profile>? organizers,
//     List<List<Participation>>? participations,
//     List<List<Juration>>? jurations,
//   }) {
//     return OrganizerHomePageState(
//       status: status,
//       message: message,
//       contests: contests ?? this.contests,
//       organizers: organizers ?? this.organizers,
//       participations: participations ?? this.participations,
//       jurations: jurations ?? this.jurations,
//     );
//   }
//
//   @override
//   List<Object?> get props => [status, message, contests, organizers, participations, jurations];
// }
