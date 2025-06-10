import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:swift_contest/model/bundles/contest_details_bundle.dart';
import 'package:swift_contest/model/bundles/juror_voting_session_bundle.dart';
import 'package:swift_contest/model/bundles/voting_session_juration_bundle.dart';
import 'package:swift_contest/model/bundles/voting_session_participation_bundle.dart';
import 'package:swift_contest/model/data_models/place.dart';
import 'package:swift_contest/model/data_models/voting_form_field.dart';
import 'package:swift_contest/model/data_models/voting_session.dart';
import 'package:swift_contest/model/data_models/voting_session_exclusion.dart';
import 'package:swift_contest/model/data_models/voting_session_juration.dart';
import 'package:swift_contest/model/data_models/voting_session_participation.dart';
import 'package:swift_contest/model/data_models/voting_session_procedure.dart';
import 'package:swift_contest/model/repositories/crud_repositories/juration_repository.dart';
import 'package:swift_contest/model/repositories/role_repositories/juror_repository.dart';
import 'package:swift_contest/model/repositories/crud_repositories/juror_vote_repository.dart';
import 'package:swift_contest/model/repositories/crud_repositories/juror_voting_repository.dart';
import 'package:swift_contest/model/repositories/role_repositories/organizer_repository.dart';
import 'package:swift_contest/model/repositories/crud_repositories/place_repository.dart';
import 'package:swift_contest/model/repositories/crud_repositories/voting_session_exclusion_repository.dart';
import 'package:swift_contest/model/repositories/crud_repositories/voting_session_juration_repository.dart';
import 'package:swift_contest/model/repositories/crud_repositories/voting_session_participation_repository.dart';
import 'package:swift_contest/model/repositories/crud_repositories/voting_session_procedure_repository.dart';
import 'package:swift_contest/utils/failures/failures.dart';
import 'package:swift_contest/viewmodel/enums/bloc_status.dart';
import 'package:swift_contest/viewmodel/enums/bloc_status_failure_type.dart';

part 'juror_voting_procedure_page_event.dart';
part 'juror_voting_procedure_page_state.dart';

