import 'package:swift_contest/model/data_models/participation/participation.dart';
import 'package:swift_contest/model/data_models/work/work.dart';

final class ParticipationAndWork {
  final Participation participation;
  final Work work;

  ParticipationAndWork({required this.participation, required this.work});

  factory ParticipationAndWork.fromJson(Map<String, dynamic> map) {
    return ParticipationAndWork(
      participation: Participation.fromJson(map['participation']),
      work: Work.fromJson(map['work']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'participation': participation.toJson(),
      'work': work.toJson(),
    };
  }
}
