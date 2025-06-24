import 'package:equatable/equatable.dart';
import 'package:swift_contest/model/data_models/juror_vote.dart';
import 'package:swift_contest/model/data_models/juror_voting.dart';

class JurorVotesRawBundle extends Equatable {
  final List<JurorVoting> jurorVotings;
  final List<JurorVote> jurorVotes;

  const JurorVotesRawBundle({required this.jurorVotings, required this.jurorVotes});

  factory JurorVotesRawBundle.fromRpcJson(Map<String, dynamic> json) {
    return JurorVotesRawBundle(
      jurorVotings: (json['juror_votings'] as List<dynamic>)
          .map((e) => JurorVoting.fromJson(e))
          .toList(growable: false),
      jurorVotes: (json['juror_votes'] as List<dynamic>)
          .map((e) => JurorVote.fromJson(e))
          .toList(growable: false),
    );
  }

  @override
  List<Object?> get props => [jurorVotings, jurorVotes];

// factory VotingSessionResultBundle.fromRpcJson(Map<String,dynamic> json) {
//   final votingSessionJurations = (json['voting_session_jurations'] as List<dynamic>).map((e)=> VotingSessionJuration.fromJson(e)).toList(growable: false);
//   final jurorVotings = (json['juror_votings'] as List<dynamic>).map((e)=> JurorVoting.fromJson(e)).toList(growable: false);
//   final jurorVotes = (json['juror_votes'] as List<dynamic>).map((e)=> JurorVote.fromJson(e)).toList(growable: false);
//
//   final Map<VotingSessionJuration, Map<VotingSessionParticipation, List<JurorVote>?>>
//   sessionParticipantsVotingsPerSessionJurorMap;
//   for(var votingSessionJuration in votingSessionJurations) {
//     final relatedJurorVotings = jurorVotings.where((e) => e.votingSessionJurationId == votingSessionJuration.id).toList(growable: false);
//
//
//     for(var jurorVoting in relatedJurorVotings) {
//       List<JurorVote>? relatedJurorVotes = jurorVotes.where((e) => e.jurorVotingId == jurorVoting.id).toList(growable: false);
//       if(relatedJurorVotes.isEmpty) {
//         relatedJurorVotes = null;
//       }
//       session
//
//
//     }
//   }
//
//
//   return VotingSessionResultBundle(
//       participantsVotingsPerJurorMap: participantsVotingsPerJurorMap
//   );
// }
}
