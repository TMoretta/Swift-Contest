// import 'package:equatable/equatable.dart';
// import 'package:swift_contest/model/db/bundles/simple_juror_vote_bundle.dart';
// import 'package:swift_contest/model/data_models/simple_juror_voting.dart';
//
// class SimpleJurorVotingBundle extends Equatable {
//   final SimpleJurorVoting simpleJurorVoting;
//   final List<SimpleJurorVoteBundle> simpleJurorsVotesBundles;
//
//   const SimpleJurorVotingBundle({
//     required this.simpleJurorVoting,
//     required this.simpleJurorsVotesBundles,
//   });
//
//   factory SimpleJurorVotingBundle.fromJson(Map<String, dynamic> json) {
//     return SimpleJurorVotingBundle(
//       simpleJurorVoting: SimpleJurorVoting.fromJson(json['simple_juror_voting']),
//       simpleJurorsVotesBundles: (json['simple_jurors_votes_bundles'] as List).map((e) => SimpleJurorVoteBundle.fromJson(e)).toList(growable: false),
//     );
//   }
//
//   Map<String, dynamic> toJson() {
//     return {
//       'simple_juror_voting': simpleJurorVoting.toJson(),
//       'simple_jurors_votes_bundles': simpleJurorsVotesBundles.map((e) => e.toJson()).toList(),
//     };
//   }
//
//   SimpleJurorVotingBundle copyWith({
//     SimpleJurorVoting? simpleJurorVoting,
//     List<SimpleJurorVoteBundle>? simpleJurorsVotesBundles,
//   }) {
//     return SimpleJurorVotingBundle(
//       simpleJurorVoting: simpleJurorVoting ?? this.simpleJurorVoting,
//       simpleJurorsVotesBundles: simpleJurorsVotesBundles ?? this.simpleJurorsVotesBundles,
//     );
//   }
//
//   @override
//   List<Object?> get props => [simpleJurorVoting, simpleJurorsVotesBundles];
// }
