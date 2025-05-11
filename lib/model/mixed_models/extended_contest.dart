// import 'package:swift_contest/model/data_models/contest/contest.dart';
// import 'package:swift_contest/model/data_models/juration/juration.dart';
// import 'package:swift_contest/model/data_models/participation/participation.dart';
// import 'package:swift_contest/model/data_models/profile/profile.dart';
// import 'package:swift_contest/model/data_models/work/work.dart';
//
// class ExtendedContest {
//   final Contest contest;
//   final Profile organizer;
//   final List<Participation> participations;
//   final List<Profile?> participants;
//   final List<Work?> works;
//   final List<Juration> jurations;
//   final List<Profile?> jurors;
//
//   ExtendedContest({
//     required this.contest,
//     required this.organizer,
//     required this.participations,
//     required this.participants,
//     required this.works,
//     required this.jurations,
//     required this.jurors,
//   });
//
//   factory ExtendedContest.fromJson(Map<String, dynamic> map) {
//
//     return ExtendedContest(
//       contest: Contest.fromJson(map['contest']),
//       organizer: Profile.fromJson(map['organizer']),
//       participations: (map['participations'] as List<dynamic>)
//           .map((e) => Participation.fromJson(e))
//           .toList(growable: false),
//       participants: (map['participants']!=null) ? (map['participants'] as List<dynamic>)
//           .map((e) => (e != null) ? Profile.fromJson(e) : null)
//           .toList(growable: false) : [],
//       works: (map['works']!=null) ?(map['works'] as List<dynamic>)
//           .map((e) => (e != null) ? Work.fromJson(e) : null)
//           .toList(growable: false) : [],
//       jurations: (map['jurations'] as List<dynamic>)
//           .map((e) => Juration.fromJson(e))
//           .toList(growable: false),
//       jurors: (map['jurors']!=null) ?(map['jurors'] as List<dynamic>)
//           .map((e) => (e != null) ? Profile.fromJson(e) : null)
//           .toList(growable: false) : [],
//     );
//   }
//
//   Map<String, dynamic> toJson() {
//     return {
//       'contest': contest.toJson(),
//       'organizer': organizer.toJson(),
//       'participations': participations.map((e) => e.toJson()).toList(),
//       'participants': participants.map((e) => e?.toJson()).toList(),
//       'jurations': jurations.map((e) => e.toJson()).toList(),
//       'jurors': jurors.map((e) => e?.toJson()).toList(),
//     };
//   }
//
//   ExtendedContest copyWith({
//     Contest? contest,
//     Profile? organizer,
//     List<Participation>? participations,
//     List<Profile?>? participants,
//     List<Work?>? works,
//     List<Juration>? jurations,
//     List<Profile?>? jurors,
//   }) {
//     return ExtendedContest(
//       contest: contest ?? this.contest,
//       organizer: organizer ?? this.organizer,
//       participations: participations ?? this.participations,
//       participants: participants ?? this.participants,
//       works: works ?? this.works,
//       jurations: jurations ?? this.jurations,
//       jurors: jurors ?? this.jurors,
//     );
//   }
//
// // factory ExtendedContest.fromJson(Map<String, dynamic> map) {
// //   return ExtendedContest(
// //     contest: Contest.fromJson(map['contest'] as Map<String, dynamic>),
// //     organizer: Profile.fromJson(map['organizer'] as Map<String, dynamic>),
// //     participationsAndParticipants: (map['participations_and_participants'] as List<dynamic>)
// //         .map((e) => ParticipationAndParticipant.fromJson(e))
// //         .toList(growable: false),
// //     jurationsAndJurors: (map['jurations_and_jurors'] as List<dynamic>)
// //         .map((e) => JurationAndJuror.fromJson(e))
// //         .toList(growable: false),
// //   );
// // }
// }
