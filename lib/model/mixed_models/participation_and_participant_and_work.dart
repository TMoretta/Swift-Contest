import 'package:swift_contest/model/data_models/participation/participation.dart';
import 'package:swift_contest/model/data_models/profile/profile.dart';
import 'package:swift_contest/model/data_models/work/work.dart';

class ParticipationAndParticipantAndWork {
  final Participation participation;
  final Profile? participant;
  final Work? work;

  ParticipationAndParticipantAndWork(
      {required this.participation, required this.participant, required this.work});

  factory ParticipationAndParticipantAndWork.fromJson(Map<String, dynamic> map) {
    final participantMap = map['participant'];
    final workMap = map['work'];
    return ParticipationAndParticipantAndWork(
      participation: Participation.fromJson(map['participation'] as Map<String, dynamic>),
      participant: (participantMap != null)
          ? Profile.fromJson(map['participant'] as Map<String, dynamic>)
          : null,
      work: (participantMap != null && workMap != null)
          ? Work.fromJson(map['work'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'participation': participation.toJson(),
      'participant': participant?.toJson(),
      'work': work?.toJson(),
    };
  }
}
