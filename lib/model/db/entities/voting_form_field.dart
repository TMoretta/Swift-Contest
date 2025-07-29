import 'package:equatable/equatable.dart';
import 'package:swift_contest/model/db/types/voting_form_field_type.dart';

class VotingFormField extends Equatable {
  final String? id;
  final DateTime? createdAt;
  final String? votingFormId;
  final String name;
  final int orderIndex;
  final VotingFormFieldType type;
  final double? minValue;
  final double? maxValue;
  final bool isRequired;

  const VotingFormField({
    required this.id,
    required this.createdAt,
    required this.votingFormId,
    required this.name,
    required this.orderIndex,
    required this.type,
    required this.minValue,
    required this.maxValue,
    required this.isRequired,
  });

  factory VotingFormField.fromJson(Map<String, dynamic> json) {
    return VotingFormField(
      id: json['id'] as String,
      createdAt: DateTime.parse(json['created_at']).toLocal(),
      votingFormId: json['voting_form_id'] as String,
      name: json['name'] as String,
      orderIndex: json['order_index'] as int,
      type: VotingFormFieldType.values.byName(json['type'] as String),
      minValue: json['min_value'] as double?,
      maxValue: json['max_value'] as double?,
      isRequired: json['is_required'] as bool,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      if (createdAt != null) 'created_at': createdAt!.toUtc().toIso8601String(),
      if(votingFormId!=null) 'voting_form_id': votingFormId,
      'name': name,
      'order_index': orderIndex,
      'type': type.name,
      if(minValue!=null) 'min_value': minValue,
      if(maxValue!=null) 'max_value': maxValue,
      'is_required': isRequired,
    };
  }

  VotingFormField copyWith({
    String? id,
    DateTime? createdAt,
    String? votingFormId,
    String? name,
    int? orderIndex,
    VotingFormFieldType? type,
    double? minValue,
    double? maxValue,
    bool? isRequired,
  }) {
    return VotingFormField(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      name: name ?? this.name,
      votingFormId: votingFormId ?? this.votingFormId,
      orderIndex: orderIndex ?? this.orderIndex,
      type: type ?? this.type,
      minValue: minValue ?? this.minValue,
      maxValue: maxValue ?? this.maxValue,
      isRequired: isRequired ?? this.isRequired,
    );
  }

  @override
  List<Object?> get props => [
        id,
        createdAt,
        name,
        votingFormId,
        orderIndex,
        type,
        minValue,
        maxValue,
        isRequired,
      ];
}
