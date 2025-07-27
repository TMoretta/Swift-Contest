// part of 'juror_voting_procedure_page_bloc.dart';
//
// sealed class JurorVotingProcedurePageEvent extends Equatable {
//   const JurorVotingProcedurePageEvent();
// }
//
// final class JurorVotingProcedurePageFetch
//     extends JurorVotingProcedurePageEvent {
//   final String votingSessionId;
//
//   const JurorVotingProcedurePageFetch({
//     required this.votingSessionId,
//   });
//
//   @override
//   List<Object?> get props => [votingSessionId];
// }
//
// final class JurorVotingProcedurePageSubmitVotes extends JurorVotingProcedurePageEvent {
//   final VotingSession votingSession;
//   final Place? geoResPlace;
//   final Map<VotingSessionParticipation, Map<VotingFormField, double>> votesPerParticipantMap;
//
//   const JurorVotingProcedurePageSubmitVotes({
//     required this.votingSession,
//     this.geoResPlace,
//     required this.votesPerParticipantMap,
//   });
//
//   @override
//   List<Object?> get props => [
//         votingSession,
//         geoResPlace,
//         votesPerParticipantMap,
//       ];
// }
