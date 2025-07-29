import 'package:equatable/equatable.dart';

class VotingSessionSimpleJuror extends Equatable {
  final String? id;
  final DateTime? createdAt;
  final String? votingSessionId;
  final String? votingSessionJuryId;
  final String? simpleJurorId;
  final bool hasSubmitted;

  const VotingSessionSimpleJuror({
    required this.id,
    required this.createdAt,
    required this.votingSessionId,
    required this.votingSessionJuryId,
    required this.simpleJurorId,
    required this.hasSubmitted,
  });

  factory VotingSessionSimpleJuror.fromJson(Map<String, dynamic> json) {
    return VotingSessionSimpleJuror(
      id: json['id'] as String,
      createdAt: DateTime.parse(json['created_at'] as String).toLocal(),
      votingSessionId: json['voting_session_id'] as String,
      votingSessionJuryId: json['voting_session_jury_id'] as String,
      simpleJurorId: json['simple_juror_id'] as String,
      hasSubmitted: json['has_submitted'] as bool,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if(id!=null) 'id': id,
      if(createdAt!=null) 'created_at': createdAt!.toUtc().toIso8601String(),
      if(votingSessionId!=null) 'voting_session_id': votingSessionId,
      if(votingSessionJuryId!=null) 'voting_session_jury_id': votingSessionJuryId,
      if(simpleJurorId!=null) 'simple_juror_id': simpleJurorId,
      'has_submitted': hasSubmitted,
    };
  }

  VotingSessionSimpleJuror copyWith({
    String? id,
    DateTime? createdAt,
    String? votingSessionId,
    String? votingSessionJuryId,
    String? simpleJurorId,
    bool? hasSubmitted,
  }) {
    return VotingSessionSimpleJuror(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      votingSessionId: votingSessionId ?? this.votingSessionId,
      votingSessionJuryId: votingSessionJuryId ?? this.votingSessionJuryId,
      simpleJurorId: simpleJurorId ?? this.simpleJurorId,
      hasSubmitted: hasSubmitted ?? this.hasSubmitted,
    );
  }

  @override
  List<Object?> get props => [
        id,
        createdAt,
        votingSessionId,
        votingSessionJuryId,
        simpleJurorId,
        hasSubmitted,
      ];
}
