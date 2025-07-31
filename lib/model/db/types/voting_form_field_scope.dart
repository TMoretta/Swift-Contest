enum VotingFormFieldScope {
  header,
  participant,
  footer,
}

extension VotingFormFieldScopeX on VotingFormFieldScope {
  bool get isHeader => this == VotingFormFieldScope.header;
  bool get isParticipant => this == VotingFormFieldScope.participant;
  bool get isFooter => this == VotingFormFieldScope.footer;
}