part of 'participant_home_page_bloc.dart';

@immutable
sealed class ParticipantHomePageState {}

final class ParticipantHomePageInitial extends ParticipantHomePageState {}

final class ParticipantHomePageLoading extends ParticipantHomePageState {}

final class ParticipantHomePageSuccess extends ParticipantHomePageState {
  final List<Contest>? contests;
  final List<Profile>? organizers;
  final List<List<Participation>>? participations;
  final List<List<Juration>>? jurations;
  final Participation? participation;

  ParticipantHomePageSuccess({
    this.contests,
    this.organizers,
    this.participations,
    this.jurations,
    this.participation,
  });
}

final class ParticipantHomePageFailure extends ParticipantHomePageState {
  final String message;

  ParticipantHomePageFailure({required this.message});
}
