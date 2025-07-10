part of 'juror_home_page_bloc.dart';

sealed class JurorHomePageEvent extends Equatable {
  const JurorHomePageEvent();
}

final class JurorHomePageInit extends JurorHomePageEvent {
  @override
  List<Object?> get props => [];
}

final class JurorHomePageRefresh extends JurorHomePageEvent {
  @override
  List<Object?> get props => [];
}

final class JurorHomePageFilterResults extends JurorHomePageEvent {
  final List<HomeContestBundle> contestsBundles;
  final String query;

  const JurorHomePageFilterResults({
    required this.contestsBundles,
    required this.query,
  });

  @override
  List<Object?> get props => [contestsBundles, query];
}

final class JurorHomePageJoinContest extends JurorHomePageEvent {
  final String token;

  const JurorHomePageJoinContest({
    required this.token,
  });

  @override
  List<Object?> get props => [token];
}

final class JurorHomePageVoteAsSimpleJuror extends JurorHomePageEvent {
  final String fullName;
  final String token;

  const JurorHomePageVoteAsSimpleJuror({
    required this.fullName,
    required this.token,
  });

  @override
  List<Object?> get props => [fullName, token];
}
