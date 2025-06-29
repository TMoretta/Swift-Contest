import 'package:equatable/equatable.dart';

class JurorVoting extends Equatable {
  final String id;
  final DateTime createdAt;
  final String votingSessionJurationId;
  final String votingSessionParticipationId;

  const JurorVoting({
    required this.id,
    required this.createdAt,
    required this.votingSessionJurationId,
    required this.votingSessionParticipationId,
  });

  factory JurorVoting.fromJson(Map<String, dynamic> json) {
    return JurorVoting(
      id: json['id'] as String,
      createdAt: DateTime.parse(json['created_at']).toLocal(),
      votingSessionJurationId: json['voting_session_juration_id'] as String,
      votingSessionParticipationId: json['voting_session_participation_id'] as String,
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

  JurorVoting copyWith({
    String? id,
    DateTime? createdAt,
    String? votingSessionJurationId,
    String? votingSessionParticipationId,
  }) {
    return JurorVoting(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      votingSessionJurationId: votingSessionJurationId ?? this.votingSessionJurationId,
      votingSessionParticipationId:
          votingSessionParticipationId ?? this.votingSessionParticipationId,
    );
  }

  @override
  List<Object?> get props => [
        id,
        createdAt,
        votingSessionJurationId,
        votingSessionParticipationId,
      ];
}

class JurorVotingNullable extends Equatable {
  final String? id;
  final DateTime? createdAt;
  final String? votingSessionJurationId;
  final String? votingSessionParticipationId;

  const JurorVotingNullable({
    this.id,
    this.createdAt,
    this.votingSessionJurationId,
    this.votingSessionParticipationId,
  });

  factory JurorVotingNullable.fromJson(Map<String, dynamic> json) {
    return JurorVotingNullable(
      id: json['id'] as String?,
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at']).toLocal() : null,
      votingSessionJurationId: json['voting_session_juration_id'] as String?,
      votingSessionParticipationId: json['voting_session_participation_id'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'created_at': createdAt?.toUtc().toIso8601String(),
      'voting_session_juration_id': votingSessionJurationId,
      'voting_session_participation_id': votingSessionParticipationId,
    };
  }

  @override
  List<Object?> get props => [
        id,
        createdAt,
        votingSessionJurationId,
        votingSessionParticipationId,
      ];
}
