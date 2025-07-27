import 'package:equatable/equatable.dart';

class SimpleJurorVoting extends Equatable {
  final String? id;
  final DateTime? createdAt;
  final String? votingSessionId;
  final String? votingSessionSimpleJurorId;
  final String? votingSessionParticipationId;

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
      if (id != null)
        'id': id,
      if (createdAt != null)
        'created_at': createdAt!.toUtc().toIso8601String(),
      if(votingSessionId!=null) 'voting_session_id': votingSessionId,
      if(votingSessionSimpleJurorId!=null) 'voting_session_simple_juror_id': votingSessionSimpleJurorId,
      if(votingSessionParticipationId!=null) 'voting_session_participation_id': votingSessionParticipationId,
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
