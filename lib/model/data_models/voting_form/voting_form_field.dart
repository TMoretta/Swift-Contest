import 'package:swift_contest/model/data_models/voting_form/voting_form_field_type.dart';

abstract class VotingFormField {
  final String name;
  final bool isOptional;
  final VotingFormFieldType type;

  VotingFormField({
    required this.name,
    required this.isOptional,
    required this.type,
  });

  Map<String, dynamic> toJson();
}

class TextualVotingFormField extends VotingFormField {
  TextualVotingFormField({
    super.type = VotingFormFieldType.textual,
    required super.name,
    required super.isOptional,
  });

  factory TextualVotingFormField.fromJson(Map<String, dynamic> map) {
    return TextualVotingFormField(
      type: VotingFormFieldType.values.byName(map['type']),
      name: map['name'] as String,
      isOptional: map['is_optional'] as bool,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'type' : super.type.name,
      'name': super.name,
      'is_optional': super.isOptional,
    };
  }
}

class NumericVotingFormField extends VotingFormField {
  final int? minValue;
  final int? maxValue;

  NumericVotingFormField({
    super.type = VotingFormFieldType.numeric,
    required super.name,
    required super.isOptional,
    this.minValue,
    this.maxValue,
  });

  factory NumericVotingFormField.fromJson(Map<String, dynamic> map) {
    return NumericVotingFormField(
      type: VotingFormFieldType.values.byName(map['type']),
      name: map['name'] as String,
      isOptional: map['is_optional'] as bool,
      minValue: map['min_value'] as int?,
      maxValue: map['max_value'] as int?,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'type' : super.type.name,
      'name': super.name,
      'is_optional': super.isOptional,
      'min_value': minValue,
      'max_value': maxValue,
    };
  }
}
