import 'package:equatable/equatable.dart';
import 'package:swift_contest/model/database/bundles/contest_bundle.dart';

class HomeContestBundle extends Equatable {
  final ContestBundle contestBundle;
  final int participantsNumber;
  final int jurorsNumber;

  const HomeContestBundle({
    required this.contestBundle,
    required this.participantsNumber,
    required this.jurorsNumber,
  });

  factory HomeContestBundle.fromJson(Map<String, dynamic> json) {
    return HomeContestBundle(
      contestBundle: ContestBundle.fromJson(json['contest_bundle']),
      participantsNumber: json['participants_number'] as int,
      jurorsNumber: json['jurors_number'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'contest_bundle': contestBundle.toJson(),
      'participants_number': participantsNumber,
      'jurors_number': jurorsNumber,
    };
  }

  HomeContestBundle copyWith({
    ContestBundle? contestBundle,
    int? participantsNumber,
    int? jurorsNumber,
  }) {
    return HomeContestBundle(
      contestBundle: contestBundle ?? this.contestBundle,
      participantsNumber: participantsNumber ?? this.participantsNumber,
      jurorsNumber: jurorsNumber ?? this.jurorsNumber,
    );
  }

  @override
  List<Object?> get props =>
      [
        contestBundle,
        participantsNumber,
        jurorsNumber,
      ];
}
