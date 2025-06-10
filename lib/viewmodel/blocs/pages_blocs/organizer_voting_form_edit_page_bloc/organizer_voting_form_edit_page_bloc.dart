import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:swift_contest/model/bundles/voting_form_bundle.dart';
import 'package:swift_contest/model/data_models/voting_form.dart';
import 'package:swift_contest/model/data_models/voting_form_field.dart';
import 'package:swift_contest/model/repositories/role_repositories/organizer_repository.dart';
import 'package:swift_contest/model/repositories/crud_repositories/voting_form_field_repository.dart';
import 'package:swift_contest/model/repositories/crud_repositories/voting_form_repository.dart';
import 'package:swift_contest/viewmodel/enums/bloc_status.dart';

part 'organizer_voting_form_edit_page_event.dart';

part 'organizer_voting_form_edit_page_state.dart';

class OrganizerVotingFormEditPageBloc
    extends Bloc<OrganizerVotingFormEditPageEvent, OrganizerVotingFormEditPageState> {
  final VotingFormRepository _votingFormRepository;
  final VotingFormFieldRepository _votingFormFieldRepository;
  final OrganizerRepository _organizerRepository;

  OrganizerVotingFormEditPageBloc({
    required VotingFormRepository votingFormRepository,
    required VotingFormFieldRepository votingFormFieldRepository,
    required OrganizerRepository organizerRepository,
  })  : _votingFormRepository = votingFormRepository,
        _votingFormFieldRepository = votingFormFieldRepository,
        _organizerRepository = organizerRepository,
        super(OrganizerVotingFormEditPageState(status: BlocStatus.initial)) {
    on<OrganizerVotingFormEditPageGetVotingForm>(_getVotingForm);
    on<OrganizerVotingFormEditPageUpdateVotingForm>(_updateVotingForm);
  }

  FutureOr<void> _getVotingForm(
    OrganizerVotingFormEditPageGetVotingForm event,
    Emitter<OrganizerVotingFormEditPageState> emit,
  ) async {
    emit(state.copyWith(status: BlocStatus.loading, sourceEvent: event));

    //* Ottengo il voting form associato al contest
    late final VotingForm? votingForm;
    final eitherVotingForm = await _votingFormRepository.getVotingFormById(id: event.votingFormId);
    eitherVotingForm.fold(
      (failure) => emit(state.copyWith(status: BlocStatus.failure, message: failure.message)),
      (success) => votingForm = success,
    );
    if (eitherVotingForm.isLeft()) {
      return;
    }
    if(votingForm == null) {
      emit(state.copyWith(status: BlocStatus.failure, message: 'Voting form not found'));
      return;
    }

    //* Ottengo i fields associati al form e li ordino
    late final List<VotingFormField> votingFormFields;
    final eitherVotingFormFields = await _votingFormFieldRepository
        .getVotingFormFieldsByVotingFormId(votingFormId: votingForm!.id);
    eitherVotingFormFields.fold(
      (failure) => emit(state.copyWith(status: BlocStatus.failure, message: failure.message)),
      (success) => votingFormFields = success,
    );
    if (eitherVotingFormFields.isLeft()) {
      return;
    }
    votingFormFields.sort((a, b) => a.orderIndex.compareTo(b.orderIndex));

    final votingFormBundle =
        VotingFormBundle(votingForm: votingForm!, votingFormFields: votingFormFields);

    emit(state.copyWith(status: BlocStatus.success, votingFormBundle: votingFormBundle));
  }

  FutureOr<void> _updateVotingForm(
    OrganizerVotingFormEditPageUpdateVotingForm event,
    Emitter<OrganizerVotingFormEditPageState> emit,
  ) async {
    emit(state.copyWith(status: BlocStatus.loading, sourceEvent: event));

    final eitherUpdateFields = await _organizerRepository.updateVotingFormFields(votingFormId: event.votingFormId, votingFormFields: event.votingFormFields);
    eitherUpdateFields.fold(
        (failure) => emit(state.copyWith(status: BlocStatus.failure,message: failure.message)),
        (success) => emit(state.copyWith(status: BlocStatus.success)),
    );
  }
}
