part of 'juror_home_page_bloc.dart';

sealed class JurorHomePageEvent extends Equatable {
  const JurorHomePageEvent();
}

final class JurorHomePageJoinContest extends JurorHomePageEvent {
  final String jurorId;
  final String contestToken;
  final String jurorToken;

  const JurorHomePageJoinContest({
    required this.jurorId,
    required this.contestToken,
    required this.jurorToken,
  });

  @override
  List<Object?> get props => [jurorId, contestToken, jurorToken];
}
