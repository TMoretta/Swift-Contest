import 'package:equatable/equatable.dart';
import 'package:swift_contest/model/bundles/participation_bundle.dart';
import 'package:swift_contest/model/data_models/voting_session_participation.dart';

class VotingSessionParticipationBundle extends Equatable {
  final VotingSessionParticipation votingSessionParticipation;
  final ParticipationBundle participationBundle;

  const VotingSessionParticipationBundle({
    required this.votingSessionParticipation,
    required this.participationBundle,
  });

  factory VotingSessionParticipationBundle.fromJson(Map<String, dynamic> json) {
    return VotingSessionParticipationBundle(
      votingSessionParticipation:
          VotingSessionParticipation.fromJson(json['voting_session_participation']),
      participationBundle: ParticipationBundle.fromJson(json['participation_bundle']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'voting_session_participation': votingSessionParticipation.toJson(),
      'participation_bundle': participationBundle.toJson(),
    };
  }

  @override
  List<Object?> get props => [votingSessionParticipation, participationBundle];
}
