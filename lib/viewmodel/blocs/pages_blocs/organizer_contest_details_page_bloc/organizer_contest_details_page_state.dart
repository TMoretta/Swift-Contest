part of 'organizer_contest_details_page_bloc.dart';

@immutable
class OrganizerContestDetailsPageState extends Equatable {
  final BlocStatus status;
  final String? message;
  final Contest? contest;
  final Profile? organizer;
  final List<Participation>? participations;
  final List<Profile?>? participants;
  final List<Work?>? works;
  final List<Juration>? jurations;
  final List<Profile?>? jurors;
  final VotingForm? votingForm;

  const OrganizerContestDetailsPageState({
    required this.status,
    this.message,
    this.contest,
    this.organizer,
    this.participations,
    this.participants,
    this.works,
    this.jurations,
    this.jurors,
    this.votingForm,
  });

  OrganizerContestDetailsPageState copyWith({
    required BlocStatus status,
    String? message,
    Contest? contest,
    Profile? organizer,
    List<Participation>? participations,
    List<Profile?>? participants,
    List<Work?>? works,
    List<Juration>? jurations,
    List<Profile?>? jurors,
    VotingForm? votingForm,
  }) {
    return OrganizerContestDetailsPageState(
      status: status,
      message: message,
      contest: contest ?? this.contest,
      organizer: organizer ?? this.organizer,
      participations: participations ?? this.participations,
      participants: participants ?? this.participants,
      works: works ?? this.works,
      jurations: jurations ?? this.jurations,
      jurors: jurors ?? this.jurors,
      votingForm: votingForm ?? this.votingForm,
    );
  }

  @override
  List<Object?> get props => [
        status,
        message,
        contest,
        organizer,
        participations,
        participants,
        works,
        jurations,
        jurors,
        votingForm,
      ];
}
