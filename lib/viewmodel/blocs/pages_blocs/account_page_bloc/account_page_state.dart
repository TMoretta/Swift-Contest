// part of 'account_page_bloc.dart';
//
// @immutable
// final class AccountPageState extends Equatable {
//   final BlocStatus status;
//   final AccountPageEvent? sourceEvent;
//   final String? message;
//
//   const AccountPageState({
//     required this.status,
//     this.message,
//     this.sourceEvent,
//   });
//
//   AccountPageState copyWith({
//     required BlocStatus status,
//     AccountPageEvent? sourceEvent,
//     String? message,
//   }) {
//     return AccountPageState(
//       status: status,
//       sourceEvent: sourceEvent ?? this.sourceEvent,
//       message: message,
//     );
//   }
//
//   @override
//   List<Object?> get props => [status, sourceEvent, message];
// }
