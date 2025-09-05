import 'package:equatable/equatable.dart';
import 'package:swift_contest/model/database/bundles/voting_session_bundle.dart';
import 'package:swift_contest/model/database/entities/voting_session_juror.dart';
import 'package:swift_contest/model/database/entities/voting_session_jury.dart';
import 'package:swift_contest/model/database/entities/voting_session_participant.dart';

import 'voting_form_bundle.dart';

class JurorVotingSessionProcedureBundle extends Equatable {
  final VotingSessionBundle votingSessionBundle;
  final List<VotingSessionParticipant> votingSessionParticipants;
  final VotingSessionJury votingSessionJury;
  final VotingFormBundle votingFormBundle;
  final VotingSessionJuror votingSessionJuror;
  final List<String> votingSessionParticipantsExclusionsIds;

  const JurorVotingSessionProcedureBundle({
    required this.votingSessionBundle,
    required this.votingSessionParticipants,
    required this.votingSessionJury,
    required this.votingSessionJuror,
    required this.votingFormBundle,
    required this.votingSessionParticipantsExclusionsIds,
  });

  factory JurorVotingSessionProcedureBundle.fromJson(Map<String, dynamic> json) {
    return JurorVotingSessionProcedureBundle(
      votingSessionBundle: VotingSessionBundle.fromJson(json['voting_session_bundle']),
      votingSessionParticipants: (json['voting_session_participants'] as List<dynamic>)
          .map((e) => VotingSessionParticipant.fromJson(e))
          .toList(growable: false),
      votingSessionJury: VotingSessionJury.fromJson(json['voting_session_jury']),
      votingFormBundle: VotingFormBundle.fromJson(json['voting_form_bundle']),
      votingSessionJuror: VotingSessionJuror.fromJson(json['voting_session_juror']),
      votingSessionParticipantsExclusionsIds:
      List<String>.from(json['voting_session_participants_exclusions_ids']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'voting_session_bundle': votingSessionBundle.toJson(),
      'voting_session_participants':
      votingSessionParticipants.map((e) => e.toJson()).toList(growable: false),
      'voting_session_jury': votingSessionJury.toJson(),
      'voting_form_bundle': votingFormBundle.toJson(),
      'voting_session_juror': votingSessionJuror.toJson(),
      'voting_session_participants_exclusions_ids': votingSessionParticipantsExclusionsIds,
    };
  }

  JurorVotingSessionProcedureBundle copyWith({
    VotingSessionBundle? votingSessionBundle,
    List<VotingSessionParticipant>? votingSessionParticipants,
    VotingSessionJury? votingSessionJury,
    VotingFormBundle? votingFormBundle,
    VotingSessionJuror? votingSessionJuror,
    List<String>? votingSessionParticipantsExclusionsIds,
  }) {
    return JurorVotingSessionProcedureBundle(
      votingSessionBundle: votingSessionBundle ?? this.votingSessionBundle,
      votingSessionParticipants: votingSessionParticipants ?? this.votingSessionParticipants,
      votingSessionJury: votingSessionJury ?? this.votingSessionJury,
      votingFormBundle: votingFormBundle ?? this.votingFormBundle,
      votingSessionJuror: votingSessionJuror ?? this.votingSessionJuror,
      votingSessionParticipantsExclusionsIds:
          votingSessionParticipantsExclusionsIds ?? this.votingSessionParticipantsExclusionsIds,
    );
  }

  @override
  List<Object?> get props => [
    votingSessionBundle,
    votingSessionParticipants,
    votingSessionJury,
    votingFormBundle,
    votingSessionJuror,
    votingSessionParticipantsExclusionsIds,
  ];
}
