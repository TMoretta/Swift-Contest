part of 'participant_home_page_bloc.dart';

@immutable
final class ParticipantHomePageState extends Equatable {
  final BlocStatus status;
  final String? message;
  // final List<Contest>? contests;
  // final List<Profile>? organizers;
  // final List<List<Participation>>? participations;
  // final List<List<Juration>>? jurations;
  final Participation? participationJoin;

  const ParticipantHomePageState({
    required this.status,
    this.message,
    // this.contests,
    // this.organizers,
    // this.participations,
    // this.jurations,
    this.participationJoin,
  });

  ParticipantHomePageState copyWith({
    required BlocStatus status,
    String? message,
    List<Contest>? contests,
    List<Profile>? organizers,
    List<List<Participation>>? participations,
    List<List<Juration>>? jurations,
    Participation? participationJoin,
  }) {
    return ParticipantHomePageState(
      status: status,
      message: message,
      // contests: contests ?? this.contests,
      // organizers: organizers ?? this.organizers,
      // participations: participations ?? this.participations,
      // jurations: jurations ?? this.jurations,
      participationJoin: participationJoin ?? this.participationJoin,
    );
  }

  @override
  List<Object?> get props => [status,message,participationJoin];
}

