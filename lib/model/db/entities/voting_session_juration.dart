import 'package:equatable/equatable.dart';

class VotingSessionJuration extends Equatable {
  final String? id;
  final DateTime? createdAt;
  final String? votingSessionId;
  final String? jurationSnapshotId;
  final bool hasSubmitted;
  final bool isExcluded;

  const VotingSessionJuration({
    required this.id,
    required this.createdAt,
    required this.votingSessionId,
    required this.jurationSnapshotId,
    required this.hasSubmitted,
    required this.isExcluded,
  });

  factory VotingSessionJuration.fromJson(Map<String, dynamic> json) {
    return VotingSessionJuration(
      id: json['id'] as String,
      createdAt: DateTime.parse(json['created_at']).toLocal(),
      votingSessionId: json['voting_session_id'] as String,
      jurationSnapshotId: json['juration_snapshot_id'] as String,
      hasSubmitted: json['has_submitted'] as bool,
      isExcluded: json['is_excluded'] as bool,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      if (createdAt != null) 'created_at': createdAt!.toUtc().toIso8601String(),
      if (votingSessionId!=null) 'voting_session_id': votingSessionId,
      if (jurationSnapshotId!=null) 'juration_snapshot_id': jurationSnapshotId,
      'has_submitted': hasSubmitted,
      'is_excluded': isExcluded,
    };
  }

  VotingSessionJuration copyWith({
    String? id,
    DateTime? createdAt,
    String? votingSessionId,
    String? jurationSnapshotId,
    bool? hasSubmitted,
    bool? isExcluded,
  }) {
    return VotingSessionJuration(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      votingSessionId: votingSessionId ?? this.votingSessionId,
      jurationSnapshotId: jurationSnapshotId ?? this.jurationSnapshotId,
      hasSubmitted: hasSubmitted ?? this.hasSubmitted,
      isExcluded: isExcluded ?? this.isExcluded,
    );
  }

  @override
  List<Object?> get props => [
        id,
        createdAt,
        votingSessionId,
        jurationSnapshotId,
        hasSubmitted,
        isExcluded,
      ];
}
