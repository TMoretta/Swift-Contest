import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:swift_contest/model/bundles/home_contest_bundle.dart';
import 'package:swift_contest/model/repositories/role_repositories/participant_repository.dart';
import 'package:swift_contest/viewmodel/enums/bloc_status.dart';

part 'participant_home_page_event.dart';
part 'participant_home_page_state.dart';

class ParticipantHomePageBloc extends Bloc<ParticipantHomePageEvent, ParticipantHomePageState> {
  final ParticipantRepository _participantRepository;

  ParticipantHomePageBloc({
    required ParticipantRepository participantRepository,
  })  :
        _participantRepository = participantRepository,
        super(ParticipantHomePageState(status: BlocStatus.initial)) {
    on<ParticipantHomePageInit>(_init);
    on<ParticipantHomePageRefresh>(_refresh);
    on<ParticipantHomePageJoinContest>(_joinContest);
  }

  FutureOr<void> _init(
    ParticipantHomePageInit event,
    Emitter<ParticipantHomePageState> emit,
  ) async {
    emit(ParticipantHomePageState(status: BlocStatus.loading, sourceEvent: event));

    final eitherContests = await _participantRepository.getJoinedContests(participantId: event.participantId);
    eitherContests.fold(
        (failure) => emit(state.copyWith(status: BlocStatus.failure,message: failure.message)),
        (success) => emit(state.copyWith(status: BlocStatus.success,joinedContestsBundles: success)),
    );

    // //* Ottengo le proprie partecipazioni
    // late final List<Participation> ownParticipations;
    // final resOwnParticipations = await _participationRepository.getParticipationsByParticipantId(
    //     participantId: event.participantId);
    // resOwnParticipations.fold(
    //       (failure) => emit(state.copyWith(status: BlocStatus.failure, message: failure.message)),
    //       (success) => ownParticipations = success,
    // );
    // if (resOwnParticipations.isLeft()) return;
    //
    // //* Ottengo i contest
    // final List<Contest> contests = [];
    // for (var ownParticipation in ownParticipations) {
    //   final contestId = ownParticipation.contestId;
    //   late final Contest? contest;
    //   final resContest = await _contestRepository.getContestById(id: contestId);
    //   resContest.fold(
    //         (failure) => emit(state.copyWith(status: BlocStatus.failure, message: failure.message)),
    //         (success) => contest = success,
    //   );
    //   if (resContest.isLeft()) {
    //     return;
    //   }
    //   if(contest==null) {
    //     emit(state.copyWith(status: BlocStatus.failure,message: 'Contest not found'));
    //     return;
    //   } else {
    //     contests.add(contest!);
    //   }
    // }
    //
    // //* Ordino i contest per data di creazione
    // contests.sort((a, b) => a.createdAt.compareTo(b.createdAt));
    //
    // //* Ottengo l'organizer per ogni contest
    // final List<Organizer> organizers = [];
    // for (var contest in contests) {
    //   late final Organizer? organizer;
    //   final resOrganizer = await _profileRepository.getProfileById(id: contest.organizerId);
    //   resOrganizer.fold(
    //     (failure) => emit(state.copyWith(status: BlocStatus.failure, message: failure.message)),
    //     (success) => organizer = success,
    //   );
    //   if (resOrganizer.isLeft()) {
    //     return;
    //   }
    //   if(organizer==null) {
    //     emit(state.copyWith(status: BlocStatus.failure,message: 'Organizer not found'));
    //     return;
    //   } else {
    //     organizers.add(organizer!);
    //   }
    // }
    //
    // //* Ottengo il place per ogni contest
    // final List<Place> places = [];
    // for (var contest in contests) {
    //   late final Place? place;
    //   final resPlace = await _placeRepository.getPlaceById(id: contest.placeId);
    //   resPlace.fold(
    //     (failure) => emit(state.copyWith(status: BlocStatus.failure, message: failure.message)),
    //     (success) => place = success,
    //   );
    //   if (resPlace.isLeft()) {
    //     return;
    //   }
    //   if(place==null) {
    //     emit(state.copyWith(status: BlocStatus.failure,message: 'Place not found'));
    //     return;
    //   } else {
    //     places.add(place!);
    //   }
    // }
    //
    // //* Ottengo le participations per ogni contest
    // final List<List<Participation>> participations = [];
    // for (var contest in contests) {
    //   final resParticipations =
    //       await _participationRepository.getParticipationsByContestId(contestId: contest.id);
    //   resParticipations.fold(
    //     (failure) => emit(state.copyWith(status: BlocStatus.failure, message: failure.message)),
    //     (success) => participations.add(success),
    //   );
    //
    //   if (resParticipations.isLeft()) {
    //     return;
    //   }
    // }
    //
    // //* Ottengo le jurations per ogni contest
    // final List<List<Juration>> jurations = [];
    // for (var contest in contests) {
    //   final resJurations = await _jurationRepository.getJurationsByContestId(contestId: contest.id);
    //   resJurations.fold(
    //     (failure) => emit(state.copyWith(status: BlocStatus.failure, message: failure.message)),
    //     (success) => jurations.add(success),
    //   );
    //
    //   if (resJurations.isLeft()) {
    //     return;
    //   }
    // }
    //
    // //* Merging all in bundles
    // final List<HomeContestBundle> joinedContestsBundles = [];
    // for (int i = 0; i < contests.length; i++) {
    //   joinedContestsBundles.add(
    //     HomeContestBundle(
    //         contest: contests[i],
    //         organizer: organizers[i],
    //         place: places[i],
    //         participations: participations[i],
    //         jurations: jurations[i]),
    //   );
    // }
    //
    // //* Emit the success
    // emit(state.copyWith(
    //   status: BlocStatus.success,
    //   joinedContestsBundles: joinedContestsBundles,
    // ));
  }

