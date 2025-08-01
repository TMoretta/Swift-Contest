import 'package:equatable/equatable.dart';
import 'package:swift_contest/model/database/bundles/juration_bundle.dart';
import 'package:swift_contest/model/database/bundles/voting_form_bundle.dart';
import 'package:swift_contest/model/database/entities/juror_invitation.dart';
import 'package:swift_contest/model/database/entities/jury.dart';

class JuryBundle extends Equatable {
  final Jury jury;
  final List<JurationBundle> jurationsBundles;
  final List<JurorInvitation> jurorsInvitations;
  final VotingFormBundle votingFormBundle;

  const JuryBundle({
    required this.jury,
    required this.jurationsBundles,
    required this.jurorsInvitations,
    required this.votingFormBundle,
  });

  factory JuryBundle.fromJson(Map<String, dynamic> json) {
    return JuryBundle(
      jury: Jury.fromJson(json['jury']),
      jurationsBundles: (json['jurations_bundles'] as List<dynamic>).map((e) => JurationBundle.fromJson(e)).toList(growable: false),
      jurorsInvitations: (json['jurors_invitations'] as List<dynamic>).map((e) => JurorInvitation.fromJson(e)).toList(growable: false),
      votingFormBundle: VotingFormBundle.fromJson(json['voting_form_bundle']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'jury': jury.toJson(),
      'jurations_bundles': jurationsBundles.map((e) => e.toJson()).toList(growable: false),
      'jurors_invitations': jurorsInvitations.map((e) => e.toJson()).toList(growable: false),
      'voting_form_bundle': votingFormBundle.toJson(),
    };
  }

  JuryBundle copyWith({
    Jury? jury,
    List<JurationBundle>? jurationsBundles,
    List<JurorInvitation>? jurorsInvitations,
    VotingFormBundle? votingFormBundle,
  }) {
    return JuryBundle(
      jury: jury ?? this.jury,
      jurationsBundles: jurationsBundles ?? this.jurationsBundles,
        jurorsInvitations: jurorsInvitations ?? this.jurorsInvitations,
        votingFormBundle: votingFormBundle ?? this.votingFormBundle,
    );
  }

  @override
  List<Object?> get props => [jury, jurationsBundles, jurorsInvitations, votingFormBundle];
}
