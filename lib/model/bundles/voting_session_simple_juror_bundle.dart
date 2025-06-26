import 'package:equatable/equatable.dart';
import 'package:swift_contest/model/data_models/simple_juror.dart';
import 'package:swift_contest/model/data_models/voting_session_simple_juror.dart';

class VotingSessionSimpleJurorBundle extends Equatable {
  final VotingSessionSimpleJuror votingSessionSimpleJuror;
  final SimpleJuror simpleJuror;

  const VotingSessionSimpleJurorBundle({
    required this.votingSessionSimpleJuror,
    required this.simpleJuror,
  });

  factory VotingSessionSimpleJurorBundle.fromJson(Map<String, dynamic> json) {
    return VotingSessionSimpleJurorBundle(
      votingSessionSimpleJuror:
          VotingSessionSimpleJuror.fromJson(json['voting_session_simple_juror']),
      simpleJuror: SimpleJuror.fromJson(json['simple_juror']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'voting_session_simple_juror': votingSessionSimpleJuror.toJson(),
      'simple_juror': simpleJuror.toJson(),
    };
  }

  VotingSessionSimpleJurorBundle copyWith({
    VotingSessionSimpleJuror? votingSessionSimpleJuror,
    SimpleJuror? simpleJuror,
  }) {
    return VotingSessionSimpleJurorBundle(
      votingSessionSimpleJuror: votingSessionSimpleJuror ?? this.votingSessionSimpleJuror,
      simpleJuror: simpleJuror ?? this.simpleJuror,
    );
  }

  @override
  List<Object?> get props => [votingSessionSimpleJuror, simpleJuror];
}
