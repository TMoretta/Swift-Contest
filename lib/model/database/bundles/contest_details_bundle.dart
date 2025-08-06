import 'package:equatable/equatable.dart';
import 'package:swift_contest/model/database/bundles/contest_bundle.dart';
import 'package:swift_contest/model/database/bundles/jury_bundle.dart';
import 'package:swift_contest/model/database/bundles/participation_bundle.dart';
import 'package:swift_contest/model/database/bundles/voting_session_bundle.dart';
import 'package:swift_contest/model/database/entities/contest_ranking.dart';
import 'package:swift_contest/model/database/entities/participant_invitation.dart';

class ContestDetailsBundle extends Equatable {
  final ContestBundle contestBundle;
  final List<ParticipationBundle> participationsBundles;
  final List<ParticipantInvitation> participantsInvitations;
  final List<JuryBundle> juriesBundles;
  final List<VotingSessionBundle> votingSessionsBundles;
  final List<ContestRanking> contestRankings;

  const ContestDetailsBundle({
    required this.contestBundle,
    required this.participationsBundles,
    required this.participantsInvitations,
    required this.juriesBundles,
    required this.votingSessionsBundles,
    required this.contestRankings,
  });

  factory ContestDetailsBundle.fromJson(Map<String, dynamic> json) {
    return ContestDetailsBundle(
      contestBundle: ContestBundle.fromJson(json['contest_bundle']),
      participationsBundles: (json['participations_bundles'] as List<dynamic>)
          .map((
            e,
          ) =>
              ParticipationBundle.fromJson(e))
          .toList(growable: false),
      participantsInvitations: (json['participants_invitations'] as List<dynamic>).map((e) => ParticipantInvitation.fromJson(e)).toList(growable: false),
      juriesBundles: (json['juries_bundles'] as List<dynamic>).map((e) => JuryBundle.fromJson(e)).toList(growable: false),
      votingSessionsBundles: (json['voting_sessions_bundles'] as List<dynamic>)
          .map((e) => VotingSessionBundle.fromJson(e))
          .toList(growable: false),
      contestRankings: (json['contest_rankings'] as List<dynamic>)
          .map((e) => ContestRanking.fromJson(e))
          .toList(growable: false),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'contest_bundle' : contestBundle.toJson(),
      'participations_bundles':
          participationsBundles.map((e) => e.toJson()).toList(growable: false),
      'participants_invitations': participantsInvitations.map((e) => e.toJson()).toList(growable: false),
      'juries_bundles': juriesBundles.map((e) => e.toJson()).toList(growable: false),
      'voting_sessions_bundles': votingSessionsBundles.map((e) => e.toJson()).toList(growable: false),
      'contest_rankings': contestRankings.map((e) => e.toJson()).toList(growable: false),
    };
  }

  ContestDetailsBundle copyWith({
    ContestBundle? contestBundle,
    List<ParticipationBundle>? participationsBundles,
    List<ParticipantInvitation>? participantsInvitations,
    List<JuryBundle>? juriesBundles,
    List<VotingSessionBundle>? votingSessionsBundles,
    List<ContestRanking>? contestRankings,
  }) {
    return ContestDetailsBundle(
      contestBundle: contestBundle ?? this.contestBundle,
      participationsBundles: participationsBundles ?? this.participationsBundles,
      participantsInvitations: participantsInvitations ?? this.participantsInvitations,
      juriesBundles: juriesBundles ?? this.juriesBundles,
      votingSessionsBundles: votingSessionsBundles ?? this.votingSessionsBundles,
      contestRankings: contestRankings ?? this.contestRankings,
    );
  }

  @override
  List<Object?> get props => [
        contestBundle,
        participationsBundles,
        participantsInvitations,
        juriesBundles,
        votingSessionsBundles,
        contestRankings,
      ];
}
