import 'package:equatable/equatable.dart';
import 'package:swift_contest/model/database/bundles/contest_bundle.dart';
import 'package:swift_contest/model/database/entities/contest_ranking.dart';
import 'package:swift_contest/model/database/entities/participation.dart';
import 'package:swift_contest/model/database/entities/work.dart';

class ParticipantContestDetailsBundle extends Equatable {
  final ContestBundle contestBundle;
  final int participantsNumber;
  final int jurorsNumber;
  final List<ContestRanking> contestRankings;
  final Work? ownWork;

  const ParticipantContestDetailsBundle({
    required this.contestBundle,
    required this.participantsNumber,
    required this.jurorsNumber,
    required this.contestRankings,
    required this.ownWork,
  });

  factory ParticipantContestDetailsBundle.fromJson(Map<String, dynamic> json) {
    return ParticipantContestDetailsBundle(
      contestBundle: ContestBundle.fromJson(json['contest_bundle']),
      participantsNumber: json['participants_number'] as int,
      jurorsNumber: json['jurors_number'] as int,
      contestRankings: (json['contest_rankings'] as List<dynamic>)
          .map((e) => ContestRanking.fromJson(e))
          .toList(growable: false),
      ownWork: json['own_work'] != null ? Work.fromJson(json['own_work']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'contest_bundle': contestBundle.toJson(),
      'participants_number': participantsNumber,
      'jurors_number': jurorsNumber,
      'contest_rankings': contestRankings.map((e) => e.toJson()).toList(growable: false),
      'own_work': ownWork?.toJson(),
    };
  }

  ParticipantContestDetailsBundle copyWith({
    ContestBundle? contestBundle,
    int? participantsNumber,
    int? jurorsNumber,
    List<ContestRanking>? contestRankings,
    Participation? ownParticipation,
    Work? ownWork,
  }) {
    return ParticipantContestDetailsBundle(
      contestBundle: contestBundle ?? this.contestBundle,
      participantsNumber: participantsNumber ?? this.participantsNumber,
      jurorsNumber: jurorsNumber ?? this.jurorsNumber,
      contestRankings: contestRankings ?? this.contestRankings,
      ownWork: ownWork ?? this.ownWork,
    );
  }

  @override
  List<Object?> get props => [
        contestBundle,
        participantsNumber,
        jurorsNumber,
        contestRankings,
        ownWork,
      ];
}
