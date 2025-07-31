// import 'package:equatable/equatable.dart';
// import 'package:swift_contest/model/db/bundles/juration_bundle.dart';
// import 'package:swift_contest/model/db/entities/voting_session_juration.dart';
//
// class VotingSessionJurationBundle extends Equatable {
//   final VotingSessionJuration votingSessionJuration;
//   final JurationBundle jurationBundle;
//
//   const VotingSessionJurationBundle(
//     this.votingSessionJuration,
//     this.jurationBundle,
//   );
//
//   factory VotingSessionJurationBundle.fromJson(Map<String, dynamic> map) {
//     return VotingSessionJurationBundle(
//       VotingSessionJuration.fromJson(map['voting_session_juration']),
//       JurationBundle.fromJson(map['juration_bundle']),
//     );
//   }
//
//   Map<String, dynamic> toJson() {
//     return {
//       'voting_session_juration': votingSessionJuration.toJson(),
//       'juration_bundle': jurationBundle.toJson(),
//     };
//   }
//
//   VotingSessionJurationBundle copyWith({
//     VotingSessionJuration? votingSessionJuration,
//     JurationBundle? jurationBundle,
//   }) {
//     return VotingSessionJurationBundle(
//       votingSessionJuration ?? this.votingSessionJuration,
//       jurationBundle ?? this.jurationBundle,
//     );
//   }
//
//   @override
//   List<Object?> get props => [
//         votingSessionJuration,
//         jurationBundle,
//       ];
// }
