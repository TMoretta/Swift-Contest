import 'package:equatable/equatable.dart';
import 'package:swift_contest/model/data_models/juror_vote.dart';
import 'package:swift_contest/model/data_models/juror_voting.dart';

class JurorVotingBundle extends Equatable {
  final JurorVoting jurorVoting;
  final List<JurorVote> jurorVotes;

  const JurorVotingBundle({
    required this.jurorVoting,
    required this.jurorVotes,
  });

  factory JurorVotingBundle.fromJson(Map<String, dynamic> json) {
    return JurorVotingBundle(
      jurorVoting: JurorVoting.fromJson(json['juror_voting']),
      jurorVotes: (json['juror_votes'] as List).map((e) => JurorVote.fromJson(e)).toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'juror_voting': jurorVoting.toJson(),
      'juror_votes': jurorVotes.map((e) => e.toJson()).toList(),
    };
  }

  JurorVotingBundle copyWith({
    JurorVoting? jurorVoting,
    List<JurorVote>? jurorVotes,
  }) {
    return JurorVotingBundle(
      jurorVoting: jurorVoting ?? this.jurorVoting,
      jurorVotes: jurorVotes ?? this.jurorVotes,
    );
  }

  @override
  List<Object?> get props => [jurorVoting, jurorVotes];
}
