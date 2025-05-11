import 'package:equatable/equatable.dart';
import 'package:swift_contest/model/enums/form_field_type.dart';

class VotingFormField extends Equatable {
  final String id;
  final DateTime createdAt;
  final String votingFormId;
  final String name;
  final int orderIndex;
  final FormFieldType fieldType;
  final bool isOptional;
  final int? minValue;
  final int? maxValue;

  const VotingFormField({
    required this.id,
    required this.createdAt,
    required this.votingFormId,
    required this.name,
    required this.orderIndex,
    required this.fieldType,
    required this.isOptional,
    this.minValue,
    this.maxValue,
  });

  factory VotingFormField.fromJson(Map<String, dynamic> json) {
    return VotingFormField(
      id: json['id'] as String,
      createdAt: DateTime.parse(json['created_at']).toLocal(),
      votingFormId: json['voting_form_id'] as String,
      name: json['name'] as String,
      orderIndex: json['order_index'] as int,
      fieldType: FormFieldType.values.byName(json['field_type']),
      isOptional: json['is_optional'] as bool,
      minValue: json['min_value'] != null ? json['min_value'] as int : null,
      maxValue: json['max_value'] != null ? json['max_value'] as int : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'created_at': createdAt.toUtc().toIso8601String(),
      'voting_form_id': votingFormId,
      'name': name,
      'order_index': orderIndex,
      'field_type': fieldType.name,
      'is_optional': isOptional,
      'min_value': minValue,
      'max_value': maxValue,
    };
  }

  VotingFormField copyWith({
    String? id,
    DateTime? createdAt,
    String? votingFormId,
    String? name,
    int? orderIndex,
    FormFieldType? fieldType,
    bool? isOptional,
    int? minValue,
    int? maxValue,
  }) {
    return VotingFormField(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      name: name ?? this.name,
      votingFormId: votingFormId ?? this.votingFormId,
      orderIndex: orderIndex ?? this.orderIndex,
      fieldType: fieldType ?? this.fieldType,
      isOptional: isOptional ?? this.isOptional,
      minValue: minValue ?? this.minValue,
      maxValue: maxValue ?? this.maxValue,
    );
  }

  @override
  List<Object?> get props => [
        id,
        createdAt,
        name,
        votingFormId,
        orderIndex,
        fieldType,
        isOptional,
        minValue,
        maxValue,
      ];
}

class RawVotingFormField {
  final String name;
  final FormFieldType fieldType;
  final bool isOptional;
  final int? minValue;
  final int? maxValue;

  RawVotingFormField({
    required this.name,
    required this.fieldType,
    required this.isOptional,
    this.minValue,
    this.maxValue,
  });

  factory RawVotingFormField.fromJson(Map<String, dynamic> json) {
    return RawVotingFormField(
      name: json['name'] as String,
      fieldType: FormFieldType.values.byName(json['field_type']),
      isOptional: json['is_optional'] as bool,
      minValue: json['min_value'] != null ? json['min_value'] as int : null,
      maxValue: json['max_value'] != null ? json['max_value'] as int : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'field_type': fieldType.name,
      'is_optional': isOptional,
      'min_value': minValue,
      'max_value': maxValue,
    };
  }
}
