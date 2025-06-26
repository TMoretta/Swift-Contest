import 'package:equatable/equatable.dart';
import 'package:swift_contest/model/data_models/juror_vote.dart';
import 'package:swift_contest/model/data_models/voting_form_field.dart';

class JurorVoteBundle extends Equatable {
  final JurorVote jurorVote;
  final VotingFormField votingFormField;

  const JurorVoteBundle({
    required this.jurorVote,
    required this.votingFormField,
  });

  factory JurorVoteBundle.fromJson(Map<String, dynamic> json) {
    return JurorVoteBundle(
      jurorVote: JurorVote.fromJson(json['juror_vote']),
      votingFormField: VotingFormField.fromJson(json['voting_form_field']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'juror_vote': jurorVote.toJson(),
      'voting_form_field': votingFormField.toJson(),
    };
  }

  JurorVoteBundle copyWith({
    JurorVote? jurorVote,
    VotingFormField? votingFormField,
  }) {
    return JurorVoteBundle(
      jurorVote: jurorVote ?? this.jurorVote,
      votingFormField: votingFormField ?? this.votingFormField,
    );
  }

  @override
  List<Object?> get props => [jurorVote, votingFormField];
}
