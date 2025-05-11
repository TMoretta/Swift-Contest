import 'package:equatable/equatable.dart';
import 'package:swift_contest/model/data_models/participation.dart';
import 'package:swift_contest/model/data_models/work.dart';

final class ParticipationAndWork extends Equatable {
  final Participation participation;
  final Work work;

  const ParticipationAndWork({required this.participation, required this.work});

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

  @override
  List<Object?> get props => [participation, work];
}
