// import 'package:equatable/equatable.dart';
// import 'package:swift_contest/model/db/bundles/juror_vote_bundle.dart';
// import 'package:swift_contest/model/data_models/juror_voting.dart';
//
// class JurorVotingBundle extends Equatable {
//   final JurorVoting jurorVoting;
//   final List<JurorVoteBundle> jurorsVotesBundles;
//
//   const JurorVotingBundle({
//     required this.jurorVoting,
//     required this.jurorsVotesBundles,
//   });
//
//   factory JurorVotingBundle.fromJson(Map<String, dynamic> json) {
//     return JurorVotingBundle(
//       jurorVoting: JurorVoting.fromJson(json['juror_voting']),
//       jurorsVotesBundles: (json['jurors_votes_bundles'] as List).map((e) => JurorVoteBundle.fromJson(e)).toList(growable: false),
//     );
//   }
//
//   Map<String, dynamic> toJson() {
//     return {
//       'juror_voting': jurorVoting.toJson(),
//       'jurors_votes_bundles': jurorsVotesBundles.map((e) => e.toJson()).toList(),
//     };
//   }
//
//   JurorVotingBundle copyWith({
//     JurorVoting? jurorVoting,
//     List<JurorVoteBundle>? jurorsVotesBundles,
//   }) {
//     return JurorVotingBundle(
//       jurorVoting: jurorVoting ?? this.jurorVoting,
//       jurorsVotesBundles: jurorsVotesBundles ?? this.jurorsVotesBundles,
//     );
//   }
//
//   @override
//   List<Object?> get props => [jurorVoting, jurorsVotesBundles];
// }
