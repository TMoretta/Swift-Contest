import 'package:equatable/equatable.dart';

class VotingSessionParticipation extends Equatable {
  final String? id;
  final DateTime? createdAt;
  final String? votingSessionId;
  final String? participationSnapshotId;
  final int orderIndex;
  final bool isExcluded;

  const VotingSessionParticipation({
    required this.id,
    required this.createdAt,
    required this.votingSessionId,
    required this.participationSnapshotId,
    required this.orderIndex,
    required this.isExcluded,
  });

  factory VotingSessionParticipation.fromJson(Map<String, dynamic> json) {
    return VotingSessionParticipation(
      id: json['id'] as String,
      createdAt: DateTime.parse(json['created_at']).toLocal(),
      votingSessionId: json['voting_session_id'] as String,
      participationSnapshotId: json['participation_snapshot_id'] as String,
      orderIndex: json['order_index'] as int,
      isExcluded: json['is_excluded'] as bool,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if(id!=null) 'id': id,
      if(createdAt!=null) 'created_at': createdAt!.toUtc().toIso8601String(),
      if(votingSessionId!=null) 'voting_session_id': votingSessionId,
      if(participationSnapshotId!=null) 'participation_snapshot_id': participationSnapshotId,
      'order_index': orderIndex,
      'is_excluded': isExcluded,
    };
  }

  VotingSessionParticipation copyWith({
    String? id,
    DateTime? createdAt,
    String? votingSessionId,
    String? participationSnapshotId,
    int? orderIndex,
    bool? isExcluded,
  }) {
    return VotingSessionParticipation(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      votingSessionId: votingSessionId ?? this.votingSessionId,
      participationSnapshotId: participationSnapshotId ?? this.participationSnapshotId,
      orderIndex: orderIndex ?? this.orderIndex,
      isExcluded: isExcluded ?? this.isExcluded,
    );
  }


  @override
  List<Object?> get props => [id, createdAt, votingSessionId, participationSnapshotId,orderIndex, isExcluded,];
}
