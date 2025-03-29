import 'package:swift_contest/model/data_models/profile/profile.dart';

class ParticipantAndJuror {
  final Profile participant;
  final Profile juror;

  ParticipantAndJuror({required this.participant, required this.juror});

  factory ParticipantAndJuror.fromJson(Map<String, dynamic> map) {
    return ParticipantAndJuror(
      participant: Profile.fromJson(map['participant']),
      juror: Profile.fromJson(map['juror']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'participant': participant.toJson(),
      'juror': juror.toJson(),
    };
  }
}
