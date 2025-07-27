import 'package:equatable/equatable.dart';

class JurorVoting extends Equatable {
  final String? id;
  final DateTime? createdAt;
  final String? votingSessionId;
  final String? votingSessionJurationId;
  final String? votingSessionParticipationId;

  const JurorVoting({
    required this.id,
    required this.createdAt,
    required this.votingSessionId,
    required this.votingSessionJurationId,
    required this.votingSessionParticipationId,
  });

  factory JurorVoting.fromJson(Map<String, dynamic> json) {
    return JurorVoting(
      id: json['id'] as String,
      createdAt: DateTime.parse(json['created_at']).toLocal(),
      votingSessionId: json['voting_session_id'] as String,
      votingSessionJurationId: json['voting_session_juration_id'] as String,
      votingSessionParticipationId: json['voting_session_participation_id'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      if (createdAt != null) 'created_at': createdAt!.toUtc().toIso8601String(),
      if(votingSessionId!=null) 'voting_session_id': votingSessionId,
      if(votingSessionJurationId!=null) 'voting_session_juration_id': votingSessionJurationId,
      if(votingSessionParticipationId!=null) 'voting_session_participation_id': votingSessionParticipationId,
    };
  }

  JurorVoting copyWith({
    String? id,
    DateTime? createdAt,
    String? votingSessionId,
    String? votingSessionJurationId,
    String? votingSessionParticipationId,
  }) {
    return JurorVoting(
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
