// import 'package:equatable/equatable.dart';
// import 'package:swift_contest/model/data_models/contest.dart';
// import 'package:swift_contest/model/data_models/profile.dart';
//
// final class ContestAndOrganizer extends Equatable{
//   final Contest contest;
//   final Organizer organizer;
//
//   const ContestAndOrganizer({required this.contest, required this.organizer});
//
//   factory ContestAndOrganizer.fromJson(Map<String, dynamic> map) {
//     return ContestAndOrganizer(
//       contest: Contest.fromJson(map['contest']),
//       organizer: Organizer.fromJson(map['organizer']),
//     );
//   }
//
//   Map<String, dynamic> toJson() {
//     return {
//       'contest': contest.toJson(),
//       'organizer': organizer.toJson(),
//     };
//   }
//
//   @override
//   List<Object?> get props => [contest, organizer];
// }
