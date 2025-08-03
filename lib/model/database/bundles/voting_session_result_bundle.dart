import 'package:equatable/equatable.dart';
import 'package:swift_contest/model/database/bundles/voting_session_bundle.dart';
import 'package:swift_contest/model/database/bundles/voting_session_jury_bundle.dart';

class VotingSessionResultBundle extends Equatable {
  final VotingSessionBundle votingSessionBundle;
  final List<VotingSessionJuryBundle> votingSessionJuriesBundles;

  const VotingSessionResultBundle({
    required this.votingSessionBundle,
    required this.votingSessionJuriesBundles,
  });

  factory VotingSessionResultBundle.fromJson(Map<String, dynamic> json) {
    return VotingSessionResultBundle(
      votingSessionBundle: VotingSessionBundle.fromJson(json['voting_session_bundle']),
      votingSessionJuriesBundles: (json['voting_session_juries_bundles'] as List<dynamic>)
          .map((e) => VotingSessionJuryBundle.fromJson(e))
          .toList(growable: false),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'voting_session_bundle': votingSessionBundle.toJson(),
      'voting_session_juries_bundles':
          votingSessionJuriesBundles.map((e) => e.toJson()).toList(growable: false),
    };
  }

  @override
  List<Object?> get props => [
    votingSessionBundle,
    votingSessionJuriesBundles,
  ];
}