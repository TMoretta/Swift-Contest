import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:swift_contest/model/data_models/profile.dart';
import 'package:swift_contest/model/data_models/simple_juror.dart';
import 'package:swift_contest/model/data_models/simple_juror_vote.dart';
import 'package:swift_contest/model/data_models/simple_juror_voting.dart';
import 'package:swift_contest/model/data_models/juror_vote.dart';
import 'package:swift_contest/model/data_models/juror_voting.dart';
import 'package:swift_contest/model/data_models/voting_form.dart';
import 'package:swift_contest/model/data_models/voting_form_field.dart';
import 'package:swift_contest/model/data_models/voting_session.dart';
import 'package:swift_contest/model/data_models/voting_session_juror.dart';
import 'package:swift_contest/model/data_models/voting_session_participant.dart';
import 'package:swift_contest/model/data_models/voting_session_simple_juror.dart';
import 'package:swift_contest/viewmodel/blocs/bloc_status.dart';
import 'package:swift_contest/viewmodel/repositories/profile_repository.dart';
import 'package:swift_contest/viewmodel/repositories/simple_juror_repository.dart';
import 'package:swift_contest/viewmodel/repositories/simple_juror_vote_repository.dart';
import 'package:swift_contest/viewmodel/repositories/simple_juror_voting_repository.dart';
import 'package:swift_contest/viewmodel/repositories/juror_vote_repository.dart';
import 'package:swift_contest/viewmodel/repositories/voting_form_field_repository.dart';
import 'package:swift_contest/viewmodel/repositories/voting_form_repository.dart';
import 'package:swift_contest/viewmodel/repositories/juror_voting_repository.dart';
import 'package:swift_contest/viewmodel/repositories/voting_session_juror_repository.dart';
import 'package:swift_contest/viewmodel/repositories/voting_session_participant_repository.dart';
import 'package:swift_contest/viewmodel/repositories/voting_session_repository.dart';
import 'package:swift_contest/viewmodel/repositories/voting_session_simple_juror_repository.dart';

part 'organizer_voting_results_page_event.dart';

part 'organizer_voting_results_page_state.dart';

