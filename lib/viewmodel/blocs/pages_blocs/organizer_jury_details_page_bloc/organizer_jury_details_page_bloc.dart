import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:swift_contest/model/database/bundles/jury_bundle.dart';
import 'package:swift_contest/model/database/entities/juror_invitation.dart';
import 'package:swift_contest/model/database/repositories/organizer_repository.dart';
import 'package:swift_contest/utils/logger/logger.dart';
import 'package:swift_contest/viewmodel/enums/bloc_status.dart';

part 'organizer_jury_details_page_event.dart';

part 'organizer_jury_details_page_state.dart';

class OrganizerJuryDetailsPageBloc
    extends Bloc<OrganizerJuryDetailsPageEvent, OrganizerJuryDetailsPageState> {
  final OrganizerRepository _organizerRepository;

  OrganizerJuryDetailsPageBloc({
    required OrganizerRepository organizerRepository,
  })  : _organizerRepository = organizerRepository,
        super(OrganizerJuryDetailsPageState(status: BlocStatus.initial)) {
    on<OrganizerJuryDetailsPageFetch>(_fetch);
    on<OrganizerJuryDetailsPageInviteJuror>(_inviteJuror);
    on<OrganizerJuryDetailsPageDeleteJurorInvitation>(_deleteJurorInvitation);
    on<OrganizerJuryDetailsPageDeleteJury>(_deleteJury);
    on<OrganizerJuryDetailsPageEditJury>(_editJury);
  }

  @override
  OrganizerJuryDetailsPageState? fromJson(Map<String, dynamic> json) {
    try {
      return OrganizerJuryDetailsPageState.fromJson(json);
    } catch (e) {
      Logger.error(e);
      return null;
    }
  }

  @override
  Map<String, dynamic>? toJson(OrganizerJuryDetailsPageState state) {
    try {
      return state.toJson();
    } catch (e) {
      Logger.error(e);
      return null;
    }
  }

  Future<void> _fetch(
    OrganizerJuryDetailsPageFetch event,
    Emitter<OrganizerJuryDetailsPageState> emit,
  ) async {
    emit(state.copyWith(status: BlocStatus.loading, sourceEvent: event));

    final eitherJuryBundle = await _organizerRepository.getJuryBundle(juryId: event.juryId);
    eitherJuryBundle.fold(
      (failure) => emit(state.copyWith(status: BlocStatus.failure, message: failure.message)),
      (success) => emit(
          state.copyWith(status: BlocStatus.success, isInitialized: true, juryBundle: success)),
    );
  }

  FutureOr<void> _inviteJuror(
    OrganizerJuryDetailsPageInviteJuror event,
    Emitter<OrganizerJuryDetailsPageState> emit,
  ) async {
    emit(state.copyWith(status: BlocStatus.loading, sourceEvent: event));

    final eitherInvite = await _organizerRepository.inviteJuror(
        jurorInvitation: JurorInvitation(
      id: null,
      createdAt: null,
      contestId: event.contestId,
      juryId: event.juryId,
      token: null,
      email: event.email,
    ));

    eitherInvite.fold(
      (failure) => emit(state.copyWith(status: BlocStatus.failure, message: failure.message)),
      (success) => emit(state.copyWith(status: BlocStatus.success)),
    );
  }

  FutureOr<void> _deleteJurorInvitation(OrganizerJuryDetailsPageDeleteJurorInvitation event, Emitter<OrganizerJuryDetailsPageState> emit,) async {
    emit(state.copyWith(status: BlocStatus.loading, sourceEvent: event));

    final eitherDelete = await _organizerRepository.deleteJurorInvitation(jurorInvitationId: event.jurorInvitationId);

    eitherDelete.fold(
        (failure) => emit(state.copyWith(status: BlocStatus.failure,message: failure.message)),
        (success) => emit(state.copyWith(status: BlocStatus.success)),
    );
  }

  FutureOr<void> _deleteJury(OrganizerJuryDetailsPageDeleteJury event, Emitter<OrganizerJuryDetailsPageState> emit,)async {
    emit(state.copyWith(status: BlocStatus.loading, sourceEvent: event));

    final eitherDelete = await _organizerRepository.deleteJury(juryId: event.juryId);
    eitherDelete.fold(
        (failure) => emit(state.copyWith(status: BlocStatus.failure, message: failure.message)),
        (success) => emit(state.copyWith(status: BlocStatus.success)),
    );
  }

  FutureOr<void> _editJury(OrganizerJuryDetailsPageEditJury event, Emitter<OrganizerJuryDetailsPageState> emit,) async{
    emit(state.copyWith(status: BlocStatus.loading, sourceEvent: event));

    final eitherUpdate = await _organizerRepository.updateJuryName(juryId: event.juryId,name: event.name);
    eitherUpdate.fold(
          (failure) => emit(state.copyWith(status: BlocStatus.failure, message: failure.message)),
          (success) => emit(state.copyWith(status: BlocStatus.success)),
    );
  }
}