class JurorVotingProcedurePageBloc
    extends Bloc<JurorVotingProcedurePageEvent, JurorVotingProcedurePageState> {
  final PlaceRepository _placeRepository;
  final VotingSessionJurationRepository _votingSessionJurationRepository;
  final VotingSessionParticipationRepository _votingSessionParticipationRepository;
  final JurationRepository _jurationRepository;
  final JurorVotingRepository _jurorVotingRepository;
  final JurorVoteRepository _jurorVoteRepository;
  final VotingSessionExclusionRepository _votingSessionExclusionRepository;
  final JurorRepository _jurorRepository;

  JurorVotingProcedurePageBloc({
    required PlaceRepository placeRepository,
    required VotingSessionJurationRepository votingSessionJurationRepository,
    required JurationRepository jurationRepository,
    required VotingSessionParticipationRepository votingSessionParticipationRepository,
    required JurorVotingRepository jurorVotingRepository,
    required JurorVoteRepository jurorVoteRepository,
    required VotingSessionExclusionRepository votingSessionExclusionsBundles,
    required JurorRepository jurorRepository,
  })  :
        _placeRepository = placeRepository,
        _votingSessionJurationRepository = votingSessionJurationRepository,
        _jurationRepository = jurationRepository,
        _votingSessionParticipationRepository = votingSessionParticipationRepository,
        _jurorVotingRepository = jurorVotingRepository,
        _jurorVoteRepository = jurorVoteRepository,
        _votingSessionExclusionRepository = votingSessionExclusionsBundles,
        _jurorRepository = jurorRepository,
        super(JurorVotingProcedurePageState(status: BlocStatus.initial)) {
    on<JurorVotingProcedurePageSubscribeToVotingSessionProcedure>(
        _subscribeToVotingSessionProcedure);
    on<JurorVotingProcedurePageSubmitVotes>(_submitVotes);
  }

  FutureOr<void> _subscribeToVotingSessionProcedure(
    JurorVotingProcedurePageSubscribeToVotingSessionProcedure event,
    Emitter<JurorVotingProcedurePageState> emit,
  ) async {
    emit(state.copyWith(status: BlocStatus.loading, sourceEvent: event));

    final contestDetailsBundle = event.contestDetailsBundle;

    if (contestDetailsBundle.liveVotingSession == null) {
      emit(state.copyWith(
          status: BlocStatus.failure,
          // failureType: BlocStatusFailureType.requestPop,
          message: 'No session live'));
      return;
    }
    final votingSession = contestDetailsBundle.liveVotingSession!;

    late final List<VotingSessionParticipation> votingSessionParticipations;
    final eitherVotingSessionParticipation = await _votingSessionParticipationRepository
        .getVotingSessionParticipationsByVotingSessionId(votingSessionId: votingSession.id);
    eitherVotingSessionParticipation.fold(
      (failure) => emit(state.copyWith(
          status: BlocStatus.failure,
          // failureType: BlocStatusFailureType.requestRefresh,
          message: failure.message)),
      (success) => votingSessionParticipations = success,
    );

    late final List<VotingSessionJuration> votingSessionJurations;
    final eitherVotingSessionJuration = await _votingSessionJurationRepository
        .getVotingSessionJurationsByVotingSessionId(votingSessionId: votingSession.id);
    eitherVotingSessionJuration.fold(
      (failure) => emit(state.copyWith(
          status: BlocStatus.failure,
          // failureType: BlocStatusFailureType.requestRefresh,
          message: failure.message)),
      (success) => votingSessionJurations = success,
    );

    final List<VotingSessionParticipationBundle> votingSessionParticipationsBundles = [];
    for (var votingSessionParticipation in votingSessionParticipations) {
      final participationBundle = contestDetailsBundle.participationsBundles
          .firstWhere((e) => e.participation.id == votingSessionParticipation.participationId);
      votingSessionParticipationsBundles.add(VotingSessionParticipationBundle(
        votingSessionParticipation: votingSessionParticipation,
        participationBundle: participationBundle,
      ));
    }

    final List<VotingSessionJurationBundle> votingSessionJurationsBundles = [];
    for (var votingSessionJuration in votingSessionJurations) {
      final jurationBundle = contestDetailsBundle.jurationsBundles
          .firstWhere((e) => e.juration.id == votingSessionJuration.jurationId);
      votingSessionJurationsBundles.add(VotingSessionJurationBundle(
        votingSessionJuration: votingSessionJuration,
        jurationBundle: jurationBundle,
      ));
    }

    late final List<VotingSessionParticipation> votingSessionParticipationsExcludedFrom;
    final ownVotingSessionJuration = votingSessionJurationsBundles
        .firstWhere((e) => e.jurationBundle.juror.id == event.jurorId)
        .votingSessionJuration;
    late final List<VotingSessionExclusion> ownVotingSessionExclusions;
    final eitherVotingSessionExclusion =
        await _votingSessionExclusionRepository.getVotingSessionExclusionsByVotingSessionJurationId(
            votingSessionJurationId: ownVotingSessionJuration.id);
    eitherVotingSessionExclusion.fold(
      (failure) => emit(state.copyWith(
          status: BlocStatus.failure,
          // failureType: BlocStatusFailureType.requestRefresh,
          message: failure.message)),
      (success) => ownVotingSessionExclusions = success,
    );
    if (eitherVotingSessionExclusion.isLeft()) {
      return;
    }
    final votingSessionParticipationsIdsInExclusion = ownVotingSessionExclusions
        .map((e) => e.votingSessionParticipationId)
        .toList(growable: false);
    votingSessionParticipationsExcludedFrom = votingSessionParticipations
        .where((e) => votingSessionParticipationsIdsInExclusion.contains(e.id))
        .toList(growable: false);

    final votingSessionBundle = JurorVotingSessionBundle(
      votingSession: votingSession,
      votingFormBundle: contestDetailsBundle.votingFormBundle,
      votingSessionParticipationsBundles: votingSessionParticipationsBundles,
      votingSessionParticipationsExcludedFrom: votingSessionParticipationsExcludedFrom,
    );

    emit(state.copyWith(
      status: BlocStatus.success,
      votingSessionBundle: votingSessionBundle,
    ));

    late final Stream<Either<Failure, VotingSession?>>
        votingSessionStream;
    final eitherVotingSessionStream = await _jurorRepository
        .getVotingSessionStream(votingSessionId: votingSession.id);
    eitherVotingSessionStream.fold(
      (failure) => emit(state.copyWith(status: BlocStatus.failure, message: failure.message)),
      (success) => votingSessionStream = success,
    );
    if (eitherVotingSessionStream.isLeft()) {
      return;
    }

    await emit.forEach(
      votingSessionStream,
      onData: (eitherNewVotingSession) {
        late VotingSession? newVotingSession;

        eitherNewVotingSession.fold(
          (failure) => null,
          (success) => newVotingSession = success,
        );
        if (eitherNewVotingSession.isLeft()) {
          return state.copyWith(
              status: BlocStatus.failure,
              // failureType: BlocStatusFailureType.showPreviousState,
              message: 'No data received');
        }
        if(newVotingSession == null) {
          return state;
        }

        final oldVotingSession = state.votingSessionBundle!.votingSession;
        if (newVotingSession == oldVotingSession) {
          return state;
        }

        return state.copyWith(
          status: BlocStatus.success,
          votingSessionBundle: state.votingSessionBundle!
              .copyWith(votingSession: newVotingSession),
        );
      },
      onError: (error, stackTrace) {
        return state.copyWith(
            status: BlocStatus.failure,
            // failureType: BlocStatusFailureType.requestRefresh,
            message: error.toString());
      },
    );
  }

  FutureOr<void> _submitVotes(
    JurorVotingProcedurePageSubmitVotes event,
    Emitter<JurorVotingProcedurePageState> emit,
  ) async {
    emit(state.copyWith(status: BlocStatus.loading, sourceEvent: event));

    final votingSession = event.votingSession;

    if (votingSession.isGeoRestricted) {
      final status = await Geolocator.checkPermission();
      if (status == LocationPermission.denied) {
        await Geolocator.requestPermission();
      }
      final currentPosition = await Geolocator.getCurrentPosition();

      late final Place? geoRestrictionPlace;
      final eitherGeoRestrictionPlace =
          await _placeRepository.getPlaceById(id: votingSession.geoRestrictionPlaceId!);
      eitherGeoRestrictionPlace.fold(
        (failure) => emit(state.copyWith(status: BlocStatus.failure, message: failure.message)),
        (success) => geoRestrictionPlace = success,
      );
      if (eitherGeoRestrictionPlace.isLeft()) {
        return;
      }
      if(geoRestrictionPlace == null) {
        emit(state.copyWith(status: BlocStatus.failure,message: 'No place found'));
        return;
      }

      final distance = Geolocator.distanceBetween(
        geoRestrictionPlace!.lat,
        geoRestrictionPlace!.lon,
        currentPosition.latitude,
        currentPosition.longitude,
      );

      if (distance > votingSession.geoRestrictionRadius!) {
        emit(state.copyWith(
            status: BlocStatus.failure,
            message:
                'The voting is georestricted and you are not inside the area of voting:\n${geoRestrictionPlace!.address}'));
        return;
      }
    }

    final eitherSubmitVotes = await _jurorRepository.submitVotes(
        jurorId: event.jurorId,
        votingSessionId: event.votingSession.id,
        contestId: event.contestId,
        votesPerParticipantMap: event.votesPerParticipantMap);
    eitherSubmitVotes.fold(
      (failure) => emit(state.copyWith(status: BlocStatus.failure, message: failure.message)),
      (success) => emit(state.copyWith(status: BlocStatus.success)),
    );

    // late final Juration juration;
    // final eitherJuration = await _jurationRepository.getJurationByContestIdAndJurorId(
    //     contestId: event.contestId, jurorId: event.jurorId);
    // eitherJuration.fold(
    //   (failure) => emit(state.copyWith(status: BlocStatus.failure, message: failure.message)),
    //   (success) => juration = success,
    // );
    // if (eitherJuration.isLeft()) {
    //   return;
    // }
    //
    // late final VotingSessionJuration votingSessionJuration;
    // final eitherVotingSessionJuration = await _votingSessionJurationRepository
    //     .getVotingSessionJurationByVotingSessionIdAndJurationId(
    //         votingSessionId: votingSession.id, jurationId: juration.id);
    // eitherVotingSessionJuration.fold(
    //   (failure) => emit(state.copyWith(status: BlocStatus.failure, message: failure.message)),
    //   (success) => votingSessionJuration = success,
    // );
    // if (eitherVotingSessionJuration.isLeft()) {
    //   return;
    // }
    //
    // final votesPerParticipantList = event.votesPerParticipantMap.entries;
    // for (var votesPerParticipant in votesPerParticipantList) {
    //   final VotingSessionParticipation votingSessionParticipation = votesPerParticipant.key;
    //   final votesList = votesPerParticipant.value.entries;
    //
    //   late final JurorVoting jurorVoting;
    //   final eitherJurorVoting = await _jurorVotingRepository.createJurorVoting(
    //       jurorVoting: JurorVoting(
    //         id: genUuid(),
    //         createdAt: now(),
    //         votingSessionJurationId: votingSessionJuration.id,
    //         votingSessionParticipationId: votingSessionParticipation.id,
    //       ));
    //   eitherJurorVoting.fold(
    //       (failure) => emit(state.copyWith(status: BlocStatus.failure, message: failure.message)),
    //       (success) => jurorVoting = success,
    //   );
    //   if(eitherJurorVoting.isLeft()) {
    //     return;
    //   }
    //
    //   for (var v in votesList) {
    //     final VotingFormField votingFormField = v.key;
    //     final int value = v.value;
    //
    //     late final JurorVote vote;
    //     final eitherVote = await _jurorVoteRepository.createJurorVote(
    //       jurorVote: JurorVote(
    //         id: genUuid(),
    //         createdAt: now(),
    //         jurorVotingId: jurorVoting.id,
    //         votingFormFieldId: votingFormField.id,
    //         value: value,
    //       ),
    //     );
    //     eitherVote.fold(
    //       (failure) => emit(state.copyWith(status: BlocStatus.failure, message: failure.message)),
    //       (success) => vote = success,
    //     );
    //     if (eitherVote.isLeft()) {
    //       return;
    //     }
    //   }
    // }
    //
    // final eitherVotingSessionJurorUpdate =
    //     await _votingSessionJurationRepository.updateVotingSessionJuration(
    //   votingSessionJuration: votingSessionJuration.copyWith(hasSubmitted: true),
    // );
    // eitherVotingSessionJurorUpdate.fold(
    //   (failure) => emit(state.copyWith(status: BlocStatus.failure, message: failure.message)),
    //   (success) => null,
    // );
    // if (eitherVotingSessionJurorUpdate.isLeft()) {
    //   return;
    // }
    //
    // emit(state.copyWith(status: BlocStatus.success));
  }
}
