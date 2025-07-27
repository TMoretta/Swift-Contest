enum ContestStatus {
  preparationPhase,
  participationPhase,
  votingPhase,
  terminated,
  deleted,
}

extension ContestStatusX on ContestStatus {
  bool get isPreparationPhase => this == ContestStatus.preparationPhase;
  bool get isParticipationPhase => this == ContestStatus.participationPhase;
  bool get isVotingPhase => this == ContestStatus.votingPhase;
  bool get isTerminated => this == ContestStatus.terminated;
  bool get isDeleted => this == ContestStatus.deleted;
}
