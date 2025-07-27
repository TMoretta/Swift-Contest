// import 'package:equatable/equatable.dart';
// import 'package:swift_contest/model/db/bundles/juration_bundle.dart';
// import 'package:swift_contest/model/db/bundles/participation_bundle.dart';
//
// class VotingExclusionBundle extends Equatable {
//   final ParticipationBundle participationBundle;
//   final JurationBundle jurationBundle;
//
//   const VotingExclusionBundle({
//     required this.participationBundle,
//     required this.jurationBundle,
//   });
//
//   factory VotingExclusionBundle.fromJson(Map<String, dynamic> json) {
//     return VotingExclusionBundle(
//       participationBundle: ParticipationBundle.fromJson(json['participation_bundle']),
//       jurationBundle: JurationBundle.fromJson(json['juration_bundle']),
//     );
//   }
//
//   Map<String, dynamic> toJson() {
//     return {
//       'participation_bundle': participationBundle.toJson(),
//       'juration_bundle': jurationBundle.toJson(),
//     };
//   }
//
//   VotingExclusionBundle copyWith({
//     ParticipationBundle? participationBundle,
//     JurationBundle? jurationBundle,
//   }) {
//     return VotingExclusionBundle(
//       participationBundle: participationBundle ?? this.participationBundle,
//       jurationBundle: jurationBundle ?? this.jurationBundle,
//     );
//   }
//
//   @override
//   List<Object?> get props => [participationBundle, jurationBundle];
// }
