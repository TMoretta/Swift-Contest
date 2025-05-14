import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:swift_contest/model/data_models/participation.dart';
import 'package:swift_contest/model/data_models/profile.dart';
import 'package:swift_contest/model/data_models/simple_juror_vote.dart';
import 'package:swift_contest/model/data_models/simple_juror_voting.dart';
import 'package:swift_contest/model/data_models/voting_form.dart';
import 'package:swift_contest/model/data_models/voting_form_field.dart';
import 'package:swift_contest/model/data_models/voting_session.dart';
import 'package:swift_contest/model/data_models/voting_session_participant.dart';
import 'package:swift_contest/model/data_models/voting_session_procedure.dart';
import 'package:swift_contest/model/data_models/voting_session_simple_juror.dart';
import 'package:swift_contest/model/data_models/work.dart';
import 'package:swift_contest/utils/functions/gen_uuid.dart';
import 'package:swift_contest/viewmodel/blocs/bloc_status.dart';
import 'package:swift_contest/viewmodel/repositories/participation_repository.dart';
import 'package:swift_contest/viewmodel/repositories/profile_repository.dart';
import 'package:swift_contest/viewmodel/repositories/simple_juror_vote_repository.dart';
import 'package:swift_contest/viewmodel/repositories/simple_juror_voting_repository.dart';
import 'package:swift_contest/viewmodel/repositories/juror_vote_repository.dart';
import 'package:swift_contest/viewmodel/repositories/voting_form_field_repository.dart';
import 'package:swift_contest/viewmodel/repositories/voting_form_repository.dart';
import 'package:swift_contest/viewmodel/repositories/juror_voting_repository.dart';
import 'package:swift_contest/viewmodel/repositories/voting_session_juror_repository.dart';
import 'package:swift_contest/viewmodel/repositories/voting_session_participant_repository.dart';
import 'package:swift_contest/viewmodel/repositories/voting_session_procedure_repository.dart';
import 'package:swift_contest/viewmodel/repositories/voting_session_repository.dart';
import 'package:swift_contest/viewmodel/repositories/voting_session_simple_juror_repository.dart';
import 'package:swift_contest/viewmodel/repositories/work_repository.dart';

part 'simple_juror_voting_procedure_page_event.dart';
part 'simple_juror_voting_procedure_page_state.dart';

