import 'package:equatable/equatable.dart';
import 'package:swift_contest/model/bundles/voting_form_bundle.dart';
import 'package:swift_contest/model/bundles/voting_session_exclusion_bundle.dart';
import 'package:swift_contest/model/bundles/voting_session_juration_bundle.dart';
import 'package:swift_contest/model/bundles/voting_session_participation_bundle.dart';
import 'package:swift_contest/model/data_models/voting_session.dart';
import 'package:swift_contest/model/data_models/voting_session_procedure.dart';

class OrganizerVotingSessionBundle extends Equatable {
  final VotingSession votingSession;
  final VotingFormBundle votingFormBundle;
  final List<VotingSessionParticipationBundle> votingSessionParticipationsBundles;
  final List<VotingSessionJurationBundle> votingSessionJurationsBundles;
  final List<VotingSessionExclusionBundle> votingSessionExclusionsBundles;

  const OrganizerVotingSessionBundle({
    required this.votingSession,
    required this.votingFormBundle,
    required this.votingSessionParticipationsBundles,
    required this.votingSessionJurationsBundles,
    required this.votingSessionExclusionsBundles,
  });

  factory OrganizerVotingSessionBundle.fromJson(Map<String, dynamic> json) {
    return OrganizerVotingSessionBundle(
      votingSession: VotingSession.fromJson(json['voting_session']),
      votingFormBundle: VotingFormBundle.fromJson(json['voting_form_bundle']),
      votingSessionParticipationsBundles: (json['voting_session_participations_bundles'] as List<dynamic>)
          .map((e) => VotingSessionParticipationBundle.fromJson(e))
          .toList(growable: false),
      votingSessionJurationsBundles: (json['voting_session_jurations_bundles'] as List<dynamic>)
          .map((e) => VotingSessionJurationBundle.fromJson(e))
          .toList(growable: false),
      votingSessionExclusionsBundles: (json['voting_session_exclusions_bundles'] as List<dynamic>)
          .map((e) => VotingSessionExclusionBundle.fromJson(e))
          .toList(growable: false),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'voting_session': votingSession.toJson(),
      'voting_form_bundle': votingFormBundle.toJson(),
      'voting_session_participations_bundles':
          votingSessionParticipationsBundles.map((e) => e.toJson()).toList(),
      'voting_session_jurations_bundles':
          votingSessionJurationsBundles.map((e) => e.toJson()).toList(),
      'voting_session_exclusions_bundles':
          votingSessionExclusionsBundles.map((e) => e.toJson()).toList(),
    };
  }

  OrganizerVotingSessionBundle copyWith({
    VotingSession? votingSession,
    VotingFormBundle? votingFormBundle,
    List<VotingSessionParticipationBundle>? votingSessionParticipationsBundles,
    List<VotingSessionJurationBundle>? votingSessionJurationsBundles,
    List<VotingSessionExclusionBundle>? votingSessionExclusionsBundles,
  }) {
    return OrganizerVotingSessionBundle(
      votingSession: votingSession ?? this.votingSession,
      votingFormBundle: votingFormBundle ?? this.votingFormBundle,
      votingSessionParticipationsBundles:
          votingSessionParticipationsBundles ?? this.votingSessionParticipationsBundles,
      votingSessionJurationsBundles:
          votingSessionJurationsBundles ?? this.votingSessionJurationsBundles,
      votingSessionExclusionsBundles:
          votingSessionExclusionsBundles ?? this.votingSessionExclusionsBundles,
    );
  }

  @override
  List<Object?> get props => [
        votingSession,
        votingFormBundle,
        votingSessionParticipationsBundles,
        votingSessionJurationsBundles,
        votingSessionExclusionsBundles,
      ];
}
