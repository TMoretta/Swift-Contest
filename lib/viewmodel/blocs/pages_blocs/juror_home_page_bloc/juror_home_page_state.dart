// part of 'juror_home_page_bloc.dart';
//
// @immutable
// final class JurorHomePageState extends Equatable {
//   final BlocStatus status;
//   final JurorHomePageEvent? sourceEvent;
//   final bool isInitialized;
//   final String? message;
//   final List<HomeContestBundle>? joinedContestsBundles;
//   final List<HomeContestBundle>? filteredContestsBundles;
//   final SimpleJurorAndVotingSessionBundle? simpleJurorAndVotingSessionBundle;
//
//   const JurorHomePageState({
//     required this.status,
//     this.sourceEvent,
//     this.isInitialized = false,
//     this.message,
//     this.joinedContestsBundles,
//     this.filteredContestsBundles,
//     this.simpleJurorAndVotingSessionBundle,
//   });
//
//   JurorHomePageState copyWith({
//     required BlocStatus status,
//     JurorHomePageEvent? sourceEvent,
//     bool? isInitialized,
//     String? message,
//     List<HomeContestBundle>? joinedContestsBundles,
//     List<HomeContestBundle>? filteredContestsBundles,
//     SimpleJurorAndVotingSessionBundle? simpleJurorAndVotingSessionBundle,
//   }) {
//     return JurorHomePageState(
//       status: status,
//       sourceEvent: sourceEvent ?? this.sourceEvent,
//       isInitialized: isInitialized ?? this.isInitialized,
//       message: message,
//       joinedContestsBundles: joinedContestsBundles ?? this.joinedContestsBundles,
//       filteredContestsBundles: filteredContestsBundles ?? this.filteredContestsBundles,
//       simpleJurorAndVotingSessionBundle:
//           simpleJurorAndVotingSessionBundle ?? this.simpleJurorAndVotingSessionBundle,
//     );
//   }
//
//   @override
//   List<Object?> get props => [
//         status,
//         sourceEvent,
//         isInitialized,
//         message,
//         joinedContestsBundles,
//         filteredContestsBundles,
//         simpleJurorAndVotingSessionBundle,
//       ];
// }
