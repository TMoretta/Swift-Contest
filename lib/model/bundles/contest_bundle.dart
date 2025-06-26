import 'package:equatable/equatable.dart';
import 'package:swift_contest/model/bundles/juration_bundle.dart';
import 'package:swift_contest/model/bundles/participation_bundle.dart';
import 'package:swift_contest/model/bundles/voting_form_bundle.dart';
import 'package:swift_contest/model/data_models/contest.dart';
import 'package:swift_contest/model/data_models/invitation.dart';
import 'package:swift_contest/model/data_models/juration.dart';
import 'package:swift_contest/model/data_models/participation.dart';
import 'package:swift_contest/model/data_models/place.dart';
import 'package:swift_contest/model/data_models/profile.dart';
import 'package:swift_contest/model/data_models/voting_form.dart';
import 'package:swift_contest/model/data_models/voting_form_field.dart';
import 'package:swift_contest/model/data_models/voting_session.dart';
import 'package:swift_contest/model/data_models/work.dart';
import 'package:swift_contest/model/enums/juror_status.dart';
import 'package:swift_contest/model/enums/member_role.dart';
import 'package:swift_contest/model/enums/participant_status.dart';
import 'package:swift_contest/model/enums/voting_session_status.dart';

class ContestBundle extends Equatable {
  final Contest contest;
  final Organizer organizer;
  final Place place;

  const ContestBundle({
    required this.contest,
    required this.organizer,
    required this.place,
  });

  factory ContestBundle.fromJson(Map<String, dynamic> json) {
    return ContestBundle(
      contest: Contest.fromJson(json['contest']),
      organizer: Organizer.fromJson(json['organizer']),
      place: Place.fromJson(json['place']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'contest': contest.toJson(),
      'organizer': organizer.toJson(),
      'place': place.toJson(),
    };
  }

  ContestBundle copyWith({
    Contest? contest,
    Organizer? organizer,
    Place? place,
  }) {
    return ContestBundle(
      contest: contest ?? this.contest,
      organizer: organizer ?? this.organizer,
      place: place ?? this.place,
    );
  }

  @override
  List<Object?> get props => [
        contest,
        organizer,
        place,
      ];
}
