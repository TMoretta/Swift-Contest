import 'package:equatable/equatable.dart';
import 'package:swift_contest/model/database/bundles/voting_session_bundle.dart';
import 'package:swift_contest/model/database/bundles/voting_session_jury_bundle.dart';
import 'package:swift_contest/model/database/entities/voting_session_exclusion.dart';
import 'package:swift_contest/model/database/entities/voting_session_participant.dart';

class OrganizerVotingSessionProcedureBundle extends Equatable {
  final VotingSessionBundle votingSessionBundle;
  final List<VotingSessionParticipant> votingSessionParticipants;
  final List<VotingSessionJuryBundle> votingSessionJuriesBundles;
  final List<VotingSessionExclusion> votingSessionExclusions;

  const OrganizerVotingSessionProcedureBundle({
    required this.votingSessionBundle,
    required this.votingSessionParticipants,
    required this.votingSessionJuriesBundles,
    required this.votingSessionExclusions,
  });

  factory OrganizerVotingSessionProcedureBundle.fromJson(Map<String, dynamic> json) {
    return OrganizerVotingSessionProcedureBundle(
      votingSessionBundle: VotingSessionBundle.fromJson(json['voting_session_bundle']),
      votingSessionParticipants: (json['voting_session_participants'] as List<dynamic>)
          .map((e) => VotingSessionParticipant.fromJson(e))
          .toList(growable: false),
      votingSessionJuriesBundles: (json['voting_session_juries_bundles'] as List<dynamic>)
          .map((e) => VotingSessionJuryBundle.fromJson(e))
          .toList(growable: false),
      votingSessionExclusions: (json['voting_session_exclusions'] as List<dynamic>)
          .map((e) => VotingSessionExclusion.fromJson(e))
          .toList(growable: false),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'voting_session_bundle': votingSessionBundle.toJson(),
      'voting_session_participants':
          votingSessionParticipants.map((e) => e.toJson()).toList(growable: false),
      'voting_session_juries_bundles':
          votingSessionJuriesBundles.map((e) => e.toJson()).toList(growable: false),
      'voting_session_exclusions':
          votingSessionExclusions.map((e) => e.toJson()).toList(growable: false),
    };
  }

  OrganizerVotingSessionProcedureBundle copyWith({
    VotingSessionBundle? votingSessionBundle,
    List<VotingSessionParticipant>? votingSessionParticipations,
    List<VotingSessionJuryBundle>? votingSessionJuriesBundles,
    List<VotingSessionExclusion>? votingSessionExclusions,
    String? contestToken,
  }) {
    return OrganizerVotingSessionProcedureBundle(
      votingSessionBundle: votingSessionBundle ?? this.votingSessionBundle,
      votingSessionParticipants: votingSessionParticipations ?? this.votingSessionParticipants,
      votingSessionJuriesBundles: votingSessionJuriesBundles ?? this.votingSessionJuriesBundles,
      votingSessionExclusions: votingSessionExclusions ?? this.votingSessionExclusions,
    );
  }

  @override
  List<Object?> get props => [
        votingSessionBundle,
        votingSessionParticipants,
        votingSessionJuriesBundles,
        votingSessionExclusions,
      ];
}
