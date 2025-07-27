// part of 'simple_juror_voting_procedure_page_bloc.dart';
//
// sealed class SimpleJurorVotingProcedurePageEvent extends Equatable {
//   const SimpleJurorVotingProcedurePageEvent();
// }
//
// final class SimpleJurorVotingProcedurePageFetch
//     extends SimpleJurorVotingProcedurePageEvent {
//   final String votingSessionId;
//
//   const SimpleJurorVotingProcedurePageFetch({
//     required this.votingSessionId,
//   });
//
//   @override
//   List<Object?> get props => [votingSessionId];
// }
//
// final class SimpleJurorVotingProcedurePageSubmitVotes extends SimpleJurorVotingProcedurePageEvent {
//   final VotingSession votingSession;
//   final Place? geoResPlace;
//   final String simpleJurorId;
//   final Map<VotingSessionParticipation, Map<VotingFormField, double>> votesPerParticipantMap;
//   final String? jurorId;
//
//   const SimpleJurorVotingProcedurePageSubmitVotes({
//     required this.votingSession,
//     this.geoResPlace,
//     required this.simpleJurorId,
//     required this.votesPerParticipantMap,
//     this.jurorId,
//   });
//
//   @override
//   List<Object?> get props => [
//         votingSession,
//         geoResPlace,
//         simpleJurorId,
//         votesPerParticipantMap,
//         jurorId,
//       ];
// }
