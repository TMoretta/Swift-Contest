part of 'juror_home_page_bloc.dart';

@immutable
class JurorHomePageState {
  final BlocStatus status;
  final String? message;
  final List<Contest>? contests;
  final List<Profile>? organizers;
  final List<List<Participation>>? participations;
  final List<List<Juration>>? jurations;
  final Juration? jurationInvite;

  const JurorHomePageState({
    required this.status,
    this.message,
    this.contests,
    this.organizers,
    this.participations,
    this.jurations,
    this.jurationInvite,
  });

  JurorHomePageState copyWith({
    required BlocStatus status,
    String? message,
    List<Contest>? contests,
    List<Profile>? organizers,
    List<List<Participation>>? participations,
    List<List<Juration>>? jurations,
    Juration? jurationInvite,
  }) {
    return JurorHomePageState(
      status: status,
      message: message,
      contests: contests ?? this.contests,
      organizers: organizers ?? this.organizers,
      participations: participations ?? this.participations,
      jurations: jurations ?? this.jurations,
      jurationInvite: jurationInvite ?? this.jurationInvite,
    );
  }
}
