import 'package:equatable/equatable.dart';
import 'package:swift_contest/model/database/bundles/voting_form_bundle.dart';
import 'package:swift_contest/model/database/bundles/voting_form_submission_bundle.dart';
import 'package:swift_contest/model/database/bundles/voting_session_bundle.dart';
import 'package:swift_contest/model/database/entities/voting_session_jury.dart';
import 'package:swift_contest/model/database/entities/voting_session_participant.dart';

class VotingSessionJurorResultBundle extends Equatable {
  final VotingSessionBundle votingSessionBundle;
  final VotingSessionJury votingSessionJury;
  final VotingFormBundle votingFormBundle;
  final List<VotingSessionParticipant> votingSessionParticipants;
  final List<String> excludedVotingSessionParticipantsIds;
  final VotingFormSubmissionBundle votingFormSubmissionBundle;

  const VotingSessionJurorResultBundle({
    required this.votingSessionBundle,
    required this.votingSessionJury,
    required this.votingFormBundle,
    required this.votingSessionParticipants,
    required this.excludedVotingSessionParticipantsIds,
    required this.votingFormSubmissionBundle,
  });

  factory VotingSessionJurorResultBundle.fromJson(Map<String, dynamic> json) {
    return VotingSessionJurorResultBundle(
      votingSessionBundle: VotingSessionBundle.fromJson(json['voting_session_bundle']),
      votingSessionJury: VotingSessionJury.fromJson(json['voting_session_jury']),
      votingFormBundle: VotingFormBundle.fromJson(json['voting_form_bundle']),
      votingSessionParticipants: (json['voting_session_participants'] as List<dynamic>)
          .map((e) => VotingSessionParticipant.fromJson(e))
          .toList(growable: false),
      excludedVotingSessionParticipantsIds: List<String>.from(json['excluded_voting_session_participants_ids']),
      votingFormSubmissionBundle:
          VotingFormSubmissionBundle.fromJson(json['voting_form_submission_bundle']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'voting_session_bundle': votingSessionBundle.toJson(),
      'voting_session_jury': votingSessionJury.toJson(),
      'voting_form_bundle': votingFormBundle.toJson(),
      'voting_session_participants':
          votingSessionParticipants.map((e) => e.toJson()).toList(growable: false),
      'excluded_voting_session_participants_ids': excludedVotingSessionParticipantsIds,
      'voting_form_submission_bundle': votingFormSubmissionBundle.toJson(),

    };
  }

  VotingSessionJurorResultBundle copyWith({
    VotingSessionBundle? votingSessionBundle,
    VotingSessionJury? votingSessionJury,
    VotingFormBundle? votingFormBundle,
    List<VotingSessionParticipant>? votingSessionParticipants,
    List<String>? excludedVotingSessionParticipantsIds,
    VotingFormSubmissionBundle? votingFormSubmissionBundle,
  }) {
    return VotingSessionJurorResultBundle(
      votingSessionBundle: votingSessionBundle ?? this.votingSessionBundle,
      votingSessionJury: votingSessionJury ?? this.votingSessionJury,
      votingFormBundle: votingFormBundle ?? this.votingFormBundle,
      votingSessionParticipants: votingSessionParticipants ?? this.votingSessionParticipants,
      excludedVotingSessionParticipantsIds:
          excludedVotingSessionParticipantsIds ?? this.excludedVotingSessionParticipantsIds,
      votingFormSubmissionBundle: votingFormSubmissionBundle ?? this.votingFormSubmissionBundle,
    );
  }

  @override
  List<Object?> get props => [
        votingSessionBundle,
        votingSessionJury,
        votingFormBundle,
        votingSessionParticipants,
        excludedVotingSessionParticipantsIds,
        votingFormSubmissionBundle,
      ];
}
