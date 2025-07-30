import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fpdart/fpdart.dart';
import 'package:geolocator/geolocator.dart';
import 'package:swift_contest/model/db/bundles/voting_session_procedure_bundle.dart';
import 'package:swift_contest/model/db/entities/voting_form_field.dart';
import 'package:swift_contest/model/db/entities/voting_session.dart';
import 'package:swift_contest/model/db/entities/voting_session_juration.dart';
import 'package:swift_contest/model/db/entities/voting_session_participation.dart';
import 'package:swift_contest/model/db/repositories/juror_repository.dart';
import 'package:swift_contest/utils/failures/failures.dart';
import 'package:swift_contest/viewmodel/enums/bloc_status.dart';

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
    on<JurorVotingProcedurePageSubmitVotes>(_submitVotes);
    on<JurorVotingProcedurePageAdvanceSession>(_advanceSession);
  }

  FutureOr<void> _fetch(
    JurorVotingProcedurePageFetch event,
    Emitter<JurorVotingProcedurePageState> emit,
  ) async {
    emit(state.copyWith(status: BlocStatus.loading, sourceEvent: event));

    //* Getting the voting session procedure bundle
    late final VotingSessionProcedureBundle votingSessionProcedureBundle;
    final eitherVotingSessionBundle = await _jurorRepository.getVotingSessionProcedureBundle(
        votingSessionId: event.votingSessionId);
    eitherVotingSessionBundle.fold(
      (failure) => emit(state.copyWith(status: BlocStatus.failure, message: failure.message)),
      (success) => votingSessionProcedureBundle = success,
    );

    //* Get own voting session juration
    late final VotingSessionJuration ownVotingSessionJuration;
    final eitherVSJ =
        await _jurorRepository.getOwnVotingSessionJuration(votingSessionId: event.votingSessionId);
    eitherVSJ.fold(
      (failure) => emit(state.copyWith(status: BlocStatus.failure, message: failure.message)),
      (success) => ownVotingSessionJuration = success,
    );

    emit(state.copyWith(
      status: BlocStatus.success,
      isInitialized: true,
      votingSessionProcedureBundle: votingSessionProcedureBundle,
      ownVotingSessionJuration: ownVotingSessionJuration,
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

  FutureOr<void> _advanceSession(
      JurorVotingProcedurePageAdvanceSession event,
      Emitter<JurorVotingProcedurePageState> emit,
      ) async {
    // Non è necessario emettere uno stato di loading,
    // perché la chiamata è "fire-and-forget".
    // La UI si aggiornerà da sola grazie allo stream realtime.
    await _jurorRepository.advanceVotingSession(
      votingSessionId: state.votingSessionProcedureBundle!.votingSessionBundle.votingSession.id!,
    );
    // Non facciamo nulla dopo la chiamata. Lo stream farà il suo lavoro.
  }

FutureOr<void> _submitVotes(
  JurorVotingProcedurePageSubmitVotes event,
  Emitter<JurorVotingProcedurePageState> emit,
) async {
  emit(state.copyWith(status: BlocStatus.loading, sourceEvent: event));

  // 1. Trasforma la mappa in un payload JSON con solo gli ID.
  final List<Map<String, dynamic>> votesPayload = [];
  final ownVotingSessionJuration = state.ownVotingSessionJuration!;
  final votingSessionExclusions = state.votingSessionProcedureBundle!.votingSessionExclusions;

  event.votesPerParticipantMap.forEach((participation, votes) {
    final isExcluded = votingSessionExclusions.any(
          (exclusion) =>
      exclusion.votingSessionJurationId == ownVotingSessionJuration.id &&
          exclusion.votingSessionParticipationId == participation.id,
    );

    // Se è escluso, salta questo partecipante e non includerlo nel payload.
    if (isExcluded) return;

    final List<Map<String, String>> votesList = [];
    votes.forEach((formField, value) {
      votesList.add({
        'voting_form_field_id': formField.id!,
        'value': value, // Il valore è già una stringa
      });
    });

    votesPayload.add({
      'voting_session_participation_id': participation.id!,
      'votes': votesList,
    });
  });

  // 2. Prepara i parametri per la chiamata RPC.
  final votingSession = state.votingSessionProcedureBundle!.votingSessionBundle.votingSession;
  double? lat;
  double? lon;

  // Aggiungi la logica per ottenere la posizione se necessario
  if (votingSession.isGeoRestricted) {
    try {
      final status = await Geolocator.checkPermission();
      if (status == LocationPermission.denied) {
        final newStatus = await Geolocator.requestPermission();
        if (newStatus == LocationPermission.denied || newStatus == LocationPermission.deniedForever) {
          emit(state.copyWith(status: BlocStatus.failure, message: 'Location permission denied.'));
          return;
        }
      }
      final position = await Geolocator.getCurrentPosition();
      lat = position.latitude;
      lon = position.longitude;
    } catch (e) {
      emit(state.copyWith(status: BlocStatus.failure, message: 'Could not get location: ${e.toString()}'));
      return;
    }
  }

  // 3. Chiama il repository.
  final result = await _jurorRepository.submitVotes(
    votingSessionId: votingSession.id!,
    votesPayload: votesPayload,
    jurorLat: lat,
    jurorLon: lon,
  );

  result.fold(
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
