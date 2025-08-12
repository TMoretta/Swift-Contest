import 'package:equatable/equatable.dart';
import 'package:swift_contest/model/database/bundles/contest_bundle.dart';
import 'package:swift_contest/model/database/bundles/voting_session_bundle.dart';
import 'package:swift_contest/model/database/entities/contest_ranking.dart';

class JurorContestDetailsBundle extends Equatable {
  final ContestBundle contestBundle;
  final int participantsNumber;
  final int jurorsNumber;
  final List<ContestRanking> contestRankings;
  final VotingSessionBundle? liveVotingSessionBundle;

  const JurorContestDetailsBundle({
    required this.contestBundle,
    required this.participantsNumber,
    required this.jurorsNumber,
    required this.contestRankings,
    required this.liveVotingSessionBundle,
  });

  factory JurorContestDetailsBundle.fromJson(Map<String, dynamic> json) {
    return JurorContestDetailsBundle(
      contestBundle: ContestBundle.fromJson(json['contest_bundle']),
      participantsNumber: json['participants_number'] as int,
      jurorsNumber: json['jurors_number'] as int,
      contestRankings: (json['contest_rankings'] as List<dynamic>)
          .map((e) => ContestRanking.fromJson(e))
          .toList(growable: false),
      liveVotingSessionBundle: json['live_voting_session'] != null
          ? VotingSessionBundle.fromJson(json['live_voting_session_bundle'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'contest_bundle': contestBundle.toJson(),
      'participants_number': participantsNumber,
      'jurors_number': jurorsNumber,
      'contest_rankings': contestRankings.map((e) => e.toJson()).toList(growable: false),
      'live_voting_session_bundle': liveVotingSessionBundle?.toJson(),
    };
  }

  JurorContestDetailsBundle copyWith({
    ContestBundle? contestBundle,
    int? participantsNumber,
    int? jurorsNumber,
    List<ContestRanking>? contestRankings,
    VotingSessionBundle? liveVotingSessionBundle,
  }) {
    return JurorContestDetailsBundle(
      contestBundle: contestBundle ?? this.contestBundle,
      participantsNumber: participantsNumber ?? this.participantsNumber,
      jurorsNumber: jurorsNumber ?? this.jurorsNumber,
      contestRankings: contestRankings ?? this.contestRankings,
      liveVotingSessionBundle: liveVotingSessionBundle ?? this.liveVotingSessionBundle,
    );
  }

  @override
  List<Object?> get props => [
        contestBundle,
        participantsNumber,
        jurorsNumber,
        contestRankings,
        liveVotingSessionBundle,
      ];
}
