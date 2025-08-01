import 'package:equatable/equatable.dart';

class VotingFormSubmission extends Equatable {
  final String? id;
  final DateTime? createdAt;
  final String? votingSessionId;
  final String? votingSessionJurorId;

  const VotingFormSubmission({
    required this.id,
    required this.createdAt,
    required this.votingSessionId,
    this.votingSessionJurorId,
  });

  factory VotingFormSubmission.fromJson(Map<String, dynamic> json) {
    return VotingFormSubmission(
      id: json['id'] as String,
      createdAt: DateTime.parse(json['created_at']).toLocal(),
      votingSessionId: json['voting_session_id'] as String,
      votingSessionJurorId: json['voting_session_juror_id'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      if (createdAt != null) 'created_at': createdAt!.toUtc().toIso8601String(),
      if (votingSessionId != null) 'voting_session_id': votingSessionId,
      if (votingSessionJurorId != null) 'voting_session_juror_id': votingSessionJurorId,
    };
  }

  VotingFormSubmission copyWith({
    String? id,
    DateTime? createdAt,
    String? votingSessionId,
    String? votingSessionJurorId,
  }) {
    return VotingFormSubmission(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      votingSessionId: votingSessionId ?? this.votingSessionId,
      votingSessionJurorId: votingSessionJurorId ?? this.votingSessionJurorId,
    );
  }

  @override
  List<Object?> get props => [
        id,
        createdAt,
        votingSessionId,
        votingSessionJurorId,
      ];
}
