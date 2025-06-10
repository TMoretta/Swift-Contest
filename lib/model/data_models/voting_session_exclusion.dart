import 'package:equatable/equatable.dart';

class VotingSessionExclusion extends Equatable {
  final String id;
  final DateTime createdAt;
  final String votingSessionJurationId;
  final String votingSessionParticipationId;

  const VotingSessionExclusion({
    required this.id,
    required this.createdAt,
    required this.votingSessionJurationId,
    required this.votingSessionParticipationId,
  });

  factory VotingSessionExclusion.fromJson(Map<String, dynamic> json) {
    return VotingSessionExclusion(
      id: json['id'],
      createdAt: DateTime.parse(json['created_at']).toLocal(),
      votingSessionJurationId: json['voting_session_juration_id'],
      votingSessionParticipationId: json['voting_session_participation_id'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'created_at': createdAt.toUtc().toIso8601String(),
      'voting_session_juration_id': votingSessionJurationId,
      'voting_session_participation_id': votingSessionParticipationId,
    };
  }

  Map<String, dynamic> toRpcJson() {
    return {
      'p_id': id,
      'p_created_at': createdAt.toUtc().toIso8601String(),
      'p_voting_session_juration_id': votingSessionJurationId,
      'p_voting_session_participation_id': votingSessionParticipationId,
    };
  }

  VotingSessionExclusion copyWith({
    String? id,
    DateTime? createdAt,
    String? votingSessionJurationId,
    String? votingSessionParticipationId,
  }) {
    return VotingSessionExclusion(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      votingSessionJurationId: votingSessionJurationId ?? this.votingSessionJurationId,
      votingSessionParticipationId:
          votingSessionParticipationId ?? this.votingSessionParticipationId,
    );
  }

  @override
  List<Object?> get props => [id, createdAt, votingSessionJurationId, votingSessionParticipationId];
}
