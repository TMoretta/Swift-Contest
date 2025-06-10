import 'package:equatable/equatable.dart';

class SimpleJurorVoting extends Equatable {
  final String id;
  final DateTime createdAt;
  final String votingSessionId;
  final String votingSessionSimpleJurorId;
  final String votingSessionParticipationId;

  const SimpleJurorVoting({
    required this.id,
    required this.createdAt,
    required this.votingSessionId,
    required this.votingSessionSimpleJurorId,
    required this.votingSessionParticipationId,
  });

  factory SimpleJurorVoting.fromJson(Map<String, dynamic> json) {
    return SimpleJurorVoting(
      id: json['id'] as String,
      createdAt: DateTime.parse(json['created_at'] as String).toLocal(),
      votingSessionId: json['voting_session_id'] as String,
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
      'voting_session_id': votingSessionId,
      'voting_session_simple_juror_id': votingSessionSimpleJurorId,
      'voting_session_participation_id': votingSessionParticipationId,
    };
  }

  Map<String, dynamic> toRpcJson() {
    return {
      'p_id': id,
      'p_created_at': createdAt.toUtc().toIso8601String(),
      'p_voting_session_id': votingSessionId,
      'p_voting_session_simple_juror_id': votingSessionSimpleJurorId,
      'p_voting_session_participation_id': votingSessionParticipationId,
    };
  }

  @override
  List<Object?> get props => [
        id,
        createdAt,
        votingSessionId,
        votingSessionSimpleJurorId,
        votingSessionParticipationId,
      ];
}
