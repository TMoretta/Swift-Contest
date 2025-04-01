part of 'juror_home_page_bloc.dart';

@immutable
final class JurorHomePageState extends Equatable {
  final BlocStatus status;
  final String? message;
  final Juration? jurationJoin;

  const JurorHomePageState({
    required this.status,
    this.message,
    this.jurationJoin,
  });

  JurorHomePageState copyWith(
      {required BlocStatus status, String? message, Juration? jurationJoin}) {
    return JurorHomePageState(
      status: status,
      message: message,
      jurationJoin: jurationJoin ?? this.jurationJoin,
    );
  }

  @override
  List<Object?> get props => [status, message, jurationJoin];
}
