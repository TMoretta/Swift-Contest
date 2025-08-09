import 'package:equatable/equatable.dart';

class VotingSessionJuror extends Equatable {
  final String? id;
  final DateTime? createdAt;
  final String? votingSessionId;
  final String? votingSessionJuryId;
  final String? jurationId;
  final String? jurorId;
  final bool hasSubmitted;
  // Snapshot data
  final String jurorFullName;

  const VotingSessionJuror({
    required this.id,
    required this.createdAt,
    required this.votingSessionId,
    required this.votingSessionJuryId,
    required this.jurationId,
    required this.jurorId,
    required this.hasSubmitted,
    required this.jurorFullName,
  });

  factory VotingSessionJuror.fromJson(Map<String, dynamic> json) {
    return VotingSessionJuror(
      id: json['id'] as String,
      createdAt: DateTime.parse(json['created_at']).toLocal(),
      votingSessionId: json['voting_session_id'] as String,
      votingSessionJuryId: json['voting_session_jury_id'] as String,
      jurationId: json['juration_id'] as String?,
      jurorId: json['juror_id'] as String?,
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
      if (jurorId!=null) 'juror_id': jurorId,
      'has_submitted': hasSubmitted,
      'juror_full_name': jurorFullName,
    };
  }

  VotingSessionJuror copyWith({
    String? id,
    DateTime? createdAt,
    String? votingSessionId,
    String? votingSessionJuryId,
    String? jurationId,
    String? jurorId,
    bool? hasSubmitted,
    bool? isExcluded,
    String? jurorFullName,
  }) {
    return VotingSessionJuror(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      votingSessionId: votingSessionId ?? this.votingSessionId,
      votingSessionJuryId: votingSessionJuryId ?? this.votingSessionJuryId,
      jurationId: jurationId ?? this.jurationId,
      jurorId: jurorId ?? this.jurorId,
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
        jurorId,
        hasSubmitted,
        jurorFullName,
      ];
}
