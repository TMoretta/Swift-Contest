enum VotingFormFieldType {
  textual,
  slider,
}

extension VotingFormFieldTypeX on VotingFormFieldType {
  bool get isTextual => this == VotingFormFieldType.textual;
  bool get isSlider => this == VotingFormFieldType.slider;
}