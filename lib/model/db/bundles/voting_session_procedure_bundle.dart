import 'package:equatable/equatable.dart';
import 'package:swift_contest/model/db/bundles/voting_session_bundle.dart';
import 'package:swift_contest/model/db/bundles/voting_session_jury_bundle.dart';
import 'package:swift_contest/model/db/entities/voting_session_exclusion.dart';
import 'package:swift_contest/model/db/entities/voting_session_participation.dart';

class VotingSessionProcedureBundle extends Equatable {
  final VotingSessionBundle votingSessionBundle;
  final List<VotingSessionParticipation> votingSessionParticipations;
  final List<VotingSessionJuryBundle> votingSessionJuriesBundles;
  final List<VotingSessionExclusion> votingSessionExclusions;
  final String contestToken;

  const VotingSessionProcedureBundle({
    required this.votingSessionBundle,
    required this.votingSessionParticipations,
    required this.votingSessionJuriesBundles,
    required this.votingSessionExclusions,
    required this.contestToken,
  });

  factory VotingSessionProcedureBundle.fromJson(Map<String, dynamic> json) {
    return VotingSessionProcedureBundle(
      votingSessionBundle: VotingSessionBundle.fromJson(json['voting_session_bundle']),
      votingSessionParticipations: (json['voting_session_participations'] as List<dynamic>)
          .map((e) => VotingSessionParticipation.fromJson(e))
          .toList(growable: false),
      votingSessionJuriesBundles: (json['voting_session_juries_bundles'] as List<dynamic>)
          .map((e) => VotingSessionJuryBundle.fromJson(e))
          .toList(growable: false),
      votingSessionExclusions: (json['voting_session_exclusions'] as List<dynamic>)
          .map((e) => VotingSessionExclusion.fromJson(e))
          .toList(growable: false),
      contestToken: json['contest_token'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'voting_session_bundle': votingSessionBundle.toJson(),
      'voting_session_participations':
          votingSessionParticipations.map((e) => e.toJson()).toList(growable: false),
      'voting_session_juries_bundles':
          votingSessionJuriesBundles.map((e) => e.toJson()).toList(growable: false),
      'voting_session_exclusions':
          votingSessionExclusions.map((e) => e.toJson()).toList(growable: false),
      'contest_token': contestToken,
    };
  }

  VotingSessionProcedureBundle copyWith({
    VotingSessionBundle? votingSessionBundle,
    List<VotingSessionParticipation>? votingSessionParticipations,
    List<VotingSessionJuryBundle>? votingSessionJuriesBundles,
    List<VotingSessionExclusion>? votingSessionExclusions,
    String? contestToken,
  }) {
    return VotingSessionProcedureBundle(
      votingSessionBundle: votingSessionBundle ?? this.votingSessionBundle,
      votingSessionParticipations: votingSessionParticipations ?? this.votingSessionParticipations,
      votingSessionJuriesBundles: votingSessionJuriesBundles ?? this.votingSessionJuriesBundles,
      votingSessionExclusions: votingSessionExclusions ?? this.votingSessionExclusions,
      contestToken: contestToken ?? this.contestToken,
    );
  }

  @override
  List<Object?> get props => [
        votingSessionBundle,
        votingSessionParticipations,
        votingSessionJuriesBundles,
        votingSessionExclusions,
        contestToken,
      ];
}
