part of 'organizer_created_contests_bloc.dart';

@immutable
final class OrganizerCreatedContestsState extends Equatable {
  final BlocStatus status;
  final String? message;
  final List<Contest>? contests;
  final List<Profile>? organizers;
  final List<List<Participation>>? participations;
  final List<List<Juration>>? jurations;

  const OrganizerCreatedContestsState({
    required this.status,
    this.message,
    this.contests,
    this.organizers,
    this.participations,
    this.jurations,
  });

  OrganizerCreatedContestsState copyWith({
    required BlocStatus status,
    String? message,
    List<Contest>? contests,
    List<Profile>? organizers,
    List<List<Participation>>? participations,
    List<List<Juration>>? jurations,
  }) {
    return OrganizerCreatedContestsState(
      status: status,
      message: message,
      contests: contests ?? this.contests,
      organizers: organizers ?? this.organizers,
      participations: participations ?? this.participations,
      jurations: jurations ?? this.jurations,
    );
  }

  @override
  List<Object?> get props => [status, message, contests, organizers, participations, jurations];
}
