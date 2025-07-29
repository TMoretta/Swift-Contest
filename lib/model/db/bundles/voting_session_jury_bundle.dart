import 'package:equatable/equatable.dart';
import 'package:swift_contest/model/db/bundles/voting_form_bundle.dart';
import 'package:swift_contest/model/db/entities/jury.dart';
import 'package:swift_contest/model/db/entities/voting_session_juration.dart';
import 'package:swift_contest/model/db/entities/voting_session_jury.dart';

class VotingSessionJuryBundle extends Equatable {
  final VotingSessionJury votingSessionJury;
  final VotingFormBundle votingFormBundle;
  final List<VotingSessionJuration> votingSessionJurations;

  const VotingSessionJuryBundle({
    required this.votingSessionJury,
    required this.votingFormBundle,
    required this.votingSessionJurations,
  });

  factory VotingSessionJuryBundle.fromJson(Map<String, dynamic> json) {
    return VotingSessionJuryBundle(
      votingSessionJury: VotingSessionJury.fromJson(json['voting_session_jury']),
      votingFormBundle: VotingFormBundle.fromJson(json['voting_form_bundle']),
      votingSessionJurations: (json['voting_session_jurations'] as List<dynamic>)
          .map((e) => VotingSessionJuration.fromJson(e))
          .toList(growable: false),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'voting_session_jury': votingSessionJury.toJson(),
      'voting_form_bundle': votingFormBundle.toJson(),
      'voting_session_jurations':
          votingSessionJurations.map((e) => e.toJson()).toList(growable: false),
    };
  }

  VotingSessionJuryBundle copyWith({
    VotingSessionJury? votingSessionJury,
    VotingFormBundle? votingFormBundle,
    List<VotingSessionJuration>? votingSessionJurations,
  }) {
    return VotingSessionJuryBundle(
      votingSessionJury: votingSessionJury ?? this.votingSessionJury,
      votingFormBundle: votingFormBundle ?? this.votingFormBundle,
      votingSessionJurations: votingSessionJurations ?? this.votingSessionJurations,
    );
  }

  @override
  List<Object?> get props => [
        votingSessionJury,
        votingFormBundle,
        votingSessionJurations,
      ];
}
