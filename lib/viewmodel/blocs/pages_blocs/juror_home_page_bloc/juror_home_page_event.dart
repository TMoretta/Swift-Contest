part of 'juror_home_page_bloc.dart';

sealed class JurorHomePageEvent extends Equatable {
  const JurorHomePageEvent();
}

final class JurorHomePageInit extends JurorHomePageEvent {
  final String jurorId;

  const JurorHomePageInit({required this.jurorId});

  @override
  List<Object?> get props => [jurorId];
}

final class JurorHomePageRefresh extends JurorHomePageEvent {
  final String jurorId;

  const JurorHomePageRefresh({required this.jurorId});

  @override
  List<Object?> get props => [jurorId];
}

final class JurorHomePageJoinContest extends JurorHomePageEvent {
  final String jurorId;
  final String token;

  const JurorHomePageJoinContest({
    required this.jurorId,
    required this.token,
  });

  @override
  List<Object?> get props => [jurorId, token];
}

final class JurorHomePageVoteAsAuthenticatedSimpleJuror extends JurorHomePageEvent {
  final String fullName;
  final String token;
  final String? jurorId;

  const JurorHomePageVoteAsAuthenticatedSimpleJuror({
    required this.fullName,
    required this.token,
     this.jurorId,
  });

  @override
  List<Object?> get props => [fullName, token, jurorId];
}
