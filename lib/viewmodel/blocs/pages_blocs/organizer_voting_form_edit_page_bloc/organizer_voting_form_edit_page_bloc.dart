import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:swift_contest/model/bundles/voting_form_bundle.dart';
import 'package:swift_contest/model/data_models/voting_form_field.dart';
import 'package:swift_contest/model/repositories/organizer_repository.dart';
import 'package:swift_contest/viewmodel/enums/bloc_status.dart';

part 'organizer_voting_form_edit_page_event.dart';

part 'organizer_voting_form_edit_page_state.dart';

class OrganizerVotingFormEditPageBloc
    extends Bloc<OrganizerVotingFormEditPageEvent, OrganizerVotingFormEditPageState> {
  final OrganizerRepository _organizerRepository;

  OrganizerVotingFormEditPageBloc({
    required OrganizerRepository organizerRepository,
  })  : _organizerRepository = organizerRepository,
        super(OrganizerVotingFormEditPageState(status: BlocStatus.initial)) {
    on<OrganizerVotingFormEditPageFetch>(_fetch);
    on<OrganizerVotingFormEditPageUpdateVotingForm>(_updateVotingForm);
  }

  FutureOr<void> _fetch(
    OrganizerVotingFormEditPageFetch event,
    Emitter<OrganizerVotingFormEditPageState> emit,
  ) async {
    emit(state.copyWith(status: BlocStatus.loading, sourceEvent: event));

    final eitherVotingForm =
        await _organizerRepository.getContestVotingFormBundle(votingFormId: event.votingFormId);
    eitherVotingForm.fold(
      (failure) => emit(state.copyWith(status: BlocStatus.failure, message: failure.message)),
      (success) => emit(state.copyWith(status: BlocStatus.success, isInitialized: true, votingFormBundle: success)),
    );
  }

  FutureOr<void> _updateVotingForm(
    OrganizerVotingFormEditPageUpdateVotingForm event,
    Emitter<OrganizerVotingFormEditPageState> emit,
  ) async {
    emit(state.copyWith(status: BlocStatus.loading, sourceEvent: event));

    final eitherUpdateFields = await _organizerRepository.updateVotingFormFields(
        votingFormId: event.votingFormId, votingFormFields: event.votingFormFields);
    eitherUpdateFields.fold(
      (failure) => emit(state.copyWith(status: BlocStatus.failure, message: failure.message)),
      (success) => emit(state.copyWith(status: BlocStatus.success)),
    );
  }
}
