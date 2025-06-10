import 'package:equatable/equatable.dart';

class VotingSessionParticipation extends Equatable {
  final String id;
  final DateTime createdAt;
  final String votingSessionId;
  final String participationId;
  final int orderIndex;

  const VotingSessionParticipation({
    required this.id,
    required this.createdAt,
    required this.votingSessionId,
    required this.participationId,
    required this.orderIndex,
  });

  factory VotingSessionParticipation.fromJson(Map<String, dynamic> json) {
    return VotingSessionParticipation(
      id: json['id'] as String,
      createdAt: DateTime.parse(json['created_at']).toLocal(),
      votingSessionId: json['voting_session_id'] as String,
      participationId: json['participation_id'] as String,
      orderIndex: json['order_index'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'created_at': createdAt.toUtc().toIso8601String(),
      'voting_session_id': votingSessionId,
      'participation_id': participationId,
      'order_index': orderIndex,
    };
  }

  Map<String, dynamic> toRpcJson() {
    return {
      'p_id': id,
      'p_created_at': createdAt.toUtc().toIso8601String(),
      'p_voting_session_id': votingSessionId,
      'p_participation_id': participationId,
      'p_order_index': orderIndex,
    };
  }

  VotingSessionParticipation copyWith({
    String? id,
    DateTime? createdAt,
    String? votingSessionId,
    String? participationId,
    int? orderIndex,
  }) {
    return VotingSessionParticipation(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      votingSessionId: votingSessionId ?? this.votingSessionId,
      participationId: participationId ?? this.participationId,
      orderIndex: orderIndex ?? this.orderIndex,
    );
  }


  @override
  List<Object?> get props => [id, createdAt, votingSessionId, participationId,orderIndex,];
}