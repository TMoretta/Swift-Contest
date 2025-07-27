import 'package:equatable/equatable.dart';
import 'package:swift_contest/model/db/bundles/contest_bundle.dart';
import 'package:swift_contest/model/db/bundles/jury_bundle.dart';
import 'package:swift_contest/model/db/bundles/participation_bundle.dart';
import 'package:swift_contest/model/db/entities/participant_invitation.dart';
import 'package:swift_contest/model/db/entities/voting_session.dart';

class ContestDetailsBundle extends Equatable {
  final ContestBundle contestBundle;
  final List<ParticipationBundle> participationsBundles;
  final List<ParticipantInvitation> participantsInvitations;
  final List<JuryBundle> juriesBundles;
  final List<VotingSession> votingSessions;

  const ContestDetailsBundle({
    required this.contestBundle,
    required this.participationsBundles,
    required this.participantsInvitations,
    required this.juriesBundles,
    required this.votingSessions,
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
      votingSessions: (json['voting_sessions'] as List<dynamic>)
          .map((e) => VotingSession.fromJson(e))
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
      'voting_sessions': votingSessions.map((e) => e.toJson()).toList(growable: false),
    };
  }

  ContestDetailsBundle copyWith({
    ContestBundle? contestBundle,
    List<ParticipationBundle>? participationsBundles,
    List<ParticipantInvitation>? participantsInvitations,
    List<JuryBundle>? juriesBundles,
    List<VotingSession>? votingSessions,
  }) {
    return ContestDetailsBundle(
      contestBundle: contestBundle ?? this.contestBundle,
      participationsBundles: participationsBundles ?? this.participationsBundles,
      participantsInvitations: participantsInvitations ?? this.participantsInvitations,
      juriesBundles: juriesBundles ?? this.juriesBundles,
      votingSessions: votingSessions ?? this.votingSessions,
    );
  }

  @override
  List<Object?> get props => [
        contestBundle,
        participationsBundles,
        participantsInvitations,
        juriesBundles,
        votingSessions,
      ];
}
