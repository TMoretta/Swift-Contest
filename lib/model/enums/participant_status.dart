enum ParticipantStatus {
  joined,
  out,
}

extension ParticipantStatusX on ParticipantStatus {
  bool get isJoined => this == ParticipantStatus.joined;
  bool get isOut => this == ParticipantStatus.out;
}
