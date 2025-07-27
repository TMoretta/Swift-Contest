import 'package:equatable/equatable.dart';
import 'package:swift_contest/model/db/entities/contest.dart';
import 'package:swift_contest/model/db/entities/place.dart';
import 'package:swift_contest/model/db/entities/profile.dart';

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
