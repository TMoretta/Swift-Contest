import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:swift_contest/model/bundles/contest_details_bundle.dart';
import 'package:swift_contest/model/bundles/juration_bundle.dart';
import 'package:swift_contest/model/bundles/juror_vote_bundle.dart';
import 'package:swift_contest/model/bundles/contest_details_bundle.dart';
import 'package:swift_contest/model/bundles/organizer_voting_session_bundle.dart';
import 'package:swift_contest/model/bundles/participation_bundle.dart';
import 'package:swift_contest/model/bundles/voting_form_bundle.dart';
import 'package:swift_contest/model/bundles/voting_session_exclusion_bundle.dart';
import 'package:swift_contest/model/bundles/voting_session_juration_bundle.dart';
import 'package:swift_contest/model/bundles/voting_session_participation_bundle.dart';
import 'package:swift_contest/model/data_models/juror_vote.dart';
import 'package:swift_contest/model/data_models/juror_voting.dart';
import 'package:swift_contest/model/data_models/voting_form.dart';
import 'package:swift_contest/model/data_models/voting_form_field.dart';
import 'package:swift_contest/model/data_models/voting_session.dart';
import 'package:swift_contest/model/data_models/voting_session_exclusion.dart';
import 'package:swift_contest/model/data_models/voting_session_juration.dart';
import 'package:swift_contest/model/data_models/voting_session_participation.dart';
import 'package:swift_contest/model/repositories/crud_repositories/juror_vote_repository.dart';
import 'package:swift_contest/model/repositories/crud_repositories/juror_voting_repository.dart';
import 'package:swift_contest/model/repositories/crud_repositories/voting_session_exclusion_repository.dart';
import 'package:swift_contest/model/repositories/crud_repositories/voting_session_juration_repository.dart';
import 'package:swift_contest/model/repositories/crud_repositories/voting_session_participation_repository.dart';
import 'package:swift_contest/viewmodel/enums/bloc_status.dart';

part 'organizer_voting_result_details_page_event.dart';
part 'organizer_voting_result_details_page_state.dart';