  FutureOr<void> _refresh(ParticipantHomePageRefresh event, Emitter<ParticipantHomePageState> emit,) async{
    emit(state.copyWith(status: BlocStatus.loading, sourceEvent: event));

    final eitherContests = await _participantRepository.getJoinedContests(participantId: event.participantId);
    eitherContests.fold(
          (failure) => emit(state.copyWith(status: BlocStatus.failure,message: failure.message)),
          (success) => emit(state.copyWith(status: BlocStatus.success,joinedContestsBundles: success)),
    );
  }

  //* Join contest
  FutureOr<void> _joinContest(ParticipantHomePageJoinContest event, Emitter<ParticipantHomePageState> emit,)async {
    emit(state.copyWith(status: BlocStatus.loading, sourceEvent: event));

    final eitherJoinContest = await _participantRepository.joinContest(participantId: event.participantId, token: event.token);
    eitherJoinContest.fold(
        (failure) => emit(state.copyWith(status: BlocStatus.failure,message: failure.message)),
        (success) => emit(state.copyWith(status: BlocStatus.success)),
    );

    // final eitherContest =
    // await _contestRepository.getContestByToken(token: event.contestToken);
    // late final Contest? contest;
    // eitherContest.fold(
    //       (failure) => emit(ParticipantHomePageState(
    //       status: BlocStatus.failure, message: failure.message)),
    //       (success) => contest = success,
    // );
    // if (eitherContest.isLeft()) return;
    // if(contest == null) {
    //   emit(ParticipantHomePageState(status: BlocStatus.failure,message: 'Contest not found'));
    //   return;
    // }
    //
    // late final List<Invitation> invitations;
    // final eitherInvitations =
    // await _invitationRepository.getInvitationsByContestIdAndMemberRole(
    //     contestId: contest!.id, memberRole: MemberRole.participant);
    // eitherInvitations.fold(
    //       (failure) => emit(ParticipantHomePageState(
    //       status: BlocStatus.failure, message: failure.message)),
    //       (success) => invitations = success,
    // );
    // if (eitherInvitations.isLeft()) return;
    //
    // if(invitations.isEmpty) {
    //   emit(ParticipantHomePageState(status: BlocStatus.failure,message: 'No invitation found with these credentials'));
    // }
    //
    // for (var invitation in invitations) {
    //   if (invitation.token == event.participantToken) {
    //     late final Participation participation;
    //     final eitherParticipation =
    //     await _participationRepository.createParticipation(
    //         participation: Participation(
    //           id: invitation.id,
    //           createdAt: DateTime.now(),
    //           contestId: contest!.id,
    //           participantId: event.participantId,
    //           participantStatus: ParticipantStatus.joined,
    //           hasSubmitted: false,
    //         ));
    //     eitherParticipation.fold(
    //           (failure) => emit(ParticipantHomePageState(
    //           status: BlocStatus.failure, message: failure.message)),
    //           (success) => participation = success,
    //     );
    //     if (eitherParticipation.isLeft()) return;
    //
    //     final eitherDeleteInvitation =
    //     await _invitationRepository.deleteInvitationById(id: invitation.id);
    //     eitherDeleteInvitation.fold(
    //             (failure) => emit(ParticipantHomePageState(
    //             status: BlocStatus.failure, message: failure.message)),
    //             (success) => null);
    //     if (eitherDeleteInvitation.isLeft()) return;
    //
    //     emit(ParticipantHomePageState(status: BlocStatus.success));
    //     break;
    //   }
    // }
    //
    // emit(ParticipantHomePageState(status: BlocStatus.failure,message: 'No invitation found with these credentials'));
  }
}
