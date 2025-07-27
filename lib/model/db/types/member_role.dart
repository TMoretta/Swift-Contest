enum MemberRole {
  participant,
  juror,
}

extension MemberRoleX on MemberRole {
  bool get isParticipant => this == MemberRole.participant;
  bool get isJuror => this == MemberRole.juror;
}
