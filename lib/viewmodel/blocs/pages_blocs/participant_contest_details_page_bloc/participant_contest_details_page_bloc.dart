import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:swift_contest/model/bundles/contest_details_bundle.dart';
import 'package:swift_contest/model/bundles/juration_bundle.dart';
import 'package:swift_contest/model/bundles/participation_bundle.dart';
import 'package:swift_contest/model/bundles/voting_form_bundle.dart';
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
import 'package:swift_contest/model/enums/participant_status.dart';
import 'package:swift_contest/model/repositories/crud_repositories/contest_repository.dart';
import 'package:swift_contest/model/repositories/crud_repositories/invitation_repository.dart';
import 'package:swift_contest/model/repositories/crud_repositories/juration_repository.dart';
import 'package:swift_contest/model/repositories/crud_repositories/participation_repository.dart';
import 'package:swift_contest/model/repositories/crud_repositories/place_repository.dart';
import 'package:swift_contest/model/repositories/crud_repositories/profile_repository.dart';
import 'package:swift_contest/model/repositories/crud_repositories/voting_form_field_repository.dart';
import 'package:swift_contest/model/repositories/crud_repositories/voting_form_repository.dart';
import 'package:swift_contest/model/repositories/crud_repositories/voting_session_repository.dart';
import 'package:swift_contest/model/repositories/crud_repositories/work_repository.dart';
import 'package:swift_contest/model/repositories/role_repositories/participant_repository.dart';
import 'package:swift_contest/viewmodel/enums/bloc_status.dart';

part 'participant_contest_details_page_event.dart';

part 'participant_contest_details_page_state.dart';

