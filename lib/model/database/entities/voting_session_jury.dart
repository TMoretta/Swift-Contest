import 'package:equatable/equatable.dart';
import 'package:swift_contest/model/database/types/jury_type.dart';

class VotingSessionJury extends Equatable {
  final String? id;
  final DateTime? createdAt;
  final String? votingSessionId;
  final String? juryId;

  // Snapshot data
  final String juryName;
  final JuryType juryType;
  final String? votingFormId;
  final String juryToken;

  const VotingSessionJury({
    required this.id,
    required this.createdAt,
    required this.votingSessionId,
    required this.juryId,
    required this.juryName,
    required this.juryType,
    required this.votingFormId,
    required this.juryToken,
  });

  factory VotingSessionJury.fromJson(Map<String, dynamic> json) {
    return VotingSessionJury(
      id: json['id'] as String,
      createdAt: DateTime.parse(json['created_at']).toLocal(),
      votingSessionId: json['voting_session_id'] as String,
      juryId: json['jury_id'] as String,
      juryName: json['jury_name'] as String,
      juryType: JuryType.values.byName(json['jury_type']),
      votingFormId: json['voting_form_id'] as String,
      juryToken: json['jury_token'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      if (createdAt != null) 'created_at': createdAt!.toUtc().toIso8601String(),
      if (votingSessionId != null) 'voting_session_id': votingSessionId,
      if (juryId != null) 'jury_id': juryId,
      'jury_name': juryName,
      'jury_type': juryType.name,
      if (votingFormId != null) 'voting_form_id': votingFormId,
      'jury_token': juryToken,
    };
  }

  VotingSessionJury copyWith({
    String? id,
    DateTime? createdAt,
    String? votingSessionId,
    String? juryId,
    String? juryName,
    JuryType? juryType,
    String? votingFormId,
    String? juryToken,
  }) {
    return VotingSessionJury(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      votingSessionId: votingSessionId ?? this.votingSessionId,
      juryId: juryId ?? this.juryId,
      juryName: juryName ?? this.juryName,
      juryType: juryType ?? this.juryType,
      votingFormId: votingFormId ?? this.votingFormId,
      juryToken: juryToken ?? this.juryToken,
    );
  }

  @override
  List<Object?> get props => [
        id,
        createdAt,
        votingSessionId,
        juryId,
        juryName,
        juryType,
        votingFormId,
        juryToken,
      ];
}
