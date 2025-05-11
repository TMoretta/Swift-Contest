import 'package:equatable/equatable.dart';
import 'package:swift_contest/model/data_models/participation.dart';
import 'package:swift_contest/model/data_models/profile.dart';

class ParticipationAndParticipant extends Equatable {
  final Participation participation;
  final Participant? participant;

  const ParticipationAndParticipant({required this.participation, required this.participant});

  factory ParticipationAndParticipant.fromJson(Map<String, dynamic> map) {
    return ParticipationAndParticipant(
      participation: Participation.fromJson(map['participation'] as Map<String, dynamic>),
      participant: (map['participant'] != null)
          ? Participant.fromJson(map['participant'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'participation': participation.toJson(),
      'participant': participant?.toJson(),
    };
  }

  @override
  List<Object?> get props => [participation, participant];
}
