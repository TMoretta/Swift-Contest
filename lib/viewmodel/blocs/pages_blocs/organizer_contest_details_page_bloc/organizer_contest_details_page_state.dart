part of 'organizer_contest_details_page_bloc.dart';

@immutable
class OrganizerContestDetailsPageState extends Equatable {
  final BlocStatus status;
  final String? message;
  final Contest? contest;
  final Organizer? organizer;
  final List<Invitation>? participantsInvitations;
  final List<Invitation>? jurorsInvitations;
  final List<Participation>? participations;
  final List<Participant?>? participants;
  final List<Work?>? works;
  final List<Juration>? jurations;
  final List<Juror?>? jurors;
  final VotingForm? votingForm;
  final List<VotingFormField>? votingFormFields;
  final Place? place;
  final VotingSession? votingSessionLive;
  final List<VotingSession>? endedVotingSessions;

  const OrganizerContestDetailsPageState({
    required this.status,
    this.message,
    this.contest,
    this.organizer,
    this.participantsInvitations,
    this.jurorsInvitations,
    this.participations,
    this.participants,
    this.works,
    this.jurations,
    this.jurors,
    this.votingForm,
    this.votingFormFields,
    this.place,
    this.votingSessionLive,
    this.endedVotingSessions,
  });

  OrganizerContestDetailsPageState copyWith({
    required BlocStatus status,
    String? message,
    Contest? contest,
    Organizer? organizer,
    List<Invitation>? participantsInvitations,
    List<Invitation>? jurorsInvitations,
    List<Participation>? participations,
    List<Participant?>? participants,
    List<Work?>? works,
    List<Juration>? jurations,
    List<Juror?>? jurors,
    VotingForm? votingForm,
    List<VotingFormField>? votingFormFields,
    Place? place,
    VotingSession? votingSessionLive,
    List<VotingSession>? endedVotingSessions,
  }) {
    return OrganizerContestDetailsPageState(
      status: status,
      message: message,
      contest: contest ?? this.contest,
      organizer: organizer ?? this.organizer,
      participantsInvitations:
          participantsInvitations ?? this.participantsInvitations,
      jurorsInvitations: jurorsInvitations ?? this.jurorsInvitations,
      participations: participations ?? this.participations,
      participants: participants ?? this.participants,
      works: works ?? this.works,
      jurations: jurations ?? this.jurations,
      jurors: jurors ?? this.jurors,
      votingForm: votingForm ?? this.votingForm,
      votingFormFields: votingFormFields ?? this.votingFormFields,
      place: place ?? this.place,
      votingSessionLive: votingSessionLive ?? this.votingSessionLive,
      endedVotingSessions: endedVotingSessions ?? this.endedVotingSessions,
    );
  }

  @override
  List<Object?> get props => [
        status,
        message,
        contest,
        organizer,
        participantsInvitations,
        jurorsInvitations,
        participations,
        participants,
        works,
        jurations,
        jurors,
        votingForm,
        votingFormFields,
        place,
        votingSessionLive,
        endedVotingSessions,
      ];
}
