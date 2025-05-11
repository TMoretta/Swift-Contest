import 'package:equatable/equatable.dart';
import 'package:swift_contest/model/data_models/participation.dart';
import 'package:swift_contest/model/data_models/profile.dart';
import 'package:swift_contest/model/data_models/work.dart';

class ParticipationAndParticipantAndWork extends Equatable {
  final Participation participation;
  final Participant? participant;
  final Work? work;

  const ParticipationAndParticipantAndWork(
      {required this.participation, required this.participant, required this.work});

  factory ParticipationAndParticipantAndWork.fromJson(Map<String, dynamic> map) {
    return ParticipationAndParticipantAndWork(
      participation: Participation.fromJson(map['participation'] as Map<String, dynamic>),
      participant: (map['participant'] != null)
          ? Participant.fromJson(map['participant'] as Map<String, dynamic>)
          : null,
      work: (map['participant'] != null && map['work'] != null)
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

  @override
  List<Object?> get props => [participation, participant, work];
}
