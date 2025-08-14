// import 'dart:async';
//
// import 'package:equatable/equatable.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:swift_contest/model/database/repositories/juror_repository.dart';
// import 'package:swift_contest/model/database/repositories/participant_repository.dart';
// import 'package:swift_contest/viewmodel/types/deep_link_status.dart';
//
// part 'deep_link_event.dart';
// part 'deep_link_state.dart';
//
// class DeepLinkBloc extends Bloc<DeepLinkEvent, DeepLinkState> {
//   final ParticipantRepository _participantRepository;
//   final JurorRepository _jurorRepository;
//
//   DeepLinkBloc({
//     required ParticipantRepository participantRepository,
//     required JurorRepository jurorRepository,
//   })  : _participantRepository = participantRepository,
//         _jurorRepository = jurorRepository,
//         super(DeepLinkState(status: DeepLinkStatus.initial)) {
//     on<DeepLinkSetPending>(_setPending);
//     on<DeepLinkHandlePending>(_handlePending);
//     on<DeepLinkHandleParticipantInvite>(_handleParticipantInvite);
//   }
//
//   FutureOr<void> _setPending(
//     DeepLinkSetPending event,
//     Emitter<DeepLinkState> emit,
//   ) async {
//     emit(DeepLinkState(status: DeepLinkStatus.pending, pendingDeepLink: event.uri));
//   }
//
//   FutureOr<void> _handlePending(
//     DeepLinkHandlePending event,
//     Emitter<DeepLinkState> emit,
//   ) async {
//     if(!state.status.isPending) {
//       emit(state.copyWith(status: DeepLinkStatus.success));
//       return;
//     }
//     try {
//       switch(state.pendingDeepLink!.pathSegments[0]) {
//         case 'participant-invite':
//           add(DeepLinkHandleParticipantInvite(token: state.pendingDeepLink!.pathSegments[1]));
//           break;
//       }
//     } catch (e) {
//       emit(state.copyWith(status: DeepLinkStatus.failure, message: 'An error occurred'));
//     }
//   }
//
//   FutureOr<void> _handleParticipantInvite(
//     DeepLinkHandleParticipantInvite event,
//     Emitter<DeepLinkState> emit,
//   ) async {
//     emit(DeepLinkState(status: DeepLinkStatus.loading, sourceEvent: event));
//
//     final res = await _participantRepository.joinContest(token: event.token);
//     res.fold(
//       (failure) => emit(state.copyWith(status: DeepLinkStatus.failure, message: failure.message)),
//       (success) => emit(state.copyWith(status: DeepLinkStatus.success)),
//     );
//   }
// }
