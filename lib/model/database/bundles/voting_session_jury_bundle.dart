import 'package:equatable/equatable.dart';
import 'package:swift_contest/model/database/bundles/voting_form_bundle.dart';
import 'package:swift_contest/model/database/entities/voting_session_juror.dart';
import 'package:swift_contest/model/database/entities/voting_session_jury.dart';

class VotingSessionJuryBundle extends Equatable {
  final VotingSessionJury votingSessionJury;
  final VotingFormBundle votingFormBundle;
  final List<VotingSessionJuror> votingSessionJurors;

  const VotingSessionJuryBundle({
    required this.votingSessionJury,
    required this.votingFormBundle,
    required this.votingSessionJurors,
  });

  factory VotingSessionJuryBundle.fromJson(Map<String, dynamic> json) {
    return VotingSessionJuryBundle(
      votingSessionJury: VotingSessionJury.fromJson(json['voting_session_jury']),
      votingFormBundle: VotingFormBundle.fromJson(json['voting_form_bundle']),
      votingSessionJurors: (json['voting_session_jurors'] as List<dynamic>)
          .map((e) => VotingSessionJuror.fromJson(e))
          .toList(growable: false),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'voting_session_jury': votingSessionJury.toJson(),
      'voting_form_bundle': votingFormBundle.toJson(),
      'voting_session_jurors':
          votingSessionJurors.map((e) => e.toJson()).toList(growable: false),
    };
  }

  VotingSessionJuryBundle copyWith({
    VotingSessionJury? votingSessionJury,
    VotingFormBundle? votingFormBundle,
    List<VotingSessionJuror>? votingSessionJurors,
  }) {
    return VotingSessionJuryBundle(
      votingSessionJury: votingSessionJury ?? this.votingSessionJury,
      votingFormBundle: votingFormBundle ?? this.votingFormBundle,
      votingSessionJurors: votingSessionJurors ?? this.votingSessionJurors,
    );
  }

  @override
  List<Object?> get props => [
        votingSessionJury,
        votingFormBundle,
        votingSessionJurors,
      ];
}