class SimpleJurorVotingProcedurePageBloc extends Bloc<
    SimpleJurorVotingProcedurePageEvent, SimpleJurorVotingProcedurePageState> {
  final VotingSessionRepository _votingSessionRepository;
  final VotingSessionProcedureRepository _votingSessionProcedureRepository;
  final VotingSessionParticipantRepository _votingSessionParticipantRepository;
  final WorkRepository _workRepository;
  final ParticipationRepository _participationRepository;
  final ProfileRepository _profileRepository;
  final VotingFormRepository _votingFormRepository;
  final VotingFormFieldRepository _votingFormFieldRepository;
  final VotingSessionJurorRepository _votingSessionJurorRepository;
  final JurorVotingRepository _jurorVotingRepository;
  final JurorVoteRepository _jurorVoteRepository;
  final SimpleJurorVotingRepository _simpleJurorVotingRepository;
  final VotingSessionSimpleJurorRepository _votingSessionSimpleJurorRepository;
  final SimpleJurorVoteRepository _simpleJurorVoteRepository;

  SimpleJurorVotingProcedurePageBloc({
    required VotingSessionRepository votingSessionRepository,
    required VotingSessionProcedureRepository votingSessionProcedureRepository,
    required VotingSessionParticipantRepository
        votingSessionParticipantRepository,
    required WorkRepository workRepository,
    required ParticipationRepository participationRepository,
    required ProfileRepository profileRepository,
    required VotingFormRepository votingFormRepository,
    required VotingFormFieldRepository votingFormFieldRepository,
    required VotingSessionJurorRepository votingSessionJurorRepository,
    required JurorVotingRepository jurorVotingRepository,
    required JurorVoteRepository jurorVoteRepository,
    required SimpleJurorVotingRepository simpleJurorVotingRepository,
    required VotingSessionSimpleJurorRepository votingSessionSimpleJurorRepository,
    required SimpleJurorVoteRepository simpleJurorVoteRepository,
  })  : _votingSessionRepository = votingSessionRepository,
        _votingSessionProcedureRepository = votingSessionProcedureRepository,
        _votingSessionParticipantRepository =
            votingSessionParticipantRepository,
        _workRepository = workRepository,
        _participationRepository = participationRepository,
        _votingFormRepository = votingFormRepository,
        _votingFormFieldRepository = votingFormFieldRepository,
        _profileRepository = profileRepository,
        _votingSessionJurorRepository = votingSessionJurorRepository,
        _jurorVotingRepository = jurorVotingRepository,
        _jurorVoteRepository = jurorVoteRepository,
        _simpleJurorVotingRepository = simpleJurorVotingRepository,
        _votingSessionSimpleJurorRepository = votingSessionSimpleJurorRepository,
        _simpleJurorVoteRepository = simpleJurorVoteRepository,
        super(SimpleJurorVotingProcedurePageState(status: BlocStatus.initial)) {
    on<SimpleJurorVotingProcedurePageSubscribeToVotingSessionProcedure>(
        _subscribeToVotingSessionProcedure);
    on<SimpleJurorVotingProcedurePageSubmitVotes>(_submitVotes);
  }

  FutureOr<void> _subscribeToVotingSessionProcedure(
    SimpleJurorVotingProcedurePageSubscribeToVotingSessionProcedure event,
    Emitter<SimpleJurorVotingProcedurePageState> emit,
  ) async {
    emit(state.copyWith(status: BlocStatus.loading));

    late final VotingSessionProcedure liveVotingSessionProcedure;
    final eitherVotingProcedures = await _votingSessionProcedureRepository
        .getVotingSessionProcedureByVotingSessionId(
            votingSessionId: event.votingSession.id);
    eitherVotingProcedures.fold(
      (failure) => emit(
          state.copyWith(status: BlocStatus.failure, message: failure.message)),
      (success) => liveVotingSessionProcedure = success,
    );
    if (eitherVotingProcedures.isLeft()) {
      return;
    }

    if (liveVotingSessionProcedure.isLive == null ||
        !liveVotingSessionProcedure.isLive!) {
      emit(state.copyWith(
          status: BlocStatus.failure,
          message: 'No live voting session procedure'));
    }

    late final List<VotingSessionParticipant> votingSessionParticipants;
    final eitherVotingSessionParticipants =
        await _votingSessionParticipantRepository
            .getVotingSessionParticipantsByVotingSessionId(
      votingSessionId: event.votingSession.id,
    );
    eitherVotingSessionParticipants.fold(
      (failure) => emit(
          state.copyWith(status: BlocStatus.failure, message: failure.message)),
      (success) => votingSessionParticipants = success,
    );
    if (eitherVotingSessionParticipants.isLeft()) {
      return;
    }

    final List<Participant> participants = [];
    final List<Work> works = [];
    for (var votingSessionParticipant in votingSessionParticipants) {
      late final Participation participation;
      final eitherParticipation = await _participationRepository
          .getParticipationByContestIdAndParticipantId(
              contestId: event.votingSession.contestId,
              participantId: votingSessionParticipant.participantId);
      eitherParticipation.fold(
        (failure) => emit(state.copyWith(
            status: BlocStatus.failure, message: failure.message)),
        (success) => participation = success,
      );
      if (eitherParticipation.isLeft()) {
        return;
      }

      final eitherParticipant = await _profileRepository.getProfileById(
          id: participation.participantId);
      eitherParticipant.fold(
        (failure) => emit(state.copyWith(
            status: BlocStatus.failure, message: failure.message)),
        (success) => participants.add(success),
      );
      if (eitherParticipant.isLeft()) {
        return;
      }

      final eitherWork = await _workRepository.getWorkByParticipationId(
          participationId: participation.id);
      eitherWork.fold(
        (failure) => emit(state.copyWith(
            status: BlocStatus.failure, message: failure.message)),
        (success) => works.add(success),
      );
      if (eitherWork.isLeft()) {
        return;
      }
    }

    late final List<SimpleJurorVoting> simpleJurorVotings;
    final eitherSimpleJurorVotings = await _simpleJurorVotingRepository
        .getSimpleJurorVotingsByVotingSessionSimpleJurorId(
            votingSessionSimpleJurorId: event.votingSessionSimpleJuror.id);
    eitherSimpleJurorVotings.fold(
      (failure) => emit(
          state.copyWith(status: BlocStatus.failure, message: failure.message)),
      (success) => simpleJurorVotings = success,
    );
    if (eitherSimpleJurorVotings.isLeft()) {
      return;
    }

    late final VotingForm votingForm;
    final eitherVotingForm = await _votingFormRepository.getVotingFormById(
        id: event.votingSession.votingFormId);
    eitherVotingForm.fold(
      (failure) => emit(
          state.copyWith(status: BlocStatus.failure, message: failure.message)),
      (success) => votingForm = success,
    );
    if (eitherVotingForm.isLeft()) {
      return;
    }

    late final List<VotingFormField> votingFormFields;
    final eitherVotingFormFields = await _votingFormFieldRepository
        .getVotingFormFieldsByVotingFormId(votingFormId: votingForm.id);
    eitherVotingFormFields.fold(
      (failure) => emit(
          state.copyWith(status: BlocStatus.failure, message: failure.message)),
      (success) => votingFormFields = success,
    );
    if (eitherVotingFormFields.isLeft()) {
      return;
    }

    votingFormFields.sort((a, b) => a.orderIndex.compareTo(b.orderIndex));

    emit(state.copyWith(
      status: BlocStatus.loading,
      votingSession: event.votingSession,
      votingSessionParticipants: votingSessionParticipants,
      participants: participants,
      works: works,
      votingForm: votingForm,
      votingFormFields: votingFormFields,
    ));

    late Stream<VotingSessionProcedure> votingSessionProcedureStream;
    final result =
        await _votingSessionProcedureRepository.getVotingSessionProcedureStream(
      votingSessionProcedureId: liveVotingSessionProcedure!.id,
    );
    result.fold(
      (failure) => emit(
          state.copyWith(status: BlocStatus.failure, message: failure.message)),
      (success) => votingSessionProcedureStream = success,
    );
    if (result.isLeft()) {
      return;
    }

    await emit.forEach(
      votingSessionProcedureStream,
      onData: (newVotingSessionProcedure) {
        final oldVotingSessionProcedure = state.votingSessionProcedure;
        if (newVotingSessionProcedure == oldVotingSessionProcedure) {
          return state;
        }
        return state.copyWith(
          status: BlocStatus.success,
          votingSessionProcedure: newVotingSessionProcedure,
        );
      },
      onError: (error, stackTrace) {
        return state.copyWith(
            status: BlocStatus.failure, message: error.toString());
      },
    );
  }

  FutureOr<void> _submitVotes(
    SimpleJurorVotingProcedurePageSubmitVotes event,
    Emitter<SimpleJurorVotingProcedurePageState> emit,
  ) async {
    emit(state.copyWith(status: BlocStatus.loading));

    late final List<SimpleJurorVoting> simpleJurorVotings;
    final eitherSimpleJurorVotings = await _simpleJurorVotingRepository
        .getSimpleJurorVotingsByVotingSessionSimpleJurorId(
            votingSessionSimpleJurorId: event.votingSessionSimpleJuror.id);
    eitherSimpleJurorVotings.fold(
      (failure) => emit(
          state.copyWith(status: BlocStatus.failure, message: failure.message)),
      (success) => simpleJurorVotings = success,
    );
    if (eitherSimpleJurorVotings.isLeft()) {
      return;
    }

    final votesPerParticipantList = event.votesPerParticipantMap.entries;
    for (var votesPerParticipant in votesPerParticipantList) {
      final VotingSessionParticipant votingSessionParticipant = votesPerParticipant.key;
      final votesList = votesPerParticipant.value.entries;

      final SimpleJurorVoting simpleJurorVoting = simpleJurorVotings.firstWhere((e) => e.votingSessionParticipantId == votingSessionParticipant.id);

      for (var v in votesList) {
        final VotingFormField votingFormField = v.key;
        final String value = v.value;

        late final SimpleJurorVote simpleJurorVote;
        final eitherVote = await _simpleJurorVoteRepository.createSimpleJurorVote(simpleJurorVote: SimpleJurorVote(
          id: genUuid(),
          createdAt: DateTime.now(),
          simpleJurorVotingId: simpleJurorVoting.id,
          votingFormFieldId: votingFormField.id,
          value: value,
        ));
        eitherVote.fold(
          (failure) => emit(state.copyWith(
              status: BlocStatus.failure, message: failure.message)),
          (success) => simpleJurorVote = success,
        );
        if (eitherVote.isLeft()) {
          return;
        }
      }
    }

    final eitherVotingSessionSimpleJurorUpdate =
        await _votingSessionSimpleJurorRepository.updateVotingSessionSimpleJurorById(
      id: event.votingSessionSimpleJuror.id,
      votingSessionSimpleJuror: event.votingSessionSimpleJuror.copyWith(hasSubmitted: true),
    );
    eitherVotingSessionSimpleJurorUpdate.fold(
      (failure) => emit(
          state.copyWith(status: BlocStatus.failure, message: failure.message)),
      (success) => null,
    );
    if (eitherVotingSessionSimpleJurorUpdate.isLeft()) {
      return;
    }

    emit(state.copyWith(status: BlocStatus.success));
  }
}
