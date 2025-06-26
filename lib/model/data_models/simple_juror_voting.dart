import 'package:equatable/equatable.dart';

class SimpleJurorVoting extends Equatable {
  final String id;
  final DateTime createdAt;
  final String votingSessionSimpleJurorId;
  final String votingSessionParticipationId;

  const SimpleJurorVoting({
    required this.id,
    required this.createdAt,
    required this.votingSessionSimpleJurorId,
    required this.votingSessionParticipationId,
  });

  factory SimpleJurorVoting.fromJson(Map<String, dynamic> json) {
    return SimpleJurorVoting(
      id: json['id'] as String,
      createdAt: DateTime.parse(json['created_at'] as String).toLocal(),
      votingSessionSimpleJurorId:
          json['voting_session_simple_juror_id'] as String,
      votingSessionParticipationId:
          json['voting_session_participation_id'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'created_at': createdAt.toUtc().toIso8601String(),
      'voting_session_simple_juror_id': votingSessionSimpleJurorId,
      'voting_session_participation_id': votingSessionParticipationId,
    };
  }

  Map<String, dynamic> toRpcJson() {
    return {
      'p_id': id,
      'p_created_at': createdAt.toUtc().toIso8601String(),
      'p_voting_session_simple_juror_id': votingSessionSimpleJurorId,
      'p_voting_session_participation_id': votingSessionParticipationId,
    };
  }

  @override
  List<Object?> get props => [
        id,
        createdAt,
        votingSessionSimpleJurorId,
        votingSessionParticipationId,
      ];
}

class SimpleJurorVotingNullable extends Equatable {
  final String? id;
  final DateTime? createdAt;
  final String? votingSessionSimpleJurorId;
  final String? votingSessionParticipationId;

  const SimpleJurorVotingNullable({
    this.id,
    this.createdAt,
    this.votingSessionSimpleJurorId,
    this.votingSessionParticipationId,
  });

  factory SimpleJurorVotingNullable.fromJson(Map<String, dynamic> json) {
    return SimpleJurorVotingNullable(
      id: json['id'] as String?,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String).toLocal()
          : null,
      votingSessionSimpleJurorId:
          json['voting_session_simple_juror_id'] as String?,
      votingSessionParticipationId:
          json['voting_session_participation_id'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'created_at': createdAt?.toUtc().toIso8601String(),
      'voting_session_simple_juror_id': votingSessionSimpleJurorId,
      'voting_session_participation_id': votingSessionParticipationId,
    };
  }

  @override
  List<Object?> get props => [
        id,
        createdAt,
        votingSessionSimpleJurorId,
        votingSessionParticipationId,
      ];
}
