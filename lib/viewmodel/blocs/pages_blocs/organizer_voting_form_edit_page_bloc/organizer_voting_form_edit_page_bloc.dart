import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:swift_contest/model/db/bundles/voting_form_bundle.dart';
import 'package:swift_contest/model/db/entities/voting_form_field.dart';
import 'package:swift_contest/model/db/repositories/organizer_repository.dart';
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
        await _organizerRepository.getVotingFormBundle(votingFormId: event.votingFormId);
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

    final updatedFields = event.votingFormFields;
    for(int i=0; i<updatedFields.length; i++) {
      updatedFields[i] = updatedFields[i].copyWith(orderIndex: i);
    }

    final eitherUpdateFields = await _organizerRepository.updateVotingForm(
        votingFormId: event.votingFormId, votingFormFields: updatedFields, header: event.header, footer: event.footer);
    eitherUpdateFields.fold(
      (failure) => emit(state.copyWith(status: BlocStatus.failure, message: failure.message)),
      (success) => emit(state.copyWith(status: BlocStatus.success)),
    );
  }
}
