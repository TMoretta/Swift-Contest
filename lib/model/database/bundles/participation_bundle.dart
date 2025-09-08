import 'package:equatable/equatable.dart';
import 'package:swift_contest/model/database/bundles/account_bundle.dart';
import 'package:swift_contest/model/database/entities/participation.dart';
import 'package:swift_contest/model/database/entities/work.dart';

final class ParticipationBundle extends Equatable {
  final Participation participation;
  final AccountBundle participantBundle;
  final Work? work;

  const ParticipationBundle({
    required this.participation,
    required this.participantBundle,
    this.work,
  });

  factory ParticipationBundle.fromJson(Map<String, dynamic> json) {
    return ParticipationBundle(
      participation: Participation.fromJson(json['participation']),
      participantBundle: AccountBundle.fromJson(json['participant_bundle']),
      work: json['work'] != null ? Work.fromJson(json['work']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'participation': participation.toJson(),
      'participant_bundle': participantBundle.toJson(),
      'work': work?.toJson(),
    };
  }

  ParticipationBundle copyWith({
    Participation? participation,
    AccountBundle? participantBundle,
    Work? work,
  }) {
    return ParticipationBundle(
      participation: participation ?? this.participation,
      participantBundle: participantBundle ?? this.participantBundle,
      work: work ?? this.work,
    );
  }

  @override
  List<Object?> get props => [participation, participantBundle, work];
}
