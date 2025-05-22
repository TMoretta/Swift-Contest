import 'package:equatable/equatable.dart';

class VotingSessionParticipant extends Equatable {
  final String id;
  final DateTime createdAt;
  final String votingSessionId;
  final String participantId;
  final int orderIndex;

  const VotingSessionParticipant({
    required this.id,
    required this.createdAt,
    required this.votingSessionId,
    required this.participantId,
    required this.orderIndex,
  });

  factory VotingSessionParticipant.fromJson(Map<String, dynamic> json) {
    return VotingSessionParticipant(
      id: json['id'] as String,
      createdAt: DateTime.parse(json['created_at']).toLocal(),
      votingSessionId: json['voting_session_id'] as String,
      participantId: json['participant_id'] as String,
      orderIndex: json['order_index'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'created_at': createdAt.toUtc().toIso8601String(),
      'voting_session_id': votingSessionId,
      'participant_id': participantId,
      'order_index': orderIndex,
    };
  }

  Map<String, dynamic> toRpcJson() {
    return {
      'p_id': id,
      'p_created_at': createdAt.toUtc().toIso8601String(),
      'p_voting_session_id': votingSessionId,
      'p_participant_id': participantId,
      'p_order_index': orderIndex,
    };
  }

  VotingSessionParticipant copyWith({
    String? id,
    DateTime? createdAt,
    String? votingSessionId,
    String? participantId,
    int? orderIndex,
  }) {
    return VotingSessionParticipant(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      votingSessionId: votingSessionId ?? this.votingSessionId,
      participantId: participantId ?? this.participantId,
      orderIndex: orderIndex ?? this.orderIndex,
    );
  }


  @override
  List<Object?> get props => [id, createdAt, votingSessionId, participantId,orderIndex,];
}