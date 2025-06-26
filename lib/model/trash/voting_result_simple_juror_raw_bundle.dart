import 'package:equatable/equatable.dart';
import 'package:swift_contest/model/data_models/simple_juror_vote.dart';
import 'package:swift_contest/model/data_models/simple_juror_voting.dart';

class VotingResultSimpleJurorRawBundle extends Equatable {
  final List<SimpleJurorVoting> simpleJurorVotings;
  final List<SimpleJurorVote> simpleJurorVotes;

  const VotingResultSimpleJurorRawBundle({
    required this.simpleJurorVotings,
    required this.simpleJurorVotes,
  });

  factory VotingResultSimpleJurorRawBundle.fromJson(Map<String, dynamic> json) {
    return VotingResultSimpleJurorRawBundle(
      simpleJurorVotings: (json['simple_juror_votings'] as List<dynamic>)
          .map((e) => SimpleJurorVoting.fromJson(e))
          .toList(growable: false),
      simpleJurorVotes: (json['simple_juror_votes'] as List<dynamic>)
          .map((e) => SimpleJurorVote.fromJson(e))
          .toList(growable: false),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'simple_juror_votings': simpleJurorVotings.map((e) => e.toJson()).toList(growable: false),
      'simple_juror_votes': simpleJurorVotes.map((e) => e.toJson()).toList(growable: false),
    };
  }

  VotingResultSimpleJurorRawBundle copyWith({
    List<SimpleJurorVoting>? simpleJurorVotings,
    List<SimpleJurorVote>? simpleJurorVotes,
  }) {
    return VotingResultSimpleJurorRawBundle(
      simpleJurorVotings: simpleJurorVotings ?? this.simpleJurorVotings,
      simpleJurorVotes: simpleJurorVotes ?? this.simpleJurorVotes,
    );
  }

  @override
  List<Object?> get props => [simpleJurorVotings, simpleJurorVotes];
}
