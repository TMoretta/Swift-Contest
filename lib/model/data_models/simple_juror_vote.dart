import 'package:equatable/equatable.dart';

class SimpleJurorVote extends Equatable {
  final String id;
  final DateTime createdAt;
  final String simpleJurorVotingId;
  final String votingFormFieldId;
  final double value;

  const SimpleJurorVote({
    required this.id,
    required this.createdAt,
    required this.simpleJurorVotingId,
    required this.votingFormFieldId,
    required this.value,
  });

  factory SimpleJurorVote.fromJson(Map<String, dynamic> json) {
    return SimpleJurorVote(
      id: json['id'] as String,
      createdAt: DateTime.parse(json['created_at']).toLocal(),
      simpleJurorVotingId: json['simple_juror_voting_id'] as String,
      votingFormFieldId: json['voting_form_field_id'] as String,
      value: json['value'] as double,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'created_at': createdAt.toUtc().toIso8601String(),
      'simple_juror_voting_id': simpleJurorVotingId,
      'voting_form_field_id': votingFormFieldId,
      'value': value,
    };
  }

  Map<String, dynamic> toRpcJson() {
    return {
      'p_id': id,
      'p_created_at': createdAt.toUtc().toIso8601String(),
      'p_simple_juror_voting_id': simpleJurorVotingId,
      'p_voting_form_field_id': votingFormFieldId,
      'p_value': value,
    };
  }

  SimpleJurorVote copyWith({
    String? id,
    DateTime? createdAt,
    String? simpleJurorVotingId,
    String? votingFormFieldId,
    double? value,
  }) {
    return SimpleJurorVote(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      simpleJurorVotingId: simpleJurorVotingId ?? this.simpleJurorVotingId,
      votingFormFieldId: votingFormFieldId ?? this.votingFormFieldId,
      value: value ?? this.value,
    );
  }


  @override
  List<Object?> get props => [id, createdAt, simpleJurorVotingId, votingFormFieldId, value];
}

class SimpleJurorVoteNullable extends Equatable {
  final String? id;
  final DateTime? createdAt;
  final String? simpleJurorVotingId;
  final String? votingFormFieldId;
  final double? value;

  const SimpleJurorVoteNullable({
    this.id,
    this.createdAt,
    this.simpleJurorVotingId,
    this.votingFormFieldId,
    this.value,
  });

  factory SimpleJurorVoteNullable.fromJson(Map<String, dynamic> json) {
    return SimpleJurorVoteNullable(
      id: json['id'] as String?,
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at']).toLocal() : null,
      simpleJurorVotingId: json['simple_juror_voting_id'] as String?,
      votingFormFieldId: json['voting_form_field_id'] as String?,
      value: json['value'] as double?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'created_at': createdAt?.toUtc().toIso8601String(),
      'simple_juror_voting_id': simpleJurorVotingId,
      'voting_form_field_id': votingFormFieldId,
      'value': value,
    };
  }

  @override
  List<Object?> get props => [id, createdAt, simpleJurorVotingId, votingFormFieldId, value];
}
