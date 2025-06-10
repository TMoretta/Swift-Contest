enum ParticipantStatus {
  joined,
  left,
}

extension ParticipantStatusX on ParticipantStatus {
  bool get isJoined => this == ParticipantStatus.joined;
  bool get isLeft => this == ParticipantStatus.left;
}
