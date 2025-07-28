import 'package:equatable/equatable.dart';
import 'package:swift_contest/model/db/bundles/voting_session_bundle.dart';
import 'package:swift_contest/model/db/bundles/voting_session_jury_bundle.dart';
import 'package:swift_contest/model/db/entities/voting_session_participation.dart';

class VotingSessionProcedureBundle extends Equatable {
  final VotingSessionBundle votingSessionBundle;
  final List<VotingSessionParticipation> votingSessionParticipations;
  final List<VotingSessionJuryBundle> votingSessionJuriesBundles;

  const VotingSessionProcedureBundle({
    required this.votingSessionBundle,
    required this.votingSessionParticipations,
    required this.votingSessionJuriesBundles,
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
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'voting_session_bundle': votingSessionBundle.toJson(),
      'voting_session_participations':
          votingSessionParticipations.map((e) => e.toJson()).toList(growable: false),
      'voting_session_juries_bundles':
          votingSessionJuriesBundles.map((e) => e.toJson()).toList(growable: false),
    };
  }

  VotingSessionProcedureBundle copyWith({
    VotingSessionBundle? votingSessionBundle,
    List<VotingSessionParticipation>? votingSessionParticipations,
    List<VotingSessionJuryBundle>? votingSessionJuriesBundles,
  }) {
    return VotingSessionProcedureBundle(
      votingSessionBundle: votingSessionBundle ?? this.votingSessionBundle,
      votingSessionParticipations: votingSessionParticipations ?? this.votingSessionParticipations,
      votingSessionJuriesBundles: votingSessionJuriesBundles ?? this.votingSessionJuriesBundles,
    );
  }

  @override
  List<Object?> get props => [
        votingSessionBundle,
        votingSessionParticipations,
        votingSessionJuriesBundles,
      ];
}
