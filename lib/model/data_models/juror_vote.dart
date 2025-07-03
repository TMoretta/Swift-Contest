import 'package:equatable/equatable.dart';

class JurorVote extends Equatable {
  final String id;
  final DateTime createdAt;
  final String jurorVotingId;
  final String votingFormFieldId;
  final double value;

  const JurorVote({
    required this.id,
    required this.createdAt,
    required this.jurorVotingId,
    required this.votingFormFieldId,
    required this.value,
  });

  factory JurorVote.fromJson(Map<String, dynamic> json) {
    return JurorVote(
      id: json['id'] as String,
      createdAt: DateTime.parse(json['created_at']).toLocal(),
      jurorVotingId: json['juror_voting_id'] as String,
      votingFormFieldId: json['voting_form_field_id'] as String,
      value: json['value'] as double,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'created_at': createdAt.toUtc().toIso8601String(),
      'juror_voting_id': jurorVotingId,
      'voting_form_field_id': votingFormFieldId,
      'value': value,
    };
  }

  JurorVote copyWith({
    String? id,
    DateTime? createdAt,
    String? jurorVotingId,
    String? votingFormFieldId,
    double? value,
  }) {
    return JurorVote(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      jurorVotingId: jurorVotingId ?? this.jurorVotingId,
      votingFormFieldId: votingFormFieldId ?? this.votingFormFieldId,
      value: value ?? this.value,
    );
  }

  @override
  List<Object?> get props => [id, createdAt, jurorVotingId, votingFormFieldId, value];
}

class JurorVoteModel extends Equatable {
  final String? id;
  final DateTime? createdAt;
  final String? jurorVotingId;
  final String? votingFormFieldId;
  final double? value;

  const JurorVoteModel({
    this.id,
    this.createdAt,
    this.jurorVotingId,
    this.votingFormFieldId,
    this.value,
  });

  factory JurorVoteModel.fromJson(Map<String, dynamic> json) {
    return JurorVoteModel(
      id: json['id'] as String?,
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at']).toLocal() : null,
      jurorVotingId: json['juror_voting_id'] as String?,
      votingFormFieldId: json['voting_form_field_id'] as String?,
      value: json['value'] as double?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'created_at': createdAt?.toUtc().toIso8601String(),
      'juror_voting_id': jurorVotingId,
      'voting_form_field_id': votingFormFieldId,
      'value': value,
    };
  }

  @override
  List<Object?> get props => [id, createdAt, jurorVotingId, votingFormFieldId, value];
}
