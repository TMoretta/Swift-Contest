import 'package:swift_contest/model/data_models/voting_form/voting_form_field.dart';
import 'package:swift_contest/model/data_models/voting_form/voting_form_field_type.dart';

class VotingForm {
  final String id;
  final List<VotingFormField> fields;

  VotingForm({required this.id, required this.fields});

  factory VotingForm.fromJson(Map<String, dynamic> map) {
    return VotingForm(
      id: map['id'] as String,
      fields: (map['fields'] as List<dynamic>).map((fieldMap) {
        final VotingFormFieldType type = VotingFormFieldType.values.byName(fieldMap['type']);
        switch (type) {
          case VotingFormFieldType.numeric:
            return NumericVotingFormField.fromJson(fieldMap);
          case VotingFormFieldType.textual:
            return TextualVotingFormField.fromJson(fieldMap);
        }
      }).toList(growable: false),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'fields': fields.map((field) => field.toJson()).toList(growable: false),
    };
  }
}
