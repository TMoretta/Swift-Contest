import 'package:equatable/equatable.dart';

class VotingSessionJuration extends Equatable {
  final String id;
  final DateTime createdAt;
  final String votingSessionId;
  final String jurationId;
  final bool hasSubmitted;

  const VotingSessionJuration({
    required this.id,
    required this.createdAt,
    required this.votingSessionId,
    required this.jurationId,
    required this.hasSubmitted,
  });

  factory VotingSessionJuration.fromJson(Map<String, dynamic> json) {
    return VotingSessionJuration(
      id: json['id'] as String,
      createdAt: DateTime.parse(json['created_at']).toLocal(),
      votingSessionId: json['voting_session_id'] as String,
      jurationId: json['juration_id'] as String,
      hasSubmitted: json['has_submitted'] as bool,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'created_at': createdAt.toUtc().toIso8601String(),
      'voting_session_id': votingSessionId,
      'juration_id': jurationId,
      'has_submitted': hasSubmitted,
    };
  }

  Map<String, dynamic> toRpcJson() {
    return {
      'p_id': id,
      'p_created_at': createdAt.toUtc().toIso8601String(),
      'p_voting_session_id': votingSessionId,
      'p_juration_id': jurationId,
      'p_has_submitted': hasSubmitted,
    };
  }

  VotingSessionJuration copyWith({
    String? id,
    DateTime? createdAt,
    String? votingSessionId,
    String? jurationId,
    bool? hasSubmitted,
  }) {
    return VotingSessionJuration(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      votingSessionId: votingSessionId ?? this.votingSessionId,
      jurationId: jurationId ?? this.jurationId,
      hasSubmitted: hasSubmitted ?? this.hasSubmitted,
    );
  }


  @override
  List<Object?> get props => [id, createdAt, votingSessionId, jurationId, hasSubmitted,];
}