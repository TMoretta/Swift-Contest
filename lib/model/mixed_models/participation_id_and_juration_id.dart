class ParticipationIdAndJurationId {
  final String participationId;
  final String jurationId;

  ParticipationIdAndJurationId({required this.participationId, required this.jurationId});

  factory ParticipationIdAndJurationId.fromJson(Map<String, dynamic> map) {
    return ParticipationIdAndJurationId(
      participationId: map['participation_id'],
      jurationId: map['juration_id'],
    );
  }

  Map<String,dynamic> toJson() {
    return {
      'participation_id' : participationId,
      'juration_id' : jurationId,
    };
  }
}
