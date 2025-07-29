enum VotingSessionStatus {
  live,
  ended,
  cancelled
}

extension VotingSessionStatusX on VotingSessionStatus {
  bool get isLive => this == VotingSessionStatus.live;
  bool get isEnded => this == VotingSessionStatus.ended;
  bool get isCancelled => this == VotingSessionStatus.cancelled;
}
