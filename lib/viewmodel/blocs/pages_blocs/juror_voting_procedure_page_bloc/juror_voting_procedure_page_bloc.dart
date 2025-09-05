import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fpdart/fpdart.dart';
import 'package:geolocator/geolocator.dart';
import 'package:swift_contest/model/database/bundles/juror_voting_session_procedure_bundle.dart';
import 'package:swift_contest/model/database/entities/voting_form_field.dart';
import 'package:swift_contest/model/database/entities/voting_session.dart';
import 'package:swift_contest/model/database/entities/voting_session_juror.dart';
import 'package:swift_contest/model/database/entities/voting_session_participant.dart';
import 'package:swift_contest/model/database/repositories/juror_repository.dart';
import 'package:swift_contest/utils/failures/failures.dart';
import 'package:swift_contest/viewmodel/types/bloc_status.dart';

part 'juror_voting_procedure_page_event.dart';
part 'juror_voting_procedure_page_state.dart';

class JurorVotingProcedurePageBloc
    extends Bloc<JurorVotingProcedurePageEvent, JurorVotingProcedurePageState> {
  final JurorRepository _jurorRepository;

  JurorVotingProcedurePageBloc({
    required JurorRepository jurorRepository,
  })  : _jurorRepository = jurorRepository,
        super(JurorVotingProcedurePageState(status: BlocStatus.initial)) {
    on<JurorVotingProcedurePageFetch>(_fetch);
    on<JurorVotingProcedurePageSubmit>(_submit);
    on<JurorVotingProcedurePageCheckVotingLocation>(_checkVotingLocation);
  }

  FutureOr<void> _fetch(
    JurorVotingProcedurePageFetch event,
    Emitter<JurorVotingProcedurePageState> emit,
  ) async {
    emit(state.copyWith(status: BlocStatus.loading, sourceEvent: event));

    //* Getting the voting session procedure bundle
    late final JurorVotingSessionProcedureBundle votingSessionProcedureBundle;
    final eitherVotingSessionBundle = await _jurorRepository.getVotingSessionProcedureBundle(
        votingSessionId: event.votingSessionId);
    eitherVotingSessionBundle.fold(
      (failure) => emit(state.copyWith(status: BlocStatus.failure, message: failure.message)),
      (success) => votingSessionProcedureBundle = success,
    );
    if(eitherVotingSessionBundle.isLeft()) {
      return;
    }

    // //* Get own voting session juration
    // late final VotingSessionJuror ownVotingSessionJuration;
    // final eitherVSJ =
    //     await _jurorRepository.getOwnVotingSessionJuration(votingSessionId: event.votingSessionId);
    // eitherVSJ.fold(
    //   (failure) => emit(state.copyWith(status: BlocStatus.failure, message: failure.message)),
    //   (success) => ownVotingSessionJuration = success,
    // );

    emit(state.copyWith(
      status: BlocStatus.success,
      isInitialized: true,
      votingSessionProcedureBundle: votingSessionProcedureBundle,
    ));

    final eitherStream =
        await _jurorRepository.getVotingSessionStream(votingSessionId: event.votingSessionId);

    if (eitherStream.isLeft()) {
      emit(state.copyWith(
          status: BlocStatus.failure, message: eitherStream.getLeft().toNullable()!.message));
    }
    final Stream<Either<Failure, VotingSession?>> votingSessionStream =
        eitherStream.getRight().toNullable()!;

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
        final oldVotingSession =
            state.votingSessionProcedureBundle!.votingSessionBundle.votingSession;
        if (newVotingSession == oldVotingSession) {
          return state;
        }

        return state.copyWith(
          status: BlocStatus.success,
          isInitialized: true,
          votingSessionProcedureBundle: state.votingSessionProcedureBundle!.copyWith(
              votingSessionBundle: state.votingSessionProcedureBundle!.votingSessionBundle
                  .copyWith(votingSession: newVotingSession)),
        );
      },
      // onError: (error, stackTrace) {
      //   return state.copyWith(status: BlocStatus.failure, message: 'An error occurred');
      // },
    );
  }

  FutureOr<void> _submit(
      JurorVotingProcedurePageSubmit event,
      Emitter<JurorVotingProcedurePageState> emit,
      ) async {
    emit(state.copyWith(status: BlocStatus.loading, sourceEvent: event));

    // 1. Trasforma le mappe dall'evento nel payload piatto richiesto dalla RPC.
    final List<Map<String, dynamic>> votesPayload = [];
    final votingSessionParticipantsExclusionsIds =
        state.votingSessionProcedureBundle!.votingSessionParticipantsExclusionsIds;

    // Aggiunge i voti dell'header (ID partecipante è nullo)
    event.headerFieldsValues.forEach((field, value) {
      votesPayload.add({
        'voting_form_field_id': field.id!,
        'value': value,
        'voting_session_participant_id': null,
      });
    });

    // Aggiunge i voti specifici per ogni partecipante
    event.participantFieldsValues.forEach((participant, votes) {
      final isExcluded = votingSessionParticipantsExclusionsIds.contains(participant.id);
      if (isExcluded) return; // Salta i partecipanti esclusi

      votes.forEach((field, value) {
        votesPayload.add({
          'voting_form_field_id': field.id!,
          'value': value,
          'voting_session_participant_id': participant.id!,
        });
      });
    });

    // Aggiunge i voti del footer (ID partecipante è nullo)
    event.footerFieldsValues.forEach((field, value) {
      votesPayload.add({
        'voting_form_field_id': field.id!,
        'value': value,
        'voting_session_participant_id': null,
      });
    });

    // 2. Prepara i parametri per la chiamata RPC.
    final votingSession = state.votingSessionProcedureBundle!.votingSessionBundle.votingSession;
    double? lat;
    double? lon;

    // Aggiunge la logica per ottenere la posizione se necessario
    if (votingSession.isGeoRestricted) {
      try {
        final status = await Geolocator.checkPermission();
        if (status == LocationPermission.denied) {
          final newStatus = await Geolocator.requestPermission();
          if (newStatus == LocationPermission.denied ||
              newStatus == LocationPermission.deniedForever) {
            emit(
                state.copyWith(status: BlocStatus.failure, message: 'Location permission denied.'));
            return;
          }
        }
        final position = await Geolocator.getCurrentPosition();
        lat = position.latitude;
        lon = position.longitude;
      } catch (e) {
        emit(state.copyWith(
            status: BlocStatus.failure, message: 'Could not get location: ${e.toString()}'));
        return;
      }
    }

    // 3. Chiama il repository con il payload piatto.
    final result = await _jurorRepository.submitVotes(
      votingSessionId: votingSession.id!,
      votesPayload: votesPayload,
      jurorLat: lat,
      jurorLon: lon,
    );

    result.fold(
          (failure) => emit(state.copyWith(status: BlocStatus.failure, message: failure.message)),
          (success) => emit(state.copyWith(status: BlocStatus.success, sourceEvent: event)),
    );
  }

  FutureOr<void> _checkVotingLocation(
      JurorVotingProcedurePageCheckVotingLocation event,
      Emitter<JurorVotingProcedurePageState> emit,
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
    final geoResPlace = state.votingSessionProcedureBundle?.votingSessionBundle.geoResPlace;
    if (geoResPlace == null) {
      emit(state.copyWith(status: BlocStatus.failure, message: 'An error occurred.'));
    }
    final distance = Geolocator.distanceBetween(
      geoResPlace!.lat,
      geoResPlace.lon,
      currentPosition.latitude,
      currentPosition.longitude,
    );

    if (distance > state.votingSessionProcedureBundle!.votingSessionBundle.votingSession.geoResRadius!) {
      emit(state.copyWith(
          status: BlocStatus.failure, message: 'You are not inside the area of voting.'));
      return;
    }

    emit(state.copyWith(status: BlocStatus.success, message: 'You are inside the area of voting.'));
  }
}
