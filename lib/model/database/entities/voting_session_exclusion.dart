import 'package:equatable/equatable.dart';

class VotingSessionExclusion extends Equatable {
  final String? id;
  final DateTime? createdAt;
  final String? votingSessionId;
  final String? votingSessionJurorId;
  final String? votingSessionParticipantId;

  const VotingSessionExclusion({
    required this.id,
    required this.createdAt,
    required this.votingSessionId,
    required this.votingSessionJurorId,
    required this.votingSessionParticipantId,
  });

  factory VotingSessionExclusion.fromJson(Map<String, dynamic> json) {
    return VotingSessionExclusion(
      id: json['id'],
      createdAt: DateTime.parse(json['created_at']).toLocal(),
      votingSessionId: json['voting_session_id'],
      votingSessionJurorId: json['voting_session_juror_id'],
      votingSessionParticipantId: json['voting_session_participant_id'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if(id!=null) 'id': id,
      if(createdAt!=null) 'created_at': createdAt!.toUtc().toIso8601String(),
      if(votingSessionId!=null) 'voting_session_id': votingSessionId,
      if(votingSessionJurorId!=null) 'voting_session_juror_id': votingSessionJurorId,
      if(votingSessionParticipantId!=null) 'voting_session_participant_id': votingSessionParticipantId,
    };
  }

  VotingSessionExclusion copyWith({
    String? id,
    DateTime? createdAt,
    String? votingSessionId,
    String? votingSessionJurorId,
    String? votingSessionParticipantId,
  }) {
    return VotingSessionExclusion(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      votingSessionId: votingSessionId ?? this.votingSessionId,
      votingSessionJurorId: votingSessionJurorId ?? this.votingSessionJurorId,
      votingSessionParticipantId:
          votingSessionParticipantId ?? this.votingSessionParticipantId,
    );
  }

  @override
  List<Object?> get props => [
        id,
        createdAt,
        votingSessionId,
        votingSessionJurorId,
        votingSessionParticipantId,
      ];
}