class ParticipantContestDetailsPageBloc
    extends Bloc<ParticipantContestDetailsPageEvent, ParticipantContestDetailsPageState> {
  final ParticipantRepository _participantRepository;

  ParticipantContestDetailsPageBloc({
    required ParticipantRepository participantRepository,
  })  :
        _participantRepository = participantRepository,
        super(ParticipantContestDetailsPageState(status: BlocStatus.initial)) {
    on<ParticipantContestDetailsPageInit>(_getInfo);
  }

  FutureOr<void> _getInfo(
    ParticipantContestDetailsPageInit event,
    Emitter<ParticipantContestDetailsPageState> emit,
  ) async {
    emit(state.copyWith(status: BlocStatus.loading, sourceEvent: event));

    late final ContestDetailsBundle contestDetailsBundle;
    final eitherContestDetails =
        await _participantRepository.getContestDetails(contestId: event.contestId);
    eitherContestDetails.fold(
      (failure) => emit(state.copyWith(status: BlocStatus.failure, message: failure.message)),
      (success) => contestDetailsBundle = success,
    );

    late final Work? submittedWork;
    final eitherSubmittedWork = await _participantRepository.getSubmittedWork(
        contestId: event.contestId, participantId: event.participantId);
    eitherSubmittedWork.fold(
      (failure) => emit(state.copyWith(status: BlocStatus.failure, message: failure.message)),
      (success) => submittedWork = success,
    );

    emit(state.copyWith(status: BlocStatus.success,contestDetailsBundle: contestDetailsBundle,submittedWork: submittedWork));

    // //* Ottengo il contest
    // late final Contest? contest;
    // final resContest = await _contestRepository.getContestById(id: event.contestId);
    // resContest.fold(
    //       (failure) => emit(state.copyWith(status: BlocStatus.failure, message: failure.message)),
    //       (success) => contest = success,
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
    //       (failure) => emit(state.copyWith(status: BlocStatus.failure, message: failure.message)),
    //       (success) => organizer = success,
    // );
    // if (resOrganizer.isLeft()) {
    //   return;
    // }
    // if(organizer == null) {
    //   emit(state.copyWith(status: BlocStatus.failure,message: 'Organizer not found'));
    //   return;
    // }
    //
    // //* Ottengo il place
    // late final Place? place;
    // final resPlace = await _placeRepository.getPlaceById(id: contest!.placeId);
    // resPlace.fold(
    //       (failure) => emit(state.copyWith(status: BlocStatus.failure, message: failure.message)),
    //       (success) => place = success,
    // );
    // if (resPlace.isLeft()) {
    //   return;
    // }
    // if(place == null) {
    //   emit(state.copyWith(status: BlocStatus.failure,message: 'Place not found'));
    //   return;
    // }
    //
    // //* Ottengo le invitations
    // late final List<Invitation> invitations;
    // final resInvitations =
    // await _invitationRepository.getInvitationsByContestId(contestId: contest!.id);
    // resInvitations.fold(
    //       (failure) => emit(state.copyWith(status: BlocStatus.failure, message: failure.message)),
    //       (success) => invitations = success,
    // );
    // if (resInvitations.isLeft()) {
    //   return;
    // }
    //
    // //* Ottengo le participations
    // late final List<Participation> participations;
    // final resParticipations =
    // await _participationRepository.getParticipationsByContestId(contestId: contest!.id);
    // resParticipations.fold(
    //       (failure) => emit(state.copyWith(status: BlocStatus.failure, message: failure.message)),
    //       (success) => participations = success,
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
    //   await _profileRepository.getProfileById(id: participation.participantId);
    //   resParticipant.fold(
    //         (failure) => emit(state.copyWith(status: BlocStatus.failure, message: failure.message)),
    //         (success) => participant = success,
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
    //   await _workRepository.getWorkByParticipationId(participationId: participation.id);
    //   resWork.fold(
    //         (failure) => emit(state.copyWith(status: BlocStatus.failure, message: failure.message)),
    //         (success) => works.add(success),
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
    //       (failure) => emit(state.copyWith(status: BlocStatus.failure, message: failure.message)),
    //       (success) => jurations = success,
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
    //         (failure) => emit(state.copyWith(status: BlocStatus.failure, message: failure.message)),
    //         (success) => juror = success,
    //   );
    //   if (resJuror.isLeft()) {
    //     return;
    //   }
    //   if(juror == null) {
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
    // await _votingFormRepository.getVotingFormById(id: contest!.votingFormId);
    // eitherVotingForm.fold(
    //       (failure) => emit(state.copyWith(status: BlocStatus.failure, message: failure.message)),
    //       (success) => votingForm = success,
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
    //       (failure) => emit(state.copyWith(status: BlocStatus.failure, message: failure.message)),
    //       (success) => votingFormFields = success,
    // );
    // if (eitherVotingFormFields.isLeft()) {
    //   return;
    // }
    // votingFormFields.sort((a, b) => a.orderIndex.compareTo(b.orderIndex));
    //
    // //* Ottengo le voting sessions
    // late final List<VotingSession> votingSessions;
    // final eitherVotingSessions =
    // await _votingSessionRepository.getVotingSessionsByContestId(contestId: event.contestId);
    // eitherVotingSessions.fold(
    //       (failure) => emit(state.copyWith(status: BlocStatus.failure, message: failure.message)),
    //       (success) => votingSessions = success,
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
    // VotingFormBundle(votingForm: votingForm!, votingFormFields: votingFormFields);
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
    // late final Participation? ownParticipation;
    // late final Work? ownWork;
    //
    // //* Ottengo la participation del participant
    // final resParticipation = await _participationRepository
    //     .getParticipationByContestIdAndParticipantId(
    //   contestId: event.contestId,
    //   participantId: event.participantId,
    // );
    // resParticipation.fold(
    //       (failure) => emit(
    //       state.copyWith(status: BlocStatus.failure, message: failure.message)),
    //       (success) => ownParticipation = success,
    // );
    // if (resParticipation.isLeft()) {
    //   return;
    // }
    //
    // if(ownParticipation == null) {
    //   emit(state.copyWith(status: BlocStatus.failure,message: 'Participation not found'));
    //   return;
    // }
    //
    // //* Ottengo il work del participant
    // if (ownParticipation!.hasSubmitted) {
    //   final resWork = await _workRepository.getWorkByParticipationId(
    //       participationId: ownParticipation!.id);
    //   resWork.fold(
    //         (failure) => emit(state.copyWith(
    //         status: BlocStatus.failure, message: failure.message)),
    //         (success) => ownWork = success,
    //   );
    //   if (resWork.isLeft()) return;
    // } else {
    //   ownWork = null;
    // }
    //
    // emit(state.copyWith(
    //   status: BlocStatus.success,
    //   ownWork: ownWork,
    //   ownParticipation: ownParticipation,
    //   contestDetailsBundle: contestDetailsBundle,
    // ));
  }

// FutureOr<void> _getRemainingInfo(ParticipantContestDetailsPageGetRemainingInfo event, Emitter<ParticipantContestDetailsPageState> emit,) async {
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
//   await _invitationRepository.getInvitationsByContestId(contestId: contest.id);
//   resInvitations.fold(
//         (failure) => emit(state.copyWith(status: BlocStatus.failure, message: failure.message)),
//         (success) => invitations = success,
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
//     await _workRepository.getWorkByParticipationId(participationId: participation.id);
//     resWork.fold(
//           (failure) => emit(state.copyWith(status: BlocStatus.failure, message: failure.message)),
//           (success) => works.add(success),
//     );
//     if (resWork.isLeft()) {
//       return;
//     }
//   }
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
//   await _votingFormRepository.getVotingFormById(id: contest.votingFormId);
//   eitherVotingForm.fold(
//         (failure) => emit(state.copyWith(status: BlocStatus.failure, message: failure.message)),
//         (success) => votingForm = success,
//   );
//   if (eitherVotingForm.isLeft()) {
//     return;
//   }
//   if(votingForm == null) {
//     emit(state.copyWith(status: BlocStatus.failure,message: 'Voting form not found'));
//     return;
//   }
//
//   //* Ottengo i fields associati al form e li ordino
//   late final List<VotingFormField> votingFormFields;
//   final eitherVotingFormFields = await _votingFormFieldRepository
//       .getVotingFormFieldsByVotingFormId(votingFormId: votingForm!.id);
//   eitherVotingFormFields.fold(
//         (failure) => emit(state.copyWith(status: BlocStatus.failure, message: failure.message)),
//         (success) => votingFormFields = success,
//   );
//   if (eitherVotingFormFields.isLeft()) {
//     return;
//   }
//   votingFormFields.sort((a, b) => a.orderIndex.compareTo(b.orderIndex));
//
//   //* Ottengo le voting sessions con stato 'ended'
//   late final List<VotingSession> votingSessions;
//   final eitherVotingSessions =
//   await _votingSessionRepository.getVotingSessionsByContestId(contestId: contest.id);
//   eitherVotingSessions.fold(
//         (failure) => emit(state.copyWith(status: BlocStatus.failure, message: failure.message)),
//         (success) => votingSessions = success,
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
