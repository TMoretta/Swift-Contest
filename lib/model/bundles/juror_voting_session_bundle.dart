import 'package:equatable/equatable.dart';
import 'package:swift_contest/model/bundles/voting_form_bundle.dart';
import 'package:swift_contest/model/bundles/voting_session_participation_bundle.dart';
import 'package:swift_contest/model/data_models/voting_session.dart';
import 'package:swift_contest/model/data_models/voting_session_participation.dart';
import 'package:swift_contest/model/data_models/voting_session_procedure.dart';

class JurorVotingSessionBundle extends Equatable {
  final VotingSession votingSession;
  final VotingFormBundle votingFormBundle;
  final List<VotingSessionParticipationBundle> votingSessionParticipationsBundles;
  final List<VotingSessionParticipation> votingSessionParticipationsExcludedFrom;

  const JurorVotingSessionBundle({
    required this.votingSession,
    required this.votingFormBundle,
    required this.votingSessionParticipationsBundles,
    required this.votingSessionParticipationsExcludedFrom,
  });

  factory JurorVotingSessionBundle.fromJson(Map<String, dynamic> json) {
    return JurorVotingSessionBundle(
      votingSession: VotingSession.fromJson(json['voting_session']),
      votingFormBundle: VotingFormBundle.fromJson(json['voting_form_bundle']),
      votingSessionParticipationsBundles: (json['voting_session_participations_bundles'] as List<dynamic>)
          .map((e) => VotingSessionParticipationBundle.fromJson(e))
          .toList(growable: false),
      votingSessionParticipationsExcludedFrom: (json['voting_session_participations_excluded_from'] as List<dynamic>)
          .map((e) => VotingSessionParticipation.fromJson(e))
          .toList(growable: false),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'voting_session': votingSession.toJson(),
      'voting_form_bundle': votingFormBundle.toJson(),
      'voting_session_participations_bundles':
      votingSessionParticipationsBundles.map((e) => e.toJson()).toList(),
      'voting_session_participations_excluded_from':
      votingSessionParticipationsExcludedFrom.map((e) => e.toJson()).toList(),
    };
  }

  JurorVotingSessionBundle copyWith({
    VotingSession? votingSession,
    VotingFormBundle? votingFormBundle,
    List<VotingSessionParticipationBundle>? votingSessionParticipationsBundles,
    List<VotingSessionParticipation>? votingSessionParticipationsExcludedFrom,
  }) {
    return JurorVotingSessionBundle(
      votingSession: votingSession ?? this.votingSession,
      votingFormBundle: votingFormBundle ?? this.votingFormBundle,
      votingSessionParticipationsBundles:
      votingSessionParticipationsBundles ?? this.votingSessionParticipationsBundles,
      votingSessionParticipationsExcludedFrom:
      votingSessionParticipationsExcludedFrom ?? this.votingSessionParticipationsExcludedFrom,

    );
  }

  @override
  List<Object?> get props => [
    votingSession,
    votingFormBundle,
    votingSessionParticipationsBundles,
    votingSessionParticipationsExcludedFrom,
  ];
}
