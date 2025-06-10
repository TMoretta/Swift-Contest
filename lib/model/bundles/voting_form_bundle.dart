import 'package:equatable/equatable.dart';
import 'package:swift_contest/model/data_models/voting_form.dart';
import 'package:swift_contest/model/data_models/voting_form_field.dart';

class VotingFormBundle extends Equatable {
  final VotingForm votingForm;
  final List<VotingFormField> votingFormFields;

  const VotingFormBundle({
    required this.votingForm,
    required this.votingFormFields,
  });

  factory VotingFormBundle.fromJson(Map<String, dynamic> json) {
    return VotingFormBundle(
      votingForm: VotingForm.fromJson(json['voting_form']),
      votingFormFields: (json['voting_form_fields'] as List<dynamic>)
          .map((e) => VotingFormField.fromJson(e))
          .toList(growable: false),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'voting_form': votingForm.toJson(),
      'voting_form_fields': votingFormFields.map((e) => e.toJson()).toList(growable: false),
    };
  }

  VotingFormBundle copyWith({
    VotingForm? votingForm,
    List<VotingFormField>? votingFormFields,
  }) {
    return VotingFormBundle(
      votingForm: votingForm ?? this.votingForm,
      votingFormFields: votingFormFields ?? this.votingFormFields,
    );
  }

  @override
  List<Object?> get props => [votingForm, votingFormFields];
}
