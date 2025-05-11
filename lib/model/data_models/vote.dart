import 'package:equatable/equatable.dart';

class Vote extends Equatable {
  final String id;
  final DateTime createdAt;
  final String votingId;
  final String votingFormFieldId;
  final String value;

  const Vote({
    required this.id,
    required this.createdAt,
    required this.votingId,
    required this.votingFormFieldId,
    required this.value,
  });

  factory Vote.fromJson(Map<String, dynamic> json) {
    return Vote(
      id: json['id'] as String,
      createdAt: DateTime.parse(json['created_at']).toLocal(),
      votingId: json['voting_id'] as String,
      votingFormFieldId: json['voting_form_field_id'] as String,
      value: json['value'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'created_at': createdAt.toUtc().toIso8601String(),
      'voting_id': votingId,
      'voting_form_field_id': votingFormFieldId,
      'value': value,
    };
  }

  Vote copyWith({
    String? id,
    DateTime? createdAt,
    String? votingId,
    String? votingFormFieldId,
    String? value,
  }) {
    return Vote(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      votingId: votingId ?? this.votingId,
      votingFormFieldId: votingFormFieldId ?? this.votingFormFieldId,
      value: value ?? this.value,
    );
  }


  @override
  List<Object?> get props => [id, createdAt, votingId, votingFormFieldId, value];
}