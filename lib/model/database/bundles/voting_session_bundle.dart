import 'package:equatable/equatable.dart';
import 'package:swift_contest/model/database/entities/place.dart';
import 'package:swift_contest/model/database/entities/voting_session.dart';

class VotingSessionBundle extends Equatable {
  final VotingSession votingSession;
  final Place? geoResPlace;

  const VotingSessionBundle({
    required this.votingSession,
    this.geoResPlace,
  });

  factory VotingSessionBundle.fromJson(Map<String, dynamic> json) {
    return VotingSessionBundle(
      votingSession: VotingSession.fromJson(json['voting_session']),
      geoResPlace: (json['geo_res_place'] != null) ? Place.fromJson(json['geo_res_place']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'voting_session': votingSession.toJson(),
      'geo_res_place': geoResPlace?.toJson(),
    };
  }

  VotingSessionBundle copyWith({
    VotingSession? votingSession,
    Place? geoResPlace,
  }) {
    return VotingSessionBundle(
      votingSession: votingSession ?? this.votingSession,
      geoResPlace: geoResPlace ?? this.geoResPlace,
    );
  }

  @override
  List<Object?> get props => [votingSession, geoResPlace];
}
