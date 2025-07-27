import 'package:equatable/equatable.dart';

class VotingSessionJury extends Equatable {
  final String? id;
  final DateTime? createdAt;
  final String? votingSessionId;
  final String? juryId;

  // Snapshot data
  final String juryName;
  final String? votingFormId;

  const VotingSessionJury({
    required this.id,
    required this.createdAt,
    required this.votingSessionId,
    required this.juryId,
    required this.juryName,
    required this.votingFormId,
  });

  factory VotingSessionJury.fromJson(Map<String, dynamic> json) {
    return VotingSessionJury(
      id: json['id'] as String,
      createdAt: DateTime.parse(json['created_at']).toLocal(),
      votingSessionId: json['voting_session_id'] as String,
      juryId: json['jury_id'] as String,
      juryName: json['jury_name'] as String,
      votingFormId: json['voting_form_id'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      if (createdAt != null) 'created_at': createdAt!.toUtc().toIso8601String(),
      if (votingSessionId != null) 'voting_session_id': votingSessionId,
      if (juryId != null) 'jury_id': juryId,
      'jury_name': juryName,
      if (votingFormId != null) 'voting_form_id': votingFormId,
    };
  }

  VotingSessionJury copyWith({
    String? id,
    DateTime? createdAt,
    String? votingSessionId,
    String? juryId,
    String? juryName,
    String? votingFormId,
  }) {
    return VotingSessionJury(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      votingSessionId: votingSessionId ?? this.votingSessionId,
      juryId: juryId ?? this.juryId,
      juryName: juryName ?? this.juryName,
      votingFormId: votingFormId ?? this.votingFormId,
    );
  }

  @override
  List<Object?> get props => [
        id,
        createdAt,
        votingSessionId,
        juryId,
        juryName,
        votingFormId,
      ];
}
