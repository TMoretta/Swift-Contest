import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:swift_contest/model/data_models/contest.dart';
import 'package:swift_contest/model/data_models/invitation.dart';
import 'package:swift_contest/model/data_models/juration.dart';
import 'package:swift_contest/model/data_models/participation.dart';
import 'package:swift_contest/model/data_models/place.dart';
import 'package:swift_contest/model/data_models/profile.dart';
import 'package:swift_contest/model/data_models/voting_form.dart';
import 'package:swift_contest/model/data_models/voting_form_field.dart';
import 'package:swift_contest/model/data_models/voting_session.dart';
import 'package:swift_contest/model/data_models/work.dart';
import 'package:swift_contest/model/enums/member_role.dart';
import 'package:swift_contest/model/enums/participant_status.dart';
import 'package:swift_contest/model/enums/work_status.dart';
import 'package:swift_contest/utils/functions/gen_uuid.dart';
import 'package:swift_contest/viewmodel/blocs/bloc_status.dart';
import 'package:swift_contest/viewmodel/repositories/contest_repository.dart';
import 'package:swift_contest/viewmodel/repositories/edge_repository.dart';
import 'package:swift_contest/viewmodel/repositories/invitation_repository.dart';
import 'package:swift_contest/viewmodel/repositories/juration_repository.dart';
import 'package:swift_contest/viewmodel/repositories/participation_repository.dart';
import 'package:swift_contest/viewmodel/repositories/place_repository.dart';
import 'package:swift_contest/viewmodel/repositories/profile_repository.dart';
import 'package:swift_contest/viewmodel/repositories/utils_repository.dart';
import 'package:swift_contest/viewmodel/repositories/vote_repository.dart';
import 'package:swift_contest/viewmodel/repositories/voting_form_field_repository.dart';
import 'package:swift_contest/viewmodel/repositories/voting_form_repository.dart';
import 'package:swift_contest/viewmodel/repositories/voting_repository.dart';
import 'package:swift_contest/viewmodel/repositories/voting_session_juror_repository.dart';
import 'package:swift_contest/viewmodel/repositories/voting_session_participant_repository.dart';
import 'package:swift_contest/viewmodel/repositories/voting_session_procedure_repository.dart';
import 'package:swift_contest/viewmodel/repositories/voting_session_repository.dart';
import 'package:swift_contest/viewmodel/repositories/work_repository.dart';

part 'organizer_contest_details_page_event.dart';
part 'organizer_contest_details_page_state.dart';

