enum VotingSessionStatus {
  initialized,
  work,
  intermission,
  review,
  ended,
  cancelled,
}

extension VotingSessionStatusX on VotingSessionStatus {
  bool get isInitialized => this == VotingSessionStatus.initialized;
  bool get isWork => this == VotingSessionStatus.work;
  bool get isIntermission => this == VotingSessionStatus.intermission;
  bool get isReview => this == VotingSessionStatus.review;
  bool get isEnded => this == VotingSessionStatus.ended;
  bool get isCancelled => this == VotingSessionStatus.cancelled;
}

// enum VotingSessionStatus {
//   live,
//   ended,
//   cancelled,
// }
//
// extension VotingSessionStatusX on VotingSessionStatus {
//   bool get isLive => this == VotingSessionStatus.live;
//
//   bool get isEnded => this == VotingSessionStatus.ended;
//
//   bool get isCancelled => this == VotingSessionStatus.cancelled;
// }
