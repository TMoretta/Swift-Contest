import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:swift_contest/model/database/bundles/juror_contest_details_bundle.dart';
import 'package:swift_contest/model/database/repositories/juror_repository.dart';
import 'package:swift_contest/model/database/repositories/storage_repository.dart';
import 'package:swift_contest/model/database/types/storage_bucket.dart';
import 'package:swift_contest/utils/logger/logger.dart';
import 'package:swift_contest/viewmodel/types/bloc_status.dart';

part 'juror_contest_details_page_event.dart';

part 'juror_contest_details_page_state.dart';

class JurorContestDetailsPageBloc
    extends Bloc<JurorContestDetailsPageEvent, JurorContestDetailsPageState> {
  final JurorRepository _jurorRepository;
  final StorageRepository _storageRepository;

  JurorContestDetailsPageBloc({
    required JurorRepository jurorRepository,
    required StorageRepository storageRepository,
  })  : _jurorRepository = jurorRepository,
        _storageRepository = storageRepository,
        super(JurorContestDetailsPageState(status: BlocStatus.initial)) {
    on<JurorContestDetailsPageFetch>(_fetch);
    on<JurorContestDetailsPageLeaveContest>(_leaveContest);
    on<JurorContestDetailsPageGetRankingFileUrl>(_getRankingFileUrl);
    on<JurorContestDetailsPageCheckVotingLocation>(_checkVotingLocation);
  }

  @override
  JurorContestDetailsPageState? fromJson(Map<String, dynamic> json) {
    try {
      return JurorContestDetailsPageState.fromJson(json);
    } catch (e) {
      Logger.error(e);
      return null;
    }
  }

  @override
  Map<String, dynamic>? toJson(JurorContestDetailsPageState state) {
    try {
      return state.toJson();
    } catch (e) {
      Logger.error(e);
      return null;
    }
  }

  FutureOr<void> _fetch(
    JurorContestDetailsPageFetch event,
    Emitter<JurorContestDetailsPageState> emit,
  ) async {
    emit(state.copyWith(status: BlocStatus.loading, sourceEvent: event));

    late final JurorContestDetailsBundle contestDetailsBundle;
    final eitherContestDetails =
        await _jurorRepository.getContestDetails(contestId: event.contestId);
    eitherContestDetails.fold(
      (failure) => emit(state.copyWith(status: BlocStatus.failure, message: failure.message)),
      (success) => contestDetailsBundle = success,
    );
    if (eitherContestDetails.isLeft()) {
      return;
    }

    emit(state.copyWith(
        status: BlocStatus.success,
        isInitialized: true,
        contestDetailsBundle: contestDetailsBundle)); //todo remove

    //TODO add
    // if (contestDetailsBundle.liveVotingSession == null) {
    //   emit(state.copyWith(status: BlocStatus.success, isInitialized: true, contestDetailsBundle: contestDetailsBundle));
    //   return;
    // }
    // final eitherProcedureBundle = await _jurorRepository.getVotingSessionProcedureBundle(
    //     votingSessionId: contestDetailsBundle.liveVotingSession!.id);
    // eitherProcedureBundle.fold(
    //   (failure) => emit(state.copyWith(status: BlocStatus.failure, message: failure.message)),
    //   (success) => emit(state.copyWith(
    //       status: BlocStatus.success,
    //       isInitialized: true,
    //       contestDetailsBundle: contestDetailsBundle,
    //       votingSessionProcedureBundle: success)),
    // );
  }

  FutureOr<void> _leaveContest(
    JurorContestDetailsPageLeaveContest event,
    Emitter<JurorContestDetailsPageState> emit,
  ) async {
    emit(state.copyWith(status: BlocStatus.loading, sourceEvent: event));

    final eitherLeaveContest = await _jurorRepository.leaveContest(contestId: event.contestId);
    eitherLeaveContest.fold(
      (failure) => emit(state.copyWith(status: BlocStatus.failure, message: failure.message)),
      (success) => emit(state.copyWith(status: BlocStatus.success)),
    );
  }

  FutureOr<void> _getRankingFileUrl(
    JurorContestDetailsPageGetRankingFileUrl event,
    Emitter<JurorContestDetailsPageState> emit,
  ) async {
    emit(state.copyWith(status: BlocStatus.loading, sourceEvent: event));

    final res =
        await _storageRepository.getSignedUrl(bucket: StorageBucket.contestsRankings, path: event.filePath);
    res.fold(
      (failure) => emit(state.copyWith(status: BlocStatus.failure, message: failure.message)),
      (success) => emit(state.copyWith(status: BlocStatus.success, rankingFileUrl: success)),
    );
  }

  FutureOr<void> _checkVotingLocation(
    JurorContestDetailsPageCheckVotingLocation event,
    Emitter<JurorContestDetailsPageState> emit,
  ) async {
    emit(state.copyWith(status: BlocStatus.loading, sourceEvent: event));

    final status = await Geolocator.checkPermission();
    if (status == LocationPermission.denied) {
      final newStatus = await Geolocator.requestPermission();
      if (newStatus == LocationPermission.denied || newStatus == LocationPermission.deniedForever) {
        emit(state.copyWith(
            status: BlocStatus.failure, message: 'Location permission denied. Can not verify.'));
        return;
      }
    }
    final currentPosition = await Geolocator.getCurrentPosition();
    final geoResPlace = state.contestDetailsBundle?.liveVotingSessionBundle?.geoResPlace;
    if (geoResPlace == null) {
      emit(state.copyWith(status: BlocStatus.failure, message: 'An error occurred.'));
    }
    final distance = Geolocator.distanceBetween(
      geoResPlace!.lat,
      geoResPlace.lon,
      currentPosition.latitude,
      currentPosition.longitude,
    );

    if (distance >
        state.contestDetailsBundle!.liveVotingSessionBundle!.votingSession.geoResRadius!) {
      emit(state.copyWith(
          status: BlocStatus.failure, message: 'You are not inside the area of voting.'));
      return;
    }

    emit(state.copyWith(status: BlocStatus.success, message: 'You are inside the area of voting.'));
  }
}
