import 'package:swift_contest/model/data_models/profile/profile.dart';
import 'package:swift_contest/model/data_models/work/work.dart';

final class ParticipantAndWork {
  final Profile participant;
  final Work work;

  ParticipantAndWork({required this.participant, required this.work});

  factory ParticipantAndWork.fromJson(Map<String, dynamic> map) {
    return ParticipantAndWork(
      participant: Profile.fromJson(map['participant']),
      work: Work.fromJson(map['work']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'participant': participant.toJson(),
      'work': work.toJson(),
    };
  }
}
