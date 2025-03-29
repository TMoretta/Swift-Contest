import 'package:swift_contest/model/data_models/contest/contest.dart';
import 'package:swift_contest/model/data_models/profile/profile.dart';

final class ContestAndOrganizer {
  final Contest contest;
  final Profile organizer;

  ContestAndOrganizer({required this.contest, required this.organizer});

  factory ContestAndOrganizer.fromJson(Map<String, dynamic> map) {
    return ContestAndOrganizer(
      contest: Contest.fromJson(map['contest']),
      organizer: Profile.fromJson(map['organizer']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'contest': contest.toJson(),
      'organizer': organizer.toJson(),
    };
  }
}
