import 'package:equatable/equatable.dart';
import 'package:swift_contest/model/data_models/simple_juror.dart';
import 'package:swift_contest/model/data_models/voting_session.dart';

class SimpleJurorAndVotingSessionBundle extends Equatable {
  final SimpleJuror simpleJuror;
  final VotingSession votingSession;

  const SimpleJurorAndVotingSessionBundle({required this.simpleJuror, required this.votingSession});

  factory SimpleJurorAndVotingSessionBundle.fromJson(Map<String, dynamic> json) {
    return SimpleJurorAndVotingSessionBundle(
      simpleJuror: SimpleJuror.fromJson(json['simple_juror']),
      votingSession: VotingSession.fromJson(json['voting_session']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'simple_juror': simpleJuror.toJson(),
      'voting_session': votingSession.toJson(),
    };
  }

  @override
  List<Object?> get props => [simpleJuror, votingSession];
}
