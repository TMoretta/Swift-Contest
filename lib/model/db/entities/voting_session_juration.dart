import 'package:equatable/equatable.dart';

class VotingSessionJuration extends Equatable {
  final String? id;
  final DateTime? createdAt;
  final String? votingSessionId;
  final String? votingSessionJuryId;
  final String? jurationId;
  final bool hasSubmitted;
  // Snapshot data
  final String jurorFullName;

  const VotingSessionJuration({
    required this.id,
    required this.createdAt,
    required this.votingSessionId,
    required this.votingSessionJuryId,
    required this.jurationId,
    required this.hasSubmitted,
    required this.jurorFullName,
  });

  factory VotingSessionJuration.fromJson(Map<String, dynamic> json) {
    return VotingSessionJuration(
      id: json['id'] as String,
      createdAt: DateTime.parse(json['created_at']).toLocal(),
      votingSessionId: json['voting_session_id'] as String,
      votingSessionJuryId: json['voting_session_jury_id'] as String,
      jurationId: json['juration_id'] as String,
      hasSubmitted: json['has_submitted'] as bool,
      jurorFullName: json['juror_full_name'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      if (createdAt != null) 'created_at': createdAt!.toUtc().toIso8601String(),
      if (votingSessionId!=null) 'voting_session_id': votingSessionId,
      if (votingSessionJuryId!=null) 'voting_session_jury_id': votingSessionJuryId,
      if (jurationId!=null) 'juration_id': jurationId,
      'has_submitted': hasSubmitted,
      'juror_full_name': jurorFullName,
    };
  }

  VotingSessionJuration copyWith({
    String? id,
    DateTime? createdAt,
    String? votingSessionId,
    String? votingSessionJuryId,
    String? jurationId,
    bool? hasSubmitted,
    bool? isExcluded,
    String? jurorFullName,
  }) {
    return VotingSessionJuration(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      votingSessionId: votingSessionId ?? this.votingSessionId,
      votingSessionJuryId: votingSessionJuryId ?? this.votingSessionJuryId,
      jurationId: jurationId ?? this.jurationId,
      hasSubmitted: hasSubmitted ?? this.hasSubmitted,
      jurorFullName: jurorFullName ?? this.jurorFullName,
    );
  }

  @override
  List<Object?> get props => [
        id,
        createdAt,
        votingSessionId,
        votingSessionJuryId,
        jurationId,
        hasSubmitted,
        jurorFullName,
      ];
}
