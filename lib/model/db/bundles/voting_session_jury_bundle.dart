import 'package:equatable/equatable.dart';
import 'package:swift_contest/model/db/entities/voting_session_juration.dart';
import 'package:swift_contest/model/db/entities/voting_session_jury.dart';

class VotingSessionJuryBundle extends Equatable {
  final VotingSessionJury votingSessionJury;
  final List<VotingSessionJuration> votingSessionJurations;

  const VotingSessionJuryBundle({
    required this.votingSessionJury,
    required this.votingSessionJurations,
  });

  factory VotingSessionJuryBundle.fromJson(Map<String, dynamic> json) {
    return VotingSessionJuryBundle(
      votingSessionJury: VotingSessionJury.fromJson(json['voting_session_jury']),
      votingSessionJurations: (json['voting_session_jurations'] as List<dynamic>)
          .map((e) => VotingSessionJuration.fromJson(e))
          .toList(growable: false),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'voting_session_jury': votingSessionJury.toJson(),
      'voting_session_jurations':
          votingSessionJurations.map((e) => e.toJson()).toList(growable: false),
    };
  }

  VotingSessionJuryBundle copyWith({
    VotingSessionJury? votingSessionJury,
    List<VotingSessionJuration>? votingSessionJurations,
  }) {
    return VotingSessionJuryBundle(
      votingSessionJury: votingSessionJury ?? this.votingSessionJury,
      votingSessionJurations: votingSessionJurations ?? this.votingSessionJurations,
    );
  }

  @override
  List<Object?> get props => [
        votingSessionJury,
        votingSessionJurations,
      ];
}
