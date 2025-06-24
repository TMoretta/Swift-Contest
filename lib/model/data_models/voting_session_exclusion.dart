import 'package:equatable/equatable.dart';

class VotingSessionExclusion extends Equatable {
  final String id;
  final DateTime createdAt;
  final String votingSessionId;
  final String votingSessionJurationId;
  final String votingSessionParticipationId;

  const VotingSessionExclusion({
    required this.id,
    required this.createdAt,
    required this.votingSessionId,
    required this.votingSessionJurationId,
    required this.votingSessionParticipationId,
  });

  factory VotingSessionExclusion.fromJson(Map<String, dynamic> json) {
    return VotingSessionExclusion(
      id: json['id'],
      createdAt: DateTime.parse(json['created_at']).toLocal(),
      votingSessionId: json['voting_session_id'],
      votingSessionJurationId: json['voting_session_juration_id'],
      votingSessionParticipationId: json['voting_session_participation_id'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'created_at': createdAt.toUtc().toIso8601String(),
      'voting_session_id': votingSessionId,
      'voting_session_juration_id': votingSessionJurationId,
      'voting_session_participation_id': votingSessionParticipationId,
    };
  }

  Map<String, dynamic> toRpcJson() {
    return {
      'p_id': id,
      'p_created_at': createdAt.toUtc().toIso8601String(),
      'p_voting_session_id': votingSessionId,
      'p_voting_session_juration_id': votingSessionJurationId,
      'p_voting_session_participation_id': votingSessionParticipationId,
    };
  }

  VotingSessionExclusion copyWith({
    String? id,
    DateTime? createdAt,
    String? votingSessionId,
    String? votingSessionJurationId,
    String? votingSessionParticipationId,
  }) {
    return VotingSessionExclusion(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      votingSessionId: votingSessionId ?? this.votingSessionId,
      votingSessionJurationId: votingSessionJurationId ?? this.votingSessionJurationId,
      votingSessionParticipationId:
          votingSessionParticipationId ?? this.votingSessionParticipationId,
    );
  }

  @override
  List<Object?> get props => [
        id,
        createdAt,
        votingSessionId,
        votingSessionJurationId,
        votingSessionParticipationId,
      ];
}
