enum VotingFormFieldType {
  textual,
  numeric,
}

extension VotingFormFieldTypeX on VotingFormFieldType {
  bool get isTextual => this == VotingFormFieldType.textual;
  bool get isNumeric => this == VotingFormFieldType.numeric;
}