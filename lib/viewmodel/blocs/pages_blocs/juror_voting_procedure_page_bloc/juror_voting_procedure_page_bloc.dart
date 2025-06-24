import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:swift_contest/model/bundles/voting_session_bundle.dart';
import 'package:swift_contest/model/data_models/place.dart';
import 'package:swift_contest/model/data_models/voting_form_field.dart';
import 'package:swift_contest/model/data_models/voting_session.dart';
import 'package:swift_contest/model/data_models/voting_session_participation.dart';
import 'package:swift_contest/model/repositories/role_repositories/juror_repository.dart';
import 'package:swift_contest/utils/failures/failures.dart';
import 'package:swift_contest/viewmodel/enums/bloc_status.dart';

part 'juror_voting_procedure_page_event.dart';
part 'juror_voting_procedure_page_state.dart';

class JurorVotingProcedurePageBloc
    extends Bloc<JurorVotingProcedurePageEvent, JurorVotingProcedurePageState> {
  final JurorRepository _jurorRepository;

  JurorVotingProcedurePageBloc({
    required JurorRepository jurorRepository,
  })  :
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

    //* Getting the voting session bundle
    late final VotingSessionBundle votingSessionBundle;
    final eitherVotingSessionBundle =
    await _jurorRepository.getVotingSessionDetails(votingSessionId: event.votingSessionId);
    eitherVotingSessionBundle.fold(
          (failure) => emit(state.copyWith(status: BlocStatus.failure, message: failure.message)),
          (success) => votingSessionBundle = success,
    );

    //* Getting the stream
    late final Stream<Either<Failure, VotingSession?>> votingSessionStream;
    final eitherVotingSessionStream =
    await _jurorRepository.getVotingSessionStream(votingSessionId: event.votingSessionId);
    eitherVotingSessionStream.fold(
          (failure) => emit(state.copyWith(status: BlocStatus.failure, message: failure.message)),
          (success) => votingSessionStream = success,
    );
    if (eitherVotingSessionStream.isLeft()) {
      return;
    }

    //* Emit the initial voting session bundle
    emit(state.copyWith(status: BlocStatus.success, votingSessionBundle: votingSessionBundle));

    //* Listen to procedure stream
    await emit.forEach(
      votingSessionStream,
      onData: (eitherNewVotingSession) {
        late VotingSession? newVotingSession;

        eitherNewVotingSession.fold(
              (failure) => null,
              (success) => newVotingSession = success,
        );
        if (eitherNewVotingSession.isLeft()) {
          return state.copyWith(status: BlocStatus.failure, message: 'No data received');
        }

        if (newVotingSession == null) {
          return state;
        }
        final oldVotingSessionProcedure = state.votingSessionBundle!.votingSession;
        if (newVotingSession == oldVotingSessionProcedure) {
          return state;
        }

        return state.copyWith(
          status: BlocStatus.success,
          votingSessionBundle: state.votingSessionBundle!.copyWith(votingSession: newVotingSession),
        );
      },
      onError: (error, stackTrace) {
        return state.copyWith(status: BlocStatus.failure, message: 'An error occurred');
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
          await _jurorRepository.getVotingSessionGeoRestrictionPlace(placeId: votingSession.geoRestrictionPlaceId!);
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
        contestId: event.votingSession.contestId,
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
