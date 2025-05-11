import 'package:equatable/equatable.dart';

class Voting extends Equatable {
  final String id;
  final DateTime createdAt;
  final String votingSessionId;
  final String votingSessionJurorId;
  final String votingSessionParticipantId;
  final bool isExcluded;

  const Voting({
    required this.id,
    required this.createdAt,
    required this.votingSessionId,
    required this.votingSessionJurorId,
    required this.votingSessionParticipantId,
    required this.isExcluded,
  });

  factory Voting.fromJson(Map<String, dynamic> json) {
    return Voting(
      id: json['id'] as String,
      createdAt: DateTime.parse(json['created_at']).toLocal(),
      votingSessionId: json['voting_session_id'] as String,
      votingSessionJurorId: json['voting_session_juror_id'] as String,
      votingSessionParticipantId: json['voting_session_participant_id'] as String,
      isExcluded: json['is_excluded'] as bool,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'created_at': createdAt.toUtc().toIso8601String(),
      'voting_session_id': votingSessionId,
      'voting_session_juror_id': votingSessionJurorId,
      'voting_session_participant_id': votingSessionParticipantId,
      'is_excluded': isExcluded,
    };
  }

  Voting copyWith({
    String? id,
    DateTime? createdAt,
    String? votingSessionId,
    String? votingSessionJurorId,
    String? votingSessionParticipantId,
    bool? isExcluded,
  }) {
    return Voting(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      votingSessionId: votingSessionId ?? this.votingSessionId,
      votingSessionJurorId: votingSessionJurorId ?? this.votingSessionJurorId,
      votingSessionParticipantId: votingSessionParticipantId ?? this.votingSessionParticipantId,
      isExcluded: isExcluded ?? this.isExcluded,
    );
  }

  @override
  List<Object?> get props => [
        id,
        createdAt,
        votingSessionId,
        votingSessionJurorId,
        votingSessionParticipantId,
        isExcluded,
      ];
}
