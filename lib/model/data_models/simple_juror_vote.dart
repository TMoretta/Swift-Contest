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

class SimpleJurorVoteModel extends Equatable {
  final String? id;
  final DateTime? createdAt;
  final String? simpleJurorVotingId;
  final String? votingFormFieldId;
  final double? value;

  const SimpleJurorVoteModel({
    this.id,
    this.createdAt,
    this.simpleJurorVotingId,
    this.votingFormFieldId,
    this.value,
  });

  factory SimpleJurorVoteModel.fromJson(Map<String, dynamic> json) {
    return SimpleJurorVoteModel(
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
