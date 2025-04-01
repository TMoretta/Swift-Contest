part of 'juror_joined_contests_bloc.dart';

sealed class JurorJoinedContestsEvent extends Equatable {
  const JurorJoinedContestsEvent();
}

final class JurorJoinedContestsGetJoinedContests extends JurorJoinedContestsEvent {
  final String jurorId;

  const JurorJoinedContestsGetJoinedContests({required this.jurorId});

  @override
  List<Object?> get props => [jurorId];
}

