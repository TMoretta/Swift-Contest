import 'package:equatable/equatable.dart';

class VotingSessionSimpleJuror extends Equatable {
  final String id;
  final DateTime createdAt;
  final String votingSessionId;
  final String simpleJurorId;
  final bool hasSubmitted;

  const VotingSessionSimpleJuror({
    required this.id,
    required this.createdAt,
    required this.votingSessionId,
    required this.simpleJurorId,
    required this.hasSubmitted,
  });

  factory VotingSessionSimpleJuror.fromJson(Map<String, dynamic> json) {
    return VotingSessionSimpleJuror(
      id: json['id'] as String,
      createdAt: DateTime.parse(json['created_at'] as String).toLocal(),
      votingSessionId: json['voting_session_id'] as String,
      simpleJurorId: json['simple_juror_id'] as String,
      hasSubmitted: json['has_submitted'] as bool,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'created_at': createdAt.toUtc().toIso8601String(),
      'voting_session_id': votingSessionId,
      'simple_juror_id': simpleJurorId,
      'has_submitted': hasSubmitted,
    };
  }

  VotingSessionSimpleJuror copyWith({
    String? id,
    DateTime? createdAt,
    String? votingSessionId,
    String? simpleJurorId,
    bool? hasSubmitted,
  }) {
    return VotingSessionSimpleJuror(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      votingSessionId: votingSessionId ?? this.votingSessionId,
      simpleJurorId: simpleJurorId ?? this.simpleJurorId,
      hasSubmitted: hasSubmitted ?? this.hasSubmitted,
    );
  }

  @override
  List<Object?> get props => [
        id,
        createdAt,
        votingSessionId,
        simpleJurorId,
        hasSubmitted,
      ];
}

class VotingSessionSimpleJurorNullable extends Equatable {
  final String? id;
  final DateTime? createdAt;
  final String? votingSessionId;
  final String? simpleJurorId;
  final bool? hasSubmitted;

  const VotingSessionSimpleJurorNullable({
    this.id,
    this.createdAt,
    this.votingSessionId,
    this.simpleJurorId,
    this.hasSubmitted,
  });

  factory VotingSessionSimpleJurorNullable.fromJson(Map<String, dynamic> json) {
    return VotingSessionSimpleJurorNullable(
      id: json['id'] as String?,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String).toLocal()
          : null,
      votingSessionId: json['voting_session_id'] as String?,
      simpleJurorId: json['simple_juror_id'] as String?,
      hasSubmitted: json['has_submitted'] as bool?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'created_at': createdAt?.toUtc().toIso8601String(),
      'voting_session_id': votingSessionId,
      'simple_juror_id': simpleJurorId,
      'has_submitted': hasSubmitted,
    };
  }

  @override
  List<Object?> get props => [
        id,
        createdAt,
        votingSessionId,
        simpleJurorId,
        hasSubmitted,
      ];
}

