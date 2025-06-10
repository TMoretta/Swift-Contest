import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:swift_contest/model/bundles/home_contest_bundle.dart';
import 'package:swift_contest/model/repositories/role_repositories/juror_repository.dart';
import 'package:swift_contest/viewmodel/enums/bloc_status.dart';

part 'juror_home_page_event.dart';
part 'juror_home_page_state.dart';

class JurorHomePageBloc extends Bloc<JurorHomePageEvent, JurorHomePageState> {
  final JurorRepository _jurorRepository;

  JurorHomePageBloc({
    required JurorRepository jurorRepository,
  })  :
        _jurorRepository = jurorRepository,
        super(JurorHomePageState(status: BlocStatus.initial)) {
    on<JurorHomePageGetJoinedContests>(_getJoinedContests);
    on<JurorHomePageJoinContest>(_joinContest);
  }

  FutureOr<void> _getJoinedContests(
    JurorHomePageGetJoinedContests event,
    Emitter<JurorHomePageState> emit,
  ) async {
    emit(JurorHomePageState(status: BlocStatus.loading, sourceEvent: event));

    final eitherContests = await _jurorRepository.getJoinedContests(jurorId: event.jurorId);
    eitherContests.fold(
          (failure) => emit(state.copyWith(status: BlocStatus.failure,message: failure.message)),
          (success) => emit(state.copyWith(status: BlocStatus.success,joinedContestsBundles: success)),
    );

    // //* Ottengo le proprie partecipazioni
    // late final List<Juration> ownJurations;
    // final resOwnParticipations =
    //     await _jurationRepository.getJurationsByJurorId(jurorId: event.jurorId);
    // resOwnParticipations.fold(
    //   (failure) => emit(state.copyWith(status: BlocStatus.failure, message: failure.message)),
    //   (success) => ownJurations = success,
    // );
    // if (resOwnParticipations.isLeft()){
    //   return;
    // }
    //
    // //* Ottengo i contest
    // final List<Contest> contests = [];
    // for (var ownParticipation in ownJurations) {
    //   final contestId = ownParticipation.contestId;
    //   late final Contest? contest;
    //   final resContest = await _contestRepository.getContestById(id: contestId);
    //   resContest.fold(
    //     (failure) => emit(state.copyWith(status: BlocStatus.failure, message: failure.message)),
    //     (success) => contest = success,
    //   );
    //   if (resContest.isLeft()) {
    //
    //     return;
    //   }
    //   if(contest == null) {
    //     emit(state.copyWith(status: BlocStatus.failure,message: 'No contest found'));
    //     return;
    //   }
    //   else {
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
    //   if(organizer == null) {
    //     emit(state.copyWith(status: BlocStatus.failure,message: 'No organizer found'));
    //     return;
    //   }
    //   else {
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
    //   if(place == null) {
    //     emit(state.copyWith(status: BlocStatus.failure,message: 'No place found'));
    //     return;
    //   }
    //   else {
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

  //* Join contest
  FutureOr<void> _joinContest(
    JurorHomePageJoinContest event,
    Emitter<JurorHomePageState> emit,
  ) async {
    emit(state.copyWith(status: BlocStatus.loading, sourceEvent: event));

    final eitherJoinContest = await _jurorRepository.joinContest(
        jurorId: event.jurorId, token: event.token);
    eitherJoinContest.fold(
      (failure) => emit(state.copyWith(status: BlocStatus.failure, message: failure.message)),
      (success) => emit(state.copyWith(status: BlocStatus.success)),
    );

    // final eitherContest = await _contestRepository.getContestByToken(token: event.contestToken);
    // late final Contest contest;
    // eitherContest.fold(
    //   (failure) =>
    //       emit(JurorHomePageState(status: BlocStatus.failure, message: failure.message)),
    //   (success) => contest = success,
    // );
    // if (eitherContest.isLeft()) return;
    //
    // late final List<Invitation> invitations;
    // final eitherInvitations = await _invitationRepository.getInvitationsByContestIdAndMemberRole(
    //     contestId: contest.id, memberRole: MemberRole.juror);
    // eitherInvitations.fold(
    //   (failure) =>
    //       emit(JurorHomePageState(status: BlocStatus.failure, message: failure.message)),
    //   (success) => invitations = success,
    // );
    // if (eitherInvitations.isLeft()) return;
    //
    // if (invitations.isEmpty) {
    //   emit(JurorHomePageState(
    //       status: BlocStatus.failure, message: 'No invitation found with these credentials'));
    // }
    //
    // for (var invitation in invitations) {
    //   if (invitation.token == event.jurorToken) {
    //     late final Juration juration;
    //     final eitherJuration = await _jurationRepository.createJuration(
    //         juration: Juration(
    //       id: invitation.id,
    //       createdAt: DateTime.now(),
    //       contestId: contest.id,
    //       jurorId: event.jurorId,
    //       jurorStatus: JurorStatus.joined,
    //     ));
    //     eitherJuration.fold(
    //       (failure) =>
    //           emit(JurorHomePageState(status: BlocStatus.failure, message: failure.message)),
    //       (success) => juration = success,
    //     );
    //     if (eitherJuration.isLeft()) return;
    //
    //     final eitherDeleteInvitation =
    //         await _invitationRepository.deleteInvitationById(id: invitation.id);
    //     eitherDeleteInvitation.fold(
    //         (failure) => emit(
    //             JurorHomePageState(status: BlocStatus.failure, message: failure.message)),
    //         (success) => null);
    //     if (eitherDeleteInvitation.isLeft()) return;
    //
    //     emit(JurorHomePageState(status: BlocStatus.success));
    //     break;
    //   }
    // }
    //
    // emit(JurorHomePageState(
    //     status: BlocStatus.failure, message: 'No invitation found with these credentials'));
  }
}
