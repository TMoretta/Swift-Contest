import 'package:equatable/equatable.dart';
import 'package:swift_contest/model/database/entities/juration.dart';
import 'package:swift_contest/model/database/entities/participation.dart';

import 'contest_bundle.dart';

class HomeContestBundle extends Equatable {
  final ContestBundle contestBundle;
  final List<Participation> participations;
  final List<Juration> jurations;

  const HomeContestBundle({
    required this.contestBundle,
    required this.participations,
    required this.jurations,
  });

  factory HomeContestBundle.fromJson(Map<String, dynamic> json) {
    return HomeContestBundle(
      contestBundle: ContestBundle.fromJson(json['contest_bundle']),
      participations: (json['participations'] as List<dynamic>)
          .map((e) => Participation.fromJson(e))
          .toList(growable: false),
      jurations: (json['jurations'] as List<dynamic>)
          .map((e) => Juration.fromJson(e))
          .toList(growable: false),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'contest_bundle': contestBundle.toJson(),
      'participations': participations.map((e) => e.toJson()).toList(growable: false),
      'jurations': jurations.map((e) => e.toJson()).toList(growable: false),
    };
  }

  HomeContestBundle copyWith({
    ContestBundle? contestBundle,
    List<Participation>? participations,
    List<Juration>? jurations,
  }) {
    return HomeContestBundle(
      contestBundle: contestBundle ?? this.contestBundle,
      participations: participations ?? this.participations,
      jurations: jurations ?? this.jurations,
    );
  }

  @override
  List<Object?> get props => [contestBundle, participations, jurations];
}
