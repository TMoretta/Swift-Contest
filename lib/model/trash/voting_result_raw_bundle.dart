import 'package:equatable/equatable.dart';
import 'package:swift_contest/model/data_models/juror_voting.dart';
import 'package:swift_contest/model/data_models/juror_vote.dart';
import 'package:swift_contest/model/data_models/simple_juror_voting.dart';
import 'package:swift_contest/model/data_models/simple_juror_vote.dart';

class VotingResultRawBundle extends Equatable {
  final List<JurorVoting> jurorVotings;
  final List<JurorVote> jurorVotes;
  final List<SimpleJurorVoting> simpleJurorVotings;
  final List<SimpleJurorVote> simpleJurorVotes;

  const VotingResultRawBundle({
    required this.jurorVotings,
    required this.jurorVotes,
    required this.simpleJurorVotings,
    required this.simpleJurorVotes,
  });

  factory VotingResultRawBundle.fromJson(Map<String, dynamic> json) {
    return VotingResultRawBundle(
      jurorVotings: (json['juror_votings'] as List<dynamic>)
          .map((e) => JurorVoting.fromJson(e))
          .toList(growable: false),
      jurorVotes: (json['juror_votes'] as List<dynamic>)
          .map((e) => JurorVote.fromJson(e))
          .toList(growable: false),
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
      'juror_votings': jurorVotings.map((e) => e.toJson()).toList(growable: false),
      'juror_votes': jurorVotes.map((e) => e.toJson()).toList(growable: false),
      'simple_juror_votings': simpleJurorVotings.map((e) => e.toJson()).toList(growable: false),
      'simple_juror_votes': simpleJurorVotes.map((e) => e.toJson()).toList(growable: false),
    };
  }

  VotingResultRawBundle copyWith({
    List<JurorVoting>? jurorVotings,
    List<JurorVote>? jurorVotes,
    List<SimpleJurorVoting>? simpleJurorVotings,
    List<SimpleJurorVote>? simpleJurorVotes,
  }) {
    return VotingResultRawBundle(
      jurorVotings: jurorVotings ?? this.jurorVotings,
      jurorVotes: jurorVotes ?? this.jurorVotes,
      simpleJurorVotings: simpleJurorVotings ?? this.simpleJurorVotings,
      simpleJurorVotes: simpleJurorVotes ?? this.simpleJurorVotes,
    );
  }

  @override
  List<Object?> get props => [jurorVotings, jurorVotes, simpleJurorVotings, simpleJurorVotes];
}
