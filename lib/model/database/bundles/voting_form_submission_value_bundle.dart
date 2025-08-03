import 'package:equatable/equatable.dart';
import 'package:swift_contest/model/database/entities/voting_form_field.dart';
import 'package:swift_contest/model/database/entities/voting_form_submission_values.dart';
import 'package:swift_contest/model/database/entities/voting_session_participant.dart';

class VotingFormSubmissionValueBundle extends Equatable {
  final VotingFormSubmissionValue votingFormSubmissionValue;
  final VotingFormField votingFormField;
  final VotingSessionParticipant? votingSessionParticipant;

  const VotingFormSubmissionValueBundle({
    required this.votingFormSubmissionValue,
    required this.votingFormField,
    required this.votingSessionParticipant,
  });

  factory VotingFormSubmissionValueBundle.fromJson(Map<String, dynamic> json) {
    return VotingFormSubmissionValueBundle(
      votingFormSubmissionValue: VotingFormSubmissionValue.fromJson(json['voting_form_submission_value']),
      votingFormField: VotingFormField.fromJson(json['voting_form_field']),
      votingSessionParticipant: json['voting_session_participant'] != null
          ? VotingSessionParticipant.fromJson(json['voting_session_participant'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'voting_form_submission_value': votingFormSubmissionValue.toJson(),
      'voting_form_field': votingFormField.toJson(),
      if (votingSessionParticipant != null)
        'voting_session_participant': votingSessionParticipant!.toJson(),
    };
  }

  VotingFormSubmissionValueBundle copyWith({
    VotingFormSubmissionValue? votingFormSubmissionValue,
    VotingFormField? votingFormField,
    VotingSessionParticipant? votingSessionParticipant,
  }) {
    return VotingFormSubmissionValueBundle(
      votingFormSubmissionValue: votingFormSubmissionValue ?? this.votingFormSubmissionValue,
      votingFormField: votingFormField ?? this.votingFormField,
      votingSessionParticipant: votingSessionParticipant ?? this.votingSessionParticipant,
    );
  }

  @override
  List<Object?> get props => [
        votingFormSubmissionValue,
        votingFormField,
        votingSessionParticipant,
      ];

}
