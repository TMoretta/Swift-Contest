import 'package:equatable/equatable.dart';

class VotingSessionSimpleJuror extends Equatable {
  final String id;
  final DateTime createdAt;
  final String votingSessionId;
  final String fullName;
  final bool hasSubmitted;

  const VotingSessionSimpleJuror({
    required this.id,
    required this.createdAt,
    required this.votingSessionId,
    required this.fullName,
    required this.hasSubmitted,
  });

  factory VotingSessionSimpleJuror.fromJson(Map<String, dynamic> json) {
    return VotingSessionSimpleJuror(
      id: json['id'] as String,
      createdAt: DateTime.parse(json['created_at'] as String).toLocal(),
      votingSessionId: json['voting_session_id'] as String,
      fullName: json['full_name'] as String,
      hasSubmitted: json['has_submitted'] as bool,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'created_at': createdAt.toUtc().toIso8601String(),
      'voting_session_id': votingSessionId,
      'full_name': fullName,
      'has_submitted': hasSubmitted,
    };
  }

  VotingSessionSimpleJuror copyWith({
    String? id,
    DateTime? createdAt,
    String? votingSessionId,
    String? fullName,
    bool? hasSubmitted,
  }) {
    return VotingSessionSimpleJuror(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      votingSessionId: votingSessionId ?? this.votingSessionId,
      fullName: fullName ?? this.fullName,
      hasSubmitted: hasSubmitted ?? this.hasSubmitted,
    );
  }

  @override
  List<Object?> get props => [
        id,
        createdAt,
        votingSessionId,
        fullName,
        hasSubmitted,
      ];
}
