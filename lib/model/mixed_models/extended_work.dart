import 'package:swift_contest/model/data_models/participation/participation.dart';
import 'package:swift_contest/model/data_models/profile/profile.dart';
import 'package:swift_contest/model/data_models/work/work.dart';

class ExtendedWork {
  final Work work;
  final Participation participation;
  final Profile participant;

  ExtendedWork({
    required this.work,
    required this.participation,
    required this.participant,
  });

  ExtendedWork.notSubmitted(this.work, this.participation, this.participant);

  factory ExtendedWork.fromJson(Map<String, dynamic> map) {
    return ExtendedWork(
      work: Work.fromJson(map['work']),
      participation: Participation.fromJson(map['participation']),
      participant: Profile.fromJson(map['participant']),
    );
  }
}

class ExtendedWorkNotSubmitted extends ExtendedWork {
  ExtendedWorkNotSubmitted({
    required super.work,
    required super.participation,
    required super.participant,
  });
}
