import 'package:equatable/equatable.dart';
import 'package:swift_contest/model/data_models/profile.dart';
import 'package:swift_contest/model/data_models/profile.dart';
import 'package:swift_contest/model/data_models/work.dart';

final class ParticipantAndWork extends Equatable{
  final Participant participant;
  final Work work;

  const ParticipantAndWork({required this.participant, required this.work});

  factory ParticipantAndWork.fromJson(Map<String, dynamic> map) {
    return ParticipantAndWork(
      participant: Participant.fromJson(map['participant']),
      work: Work.fromJson(map['work']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'participant': participant.toJson(),
      'work': work.toJson(),
    };
  }

  @override
  List<Object?> get props => [participant,work];
}
