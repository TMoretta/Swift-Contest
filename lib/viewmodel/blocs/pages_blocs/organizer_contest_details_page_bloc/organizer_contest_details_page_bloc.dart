import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:swift_contest/model/bundles/contest_details_bundle.dart';
import 'package:swift_contest/model/data_models/invitation.dart';
import 'package:swift_contest/model/enums/member_role.dart';
import 'package:swift_contest/model/repositories/role_repositories/organizer_repository.dart';
import 'package:swift_contest/model/repositories/utils_repository.dart';
import 'package:swift_contest/utils/functions/gen_uuid.dart';
import 'package:swift_contest/utils/functions/now.dart';
import 'package:swift_contest/viewmodel/enums/bloc_status.dart';

part 'organizer_contest_details_page_event.dart';
part 'organizer_contest_details_page_state.dart';

class OrganizerContestDetailsPageBloc
    extends Bloc<OrganizerContestDetailsPageEvent, OrganizerContestDetailsPageState> {
  final UtilsRepository _utilsRepository;
  final OrganizerRepository _organizerRepository;

  OrganizerContestDetailsPageBloc({
    required UtilsRepository utilsRepository,
    required OrganizerRepository organizerRepository,
  })  :
        _utilsRepository = utilsRepository,
        _organizerRepository = organizerRepository,
        super(OrganizerContestDetailsPageState(status: BlocStatus.initial)) {
    on<OrganizerContestDetailsPageInit>(_init);
    on<OrganizerContestDetailsPageSendParticipantInvite>(_sendParticipantInvite);
    on<OrganizerContestDetailsPageSendJurorInvite>(_sendJurorInvite);
  }

  FutureOr<void> _init(
    OrganizerContestDetailsPageInit event,
    Emitter<OrganizerContestDetailsPageState> emit,
  ) async {
    emit(state.copyWith(status: BlocStatus.loading, sourceEvent: event));

    final eitherDetails = await _organizerRepository.getContestDetails(contestId: event.contestId);
    eitherDetails.fold(
        (failure) => emit(state.copyWith(status: BlocStatus.failure,message: failure.message)),
        (success) {
          if(success != null) {
            emit(state.copyWith(status: BlocStatus.success, contestDetailsBundle: success));
          } else {
            emit(state.copyWith(status: BlocStatus.failure,message: 'Contest not found'));
          }
        },
    );

    // //* Ottengo il contest
    // late final Contest? contest;
    // final resContest = await _contestRepository.getContestById(id: event.contestId);
    // resContest.fold(
    //   (failure) => emit(state.copyWith(status: BlocStatus.failure, message: failure.message)),
    //   (success) => contest = success,
    // );
    // if (resContest.isLeft()) {
    //   return;
    // }
    // if(contest == null) {
    //   emit(state.copyWith(status: BlocStatus.failure,message: 'Contest not found'));
    //   return;
    // }
    //
    // //* Ottengo l'organizer
    // late final Organizer? organizer;
    // final resOrganizer = await _profileRepository.getProfileById(id: contest!.organizerId);
    // resOrganizer.fold(
    //   (failure) => emit(state.copyWith(status: BlocStatus.failure, message: failure.message)),
    //   (success) => organizer = success,
    // );
    // if (resOrganizer.isLeft()) {
    //   return;
    // }
    // if(organizer == null) {
    //   emit(state.copyWith(status: BlocStatus.failure, message: 'Organizer not found'));
    //   return;
    // }
    //
    // //* Ottengo il place
    // late final Place? place;
    // final resPlace = await _placeRepository.getPlaceById(id: contest!.placeId);
    // resPlace.fold(
    //   (failure) => emit(state.copyWith(status: BlocStatus.failure, message: failure.message)),
    //   (success) => place = success,
    // );
    // if (resPlace.isLeft()) {
    //   return;
    // }
    // if(place == null) {
    //   emit(state.copyWith(status: BlocStatus.failure, message: 'Place not found'));
    //   return;
    // }
    //
    // //* Ottengo le invitations
    // late final List<Invitation> invitations;
    // final resInvitations =
    //     await _invitationRepository.getInvitationsByContestId(contestId: contest!.id);
    // resInvitations.fold(
    //   (failure) => emit(state.copyWith(status: BlocStatus.failure, message: failure.message)),
    //   (success) => invitations = success,
    // );
    // if (resInvitations.isLeft()) {
    //   return;
    // }
    //
    // //* Ottengo le participations
    // late final List<Participation> participations;
    // final resParticipations =
    //     await _participationRepository.getParticipationsByContestId(contestId: contest!.id);
    // resParticipations.fold(
    //   (failure) => emit(state.copyWith(status: BlocStatus.failure, message: failure.message)),
    //   (success) => participations = success,
    // );
    // if (resParticipations.isLeft()) {
    //   return;
    // }
    //
    // //* Ottengo i participants
    // final List<Participant> participants = [];
    // for (var participation in participations) {
    //   late final Participant? participant;
    //   final resParticipant =
    //       await _profileRepository.getProfileById(id: participation.participantId);
    //   resParticipant.fold(
    //     (failure) => emit(state.copyWith(status: BlocStatus.failure, message: failure.message)),
    //     (success) => participant = success,
    //   );
    //   if (resParticipant.isLeft()) {
    //     return;
    //   }
    //   if(participant == null) {
    //     emit(state.copyWith(status: BlocStatus.failure,message: 'Participant not found'));
    //     return;
    //   } else {
    //     participants.add(participant!);
    //   }
    // }
    //
    // //* Ottengo i works
    // final List<Work?> works = [];
    // for (var participation in participations) {
    //   if (participation.participantStatus != ParticipantStatus.joined ||
    //       !participation.hasSubmitted) {
    //     works.add(null);
    //     continue;
    //   }
    //   final resWork =
    //       await _workRepository.getWorkByParticipationId(participationId: participation.id);
    //   resWork.fold(
    //     (failure) => emit(state.copyWith(status: BlocStatus.failure, message: failure.message)),
    //     (success) => works.add(success),
    //   );
    //   if (resWork.isLeft()) {
    //     return;
    //   }
    // }
    //
    // //* Ottengo le jurations
    // late final List<Juration> jurations;
    // final resJurations = await _jurationRepository.getJurationsByContestId(contestId: contest!.id);
    // resJurations.fold(
    //   (failure) => emit(state.copyWith(status: BlocStatus.failure, message: failure.message)),
    //   (success) => jurations = success,
    // );
    // if (resJurations.isLeft()) {
    //   return;
    // }
    //
    // //* Ottengo i jurors
    // final List<Juror> jurors = [];
    // for (var juration in jurations) {
    //   late final Juror? juror;
    //   final resJuror = await _profileRepository.getProfileById(id: juration.jurorId);
    //   resJuror.fold(
    //     (failure) => emit(state.copyWith(status: BlocStatus.failure, message: failure.message)),
    //     (success) => juror = success,
    //   );
    //   if (resJuror.isLeft()) {
    //     return;
    //   }
    //   if(juror==null) {
    //     emit(state.copyWith(status: BlocStatus.failure,message: 'Juror not found'));
    //     return;
    //   } else {
    //     jurors.add(juror!);
    //   }
    // }
    //
    // //* Ottengo il voting form associato al contest
    // late final VotingForm? votingForm;
    // final eitherVotingForm =
    //     await _votingFormRepository.getVotingFormById(id: contest!.votingFormId);
    // eitherVotingForm.fold(
    //   (failure) => emit(state.copyWith(status: BlocStatus.failure, message: failure.message)),
    //   (success) => votingForm = success,
    // );
    // if (eitherVotingForm.isLeft()) {
    //   return;
    // }
    // if(votingForm == null) {
    //   emit(state.copyWith(status: BlocStatus.failure,message: 'Voting form not found'));
    //   return;
    // }
    //
    // //* Ottengo i fields associati al form e li ordino
    // late final List<VotingFormField> votingFormFields;
    // final eitherVotingFormFields = await _votingFormFieldRepository
    //     .getVotingFormFieldsByVotingFormId(votingFormId: votingForm!.id);
    // eitherVotingFormFields.fold(
    //   (failure) => emit(state.copyWith(status: BlocStatus.failure, message: failure.message)),
    //   (success) => votingFormFields = success,
    // );
    // if (eitherVotingFormFields.isLeft()) {
    //   return;
    // }
    // votingFormFields.sort((a, b) => a.orderIndex.compareTo(b.orderIndex));
    //
    // //* Ottengo le voting sessions
    // late final List<VotingSession> votingSessions;
    // final eitherVotingSessions =
    //     await _votingSessionRepository.getVotingSessionsByContestId(contestId: event.contestId);
    // eitherVotingSessions.fold(
    //   (failure) => emit(state.copyWith(status: BlocStatus.failure, message: failure.message)),
    //   (success) => votingSessions = success,
    // );
    // if (eitherVotingSessions.isLeft()) {
    //   return;
    // }
    //
    // //* Merging into participationsBundles
    // final List<ParticipationBundle> participationsBundles = [];
    // for (int i = 0; i < participations.length; i++) {
    //   participationsBundles.add(ParticipationBundle(
    //     participation: participations[i],
    //     participant: participants[i],
    //     work: works[i],
    //   ));
    // }
    //
    // //* Merging into the jurationsBundles
    // final List<JurationBundle> jurationsBundles = [];
    // for (int i = 0; i < jurations.length; i++) {
    //   jurationsBundles.add(JurationBundle(
    //     juration: jurations[i],
    //     juror: jurors[i],
    //   ));
    // }
    //
    // //* Merging into the votingFormBundle
    // final votingFormBundle =
    //     VotingFormBundle(votingForm: votingForm!, votingFormFields: votingFormFields);
    //
    // //* Merging all into contestDetailsBundle
    // final contestDetailsBundle = ContestDetailsBundle(
    //   contest: contest!,
    //   organizer: organizer!,
    //   place: place!,
    //   invitations: invitations,
    //   participationsBundles: participationsBundles,
    //   jurationsBundles: jurationsBundles,
    //   votingFormBundle: votingFormBundle,
    //   votingSessions: votingSessions,
    // );
    //
    // emit(state.copyWith(
    //   status: BlocStatus.success,
    //   contestDetailsBundle: contestDetailsBundle,
    // ));
  }

  FutureOr<void> _sendParticipantInvite(
    OrganizerContestDetailsPageSendParticipantInvite event,
    Emitter<OrganizerContestDetailsPageState> emit,
  ) async {
    emit(state.copyWith(status: BlocStatus.loading, sourceEvent: event));

    late final String token;
    final eitherToken = await _utilsRepository.genUniqueToken(
        tableName: 'invitations', columnName: 'token', length: 14);
    eitherToken.fold(
      (failure) => emit(state.copyWith(status: BlocStatus.failure, message: failure.message)),
      (success) => token = success,
    );
    if (eitherToken.isLeft()) {
      return;
    }

    final Invitation invitation = Invitation(id: genUuid(), createdAt: now(), contestId: event.contestId, token: token, email: event.email, memberRole: MemberRole.participant,);

    final eitherInvite = await _organizerRepository.sendInvite(invitation: invitation);
    eitherInvite.fold(
        (failure) => emit(state.copyWith(status: BlocStatus.failure,message: failure.message)),
        (success) => emit(state.copyWith(status: BlocStatus.success))
    );
  }

  FutureOr<void> _sendJurorInvite(
    OrganizerContestDetailsPageSendJurorInvite event,
    Emitter<OrganizerContestDetailsPageState> emit,
  ) async {
    emit(state.copyWith(status: BlocStatus.loading, sourceEvent: event));

    late final String token;
    final eitherToken = await _utilsRepository.genUniqueToken(
        tableName: 'invitations', columnName: 'token', length: 14);
    eitherToken.fold(
          (failure) => emit(state.copyWith(status: BlocStatus.failure, message: failure.message)),
          (success) => token = success,
    );
    if (eitherToken.isLeft()) {
      return;
    }

    final Invitation invitation = Invitation(id: genUuid(), createdAt: now(), contestId: event.contestId, token: token, email: event.email, memberRole: MemberRole.juror,);

    final eitherInvite = await _organizerRepository.sendInvite(invitation: invitation);
    eitherInvite.fold(
            (failure) => emit(state.copyWith(status: BlocStatus.failure,message: failure.message)),
            (success) => emit(state.copyWith(status: BlocStatus.success))
    );
  }
  //
  // FutureOr<void> _getRemainingInfo(
  //   OrganizerContestDetailsPageGetRemainingInfo event,
  //   Emitter<OrganizerContestDetailsPageState> emit,
  // ) async {
  //   emit(state.copyWith(status: BlocStatus.loading, sourceEvent: event));
  //
  //   final homeContestBundle = event.homeContestBundle;
  //   final contest = homeContestBundle.contest;
  //   final organizer = homeContestBundle.organizer;
  //   final place = homeContestBundle.place;
  //   final participations = homeContestBundle.participations;
  //   final jurations = homeContestBundle.jurations;
  //
  //   //* Ottengo le invitations
  //   late final List<Invitation> invitations;
  //   final resInvitations =
  //       await _invitationRepository.getInvitationsByContestId(contestId: contest.id);
  //   resInvitations.fold(
  //     (failure) => emit(state.copyWith(status: BlocStatus.failure, message: failure.message)),
  //     (success) => invitations = success,
  //   );
  //   if (resInvitations.isLeft()) {
  //     return;
  //   }
  //
  //   //* Ottengo i participants
  //   final List<Participant> participants = [];
  //   for (var participation in participations) {
  //     late final Participant? participant;
  //     final resParticipant =
  //     await _profileRepository.getProfileById(id: participation.participantId);
  //     resParticipant.fold(
  //           (failure) => emit(state.copyWith(status: BlocStatus.failure, message: failure.message)),
  //           (success) => participant = success,
  //     );
  //     if (resParticipant.isLeft()) {
  //       return;
  //     }
  //     if(participant == null) {
  //       emit(state.copyWith(status: BlocStatus.failure,message: 'Participant not found'));
  //       return;
  //     } else {
  //       participants.add(participant!);
  //     }
  //   }
  //
  //   //* Ottengo i works
  //   final List<Work?> works = [];
  //   for (var participation in participations) {
  //     if (participation.participantStatus != ParticipantStatus.joined ||
  //         !participation.hasSubmitted) {
  //       works.add(null);
  //       continue;
  //     }
  //     final resWork =
  //         await _workRepository.getWorkByParticipationId(participationId: participation.id);
  //     resWork.fold(
  //       (failure) => emit(state.copyWith(status: BlocStatus.failure, message: failure.message)),
  //       (success) => works.add(success),
  //     );
  //     if (resWork.isLeft()) {
  //       return;
  //     }
  //   }
  //
  //   //* Ottengo i jurors
  //   final List<Juror> jurors = [];
  //   for (var juration in jurations) {
  //     late final Juror? juror;
  //     final resJuror = await _profileRepository.getProfileById(id: juration.jurorId);
  //     resJuror.fold(
  //           (failure) => emit(state.copyWith(status: BlocStatus.failure, message: failure.message)),
  //           (success) => juror = success,
  //     );
  //     if (resJuror.isLeft()) {
  //       return;
  //     }
  //     if(juror==null) {
  //       emit(state.copyWith(status: BlocStatus.failure,message: 'Juror not found'));
  //       return;
  //     } else {
  //       jurors.add(juror!);
  //     }
  //   }
  //
  //   //* Ottengo il voting form associato al contest
  //   late final VotingForm? votingForm;
  //   final eitherVotingForm =
  //       await _votingFormRepository.getVotingFormById(id: contest.votingFormId);
  //   eitherVotingForm.fold(
  //     (failure) => emit(state.copyWith(status: BlocStatus.failure, message: failure.message)),
  //     (success) => votingForm = success,
  //   );
  //   if (eitherVotingForm.isLeft()) {
  //     return;
  //   }
  //   if(votingForm==null) {
  //     emit(state.copyWith(status: BlocStatus.failure,message: 'Voting form not found'));
  //     return;
  //   }
  //
  //   //* Ottengo i fields associati al form e li ordino
  //   late final List<VotingFormField> votingFormFields;
  //   final eitherVotingFormFields = await _votingFormFieldRepository
  //       .getVotingFormFieldsByVotingFormId(votingFormId: votingForm!.id);
  //   eitherVotingFormFields.fold(
  //     (failure) => emit(state.copyWith(status: BlocStatus.failure, message: failure.message)),
  //     (success) => votingFormFields = success,
  //   );
  //   if (eitherVotingFormFields.isLeft()) {
  //     return;
  //   }
  //   votingFormFields.sort((a, b) => a.orderIndex.compareTo(b.orderIndex));
  //
  //   //* Ottengo le voting sessions con stato 'ended'
  //   late final List<VotingSession> votingSessions;
  //   final eitherVotingSessions =
  //       await _votingSessionRepository.getVotingSessionsByContestId(contestId: contest.id);
  //   eitherVotingSessions.fold(
  //     (failure) => emit(state.copyWith(status: BlocStatus.failure, message: failure.message)),
  //     (success) => votingSessions = success,
  //   );
  //   if (eitherVotingSessions.isLeft()) {
  //     return;
  //   }
  //
  //   //* Merging into participationsBundles
  //   final List<ParticipationBundle> participationsBundles = [];
  //   for (int i = 0; i < participations.length; i++) {
  //     participationsBundles.add(ParticipationBundle(
  //       participation: participations[i],
  //       participant: participants[i],
  //       work: works[i],
  //     ));
  //   }
  //
  //   //* Merging into the jurationsBundles
  //   final List<JurationBundle> jurationsBundles = [];
  //   for (int i = 0; i < jurations.length; i++) {
  //     jurationsBundles.add(JurationBundle(
  //       juration: jurations[i],
  //       juror: jurors[i],
  //     ));
  //   }
  //
  //   //* Merging into the votingFormBundle
  //   final votingFormBundle =
  //   VotingFormBundle(votingForm: votingForm!, votingFormFields: votingFormFields);
  //
  //   //* Merging all into contestDetailsBundle
  //   final contestDetailsBundle = ContestDetailsBundle(
  //     contest: contest,
  //     organizer: organizer,
  //     place: place,
  //     invitations: invitations,
  //     participationsBundles: participationsBundles,
  //     jurationsBundles: jurationsBundles,
  //     votingFormBundle: votingFormBundle,
  //     votingSessions: votingSessions,
  //   );
  //
  //   emit(state.copyWith(
  //     status: BlocStatus.success,
  //     contestDetailsBundle: contestDetailsBundle,
  //   ));
  // }
}
