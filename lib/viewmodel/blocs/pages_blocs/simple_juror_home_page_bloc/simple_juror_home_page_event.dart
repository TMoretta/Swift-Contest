part of 'simple_juror_home_page_bloc.dart';

sealed class SimpleJurorHomePageEvent extends Equatable {
  const SimpleJurorHomePageEvent();
}

final class SimpleJurorHomePageAccessVoting extends SimpleJurorHomePageEvent {
  final String token;

  const SimpleJurorHomePageAccessVoting({required this.token});

  @override
  List<Object?> get props => [token];
}

final class SimpleJurorHomePageSignOut extends SimpleJurorHomePageEvent {
  @override
  List<Object?> get props => [];
}
