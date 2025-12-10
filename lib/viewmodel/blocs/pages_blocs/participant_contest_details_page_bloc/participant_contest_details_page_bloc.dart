import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:swift_contest/model/database/bundles/participant_contest_details_bundle.dart';
import 'package:swift_contest/model/database/repositories/participant_repository.dart';
import 'package:swift_contest/model/database/repositories/storage_repository.dart';
import 'package:swift_contest/model/database/types/storage_bucket.dart';
import 'package:swift_contest/viewmodel/types/bloc_status.dart';

part 'participant_contest_details_page_event.dart';
part 'participant_contest_details_page_state.dart';

class ParticipantContestDetailsPageBloc
    extends Bloc<ParticipantContestDetailsPageEvent, ParticipantContestDetailsPageState> {
  final ParticipantRepository _participantRepository;
  final StorageRepository _storageRepository;

  ParticipantContestDetailsPageBloc({
    required ParticipantRepository participantRepository,
    required StorageRepository storageRepository,
  })  : _participantRepository = participantRepository,
        _storageRepository = storageRepository,
        super(const ParticipantContestDetailsPageState(status: BlocStatus.initial)) {
    on<ParticipantContestDetailsPageFetch>(_fetch);
    on<ParticipantContestDetailsPageLeaveContest>(_leaveContest);
    on<ParticipantContestDetailsPageGetRankingFileUrl>(_getRankingFileUrl);
    on<ParticipantContestDetailsPageGetWorkFileUrl>(_getWorkFileUrl);
  }

  FutureOr<void> _fetch(
    ParticipantContestDetailsPageFetch event,
    Emitter<ParticipantContestDetailsPageState> emit,
  ) async {
    emit(state.copyWith(status: BlocStatus.loading, sourceEvent: event));

    late final ParticipantContestDetailsBundle contestDetailsBundle;
    final eitherContestDetails =
        await _participantRepository.getContestDetails(contestId: event.contestId);
    eitherContestDetails.fold(
      (failure) => emit(state.copyWith(status: BlocStatus.failure, message: failure.message)),
      (success) => contestDetailsBundle = success,
    );

    emit(state.copyWith(
        status: BlocStatus.success,
        isInitialized: true,
        contestDetailsBundle: contestDetailsBundle));
  }

  FutureOr<void> _leaveContest(
    ParticipantContestDetailsPageLeaveContest event,
    Emitter<ParticipantContestDetailsPageState> emit,
  ) async {
    emit(state.copyWith(status: BlocStatus.loading, sourceEvent: event));

    final eitherLeaveContest =
        await _participantRepository.leaveContest(contestId: event.contestId);
    eitherLeaveContest.fold(
      (failure) => emit(state.copyWith(status: BlocStatus.failure, message: failure.message)),
      (success) => emit(state.copyWith(status: BlocStatus.success)),
    );
  }

  FutureOr<void> _getRankingFileUrl(
    ParticipantContestDetailsPageGetRankingFileUrl event,
    Emitter<ParticipantContestDetailsPageState> emit,
  ) async {
    emit(state.copyWith(status: BlocStatus.loading, sourceEvent: event));

    final res =
        await _storageRepository.getSignedUrl(bucket: StorageBucket.contestsRankings, path: event.filePath);
    res.fold(
      (failure) => emit(state.copyWith(status: BlocStatus.failure, message: failure.message)),
      (success) => emit(state.copyWith(status: BlocStatus.success, rankingFileUrl: success)),
    );
  }

  FutureOr<void> _getWorkFileUrl(
    ParticipantContestDetailsPageGetWorkFileUrl event,
    Emitter<ParticipantContestDetailsPageState> emit,
  ) async {
    emit(state.copyWith(status: BlocStatus.loading, sourceEvent: event));

    final res =
        await _storageRepository.getSignedUrl(bucket: StorageBucket.worksFiles, path: event.filePath);
    res.fold(
      (failure) => emit(state.copyWith(status: BlocStatus.failure, message: failure.message)),
      (success) => emit(state.copyWith(status: BlocStatus.success, workFileUrl: success)),
    );
  }

}