class OrganizerVotingResultDetailsPageBloc
    extends Bloc<OrganizerVotingResultDetailsPageEvent, OrganizerVotingResultDetailsPageState> {
  final JurorVotingRepository _jurorVotingRepository;
  final JurorVoteRepository _jurorVoteRepository;
  final VotingSessionParticipationRepository _votingSessionParticipationRepository;
  final VotingSessionJurationRepository _votingSessionJurationRepository;
  final VotingSessionExclusionRepository _votingSessionExclusionRepository;

  OrganizerVotingResultDetailsPageBloc({
    required JurorVotingRepository jurorVotingRepository,
    required JurorVoteRepository jurorVoteRepository,
    required VotingSessionParticipationRepository votingSessionParticipationRepository,
    required VotingSessionJurationRepository votingSessionJurationRepository,
    required VotingSessionExclusionRepository votingSessionExclusionRepository,
  })  : _jurorVotingRepository = jurorVotingRepository,
        _jurorVoteRepository = jurorVoteRepository,
        _votingSessionParticipationRepository = votingSessionParticipationRepository,
        _votingSessionJurationRepository = votingSessionJurationRepository,
        _votingSessionExclusionRepository = votingSessionExclusionRepository,
        super(OrganizerVotingResultDetailsPageState(status: BlocStatus.initial)) {
    on<OrganizerVotingResultDetailsPageGetResultInfo>(_getResultInfo);
  }

  FutureOr<void> _getResultInfo(
    OrganizerVotingResultDetailsPageGetResultInfo event,
    Emitter<OrganizerVotingResultDetailsPageState> emit,
  ) async {
    emit(state.copyWith(status: BlocStatus.loading, sourceEvent: event));

    final ContestDetailsBundle contestDetailsBundle = event.contestDetailsBundle;

    late final List<VotingSessionParticipation> votingSessionParticipations;
    final eitherVotingSessionParticipation = await _votingSessionParticipationRepository
        .getVotingSessionParticipationsByVotingSessionId(votingSessionId: event.votingSession.id);
    eitherVotingSessionParticipation.fold(
      (failure) => emit(state.copyWith(status: BlocStatus.failure, message: failure.message)),
      (success) => votingSessionParticipations = success,
    );

    late final List<VotingSessionJuration> votingSessionJurations;
    final eitherVotingSessionJuration = await _votingSessionJurationRepository
        .getVotingSessionJurationsByVotingSessionId(votingSessionId: event.votingSession.id);
    eitherVotingSessionJuration.fold(
      (failure) => emit(state.copyWith(status: BlocStatus.failure, message: failure.message)),
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

    final List<VotingSessionExclusion> votingSessionExclusions = [];
    for (var votingSessionJuration in votingSessionJurations) {
      final eitherVotingSessionExclusions = await _votingSessionExclusionRepository
          .getVotingSessionExclusionsByVotingSessionJurationId(
              votingSessionJurationId: votingSessionJuration.id);
      eitherVotingSessionExclusions.fold(
        (failure) => emit(state.copyWith(status: BlocStatus.failure, message: failure.message)),
        (success) => votingSessionExclusions.addAll(success),
      );
    }

    final List<VotingSessionExclusionBundle> votingSessionExclusionsBundles = [];
    for (var votingSessionExclusion in votingSessionExclusions) {
      final votingSessionParticipation = votingSessionParticipations
          .firstWhere((e) => e.id == votingSessionExclusion.votingSessionParticipationId);
      final votingSessionJuration = votingSessionJurations
          .firstWhere((e) => e.id == votingSessionExclusion.votingSessionJurationId);

      final VotingSessionExclusionBundle votingSessionExclusionBundle =
          VotingSessionExclusionBundle(
        votingSessionParticipation: votingSessionParticipation,
        votingSessionJuration: votingSessionJuration,
      );
      votingSessionExclusionsBundles.add(votingSessionExclusionBundle);
    }

    //* Ottengo i voti dei singoli giurati che hanno inviato la votazione per i partecipanti
    final Map<JurationBundle, Map<ParticipationBundle, List<JurorVoteBundle>?>>
        participantsVotingsPerJurorMap = {};
    final List<JurationBundle> jurorsWithoutSubmissionBundles = [];
    for (int i = 0; i < votingSessionJurationsBundles.length; i++) {
      final votingSessionJurationBundle = votingSessionJurationsBundles[i];
      final jurationBundle = votingSessionJurationBundle.jurationBundle;
      if (!votingSessionJurationBundle.votingSessionJuration.hasSubmitted) {
        jurorsWithoutSubmissionBundles.add(jurationBundle);
        continue;
      }

      final Map<ParticipationBundle, List<JurorVoteBundle>?> participantsVotes = {};
      for (int j = 0; j < votingSessionParticipationsBundles.length; j++) {
        final votingSessionParticipationBundle = votingSessionParticipationsBundles[j];
        final participationBundle = votingSessionParticipationBundle.participationBundle;

        //* Se il giurato era escluso lo aggiungo come giurato escluso per il determinato partecipante
        if (votingSessionExclusionsBundles.contains(VotingSessionExclusionBundle(
            votingSessionJuration: votingSessionJurationBundle.votingSessionJuration,
            votingSessionParticipation:
                votingSessionParticipationBundle.votingSessionParticipation))) {
          participantsVotes.addAll({participationBundle: null});
          continue;
        }

        late final JurorVoting? jurorVoting;
        final eitherVoting = await _jurorVotingRepository
            .getJurorVotingByVotingSessionJurationIdAndVotingSessionParticipationId(
                votingSessionJurationId: votingSessionJurationBundle.votingSessionJuration.id,
                votingSessionParticipationId:
                    votingSessionParticipationBundle.votingSessionParticipation.id);
        eitherVoting.fold(
          (failure) => emit(state.copyWith(status: BlocStatus.failure, message: failure.message)),
          (success) => jurorVoting = success,
        );
        if (eitherVoting.isLeft()) {
          return;
        }
        if(jurorVoting==null) {
          emit(state.copyWith(status: BlocStatus.failure,message: 'Juror voting not found'));
          return;
        }

        late final List<JurorVote> jurorVotes;
        final eitherVotes =
            await _jurorVoteRepository.getJurorVotesByJurorVotingId(jurorVotingId: jurorVoting!.id);
        eitherVotes.fold(
          (failure) => emit(state.copyWith(status: BlocStatus.failure, message: failure.message)),
          (success) {
            jurorVotes = success;
          },
        );
        if (eitherVotes.isLeft()) {
          return;
        }
        final List<JurorVoteBundle> jurorVotesBundles = [];
        for (var jurorVote in jurorVotes) {
          jurorVotesBundles.add(JurorVoteBundle(
              jurorVote: jurorVote,
              votingFormField: contestDetailsBundle.votingFormBundle.votingFormFields
                  .where((e) => e.id == jurorVote.votingFormFieldId)
                  .first));
        }

        jurorVotesBundles
            .sort((a, b) => a.votingFormField.orderIndex.compareTo(b.votingFormField.orderIndex));
        participantsVotes.addAll({participationBundle: jurorVotesBundles});
      }
      participantsVotingsPerJurorMap.addAll({jurationBundle: participantsVotes});
    }

    //* Ottengo i voti ricevuti dai singoli partecipanti dai giurati
    final Map<ParticipationBundle, Map<JurationBundle, List<JurorVoteBundle>?>>
        jurorsVotingsPerParticipantMap = {};
    for (final jurorEntry in participantsVotingsPerJurorMap.entries) {
      final jurationBundle = jurorEntry.key;
      final participantsVotes = jurorEntry.value;

      for (final participantEntry in participantsVotes.entries) {
        final participationBundle = participantEntry.key;
        final votes = participantEntry.value;

        jurorsVotingsPerParticipantMap
            .putIfAbsent(participationBundle, () => {})
            .addAll({jurationBundle: votes});
      }
    }

    emit(state.copyWith(
      status: BlocStatus.success,
      participantsVotingsPerJurorMap: participantsVotingsPerJurorMap,
      jurorsVotingsPerParticipantMap: jurorsVotingsPerParticipantMap,
      jurorsWithoutSubmissionBundles: jurorsWithoutSubmissionBundles,
    ));

    // final List<JurorVotingPerJurorBundle> jurorVotingsPerJurorBundles = [];
    // for (var votingSessionJurationBundle in votingSessionJurationsBundles) {
    //   //* Se non ha fatto il submit lo inserisco come non submitted
    //   if (!votingSessionJurationBundle.votingSessionJuration.hasSubmitted) {
    //     jurorVotingsPerJurorBundles.add(JurorWithoutSubmissionVotingPerJurorBundle(
    //         votingSessionJurationBundle: votingSessionJurationBundle));
    //     continue;
    //   }
    //   final List<ParticipantVotingBundle> participantsVotingsBundles = [];
    //   for (var votingSessionParticipationBundle in votingSessionParticipationsBundles) {
    //     final votingSessionJuration = votingSessionJurationBundle.votingSessionJuration;
    //     final votingSessionParticipation =
    //         votingSessionParticipationBundle.votingSessionParticipation;
    //
    //     //* Se il giurato era escluso lo aggiungo come giurato escluso per il determinato partecipante
    //     if (votingSessionExclusionsBundles.contains(VotingSessionExclusionBundle(
    //         votingSessionJuration: votingSessionJuration,
    //         votingSessionParticipation: votingSessionParticipation))) {
    //       participantsVotingsBundles.add(ParticipantVotingBundle(
    //           votingSessionParticipationBundle: votingSessionParticipationBundle,
    //           isExcluded: true));
    //       continue;
    //     }
    //
    //     //* Altrimenti ottengo voting e votes e lo inserisco come submitted
    //     late final JurorVoting jurorVoting;
    //     final eitherVoting = await _jurorVotingRepository
    //         .getJurorVotingByVotingSessionJurationIdAndVotingSessionParticipationId(
    //             votingSessionJurationId: votingSessionJuration.id,
    //             votingSessionParticipationId: votingSessionParticipation.id);
    //     eitherVoting.fold(
    //       (failure) => emit(state.copyWith(status: BlocStatus.failure, message: failure.message)),
    //       (success) => jurorVoting = success,
    //     );
    //     if (eitherVoting.isLeft()) {
    //       return;
    //     }
    //
    //     late final List<JurorVote> jurorVotes;
    //     final eitherVotes =
    //         await _jurorVoteRepository.getJurorVotesByJurorVotingId(jurorVotingId: jurorVoting.id);
    //     eitherVotes.fold(
    //       (failure) => emit(state.copyWith(status: BlocStatus.failure, message: failure.message)),
    //       (success) {
    //         // success.sort((a, b) {
    //         //   final orderIndexA =
    //         //       votingFormFields.where((e) => e.id == a.votingFormFieldId).first.orderIndex;
    //         //   final orderIndexB =
    //         //       votingFormFields.where((e) => e.id == b.votingFormFieldId).first.orderIndex;
    //         //   return orderIndexA.compareTo(orderIndexB);
    //         // });
    //         jurorVotes = success;
    //       },
    //     );
    //     if (eitherVotes.isLeft()) {
    //       return;
    //     }
    //
    //     final List<JurorVoteBundle> jurorVotesBundles = [];
    //     for (var jurorVote in jurorVotes) {
    //       jurorVotesBundles.add(JurorVoteBundle(
    //           jurorVote: jurorVote,
    //           votingFormField:
    //               votingFormFields.where((e) => e.id == jurorVote.votingFormFieldId).first));
    //     }
    //
    //     jurorVotesBundles
    //         .sort((a, b) => a.votingFormField.orderIndex.compareTo(b.votingFormField.orderIndex));
    //
    //     participantsVotingsBundles.add(ParticipantVotingBundle(
    //         votingSessionParticipationBundle: votingSessionParticipationBundle,
    //         isExcluded: false,
    //         jurorVoting: jurorVoting,
    //         jurorVotesBundles: jurorVotesBundles));
    //   }
    //   jurorVotingsPerJurorBundles.add(JurorWithSubmissionVotingPerJurorBundle(
    //     votingSessionJurationBundle: votingSessionJurationBundle,
    //     participantsVotingsBundles: participantsVotingsBundles,
    //   ));
    // }
  }
}