class OrganizerVotingResultsPageBloc extends Bloc<
    OrganizerVotingResultsPageEvent, OrganizerVotingResultsPageState> {
  final VotingSessionRepository _votingSessionRepository;
  final ProfileRepository _profileRepository;
  final VotingSessionParticipantRepository _votingSessionParticipantRepository;
  final VotingSessionJurorRepository _votingSessionJurorRepository;
  final JurorVotingRepository _jurorVotingRepository;
  final JurorVoteRepository _jurorVoteRepository;
  final VotingFormRepository _votingFormRepository;
  final VotingFormFieldRepository _votingFormFieldRepository;
  final VotingSessionSimpleJurorRepository _votingSessionSimpleJurorRepository;
  final SimpleJurorVotingRepository _simpleJurorVotingRepository;
  final SimpleJurorVoteRepository _simpleJurorVoteRepository;
  final SimpleJurorRepository _simpleJurorRepository;

  OrganizerVotingResultsPageBloc({
    required VotingSessionRepository votingSessionRepository,
    required ProfileRepository profileRepository,
    required VotingSessionParticipantRepository
        votingSessionParticipantRepository,
    required VotingSessionJurorRepository votingSessionJurorRepository,
    required JurorVotingRepository jurorVotingRepository,
    required JurorVoteRepository jurorVoteRepository,
    required VotingFormRepository votingFormRepository,
    required VotingFormFieldRepository votingFormFieldRepository,
    required VotingSessionSimpleJurorRepository
        votingSessionSimpleJurorRepository,
    required SimpleJurorVotingRepository simpleJurorVotingRepository,
    required SimpleJurorVoteRepository simpleJurorVoteRepository,
    required SimpleJurorRepository simpleJurorRepository,
  })  : _votingSessionRepository = votingSessionRepository,
        _profileRepository = profileRepository,
        _votingSessionParticipantRepository =
            votingSessionParticipantRepository,
        _votingSessionJurorRepository = votingSessionJurorRepository,
        _jurorVotingRepository = jurorVotingRepository,
        _jurorVoteRepository = jurorVoteRepository,
        _votingFormRepository = votingFormRepository,
        _votingFormFieldRepository = votingFormFieldRepository,
        _votingSessionSimpleJurorRepository =
            votingSessionSimpleJurorRepository,
        _simpleJurorVotingRepository = simpleJurorVotingRepository,
        _simpleJurorVoteRepository = simpleJurorVoteRepository,
        _simpleJurorRepository = simpleJurorRepository,
        super(OrganizerVotingResultsPageState(status: BlocStatus.initial)) {
    on<OrganizerVotingResultsPageGetResultsInfo>(_getResultsInfo);
  }

  FutureOr<void> _getResultsInfo(
    OrganizerVotingResultsPageGetResultsInfo event,
    Emitter<OrganizerVotingResultsPageState> emit,
  ) async {
    emit(state.copyWith(status: BlocStatus.loading));

    //* Ottengo la voting session
    late final VotingSession votingSession;
    final eitherVotingSession = await _votingSessionRepository
        .getVotingSessionById(id: event.votingSessionId);
    eitherVotingSession.fold(
      (failure) => emit(
          state.copyWith(status: BlocStatus.failure, message: failure.message)),
      (success) => votingSession = success,
    );
    if (eitherVotingSession.isLeft()) {
      return;
    }

    //* Ottengo i voting session participants
    late final List<VotingSessionParticipant> votingSessionParticipants;
    final eitherVotingSessionParticipants =
        await _votingSessionParticipantRepository
            .getVotingSessionParticipantsByVotingSessionId(
                votingSessionId: votingSession.id);
    eitherVotingSessionParticipants.fold(
      (failure) => emit(
          state.copyWith(status: BlocStatus.failure, message: failure.message)),
      (success) => votingSessionParticipants = success,
    );
    if (eitherVotingSessionParticipants.isLeft()) {
      return;
    }

    //* Ottengo i profili dei partecipanti
    final List<Participant> participants = [];
    for (var votingSessionParticipant in votingSessionParticipants) {
      final eitherParticipant = await _profileRepository.getProfileById(
          id: votingSessionParticipant.participantId);
      eitherParticipant.fold(
        (failure) => emit(state.copyWith(
            status: BlocStatus.failure, message: failure.message)),
        (success) => participants.add(success),
      );
      if (eitherParticipant.isLeft()) {
        return;
      }
    }

    //* Ottengo i voting session jurors
    late final List<VotingSessionJuror> votingSessionJurors;
    final eitherVotingSessionJurors = await _votingSessionJurorRepository
        .getVotingSessionJurorsByVotingSessionId(
            votingSessionId: votingSession.id);
    eitherVotingSessionJurors.fold(
      (failure) => emit(
          state.copyWith(status: BlocStatus.failure, message: failure.message)),
      (success) => votingSessionJurors = success,
    );
    if (eitherVotingSessionJurors.isLeft()) {
      return;
    }

    //* Ottengo i profili dei jurors
    final List<Juror> jurors = [];
    final List<Juror> jurorsThatSubmitted = [];
    final List<Juror> jurorsThatNotSubmitted = [];
    for (var votingSessionJuror in votingSessionJurors) {
      final eitherJuror = await _profileRepository.getProfileById(
          id: votingSessionJuror.jurorId);
      eitherJuror.fold(
        (failure) => emit(state.copyWith(
            status: BlocStatus.failure, message: failure.message)),
        (success) {
          jurors.add(success);
          if (votingSessionJuror.hasSubmitted) {
            jurorsThatSubmitted.add(success);
          } else {
            jurorsThatNotSubmitted.add(success);
          }
        },
      );
      if (eitherJuror.isLeft()) {
        return;
      }
    }

    //* Ottengo le voting exclusions
    final Map<Juror, List<Participant>> participantsExclusionsPerJurorMap = {};
    for (var votingSessionJuror in votingSessionJurors) {
      late final List<JurorVoting> votings;
      final eitherVotings =
          await _jurorVotingRepository.getJurorVotingsByVotingSessionJurorId(
              votingSessionJurorId: votingSessionJuror.id);
      eitherVotings.fold(
        (failure) => emit(state.copyWith(
            status: BlocStatus.failure, message: failure.message)),
        (success) => votings = success,
      );
      if (eitherVotings.isLeft()) {
        return;
      }

      final Juror excludedJuror =
          jurors.firstWhere((e) => e.id == votingSessionJuror.jurorId);
      final List<Participant> excludedParticipants = [];
      for (var voting in votings) {
        if (voting.isExcluded) {
          final excludedParticipantId = votingSessionParticipants
              .firstWhere((e) => e.id == voting.votingSessionParticipantId)
              .participantId;
          final excludedParticipant =
              participants.firstWhere((e) => e.id == excludedParticipantId);
          excludedParticipants.add(excludedParticipant);
        }
      }
      participantsExclusionsPerJurorMap
          .addAll({excludedJuror: excludedParticipants});
    }

    //* Ottengo i voting form fields
    late final VotingForm votingForm;
    final eitherVotingForm = await _votingFormRepository.getVotingFormById(
        id: votingSession.votingFormId);
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
      (success) {
        success.sort((a, b) => a.orderIndex.compareTo(b.orderIndex));
        votingFormFields = success;
      },
    );
    if (eitherVotingFormFields.isLeft()) {
      return;
    }

    //* Ottengo i voti dei singoli giurati che hanno inviato la votazione per i partecipanti
    final Map<Juror, Map<Participant, List<JurorVote>?>> votesPerJurorMap = {};
    for (int i = 0; i < votingSessionJurors.length; i++) {
      final votingSessionJuror = votingSessionJurors[i];
      final juror = jurors[i];

      if (!votingSessionJuror.hasSubmitted) {
        continue;
      }

      final Map<Participant, List<JurorVote>?> participantVotes = {};
      for (int j = 0; j < votingSessionParticipants.length; j++) {
        final votingSessionParticipant = votingSessionParticipants[j];
        final participant = participants[j];

        if (participantsExclusionsPerJurorMap[juror]!.contains(participant)) {
          participantVotes.addAll({participant: null});
          continue;
        }

        late final JurorVoting voting;
        final eitherVoting = await _jurorVotingRepository
            .getJurorVotingByVotingSessionJurorIdAndVotingSessionParticipantId(
                votingSessionJurorId: votingSessionJuror.id,
                votingSessionParticipantId: votingSessionParticipant.id);
        eitherVoting.fold(
          (failure) => emit(state.copyWith(
              status: BlocStatus.failure, message: failure.message)),
          (success) => voting = success,
        );
        if (eitherVoting.isLeft()) {
          return;
        }

        late final List<JurorVote> votes;
        final eitherVotes =
            await _jurorVoteRepository.getJurorVotesByJurorVotingId(jurorVotingId: voting.id);
        eitherVotes.fold(
          (failure) => emit(state.copyWith(
              status: BlocStatus.failure, message: failure.message)),
          (success) {
            success.sort((a, b) {
              final orderIndexA = votingFormFields
                  .where((e) => e.id == a.votingFormFieldId)
                  .first
                  .orderIndex;
              final orderIndexB = votingFormFields
                  .where((e) => e.id == b.votingFormFieldId)
                  .first
                  .orderIndex;
              return orderIndexA.compareTo(orderIndexB);
            });
            votes = success;
            participantVotes.addAll({participant: votes});
          },
        );
        if (eitherVotes.isLeft()) {
          return;
        }
      }
      votesPerJurorMap.addAll({juror: participantVotes});
    }

    //* Ottengo i voti ricevuti dai singoli partecipanti dai giurati
    final Map<Participant, Map<Juror, List<JurorVote>?>> votesPerParticipantMap = {};
    for (final jurorEntry in votesPerJurorMap.entries) {
      final juror = jurorEntry.key;
      final participantVotes = jurorEntry.value;

      for (final participantEntry in participantVotes.entries) {
        final participant = participantEntry.key;
        final votes = participantEntry.value;

        votesPerParticipantMap
            .putIfAbsent(participant, () => {})
            .addAll({juror: votes});
      }
    }

    //* Se i giurati semplici sono ammessi devo ottenere anche i loro voti
    if (votingSession.areSimpleJurorsAllowed) {
      //* Ottengo i simple jurors
      late final List<VotingSessionSimpleJuror> votingSessionSimpleJurors;
      final eitherVotingSessionSimpleJurors =
          await _votingSessionSimpleJurorRepository
              .getVotingSessionSimpleJurorsByVotingSessionId(
                  votingSessionId: votingSession.id);
      eitherVotingSessionSimpleJurors.fold(
        (failure) => emit(state.copyWith(
            status: BlocStatus.failure, message: failure.message)),
        (success) => votingSessionSimpleJurors = success,
      );
      if (eitherVotingSessionSimpleJurors.isLeft()) {
        return;
      }

      //* Ottengo i profili dei simple jurors
      final List<SimpleJuror> simpleJurors = [];
      final List<SimpleJuror> simpleJurorsThatSubmitted = [];
      final List<SimpleJuror> simpleJurorsThatNotSubmitted = [];
      for (var votingSessionSimpleJuror in votingSessionSimpleJurors) {
        final eitherSimpleJuror = await _simpleJurorRepository
            .getSimpleJurorById(id: votingSessionSimpleJuror.simpleJurorId);
        eitherSimpleJuror.fold(
          (failure) => emit(state.copyWith(
              status: BlocStatus.failure, message: failure.message)),
          (success) {
            simpleJurors.add(success);
            if (votingSessionSimpleJuror.hasSubmitted) {
              simpleJurorsThatSubmitted.add(success);
            } else {
              simpleJurorsThatNotSubmitted.add(success);
            }
          },
        );
        if (eitherSimpleJuror.isLeft()) {
          return;
        }
      }

      //* Ottengo i voti dei singoli simple jurors che hanno inviato la votazione per i partecipanti
      final Map<SimpleJuror, Map<Participant, List<SimpleJurorVote>>>
          simpleJurorVotesPerSimpleJurorMap = {};
      for (int i = 0; i < votingSessionSimpleJurors.length; i++) {
        final votingSessionSimpleJuror = votingSessionSimpleJurors[i];
        final simpleJuror = simpleJurors[i];

        if (!votingSessionSimpleJuror.hasSubmitted) {
          continue;
        }

        final Map<Participant, List<SimpleJurorVote>>
            participantSimpleJurorVotes = {};
        for (int j = 0; j < votingSessionParticipants.length; j++) {
          final votingSessionParticipant = votingSessionParticipants[j];
          final participant = participants[j];

          late final SimpleJurorVoting simpleJurorVoting;
          final eitherSimpleJurorVoting = await _simpleJurorVotingRepository
              .getVotingByVotingSessionSimpleJurorIdAndVotingSessionParticipantId(
                  votingSessionSimpleJurorId: votingSessionSimpleJuror.id,
                  votingSessionParticipantId: votingSessionParticipant.id);
          eitherSimpleJurorVoting.fold(
            (failure) => emit(state.copyWith(
                status: BlocStatus.failure, message: failure.message)),
            (success) => simpleJurorVoting = success,
          );
          if (eitherSimpleJurorVoting.isLeft()) {
            return;
          }

          late final List<SimpleJurorVote> simpleJurorVotes;
          final eitherSimpleJurorVotes = await _simpleJurorVoteRepository
              .getSimpleJurorVotesBySimpleJurorVotingId(
                  simpleJurorVotingId: simpleJurorVoting.id);
          eitherSimpleJurorVotes.fold(
            (failure) => emit(state.copyWith(
                status: BlocStatus.failure, message: failure.message)),
            (success) {
              success.sort((a, b) {
                final orderIndexA = votingFormFields
                    .where((e) => e.id == a.votingFormFieldId)
                    .first
                    .orderIndex;
                final orderIndexB = votingFormFields
                    .where((e) => e.id == b.votingFormFieldId)
                    .first
                    .orderIndex;
                return orderIndexA.compareTo(orderIndexB);
              });
              simpleJurorVotes = success;
              participantSimpleJurorVotes
                  .addAll({participant: simpleJurorVotes});
            },
          );
          if (eitherSimpleJurorVotes.isLeft()) {
            return;
          }
        }
        simpleJurorVotesPerSimpleJurorMap
            .addAll({simpleJuror: participantSimpleJurorVotes});
      }

      //* Ottengo i voti ricevuti dai singoli partecipanti dai simple jurors
      final Map<Participant, Map<SimpleJuror, List<SimpleJurorVote>>>
          simpleJurorVotesPerParticipantMap = {};
      for (final simpleJurorEntry
          in simpleJurorVotesPerSimpleJurorMap.entries) {
        final simpleJuror = simpleJurorEntry.key;
        final participantVotes = simpleJurorEntry.value;

        for (final participantEntry in participantVotes.entries) {
          final participant = participantEntry.key;
          final simpleJurorVotes = participantEntry.value;

          simpleJurorVotesPerParticipantMap
              .putIfAbsent(participant, () => {})
              .addAll({simpleJuror: simpleJurorVotes});
        }
      }

      emit(state.copyWith(
        simpleJurors: simpleJurors,
        simpleJurorsThatSubmitted: simpleJurorsThatSubmitted,
        simpleJurorsThatNotSubmitted: simpleJurorsThatNotSubmitted,
        simpleJurorVotesPerSimpleJurorMap: simpleJurorVotesPerSimpleJurorMap,
        simpleJurorVotesPerParticipantMap: simpleJurorVotesPerParticipantMap,
      ));
    }

    emit(state.copyWith(
      status: BlocStatus.success,
      votingSession: votingSession,
      participants: participants,
      jurors: jurors,
      jurorsThatSubmitted: jurorsThatSubmitted,
      jurorsThatNotSubmitted: jurorsThatNotSubmitted,
      votingFormFields: votingFormFields,
      jurorVotesPerJurorMap: votesPerJurorMap,
      jurorVotesPerParticipantMap: votesPerParticipantMap,
      participantsExclusionsPerJurorMap: participantsExclusionsPerJurorMap,
    ));
  }
}