class OrganizerContestDetailsPageBloc
    extends Bloc<OrganizerContestDetailsPageEvent, OrganizerContestDetailsPageState> {
  final EdgeRepository _edgeRepository;
  final ContestRepository _contestRepository;
  final ProfileRepository _profileRepository;
  final ParticipationRepository _participationRepository;
  final JurationRepository _jurationRepository;
  final WorkRepository _workRepository;
  final VotingFormRepository _votingFormRepository;
  final VotingFormFieldRepository _votingFormFieldRepository;
  final UtilsRepository _utilsRepository;
  final PlaceRepository _placeRepository;
  final InvitationRepository _invitationRepository;
  final VotingSessionRepository _votingSessionRepository;
  final VotingSessionProcedureRepository _votingSessionProcedureRepository;
  final VotingRepository _votingRepository;
  final VoteRepository _voteRepository;
  final VotingSessionParticipantRepository _votingSessionParticipantRepository;
  final VotingSessionJurorRepository _votingSessionJurorRepository;

  OrganizerContestDetailsPageBloc({
    required ParticipationRepository participationRepository,
    required JurationRepository jurationRepository,
    required EdgeRepository edgeRepository,
    required ProfileRepository profileRepository,
    required ContestRepository contestRepository,
    required WorkRepository workRepository,
    required VotingFormRepository votingFormRepository,
    required VotingFormFieldRepository votingFormFieldRepository,
    required UtilsRepository utilsRepository,
    required PlaceRepository placeRepository,
    required InvitationRepository invitationRepository,
    required VotingSessionRepository votingSessionRepository,
    required VotingSessionProcedureRepository votingSessionProcedureRepository,
    required VotingRepository votingRepository,
    required VoteRepository voteRepository,
    required VotingSessionParticipantRepository votingSessionParticipantRepository,
    required VotingSessionJurorRepository votingSessionJurorRepository,
  })  : _participationRepository = participationRepository,
        _jurationRepository = jurationRepository,
        _edgeRepository = edgeRepository,
        _profileRepository = profileRepository,
        _contestRepository = contestRepository,
        _workRepository = workRepository,
        _votingFormRepository = votingFormRepository,
        _votingFormFieldRepository = votingFormFieldRepository,
        _placeRepository = placeRepository,
        _utilsRepository = utilsRepository,
        _invitationRepository = invitationRepository,
        _votingSessionRepository = votingSessionRepository,
        _votingSessionProcedureRepository = votingSessionProcedureRepository,
        _votingRepository = votingRepository,
        _voteRepository = voteRepository,
        _votingSessionParticipantRepository = votingSessionParticipantRepository,
        _votingSessionJurorRepository = votingSessionJurorRepository,
        super(OrganizerContestDetailsPageState(status: BlocStatus.initial)) {
    on<OrganizerContestDetailsPageSendParticipantInvite>(_sendParticipantInvite);
    on<OrganizerContestDetailsPageSendJurorInvite>(_sendJurorInvite);
    on<OrganizerContestDetailsPageGetContestMainInfo>(_getContestMainInfo);
    on<OrganizerContestDetailsPageGetVotingTabInfo>(_getVotingTabInfo);
    on<OrganizerContestDetailsPageUpdateVotingFormFields>(_updateVotingFormFields);
  }

  Future<void> _sendParticipantInvite(
    OrganizerContestDetailsPageSendParticipantInvite event,
    Emitter<OrganizerContestDetailsPageState> emit,
  ) async {
    emit(state.copyWith(status: BlocStatus.loading));

    late final String memberToken;
    final eitherToken = await _utilsRepository.genUniqueToken(
        tableName: 'invitations', columnName: 'token', length: 8);
    eitherToken.fold(
      (failure) => emit(state.copyWith(status: BlocStatus.failure, message: failure.message)),
      (success) => memberToken = success,
    );
    if (eitherToken.isLeft()) return;

    late final Invitation invitation;
    final eitherInvitation = await _invitationRepository.createInvitation(
        invitation: Invitation(
      id: genUuid(),
      createdAt: DateTime.now(),
      contestId: event.contest.id,
      token: memberToken,
      email: event.email,
      memberRole: MemberRole.participant,
    ));
    eitherInvitation.fold(
      (failure) => emit(state.copyWith(status: BlocStatus.failure, message: failure.message)),
      (success) => invitation = success,
    );
    if (eitherInvitation.isLeft()) {
      return;
    }

    // late final Participation participation;
    // final eitherParticipation =
    //     await _participationRepository.createParticipation(
    //         participation: Participation(
    //   id: Uuid().v4(),
    //   createdAt: DateTime.now(),
    //   contestId: event.contest.id,
    //   token: token,
    //   participantStatus: ParticipantStatus.attended,
    //   workStatus: WorkStatus.out,
    //   invitationEmail: event.email,
    // ));
    // eitherParticipation.fold(
    //   (failure) => emit(
    //       state.copyWith(status: BlocStatus.failure, message: failure.message)),
    //   (success) => participation = success,
    // );
    // if (eitherParticipation.isLeft()) return;

    final eitherInvite = await _edgeRepository.sendParticipantInvite(
      email: event.email,
      contestToken: event.contest.token,
      participantToken: invitation.token,
    );
    eitherInvite.fold(
      (failure) => emit(state.copyWith(status: BlocStatus.failure, message: failure.message)),
      (unit) => emit(state.copyWith(status: BlocStatus.success)),
    );
  }

  Future<void> _sendJurorInvite(
    OrganizerContestDetailsPageSendJurorInvite event,
    Emitter<OrganizerContestDetailsPageState> emit,
  ) async {
    emit(state.copyWith(status: BlocStatus.loading));

    late final String memberToken;
    final eitherToken = await _utilsRepository.genUniqueToken(
        tableName: 'invitations', columnName: 'token', length: 8);
    eitherToken.fold(
      (failure) => emit(state.copyWith(status: BlocStatus.failure, message: failure.message)),
      (success) => memberToken = success,
    );
    if (eitherToken.isLeft()) {
      return;
    }

    late final Invitation invitation;
    final eitherInvitation = await _invitationRepository.createInvitation(
        invitation: Invitation(
      id: genUuid(),
      createdAt: DateTime.now(),
      contestId: event.contest.id,
      token: memberToken,
      email: event.email,
      memberRole: MemberRole.juror,
    ));
    eitherInvitation.fold(
      (failure) => emit(state.copyWith(status: BlocStatus.failure, message: failure.message)),
      (success) => invitation = success,
    );
    if (eitherInvitation.isLeft()) {
      return;
    }

    // late final Juration juration;
    // final eitherJuration = await _jurationRepository.createJuration(
    //     juration: Juration(
    //   id: Uuid().v4(),
    //   createdAt: DateTime.now(),
    //   contestId: event.contest.id,
    //   token: token,
    //   jurorStatus: JurorStatus.attended,
    //   invitationEmail: event.email,
    // ));
    // eitherJuration.fold(
    //   (failure) => emit(
    //       state.copyWith(status: BlocStatus.failure, message: failure.message)),
    //   (success) => juration = success,
    // );
    // if (eitherJuration.isLeft()) return;

    final eitherInvite = await _edgeRepository.sendJurorInvite(
      email: event.email,
      contestToken: event.contest.token,
      jurorToken: invitation.token,
    );
    eitherInvite.fold(
      (failure) => emit(state.copyWith(status: BlocStatus.failure, message: failure.message)),
      (unit) => emit(state.copyWith(status: BlocStatus.success)),
    );
  }

  FutureOr<void> _getContestMainInfo(
    OrganizerContestDetailsPageGetContestMainInfo event,
    Emitter<OrganizerContestDetailsPageState> emit,
  ) async {
    emit(state.copyWith(status: BlocStatus.loading));

    late final Contest contest;
    late final Profile organizer;
    late final Place place;
    late final List<Invitation> participantsInvitations;
    late final List<Invitation> jurorsInvitations;
    late final List<Participation> participations;
    final List<Profile?> participants = [];
    late final List<Juration> jurations;
    final List<Profile?> jurors = [];

    //* Ottengo il contest
    final resContest = await _contestRepository.getContestById(id: event.contestId);
    resContest.fold(
      (failure) => emit(state.copyWith(status: BlocStatus.failure, message: failure.message)),
      (success) => contest = success,
    );
    if (resContest.isLeft()) {
      return;
    }

    //* Ottengo l'organizer
    final resOrganizer = await _profileRepository.getProfileById(id: contest.organizerId);
    resOrganizer.fold(
      (failure) => emit(state.copyWith(status: BlocStatus.failure, message: failure.message)),
      (success) => organizer = success,
    );
    if (resOrganizer.isLeft()) {
      return;
    }

    //* Ottengo il place
    final resPlace = await _placeRepository.getPlaceById(id: contest.placeId);
    resPlace.fold(
      (failure) => emit(state.copyWith(status: BlocStatus.failure, message: failure.message)),
      (success) => place = success,
    );
    if (resPlace.isLeft()) {
      return;
    }

    //* Ottengo le participants invitations
    final resParticipantsInvitations =
        await _invitationRepository.getInvitationsByContestIdAndMemberRole(
            contestId: contest.id, memberRole: MemberRole.participant);
    resParticipantsInvitations.fold(
      (failure) => emit(state.copyWith(status: BlocStatus.failure, message: failure.message)),
      (success) => participantsInvitations = success,
    );
    if (resParticipantsInvitations.isLeft()) {
      return;
    }

    //* Ottengo le jurors invitations
    final resJurorsInvitations = await _invitationRepository.getInvitationsByContestIdAndMemberRole(
        contestId: contest.id, memberRole: MemberRole.juror);
    resJurorsInvitations.fold(
      (failure) => emit(state.copyWith(status: BlocStatus.failure, message: failure.message)),
      (success) => jurorsInvitations = success,
    );
    if (resJurorsInvitations.isLeft()) {
      return;
    }

    //* Ottengo le participations
    final resParticipations =
        await _participationRepository.getParticipationsByContestId(contestId: contest.id);
    resParticipations.fold(
      (failure) => emit(state.copyWith(status: BlocStatus.failure, message: failure.message)),
      (success) => participations = success,
    );
    if (resParticipations.isLeft()) {
      return;
    }

    //* Ottengo i participants
    for (var participation in participations) {
      final resParticipant =
          await _profileRepository.getProfileById(id: participation.participantId);
      resParticipant.fold(
        (failure) => emit(state.copyWith(status: BlocStatus.failure, message: failure.message)),
        (success) => participants.add(success),
      );
      if (resParticipant.isLeft()) {
        return;
      }
    }

    final List<Work?> works = [];

    //* Ottengo i works
    for (var participation in participations) {
      if (participation.participantStatus != ParticipantStatus.joined ||
          participation.workStatus != WorkStatus.submitted) {
        works.add(null);
        continue;
      }
      final resWork =
          await _workRepository.getWorkByParticipationId(participationId: participation.id);
      resWork.fold(
        (failure) => emit(state.copyWith(status: BlocStatus.failure, message: failure.message)),
        (success) => works.add(success),
      );
      if (resWork.isLeft()) {
        return;
      }
    }

    //* Ottengo le jurations
    final resJurations = await _jurationRepository.getJurationsByContestId(contestId: contest.id);
    resJurations.fold(
      (failure) => emit(state.copyWith(status: BlocStatus.failure, message: failure.message)),
      (success) => jurations = success,
    );
    if (resJurations.isLeft()) {
      return;
    }

    //* Ottengo i jurors
    for (var juration in jurations) {
      final resJuror = await _profileRepository.getProfileById(id: juration.jurorId);
      resJuror.fold(
        (failure) => emit(state.copyWith(status: BlocStatus.failure, message: failure.message)),
        (success) => jurors.add(success),
      );
      if (resJuror.isLeft()) {
        return;
      }
    }

    emit(state.copyWith(
      status: BlocStatus.success,
      contest: contest,
      organizer: organizer,
      participantsInvitations: participantsInvitations,
      jurorsInvitations: jurorsInvitations,
      participations: participations,
      participants: participants,
      works: works,
      jurations: jurations,
      jurors: jurors,
      place: place,
    ));
  }

  // FutureOr<void> _getWorks(
  //   OrganizerContestDetailsPageGetWorks event,
  //   Emitter<OrganizerContestDetailsPageState> emit,
  // ) async {
  //   emit(state.copyWith(status: BlocStatus.loading));
  //
  //   if (state.participations == null) {
  //     emit(state.copyWith(
  //         status: BlocStatus.failure, message: 'An error occurred'));
  //     return;
  //   }
  //
  //   final List<Participation> participations = state.participations!;
  //   final List<Work?> works = [];
  //
  //   //* Ottengo i works
  //   for (var participation in participations) {
  //     if (participation.workStatus != WorkStatus.submitted ||
  //         participation.workId == null) {
  //       works.add(null);
  //       continue;
  //     }
  //     final resWork =
  //         await _workRepository.getWorkById(id: participation.workId!);
  //     resWork.fold(
  //       (failure) => emit(state.copyWith(
  //           status: BlocStatus.failure, message: failure.message)),
  //       (success) => works.add(success),
  //     );
  //     if (resWork.isLeft()) return;
  //   }
  //
  //   emit(state.copyWith(
  //     status: BlocStatus.success,
  //     works: works,
  //   ));
  // }

  FutureOr<void> _getVotingTabInfo(
    OrganizerContestDetailsPageGetVotingTabInfo event,
    Emitter<OrganizerContestDetailsPageState> emit,
  ) async {
    emit(state.copyWith(status: BlocStatus.loading));

    if (state.contest?.votingFormId == null) {
      emit(state.copyWith(status: BlocStatus.failure, message: 'An error occurred'));
      return;
    }

    final votingFormId = state.contest!.votingFormId;

    late final VotingForm votingForm;
    final eitherVotingForm = await _votingFormRepository.getVotingFormById(id: votingFormId);
    eitherVotingForm.fold(
      (failure) => emit(state.copyWith(status: BlocStatus.failure, message: failure.message)),
      (success) => votingForm = success,
    );
    if (eitherVotingForm.isLeft()) {
      return;
    }

    late final List<VotingFormField> votingFormFields;

    final eitherVotingFormFields = await _votingFormFieldRepository
        .getVotingFormFieldsByVotingFormId(votingFormId: votingForm.id);
    eitherVotingFormFields.fold(
      (failure) => emit(state.copyWith(status: BlocStatus.failure, message: failure.message)),
      (success) => votingFormFields = success,
    );
    if (eitherVotingFormFields.isLeft()) {
      return;
    }

    votingFormFields.sort((a, b) => a.orderIndex.compareTo(b.orderIndex));

    late final List<VotingSession> votingSessions;
    final eitherVotingSessions =
        await _votingSessionRepository.getVotingSessionsByContestId(contestId: event.contestId);
    eitherVotingSessions.fold(
      (failure) => emit(state.copyWith(status: BlocStatus.failure, message: failure.message)),
      (success) => votingSessions = success,
    );
    if (eitherVotingSessions.isLeft()) {
      return;
    }

    final List<VotingSession> endedVotingSessions = [];
    for (var votingSession in votingSessions) {
      if (votingSession.isEnded) {
        endedVotingSessions.add(votingSession);
      }
    }

    emit(state.copyWith(
      status: BlocStatus.success,
      votingForm: votingForm,
      votingFormFields: votingFormFields,
      endedVotingSessions: endedVotingSessions,
    ));
  }

  FutureOr<void> _updateVotingFormFields(
    OrganizerContestDetailsPageUpdateVotingFormFields event,
    Emitter<OrganizerContestDetailsPageState> emit,
  ) async {
    emit(state.copyWith(status: BlocStatus.loading));

    //* Deleting old fields
    late final List<VotingFormField> oldVotingFormFields;
    final eitherOldFields = await _votingFormFieldRepository.getVotingFormFieldsByVotingFormId(
        votingFormId: event.votingFormId);
    eitherOldFields.fold(
      (failure) => emit(state.copyWith(status: BlocStatus.failure, message: failure.message)),
      (success) => oldVotingFormFields = success,
    );
    if (eitherOldFields.isLeft()) return;

    for (var oldField in oldVotingFormFields) {
      final eitherDeletion =
          await _votingFormFieldRepository.deleteVotingFormFieldById(id: oldField.id);
      eitherDeletion.fold(
        (failure) => emit(state.copyWith(status: BlocStatus.failure, message: failure.message)),
        (unit) => null,
      );
      if (eitherDeletion.isLeft()) return;
    }

    //* Parsing from raw voting form fields to voting form fields
    final List<VotingFormField> votingFormFields = [];
    for (int i = 0; i < event.rawVotingFormFields.length; i++) {
      final raw = event.rawVotingFormFields[i];
      votingFormFields.add(VotingFormField(
        id: genUuid(),
        createdAt: DateTime.now(),
        votingFormId: event.votingFormId,
        name: raw.name,
        orderIndex: i,
        fieldType: raw.fieldType,
        isOptional: raw.isOptional,
      ));
    }

    final List<VotingFormField> newVotingFormFields = [];
    for (var votingFormField in votingFormFields) {
      final eitherCreation =
          await _votingFormFieldRepository.createVotingFormField(votingFormField: votingFormField);
      eitherCreation.fold(
        (failure) => emit(state.copyWith(status: BlocStatus.failure, message: failure.message)),
        (success) => newVotingFormFields.add(success),
      );
      if (eitherCreation.isLeft()) return;
    }

    emit(state.copyWith(
      status: BlocStatus.success,
      votingFormFields: newVotingFormFields,
    ));
  }
}
