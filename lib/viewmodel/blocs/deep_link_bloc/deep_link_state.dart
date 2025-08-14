// part of 'deep_link_bloc.dart';
//
// @immutable
// final class DeepLinkState extends Equatable {
//   final DeepLinkStatus status;
//   final DeepLinkEvent? sourceEvent;
//   final String? message;
//   final Uri? pendingDeepLink;
//
//   const DeepLinkState({
//     required this.status,
//     this.sourceEvent,
//     this.message,
//     this.pendingDeepLink,
//   });
//
//   DeepLinkState copyWith({
//     required DeepLinkStatus status,
//     DeepLinkEvent? sourceEvent,
//     String? message,
//     Uri? pendingDeepLink,
//   }) {
//     return DeepLinkState(
//       status: status,
//       sourceEvent: sourceEvent ?? this.sourceEvent,
//       message: message,
//       pendingDeepLink: pendingDeepLink,
//     );
//   }
//
//   @override
//   List<Object?> get props => [
//         status,
//         sourceEvent,
//         message,
//         pendingDeepLink,
//       ];
// }
