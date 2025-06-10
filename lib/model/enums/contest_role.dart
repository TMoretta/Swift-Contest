enum ContestRole {
  organizer,
  participant,
  juror,
}

extension ContestRoleX on ContestRole {
  bool get isOrganizer => this == ContestRole.organizer;
  bool get isParticipant => this == ContestRole.participant;
  bool get isJuror => this == ContestRole.juror;
}