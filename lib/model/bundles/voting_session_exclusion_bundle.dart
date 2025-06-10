import 'package:equatable/equatable.dart';
import 'package:swift_contest/model/data_models/voting_session_juration.dart';
import 'package:swift_contest/model/data_models/voting_session_participation.dart';

class VotingSessionExclusionBundle extends Equatable {
  final VotingSessionParticipation votingSessionParticipation;
  final VotingSessionJuration votingSessionJuration;

  const VotingSessionExclusionBundle({
    required this.votingSessionParticipation,
    required this.votingSessionJuration,
  });

  factory VotingSessionExclusionBundle.fromJson(Map<String, dynamic> json) {
    return VotingSessionExclusionBundle(
      votingSessionParticipation:
          VotingSessionParticipation.fromJson(json['voting_session_participation']),
      votingSessionJuration:
          VotingSessionJuration.fromJson(json['voting_session_juration']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'voting_session_participation': votingSessionParticipation.toJson(),
      'voting_session_juration': votingSessionJuration.toJson(),
    };
  }

  VotingSessionExclusionBundle copyWith({
    VotingSessionParticipation? votingSessionParticipation,
    VotingSessionJuration? votingSessionJuration,
  }) {
    return VotingSessionExclusionBundle(
      votingSessionParticipation:
          votingSessionParticipation ?? this.votingSessionParticipation,
      votingSessionJuration: votingSessionJuration ?? this.votingSessionJuration,
    );
  }

  @override
  List<Object?> get props => [votingSessionParticipation, votingSessionJuration];
}
