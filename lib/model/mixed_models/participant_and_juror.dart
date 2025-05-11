import 'package:equatable/equatable.dart';
import 'package:swift_contest/model/data_models/profile.dart';

class ParticipantAndJuror extends Equatable{
  final Participant participant;
  final Juror juror;

  const ParticipantAndJuror({required this.participant, required this.juror});

  factory ParticipantAndJuror.fromJson(Map<String, dynamic> map) {
    return ParticipantAndJuror(
      participant: Participant.fromJson(map['participant']),
      juror: Juror.fromJson(map['juror']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'participant': participant.toJson(),
      'juror': juror.toJson(),
    };
  }

  @override
  List<Object?> get props => [participant,juror];
}
