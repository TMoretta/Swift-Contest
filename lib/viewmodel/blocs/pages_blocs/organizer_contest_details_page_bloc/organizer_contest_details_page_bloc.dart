import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:swift_contest/model/bundles/contest_details_bundle.dart';
import 'package:swift_contest/model/data_models/invitation.dart';
import 'package:swift_contest/model/enums/member_role.dart';
import 'package:swift_contest/model/repositories/generic_repository.dart';
import 'package:swift_contest/model/repositories/organizer_repository.dart';
import 'package:swift_contest/viewmodel/enums/bloc_status.dart';

part 'organizer_contest_details_page_event.dart';

part 'organizer_contest_details_page_state.dart';

class OrganizerContestDetailsPageBloc
    extends Bloc<OrganizerContestDetailsPageEvent, OrganizerContestDetailsPageState> {
  final GenericRepository _genericRepository;
  final OrganizerRepository _organizerRepository;

  OrganizerContestDetailsPageBloc({
    required GenericRepository genericRepository,
    required OrganizerRepository organizerRepository,
  })  : _genericRepository = genericRepository,
        _organizerRepository = organizerRepository,
        super(OrganizerContestDetailsPageState(status: BlocStatus.initial)) {
    on<OrganizerContestDetailsPageInit>(_init);
    on<OrganizerContestDetailsPageRefresh>(_refresh);
    on<OrganizerContestDetailsPageSendParticipantInvite>(_sendParticipantInvite);
    on<OrganizerContestDetailsPageSendJurorInvite>(_sendJurorInvite);
    on<OrganizerContestDetailsPageDeleteInvitation>(_deleteInvitation);
    on<OrganizerContestDetailsPageEditVotingSessionName>(_editVotingSessionName);
    on<OrganizerContestDetailsPageRemoveParticipant>(_removeParticipant);
    on<OrganizerContestDetailsPageRemoveJuror>(_removeJuror);
    on<OrganizerContestDetailsPageDeleteContest>(_deleteContest);
    on<OrganizerContestDetailsPageSetStatusAsActive>(_setStatusAsActive);
    on<OrganizerContestDetailsPageSetStatusAsTerminated>(_setStatusAsTerminated);
  }

  FutureOr<void> _init(
    OrganizerContestDetailsPageInit event,
    Emitter<OrganizerContestDetailsPageState> emit,
  ) async {
    emit(state.copyWith(status: BlocStatus.loading, sourceEvent: event));

    final eitherDetails = await _genericRepository.getContestDetails(contestId: event.contestId);
    eitherDetails.fold(
      (failure) => emit(state.copyWith(status: BlocStatus.failure, message: failure.message)),
      (success) {
        emit(state.copyWith(status: BlocStatus.success, contestDetailsBundle: success));
      },
    );
  }

  FutureOr<void> _refresh(
    OrganizerContestDetailsPageRefresh event,
    Emitter<OrganizerContestDetailsPageState> emit,
  ) async {
    emit(state.copyWith(status: BlocStatus.loading, sourceEvent: event));

    final eitherDetails = await _genericRepository.getContestDetails(contestId: event.contestId);
    eitherDetails.fold(
      (failure) => emit(state.copyWith(status: BlocStatus.failure, message: failure.message)),
      (success) {
        emit(state.copyWith(status: BlocStatus.success, contestDetailsBundle: success));
      },
    );
  }

  FutureOr<void> _sendParticipantInvite(
    OrganizerContestDetailsPageSendParticipantInvite event,
    Emitter<OrganizerContestDetailsPageState> emit,
  ) async {
    emit(state.copyWith(status: BlocStatus.loading, sourceEvent: event));

    final InvitationNullable invitation = InvitationNullable(
      contestId: event.contestId,
      email: event.email,
      memberRole: MemberRole.participant,
    );

    final eitherInvite = await _organizerRepository.sendInvite(invitation: invitation);
    eitherInvite.fold(
        (failure) => emit(state.copyWith(status: BlocStatus.failure, message: failure.message)),
        (success) => emit(state.copyWith(status: BlocStatus.success)));
  }

  FutureOr<void> _sendJurorInvite(
    OrganizerContestDetailsPageSendJurorInvite event,
    Emitter<OrganizerContestDetailsPageState> emit,
  ) async {
    emit(state.copyWith(status: BlocStatus.loading, sourceEvent: event));

    final InvitationNullable invitation = InvitationNullable(
      contestId: event.contestId,
      email: event.email,
      memberRole: MemberRole.juror,
    );

    final eitherInvite = await _organizerRepository.sendInvite(invitation: invitation);
    eitherInvite.fold(
        (failure) => emit(state.copyWith(status: BlocStatus.failure, message: failure.message)),
        (success) => emit(state.copyWith(status: BlocStatus.success)));
  }

  FutureOr<void> _deleteInvitation(
    OrganizerContestDetailsPageDeleteInvitation event,
    Emitter<OrganizerContestDetailsPageState> emit,
  ) async {
    emit(state.copyWith(status: BlocStatus.loading, sourceEvent: event));

    final eitherDeleteInvitation =
        await _organizerRepository.deleteInvitation(invitationId: event.invitationId);
    eitherDeleteInvitation.fold(
      (failure) => emit(state.copyWith(status: BlocStatus.failure, message: failure.message)),
      (success) => emit(state.copyWith(status: BlocStatus.success)),
    );
  }

  FutureOr<void> _editVotingSessionName(
    OrganizerContestDetailsPageEditVotingSessionName event,
    Emitter<OrganizerContestDetailsPageState> emit,
  ) async {
    emit(state.copyWith(status: BlocStatus.loading, sourceEvent: event));

    final eitherDeleteInvitation = await _organizerRepository.updateVotingSessionName(
        votingSessionId: event.votingSessionId, name: event.name);
    eitherDeleteInvitation.fold(
      (failure) => emit(state.copyWith(status: BlocStatus.failure, message: failure.message)),
      (success) => emit(state.copyWith(status: BlocStatus.success)),
    );
  }

  FutureOr<void> _removeParticipant(
    OrganizerContestDetailsPageRemoveParticipant event,
    Emitter<OrganizerContestDetailsPageState> emit,
  ) async {
    emit(state.copyWith(status: BlocStatus.loading, sourceEvent: event));

    final eitherRemoveParticipant = await _organizerRepository.removeParticipant(
        participationId: event.participationId);
    eitherRemoveParticipant.fold(
      (failure) => emit(state.copyWith(status: BlocStatus.failure, message: failure.message)),
      (success) => emit(state.copyWith(status: BlocStatus.success)),
    );
  }

  FutureOr<void> _removeJuror(
    OrganizerContestDetailsPageRemoveJuror event,
    Emitter<OrganizerContestDetailsPageState> emit,
  ) async {
    emit(state.copyWith(status: BlocStatus.loading, sourceEvent: event));

    final eitherRemoveJuror = await _organizerRepository.removeJuror(
        jurationId: event.jurationId);
    eitherRemoveJuror.fold(
      (failure) => emit(state.copyWith(status: BlocStatus.failure, message: failure.message)),
      (success) => emit(state.copyWith(status: BlocStatus.success)),
    );
  }

  FutureOr<void> _deleteContest(
    OrganizerContestDetailsPageDeleteContest event,
    Emitter<OrganizerContestDetailsPageState> emit,
  ) async {
    emit(state.copyWith(status: BlocStatus.loading, sourceEvent: event));

    final eitherDeleteContest =
        await _organizerRepository.deleteContest(contestId: event.contestId);
    eitherDeleteContest.fold(
      (failure) => emit(state.copyWith(status: BlocStatus.failure, message: failure.message)),
      (success) => emit(state.copyWith(status: BlocStatus.success)),
    );
  }

  FutureOr<void> _setStatusAsActive(
    OrganizerContestDetailsPageSetStatusAsActive event,
    Emitter<OrganizerContestDetailsPageState> emit,
  ) async {
    emit(state.copyWith(status: BlocStatus.loading, sourceEvent: event));

    final eitherSetStatus =
        await _organizerRepository.setContestStatusAsActive(contestId: event.contestId);
    eitherSetStatus.fold(
      (failure) => emit(state.copyWith(status: BlocStatus.failure, message: failure.message)),
      (success) => emit(state.copyWith(status: BlocStatus.success)),
    );
  }

  FutureOr<void> _setStatusAsTerminated(
    OrganizerContestDetailsPageSetStatusAsTerminated event,
    Emitter<OrganizerContestDetailsPageState> emit,
  ) async {
    emit(state.copyWith(status: BlocStatus.loading, sourceEvent: event));

    final eitherSetStatus =
        await _organizerRepository.setContestStatusAsTerminated(contestId: event.contestId);
    eitherSetStatus.fold(
      (failure) => emit(state.copyWith(status: BlocStatus.failure, message: failure.message)),
      (success) => emit(state.copyWith(status: BlocStatus.success)),
    );
  }
}
