import 'package:equatable/equatable.dart';
import 'package:swift_contest/model/database/bundles/voting_form_submission_value_bundle.dart';
import 'package:swift_contest/model/database/entities/voting_form_submission.dart';
import 'package:swift_contest/model/database/entities/voting_session_juror.dart';
import 'package:swift_contest/model/database/entities/voting_session_participant.dart';
import 'package:swift_contest/model/database/types/voting_form_field_scope.dart';

class VotingFormSubmissionBundle extends Equatable {
  final VotingFormSubmission votingFormSubmission;
  final VotingSessionJuror votingSessionJuror;
  final List<VotingFormSubmissionValueBundle> votingFormSubmissionValuesBundles;

  //poi altri attributi che vengono ottenuti nel client mappando
  final List<VotingFormSubmissionValueBundle> headerVotingFormSubmissionValuesBundles;
  final Map<VotingSessionParticipant, List<VotingFormSubmissionValueBundle>>
      participantVotingFormSubmissionValuesBundles;
  final List<VotingFormSubmissionValueBundle> footerVotingFormSubmissionValuesBundles;

  const VotingFormSubmissionBundle({
    required this.votingFormSubmission,
    required this.votingSessionJuror,
    required this.votingFormSubmissionValuesBundles,
    required this.headerVotingFormSubmissionValuesBundles,
    required this.participantVotingFormSubmissionValuesBundles,
    required this.footerVotingFormSubmissionValuesBundles,
  });

  factory VotingFormSubmissionBundle.fromJson(Map<String, dynamic> json) {
    final List<VotingFormSubmissionValueBundle> allValues =
        (json['voting_form_submission_values_bundles'] as List<dynamic>)
            .map((e) => VotingFormSubmissionValueBundle.fromJson(e))
            .toList(growable: false);

    final List<VotingFormSubmissionValueBundle> headerValues = allValues
        .where((element) => element.votingFormField.scope.isHeader)
        .toList(growable: false);

    headerValues
        .sort((a, b) => a.votingFormField.orderIndex.compareTo(b.votingFormField.orderIndex));

    final Map<VotingSessionParticipant, List<VotingFormSubmissionValueBundle>> participantValues = {};
    allValues
        .where((element) => element.votingFormField.scope.isParticipant)
        .forEach((element) {
      if (element.votingSessionParticipant != null) {
        if (!participantValues.containsKey(element.votingSessionParticipant!)) {
          participantValues[element.votingSessionParticipant!] = [];
        }
        participantValues[element.votingSessionParticipant!]!.add(element);
      }
    });

    participantValues.forEach((key, value) {
      value.sort((a, b) => a.votingFormField.orderIndex.compareTo(b.votingFormField.orderIndex));
    });


    final List<VotingFormSubmissionValueBundle> footerValues = allValues
        .where((element) => element.votingFormField.scope.isFooter)
        .toList(growable: false);

    footerValues
        .sort((a, b) => a.votingFormField.orderIndex.compareTo(b.votingFormField.orderIndex));

    return VotingFormSubmissionBundle(
      votingFormSubmission: VotingFormSubmission.fromJson(json['voting_form_submission']),
      votingSessionJuror: VotingSessionJuror.fromJson(json['voting_session_juror']),
      votingFormSubmissionValuesBundles: allValues,
      headerVotingFormSubmissionValuesBundles: headerValues,
      participantVotingFormSubmissionValuesBundles: participantValues,
      footerVotingFormSubmissionValuesBundles: footerValues,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'voting_form_submission': votingFormSubmission.toJson(),
      'voting_session_juror': votingSessionJuror.toJson(),
      'voting_form_submission_values_bundles':
          votingFormSubmissionValuesBundles.map((e) => e.toJson()).toList(growable: false),
    };
  }

  VotingFormSubmissionBundle copyWith({
    VotingFormSubmission? votingFormSubmission,
    VotingSessionJuror? votingSessionJuror,
    List<VotingFormSubmissionValueBundle>? votingFormSubmissionValuesBundles,
    List<VotingFormSubmissionValueBundle>? headerVotingFormSubmissionValuesBundles,
    Map<VotingSessionParticipant, List<VotingFormSubmissionValueBundle>>?
        participantVotingFormSubmissionValuesBundles,
    List<VotingFormSubmissionValueBundle>? footerVotingFormSubmissionValuesBundles,
  }) {
    return VotingFormSubmissionBundle(
      votingFormSubmission: votingFormSubmission ?? this.votingFormSubmission,
      votingSessionJuror: votingSessionJuror ?? this.votingSessionJuror,
      votingFormSubmissionValuesBundles:
          votingFormSubmissionValuesBundles ?? this.votingFormSubmissionValuesBundles,
      headerVotingFormSubmissionValuesBundles:
          headerVotingFormSubmissionValuesBundles ?? this.headerVotingFormSubmissionValuesBundles,
      participantVotingFormSubmissionValuesBundles:
          participantVotingFormSubmissionValuesBundles ?? this.participantVotingFormSubmissionValuesBundles,
      footerVotingFormSubmissionValuesBundles:
          footerVotingFormSubmissionValuesBundles ?? this.footerVotingFormSubmissionValuesBundles,
    );
  }

  @override
  List<Object?> get props => [
        votingFormSubmission,
        votingSessionJuror,
        votingFormSubmissionValuesBundles,
        headerVotingFormSubmissionValuesBundles,
        participantVotingFormSubmissionValuesBundles,
        footerVotingFormSubmissionValuesBundles,
      ];
}
