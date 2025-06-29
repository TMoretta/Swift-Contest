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

class VotingSessionExclusionNullable extends Equatable {
  final String? id;
  final DateTime? createdAt;
  final String? votingSessionId;
  final String? votingSessionJurationId;
  final String? votingSessionParticipationId;

  const VotingSessionExclusionNullable({
    this.id,
    this.createdAt,
    this.votingSessionId,
    this.votingSessionJurationId,
    this.votingSessionParticipationId,
  });

  factory VotingSessionExclusionNullable.fromJson(Map<String, dynamic> json) {
    return VotingSessionExclusionNullable(
      id: json['id'],
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at']).toLocal() : null,
      votingSessionId: json['voting_session_id'],
      votingSessionJurationId: json['voting_session_juration_id'],
      votingSessionParticipationId: json['voting_session_participation_id'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'created_at': createdAt?.toUtc().toIso8601String(),
      'voting_session_id': votingSessionId,
      'voting_session_juration_id': votingSessionJurationId,
      'voting_session_participation_id': votingSessionParticipationId,
    };
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
