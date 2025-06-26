import 'package:equatable/equatable.dart';
import 'package:swift_contest/model/data_models/juror_vote.dart';
import 'package:swift_contest/model/data_models/juror_voting.dart';

class VotingResultJurorRawBundle extends Equatable {
  final List<JurorVoting> jurorVotings;
  final List<JurorVote> jurorVotes;

  const VotingResultJurorRawBundle({
    required this.jurorVotings,
    required this.jurorVotes,
  });

  factory VotingResultJurorRawBundle.fromJson(Map<String, dynamic> json) {
    return VotingResultJurorRawBundle(
      jurorVotings: (json['juror_votings'] as List<dynamic>)
          .map((e) => JurorVoting.fromJson(e))
          .toList(growable: false),
      jurorVotes: (json['juror_votes'] as List<dynamic>)
          .map((e) => JurorVote.fromJson(e))
          .toList(growable: false),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'juror_votings': jurorVotings.map((e) => e.toJson()).toList(growable: false),
      'juror_votes': jurorVotes.map((e) => e.toJson()).toList(growable: false),
    };
  }

  VotingResultJurorRawBundle copyWith({
    List<JurorVoting>? jurorVotings,
    List<JurorVote>? jurorVotes,
  }) {
    return VotingResultJurorRawBundle(
      jurorVotings: jurorVotings ?? this.jurorVotings,
      jurorVotes: jurorVotes ?? this.jurorVotes,
    );
  }

  @override
  List<Object?> get props => [jurorVotings, jurorVotes];
}
