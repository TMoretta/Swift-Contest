import 'package:equatable/equatable.dart';

class VotingFormSubmissionValue extends Equatable {
  final String? id;
  final String? votingFormSubmissionId;
  final String? votingFormFieldId;
  final String value;
  final String? votingSessionParticipationId;

  const VotingFormSubmissionValue({
    required this.id,
    required this.votingFormSubmissionId,
    required this.votingFormFieldId,
    required this.value,
    this.votingSessionParticipationId,
  });

  factory VotingFormSubmissionValue.fromJson(Map<String, dynamic> json) {
    return VotingFormSubmissionValue(
      id: json['id'] as String,
      votingFormSubmissionId: json['voting_form_submission_id'] as String,
      votingFormFieldId: json['voting_form_field_id'] as String,
      value: json['value'] as String,
      votingSessionParticipationId: json['voting_session_participation_id'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      if (votingFormSubmissionId != null) 'voting_form_submission_id': votingFormSubmissionId,
      if (votingFormFieldId != null) 'voting_form_field_id': votingFormFieldId,
      'value': value,
      if (votingSessionParticipationId != null)
        'voting_session_participation_id': votingSessionParticipationId,
    };
  }

  VotingFormSubmissionValue copyWith({
    String? id,
    String? votingFormSubmissionId,
    String? votingFormFieldId,
    String? value,
    String? votingSessionParticipationId,
  }) {
    return VotingFormSubmissionValue(
      id: id ?? this.id,
      votingFormSubmissionId: votingFormSubmissionId ?? this.votingFormSubmissionId,
      votingFormFieldId: votingFormFieldId ?? this.votingFormFieldId,
      value: value ?? this.value,
      votingSessionParticipationId:
          votingSessionParticipationId ?? this.votingSessionParticipationId,
    );
  }

  @override
  List<Object?> get props => [
        id,
        votingFormSubmissionId,
        votingFormFieldId,
        value,
        votingSessionParticipationId,
      ];
}
