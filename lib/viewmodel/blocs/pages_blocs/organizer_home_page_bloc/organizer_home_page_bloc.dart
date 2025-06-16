import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:swift_contest/model/bundles/home_contest_bundle.dart';
import 'package:swift_contest/model/repositories/role_repositories/organizer_repository.dart';
import 'package:swift_contest/viewmodel/enums/bloc_status.dart';

part 'organizer_home_page_event.dart';
part 'organizer_home_page_state.dart';

class OrganizerHomePageBloc extends Bloc<OrganizerHomePageEvent, OrganizerHomePageState> {
  final OrganizerRepository _organizerRepository;

  OrganizerHomePageBloc({
    required OrganizerRepository organizerRepository,
  })  : _organizerRepository = organizerRepository,
        super(OrganizerHomePageState(status: BlocStatus.initial)) {
    on<OrganizerHomePageInit>(_init);
    on<OrganizerHomePageRefresh>(_refresh);
  }

  FutureOr<void> _init(
    OrganizerHomePageInit event,
    Emitter<OrganizerHomePageState> emit,
  ) async {
    emit(OrganizerHomePageState(status: BlocStatus.loading, sourceEvent: event));

    final eitherContests =
        await _organizerRepository.getCreatedContests(organizerId: event.organizerId);
    eitherContests.fold(
      (failure) => emit(state.copyWith(status: BlocStatus.failure, message: failure.message)),
      (success) =>
          emit(state.copyWith(status: BlocStatus.success, createdContestsBundles: success)),
    );

    // //* Ottengo i contest
    // final List<Contest> contests = [];
    // final resContest =
    // await _contestRepository.getContestsByOrganizerId(organizerId: event.organizerId);
    // resContest.fold(
    //       (failure) => emit(state.copyWith(status: BlocStatus.failure, message: failure.message)),
    //       (success) => contests.addAll(success),
    // );
    // if (resContest.isLeft()) {
    //   return;
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
    //         (failure) => emit(state.copyWith(status: BlocStatus.failure, message: failure.message)),
    //         (success) => organizer = success,
    //   );
    //   if (resOrganizer.isLeft()) {
    //     return;
    //   }
    //   if(organizer == null) {
    //     emit(state.copyWith(status: BlocStatus.failure,message: 'No organizer found'));
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
    //         (failure) => emit(state.copyWith(status: BlocStatus.failure, message: failure.message)),
    //         (success) => place = success,
    //   );
    //   if (resPlace.isLeft()) {
    //     return;
    //   }
    //   if(place == null) {
    //     emit(state.copyWith(status: BlocStatus.failure, message: 'No place found'));
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
    //   await _participationRepository.getParticipationsByContestId(contestId: contest.id);
    //   resParticipations.fold(
    //         (failure) => emit(state.copyWith(status: BlocStatus.failure, message: failure.message)),
    //         (success) => participations.add(success),
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
    //         (failure) => emit(state.copyWith(status: BlocStatus.failure, message: failure.message)),
    //         (success) => jurations.add(success),
    //   );
    //
    //   if (resJurations.isLeft()) {
    //     return;
    //   }
    // }
    //
    // //* Merging all in bundles
    // final List<ContestCardBundle> createdContestsBundles = [];
    // for (int i = 0; i < contests.length; i++) {
    //   createdContestsBundles.add(
    //     ContestCardBundle(
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
    //   createdContestsBundles: createdContestsBundles,
    // ));
  }

  FutureOr<void> _refresh(OrganizerHomePageRefresh event, Emitter<OrganizerHomePageState> emit,)async {
    emit(OrganizerHomePageState(status: BlocStatus.loading, sourceEvent: event));

    final eitherContests =
    await _organizerRepository.getCreatedContests(organizerId: event.organizerId);
    eitherContests.fold(
          (failure) => emit(state.copyWith(status: BlocStatus.failure, message: failure.message)),
          (success) =>
          emit(state.copyWith(status: BlocStatus.success, createdContestsBundles: success)),
    );
  }
}
