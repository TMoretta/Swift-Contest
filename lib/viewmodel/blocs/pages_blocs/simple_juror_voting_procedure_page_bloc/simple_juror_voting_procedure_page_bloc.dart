import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:swift_contest/model/bundles/voting_session_procedure_bundle.dart';
import 'package:swift_contest/model/data_models/place.dart';
import 'package:swift_contest/model/data_models/voting_form_field.dart';
import 'package:swift_contest/model/data_models/voting_session.dart';
import 'package:swift_contest/model/data_models/voting_session_participation.dart';
import 'package:swift_contest/model/repositories/generic_repository.dart';
import 'package:swift_contest/model/repositories/juror_repository.dart';
import 'package:swift_contest/utils/failures/failures.dart';
import 'package:swift_contest/viewmodel/enums/bloc_status.dart';

part 'simple_juror_voting_procedure_page_event.dart';

part 'simple_juror_voting_procedure_page_state.dart';

class SimpleJurorVotingProcedurePageBloc
    extends Bloc<SimpleJurorVotingProcedurePageEvent, SimpleJurorVotingProcedurePageState> {
  final GenericRepository _genericRepository;
  final JurorRepository _jurorRepository;

  SimpleJurorVotingProcedurePageBloc({
    required GenericRepository genericRepository,
    required JurorRepository jurorRepository,
  })  :

        _genericRepository = genericRepository,
        _jurorRepository = jurorRepository,
        super(SimpleJurorVotingProcedurePageState(status: BlocStatus.loading)) {
    on<SimpleJurorVotingProcedurePageInit>(_init);
    on<SimpleJurorVotingProcedurePageRefresh>(_refresh);
    on<SimpleJurorVotingProcedurePageSubmitVotes>(_submitVotes);
  }

  FutureOr<void> _init(
    SimpleJurorVotingProcedurePageInit event,
    Emitter<SimpleJurorVotingProcedurePageState> emit,
  ) async {
    emit(state.copyWith(status: BlocStatus.loading, sourceEvent: event));

    //* Getting the voting session bundle
    late final VotingSessionProcedureBundle votingSessionBundle;
    final eitherVotingSessionBundle = await _genericRepository.getVotingSessionProcedureBundle(
        votingSessionId: event.votingSessionId);
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
    emit(state.copyWith(
        status: BlocStatus.success, votingSessionProcedureBundle: votingSessionBundle));

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
        final oldVotingSession = state.votingSessionProcedureBundle!.votingSessionBundle.votingSession;
        if (newVotingSession == oldVotingSession) {
          return state;
        }

        return state.copyWith(
          status: BlocStatus.success,
          votingSessionProcedureBundle: state.votingSessionProcedureBundle!.copyWith(
              votingSessionBundle: state.votingSessionProcedureBundle!.votingSessionBundle
                  .copyWith(votingSession: newVotingSession)),
        );
      },
      onError: (error, stackTrace) {
        return state.copyWith(status: BlocStatus.failure, message: 'An error occurred');
      },
    );
  }

  FutureOr<void> _refresh(
      SimpleJurorVotingProcedurePageRefresh event,
      Emitter<SimpleJurorVotingProcedurePageState> emit,
      ) async {
    emit(state.copyWith(status: BlocStatus.loading, sourceEvent: event));

    //* Getting the voting session bundle
    late final VotingSessionProcedureBundle votingSessionBundle;
    final eitherVotingSessionBundle = await _genericRepository.getVotingSessionProcedureBundle(
        votingSessionId: event.votingSessionId);
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
    emit(state.copyWith(
        status: BlocStatus.success, votingSessionProcedureBundle: votingSessionBundle));

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
        final oldVotingSession = state.votingSessionProcedureBundle!.votingSessionBundle.votingSession;
        if (newVotingSession == oldVotingSession) {
          return state;
        }

        return state.copyWith(
          status: BlocStatus.success,
          votingSessionProcedureBundle: state.votingSessionProcedureBundle!.copyWith(
              votingSessionBundle: state.votingSessionProcedureBundle!.votingSessionBundle
                  .copyWith(votingSession: newVotingSession)),
        );
      },
      onError: (error, stackTrace) {
        return state.copyWith(status: BlocStatus.failure, message: 'An error occurred');
      },
    );
  }

  FutureOr<void> _submitVotes(
    SimpleJurorVotingProcedurePageSubmitVotes event,
    Emitter<SimpleJurorVotingProcedurePageState> emit,
  ) async {
    emit(state.copyWith(status: BlocStatus.loading, sourceEvent: event));

    final votingSession = event.votingSession;
    final Place? geoResPlace = event.geoResPlace;

    if (votingSession.isGeoRestricted && geoResPlace!=null) {
      final status = await Geolocator.checkPermission();
      if (status == LocationPermission.denied) {
        await Geolocator.requestPermission();
      }
      final currentPosition = await Geolocator.getCurrentPosition();

      final distance = Geolocator.distanceBetween(
        geoResPlace.lat,
        geoResPlace.lon,
        currentPosition.latitude,
        currentPosition.longitude,
      );

      if (distance > votingSession.geoResRadius!) {
        emit(state.copyWith(
            status: BlocStatus.failure,
            message:
                'The voting is georestricted and you are not inside the area of voting:\n${geoResPlace.address}'));
        return;
      }
    }

    final eitherSubmitVotes = await _jurorRepository.simpleJurorSubmitVotes(
        simpleJurorId: event.simpleJurorId,
        votingSessionId: event.votingSession.id,
        contestId: event.votingSession.contestId,
        votesPerParticipantMap: event.votesPerParticipantMap);
    eitherSubmitVotes.fold(
      (failure) => emit(state.copyWith(status: BlocStatus.failure, message: failure.message)),
      (success) => emit(state.copyWith(status: BlocStatus.success)),
    );
  }
}
