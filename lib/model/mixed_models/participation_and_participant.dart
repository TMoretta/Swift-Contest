import 'package:swift_contest/model/data_models/participation/participation.dart';
import 'package:swift_contest/model/data_models/profile/profile.dart';

class ParticipationAndParticipant {
  final Participation participation;
  final Profile? participant;

  ParticipationAndParticipant({required this.participation, required this.participant});

  factory ParticipationAndParticipant.fromJson(Map<String, dynamic> map) {
    final participantMap = map['participant'];
    return ParticipationAndParticipant(
      participation:
          Participation.fromJson(map['participation'] as Map<String, dynamic>),
      participant: (participantMap != null)
          ? Profile.fromJson(map['participant'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'participation': participation.toJson(),
      'participant': participant?.toJson(),
    };
  }
}
