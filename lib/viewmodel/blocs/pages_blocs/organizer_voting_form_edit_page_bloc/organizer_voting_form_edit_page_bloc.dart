import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:swift_contest/model/database/bundles/voting_form_bundle.dart';
import 'package:swift_contest/model/database/entities/voting_form_field.dart';
import 'package:swift_contest/model/database/repositories/organizer_repository.dart';
import 'package:swift_contest/utils/logger/logger.dart';
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

  @override
  OrganizerVotingFormEditPageState? fromJson(Map<String, dynamic> json) {
    try {
      return OrganizerVotingFormEditPageState.fromJson(json);
    } catch (e) {
      Logger.error(e);
      return null;
    }
  }

  @override
  Map<String, dynamic>? toJson(OrganizerVotingFormEditPageState state) {
    try {
      return state.toJson();
    } catch (e) {
      Logger.error(e);
      return null;
    }
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

    final List<VotingFormField> updatedFields = [];

    for(int i=0; i<event.headerFormFields.length; i++) {
      updatedFields.add(event.headerFormFields[i].copyWith(orderIndex: i));
    }
    for(int i=0; i<event.participantFormFields.length; i++) {
      updatedFields.add(event.participantFormFields[i].copyWith(orderIndex: i));
    }
    for(int i=0; i<event.footerFormFields.length; i++) {
      updatedFields.add(event.footerFormFields[i].copyWith(orderIndex: i));
    }

    final eitherUpdateFields = await _organizerRepository.updateVotingForm(
        votingFormId: event.votingFormId, votingFormFields: updatedFields, name: event.name, description: event.description);
    eitherUpdateFields.fold(
      (failure) => emit(state.copyWith(status: BlocStatus.failure, message: failure.message)),
      (success) => emit(state.copyWith(status: BlocStatus.success)),
    );
  }
}
