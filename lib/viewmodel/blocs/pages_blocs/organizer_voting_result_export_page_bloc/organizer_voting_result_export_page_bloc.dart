// import 'dart:async';
//
// import 'package:equatable/equatable.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:swift_contest/model/database/bundles/voting_session_result_bundle.dart';
// import 'package:swift_contest/model/database/repositories/organizer_repository_.dart';
// import 'package:swift_contest/viewmodel/enums/bloc_status.dart';
//
// part 'organizer_voting_result_export_page_event.dart';
//
// part 'organizer_voting_result_export_page_state.dart';
//
// class OrganizerVotingResultExportPageBloc
//     extends Bloc<OrganizerVotingResultExportPageEvent, OrganizerVotingResultExportPageState> {
//   final OrganizerRepository _organizerRepository;
//
//   OrganizerVotingResultExportPageBloc({
//     required OrganizerRepository organizerRepository,
//   })  : _organizerRepository = organizerRepository,
//         super(OrganizerVotingResultExportPageState(status: BlocStatus.initial)) {
//     on<OrganizerVotingResultExportPageFetch>(_fetch);
//   }
//
//   FutureOr<void> _fetch(
//     OrganizerVotingResultExportPageFetch event,
//     Emitter<OrganizerVotingResultExportPageState> emit,
//   ) async {
//     late final VotingSessionResultBundle votingSessionBundle;
//     final eitherVotingSessionBundle = await _organizerRepository.getVotingSessionResultBundle(
//         votingSessionId: event.votingSessionId);
//     eitherVotingSessionBundle.fold(
//       (failure) => emit(state.copyWith(status: BlocStatus.failure, message: failure.message)),
//       (success) => votingSessionBundle = success,
//     );
//
//     emit(state.copyWith(
//       status: BlocStatus.success,
//       isInitialized: true,
//       votingSessionResultBundle: votingSessionBundle,
//     ));
//   }
// }
