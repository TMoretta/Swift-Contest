import 'package:equatable/equatable.dart';

class VotingSessionJuror extends Equatable {
  final String id;
  final DateTime createdAt;
  final String votingSessionId;
  final String jurorId;
  final bool hasSubmitted;

  const VotingSessionJuror({
    required this.id,
    required this.createdAt,
    required this.votingSessionId,
    required this.jurorId,
    required this.hasSubmitted,
  });

  factory VotingSessionJuror.fromJson(Map<String, dynamic> json) {
    return VotingSessionJuror(
      id: json['id'] as String,
      createdAt: DateTime.parse(json['created_at']).toLocal(),
      votingSessionId: json['voting_session_id'] as String,
      jurorId: json['juror_id'] as String,
      hasSubmitted: json['has_submitted'] as bool,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'created_at': createdAt.toUtc().toIso8601String(),
      'voting_session_id': votingSessionId,
      'juror_id': jurorId,
      'has_submitted': hasSubmitted,
    };
  }

  VotingSessionJuror copyWith({
    String? id,
    DateTime? createdAt,
    String? votingSessionId,
    String? jurorId,
    bool? hasSubmitted,
  }) {
    return VotingSessionJuror(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      votingSessionId: votingSessionId ?? this.votingSessionId,
      jurorId: jurorId ?? this.jurorId,
      hasSubmitted: hasSubmitted ?? this.hasSubmitted,
    );
  }


  @override
  List<Object?> get props => [id, createdAt, votingSessionId, jurorId, hasSubmitted,];
}