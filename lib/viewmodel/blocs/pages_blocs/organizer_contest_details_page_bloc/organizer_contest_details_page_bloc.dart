import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:swift_contest/model/database/bundles/contest_details_bundle.dart';
import 'package:swift_contest/model/database/entities/juror_invitation.dart';
import 'package:swift_contest/model/database/entities/jury.dart';
import 'package:swift_contest/model/database/entities/participant_invitation.dart';
import 'package:swift_contest/model/database/repositories/organizer_repository.dart';
import 'package:swift_contest/model/database/types/jury_type.dart';
import 'package:swift_contest/utils/functions/gen_uuid.dart';
import 'package:swift_contest/utils/functions/now.dart';
import 'package:swift_contest/utils/logger/logger.dart';
import 'package:swift_contest/viewmodel/enums/bloc_status.dart';

part 'organizer_contest_details_page_event.dart';

part 'organizer_contest_details_page_state.dart';

class OrganizerContestDetailsPageBloc
    extends HydratedBloc<OrganizerContestDetailsPageEvent, OrganizerContestDetailsPageState> {
  final OrganizerRepository _organizerRepository;

  OrganizerContestDetailsPageBloc({
    required OrganizerRepository organizerRepository,
  })  : _organizerRepository = organizerRepository,
        super(OrganizerContestDetailsPageState(status: BlocStatus.initial)) {
    on<OrganizerContestDetailsPageFetch>(_fetch);
    on<OrganizerContestDetailsPageSendParticipantInvite>(_sendParticipantInvite);
    on<OrganizerContestDetailsPageSendJurorInvite>(_sendJurorInvite);
    on<OrganizerContestDetailsPageDeleteParticipantInvitation>(_deleteParticipantInvitation);
    on<OrganizerContestDetailsPageDeleteJurorInvitation>(_deleteJurorInvitation);
    on<OrganizerContestDetailsPageRemoveParticipant>(_removeParticipant);
    on<OrganizerContestDetailsPageRemoveJuror>(_removeJuror);
    on<OrganizerContestDetailsPageDeleteContest>(_deleteContest);
    on<OrganizerContestDetailsPageCreateJury>(_createJury);
  }

  @override
  OrganizerContestDetailsPageState? fromJson(Map<String, dynamic> json) {
    try {
      return OrganizerContestDetailsPageState.fromJson(json);
    } catch (e) {
      Logger.error(e);
      return null;
    }
  }

  @override
  Map<String, dynamic>? toJson(OrganizerContestDetailsPageState state) {
    try {
      return state.toJson();
    } catch (e) {
      Logger.error(e);
      return null;
    }
  }

  FutureOr<void> _fetch(
    OrganizerContestDetailsPageFetch event,
    Emitter<OrganizerContestDetailsPageState> emit,
  ) async {
    emit(state.copyWith(status: BlocStatus.loading, sourceEvent: event));

    final eitherDetails = await _organizerRepository.getContestDetails(contestId: event.contestId);
    eitherDetails.fold(
      (failure) => emit(state.copyWith(status: BlocStatus.failure, message: failure.message)),
      (success) {
        emit(state.copyWith(
            status: BlocStatus.success, isInitialized: true, contestDetailsBundle: success));
      },
    );
  }

  FutureOr<void> _sendParticipantInvite(
    OrganizerContestDetailsPageSendParticipantInvite event,
    Emitter<OrganizerContestDetailsPageState> emit,
  ) async {
    emit(state.copyWith(status: BlocStatus.loading, sourceEvent: event));

    final ParticipantInvitation invitation = ParticipantInvitation(
      id: genUuid(),
      createdAt: now(),
      contestId: event.contestId,
      email: event.email,
      token: '',
    );

    final eitherInvite =
        await _organizerRepository.inviteParticipant(participantInvitation: invitation);
    eitherInvite.fold(
        (failure) => emit(state.copyWith(status: BlocStatus.failure, message: failure.message)),
        (success) => emit(state.copyWith(status: BlocStatus.success)));
  }

  FutureOr<void> _sendJurorInvite(
    OrganizerContestDetailsPageSendJurorInvite event,
    Emitter<OrganizerContestDetailsPageState> emit,
  ) async {
    emit(state.copyWith(status: BlocStatus.loading, sourceEvent: event));

    final JurorInvitation invitation = JurorInvitation(
      id: genUuid(),
      createdAt: now(),
      contestId: event.contestId,
      juryId: event.juryId,
      email: event.email,
      token: '',
    );

    final eitherInvite = await _organizerRepository.inviteJuror(jurorInvitation: invitation);
    eitherInvite.fold(
        (failure) => emit(state.copyWith(status: BlocStatus.failure, message: failure.message)),
        (success) => emit(state.copyWith(status: BlocStatus.success)));
  }

  FutureOr<void> _deleteParticipantInvitation(
    OrganizerContestDetailsPageDeleteParticipantInvitation event,
    Emitter<OrganizerContestDetailsPageState> emit,
  ) async {
    emit(state.copyWith(status: BlocStatus.loading, sourceEvent: event));

    final eitherDeleteInvitation = await _organizerRepository.deleteParticipantInvitation(
        participantInvitationId: event.participantInvitationId);
    eitherDeleteInvitation.fold(
      (failure) => emit(state.copyWith(status: BlocStatus.failure, message: failure.message)),
      (success) => emit(state.copyWith(status: BlocStatus.success)),
    );
  }

  FutureOr<void> _deleteJurorInvitation(
    OrganizerContestDetailsPageDeleteJurorInvitation event,
    Emitter<OrganizerContestDetailsPageState> emit,
  ) async {
    emit(state.copyWith(status: BlocStatus.loading, sourceEvent: event));

    final eitherDeleteInvitation = await _organizerRepository.deleteJurorInvitation(
        jurorInvitationId: event.jurorInvitationId);
    eitherDeleteInvitation.fold(
      (failure) => emit(state.copyWith(status: BlocStatus.failure, message: failure.message)),
      (success) => emit(state.copyWith(status: BlocStatus.success)),
    );
  }

  // FutureOr<void> _editVotingSessionName(
  //   OrganizerContestDetailsPageEditVotingSessionName event,
  //   Emitter<OrganizerContestDetailsPageState> emit,
  // ) async {
  //   emit(state.copyWith(status: BlocStatus.loading, sourceEvent: event));
  //
  //   final eitherDeleteInvitation = await _organizerRepository.updateVotingSessionName(
  //       votingSessionId: event.votingSessionId, name: event.name);
  //   eitherDeleteInvitation.fold(
  //     (failure) => emit(state.copyWith(status: BlocStatus.failure, message: failure.message)),
  //     (success) => emit(state.copyWith(status: BlocStatus.success)),
  //   );
  // }

  FutureOr<void> _removeParticipant(
    OrganizerContestDetailsPageRemoveParticipant event,
    Emitter<OrganizerContestDetailsPageState> emit,
  ) async {
    emit(state.copyWith(status: BlocStatus.loading, sourceEvent: event));

    final eitherRemoveParticipant =
        await _organizerRepository.removeParticipant(participationId: event.participationId);
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

    final eitherRemoveJuror = await _organizerRepository.removeJuror(jurationId: event.jurationId);
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

  FutureOr<void> _createJury(
    OrganizerContestDetailsPageCreateJury event,
    Emitter<OrganizerContestDetailsPageState> emit,
  ) async {
    emit(state.copyWith(status: BlocStatus.loading, sourceEvent: event));

    final eitherCreateJury = await _organizerRepository.createJury(
      jury: Jury(
        id: null,
        createdAt: null,
        contestId: event.contestId,
        votingFormId: null,
        name: event.juryName,
        token: null,
        type: event.juryType,
      ),
    );
    eitherCreateJury.fold(
      (failure) => emit(state.copyWith(status: BlocStatus.failure, message: failure.message)),
      (success) => emit(state.copyWith(status: BlocStatus.success)),
    );
  }
}
