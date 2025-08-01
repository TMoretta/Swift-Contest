import 'package:equatable/equatable.dart';
import 'package:swift_contest/model/database/types/voting_form_field_scope.dart';
import 'package:swift_contest/model/database/types/voting_form_field_type.dart';

class VotingFormField extends Equatable {
  final String? id;
  final DateTime? createdAt;
  final String? votingFormId;
  final String question;
  final int orderIndex;
  final VotingFormFieldType type;
  final int? sliderMinValue;
  final int? sliderMaxValue;
  final bool isRequired;
  final VotingFormFieldScope scope;

  const VotingFormField({
    required this.id,
    required this.createdAt,
    required this.votingFormId,
    required this.question,
    required this.orderIndex,
    required this.type,
    required this.sliderMinValue,
    required this.sliderMaxValue,
    required this.isRequired,
    required this.scope,
  });

  factory VotingFormField.fromJson(Map<String, dynamic> json) {
    return VotingFormField(
      id: json['id'] as String,
      createdAt: DateTime.parse(json['created_at']).toLocal(),
      votingFormId: json['voting_form_id'] as String,
      question: json['question'] as String,
      orderIndex: json['order_index'] as int,
      type: VotingFormFieldType.values.byName(json['type'] as String),
      sliderMinValue: json['slider_min_value'] as int?,
      sliderMaxValue: json['slider_max_value'] as int?,
      isRequired: json['is_required'] as bool,
      scope: VotingFormFieldScope.values.byName(json['scope'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      if (createdAt != null) 'created_at': createdAt!.toUtc().toIso8601String(),
      if (votingFormId != null) 'voting_form_id': votingFormId,
      'question': question,
      'order_index': orderIndex,
      'type': type.name,
      if(sliderMinValue!=null) 'slider_min_value': sliderMinValue,
      if(sliderMaxValue!=null) 'slider_max_value': sliderMaxValue,
      'is_required': isRequired,
      'scope': scope.name,
    };
  }

  VotingFormField copyWith({
    String? id,
    DateTime? createdAt,
    String? votingFormId,
    String? question,
    int? orderIndex,
    VotingFormFieldType? type,
    int? sliderMinValue,
    int? sliderMaxValue,
    bool? isRequired,
    VotingFormFieldScope? scope,
  }) {
    return VotingFormField(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      question: question ?? this.question,
      votingFormId: votingFormId ?? this.votingFormId,
      orderIndex: orderIndex ?? this.orderIndex,
      type: type ?? this.type,
      sliderMinValue: sliderMinValue ?? this.sliderMinValue,
      sliderMaxValue: sliderMaxValue ?? this.sliderMaxValue,
      isRequired: isRequired ?? this.isRequired,
      scope: scope ?? this.scope,
    );
  }

  @override
  List<Object?> get props => [
    id,
    createdAt,
    question,
    votingFormId,
    orderIndex,
    type,
    sliderMinValue,
    sliderMaxValue,
    isRequired,
    scope,
  ];
}
