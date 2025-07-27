import 'package:equatable/equatable.dart';
import 'package:swift_contest/model/db/entities/participation.dart';
import 'package:swift_contest/model/db/entities/profile.dart';
import 'package:swift_contest/model/db/entities/work.dart';

final class ParticipationBundle extends Equatable {
  final Participation participation;
  final Participant participant;
  final Work? work;

  const ParticipationBundle({
    required this.participation,
    required this.participant,
    this.work,
  });

  factory ParticipationBundle.fromJson(Map<String, dynamic> json) {
    return ParticipationBundle(
      participation: Participation.fromJson(json['participation']),
      participant: Participant.fromJson(json['participant']),
      work: json['work'] != null ? Work.fromJson(json['work']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'participation': participation.toJson(),
      'participant': participant.toJson(),
      'work': work?.toJson(),
    };
  }

  ParticipationBundle copyWith({
    Participation? participation,
    Participant? participant,
    Work? work,
  }) {
    return ParticipationBundle(
      participation: participation ?? this.participation,
      participant: participant ?? this.participant,
      work: work ?? this.work,
    );
  }

  @override
  List<Object?> get props => [participation, participant, work];
}
