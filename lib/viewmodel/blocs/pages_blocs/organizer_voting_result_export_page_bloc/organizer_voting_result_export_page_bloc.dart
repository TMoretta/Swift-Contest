import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:swift_contest/model/bundles/voting_session_result_bundle.dart';
import 'package:swift_contest/model/repositories/generic_repository.dart';
import 'package:swift_contest/model/repositories/organizer_repository.dart';
import 'package:swift_contest/viewmodel/enums/bloc_status.dart';

part 'organizer_voting_result_export_page_event.dart';
part 'organizer_voting_result_export_page_state.dart';

class OrganizerVotingResultExportPageBloc
    extends Bloc<OrganizerVotingResultExportPageEvent, OrganizerVotingResultExportPageState> {
  final GenericRepository _genericRepository;
  final OrganizerRepository _organizerRepository;

  OrganizerVotingResultExportPageBloc({
    required GenericRepository genericRepository,
    required OrganizerRepository organizerRepository,
  })  :

        _genericRepository = genericRepository,
        _organizerRepository = organizerRepository,
        super(OrganizerVotingResultExportPageState(status: BlocStatus.initial)) {
    on<OrganizerVotingResultExportPageInit>(_init);
    on<OrganizerVotingResultExportPageRefresh>(_refresh);
  }

  FutureOr<void> _init(
    OrganizerVotingResultExportPageInit event,
    Emitter<OrganizerVotingResultExportPageState> emit,
  ) async {
    late final VotingSessionResultBundle votingSessionBundle;
    final eitherVotingSessionBundle =
    await _genericRepository.getVotingSessionResultBundle(votingSessionId: event.votingSessionId);
    eitherVotingSessionBundle.fold(
          (failure) => emit(state.copyWith(status: BlocStatus.failure, message: failure.message)),
          (success) => votingSessionBundle = success,
    );

    emit(state.copyWith(
      status: BlocStatus.success,
      votingSessionResultBundle: votingSessionBundle,
    ));
  }

  FutureOr<void> _refresh(
    OrganizerVotingResultExportPageRefresh event,
    Emitter<OrganizerVotingResultExportPageState> emit,
  ) async {
    late final VotingSessionResultBundle votingSessionBundle;
    final eitherVotingSessionBundle =
    await _genericRepository.getVotingSessionResultBundle(votingSessionId: event.votingSessionId);
    eitherVotingSessionBundle.fold(
          (failure) => emit(state.copyWith(status: BlocStatus.failure, message: failure.message)),
          (success) => votingSessionBundle = success,
    );

    emit(state.copyWith(
      status: BlocStatus.success,
      votingSessionResultBundle: votingSessionBundle,
    ));
  }
}
