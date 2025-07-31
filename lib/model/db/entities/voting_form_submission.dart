import 'package:equatable/equatable.dart';

class VotingFormSubmission extends Equatable {
  final String? id;
  final DateTime? createdAt;
  final String? votingSessionId;
  final String? votingSessionJurationId;
  final String? votingSessionSimpleJurorId;

  const VotingFormSubmission({
    required this.id,
    required this.createdAt,
    required this.votingSessionId,
    this.votingSessionJurationId,
    this.votingSessionSimpleJurorId,
  });

  factory VotingFormSubmission.fromJson(Map<String, dynamic> json) {
    return VotingFormSubmission(
      id: json['id'] as String,
      createdAt: DateTime.parse(json['created_at']).toLocal(),
      votingSessionId: json['voting_session_id'] as String,
      votingSessionJurationId: json['voting_session_juration_id'] as String?,
      votingSessionSimpleJurorId: json['voting_session_simple_juror_id'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      if (createdAt != null) 'created_at': createdAt!.toUtc().toIso8601String(),
      if (votingSessionId != null) 'voting_session_id': votingSessionId,
      if (votingSessionJurationId != null) 'voting_session_juration_id': votingSessionJurationId,
      if (votingSessionSimpleJurorId != null)
        'voting_session_simple_juror_id': votingSessionSimpleJurorId,
    };
  }

  VotingFormSubmission copyWith({
    String? id,
    DateTime? createdAt,
    String? votingSessionId,
    String? votingSessionJurationId,
    String? votingSessionSimpleJurorId,
  }) {
    return VotingFormSubmission(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      votingSessionId: votingSessionId ?? this.votingSessionId,
      votingSessionJurationId: votingSessionJurationId ?? this.votingSessionJurationId,
      votingSessionSimpleJurorId: votingSessionSimpleJurorId ?? this.votingSessionSimpleJurorId,
    );
  }

  @override
  List<Object?> get props => [
        id,
        createdAt,
        votingSessionId,
        votingSessionJurationId,
        votingSessionSimpleJurorId,
      ];
}
