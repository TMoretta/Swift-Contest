import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:swift_contest/model/bundles/juration_bundle.dart';
import 'package:swift_contest/model/bundles/juror_vote_bundle.dart';
import 'package:swift_contest/model/bundles/voting_session_result_bundle.dart';
import 'package:swift_contest/model/trash/juror_votes_raw_bundle.dart';
import 'package:swift_contest/model/bundles/participation_bundle.dart';
import 'package:swift_contest/model/bundles/voting_session_procedure_bundle.dart';
import 'package:swift_contest/model/repositories/organizer_repository.dart';
import 'package:swift_contest/viewmodel/enums/bloc_status.dart';

part 'organizer_voting_result_details_page_event.dart';
part 'organizer_voting_result_details_page_state.dart';

class OrganizerVotingResultDetailsPageBloc
    extends Bloc<OrganizerVotingResultDetailsPageEvent, OrganizerVotingResultDetailsPageState> {
  final OrganizerRepository _organizerRepository;

  OrganizerVotingResultDetailsPageBloc({
    required OrganizerRepository organizerRepository,
  })  : _organizerRepository = organizerRepository,
        super(OrganizerVotingResultDetailsPageState(status: BlocStatus.initial)) {
    on<OrganizerVotingResultDetailsPageInit>(_init);
    on<OrganizerVotingResultDetailsPageRefresh>(_refresh);
    on<OrganizerVotingResultDetailsPageEditVotingSessionName>(_editVotingSessionName);
  }

  FutureOr<void> _init(
    OrganizerVotingResultDetailsPageInit event,
    Emitter<OrganizerVotingResultDetailsPageState> emit,
  ) async {
    emit(state.copyWith(status: BlocStatus.loading, sourceEvent: event));

    late final VotingSessionResultBundle votingSessionBundle;
    final eitherVotingSessionBundle =
        await _organizerRepository.getVotingSessionResultBundle(votingSessionId: event.votingSessionId);
    eitherVotingSessionBundle.fold(
      (failure) => emit(state.copyWith(status: BlocStatus.failure, message: failure.message)),
      (success) => votingSessionBundle = success,
    );

    emit(state.copyWith(
      status: BlocStatus.success,
      votingSessionResultBundle: votingSessionBundle,
    ));

    // late final JurorVotesRawBundle jurorVotesRawBundle;
    // final eitherJurorVotesRawBundle = await _organizerRepository.getVotingSessionJurorVotes(
    //     votingSessionId: event.votingSessionId);
    // eitherJurorVotesRawBundle.fold(
    //   (failure) => emit(state.copyWith(status: BlocStatus.failure, message: failure.message)),
    //   (success) => jurorVotesRawBundle = success,
    // );
    // if(eitherJurorVotesRawBundle.isLeft()) {
    //   return;
    // }
    //
    // //* Ottengo i voti dei singoli giurati che hanno inviato la votazione per i partecipanti
    // final Map<JurationBundle, Map<ParticipationBundle, List<JurorVoteBundle>?>>
    //     participantsVotingsPerJurorMap = {};
    // final List<JurationBundle> jurorsWithoutSubmissionBundles = [];
    // for (var includedVotingSessionJurationBundle
    //     in votingSessionBundle.includedVotingSessionJurationsBundles) {
    //   final votingSessionJuration = includedVotingSessionJurationBundle.votingSessionJuration;
    //   final jurationBundle = includedVotingSessionJurationBundle.jurationBundle;
    //   if (!votingSessionJuration.hasSubmitted) {
    //     jurorsWithoutSubmissionBundles.add(jurationBundle);
    //     continue;
    //   }
    //
    //   final Map<ParticipationBundle, List<JurorVoteBundle>?> participantsVotes = {};
    //   for (var includedVotingSessionParticipationBundle
    //       in votingSessionBundle.includedVotingSessionParticipationsBundles) {
    //     final votingSessionParticipation =
    //         includedVotingSessionParticipationBundle.votingSessionParticipation;
    //     final participationBundle = includedVotingSessionParticipationBundle.participationBundle;
    //
    //     //* Se il giurato era escluso lo aggiungo come giurato escluso per il determinato partecipante
    //     final exclusion = votingSessionBundle.votingSessionExclusions
    //         .where((e) =>
    //             e.votingSessionParticipationId == votingSessionParticipation.id &&
    //             e.votingSessionJurationId == votingSessionJuration.id)
    //         .firstOrNull;
    //     if (exclusion != null) {
    //       participantsVotes.addAll({participationBundle: null});
    //       continue;
    //     }
    //
    //     final jurorVoting = jurorVotesRawBundle.jurorVotings
    //         .where((e) =>
    //             e.votingSessionJurationId == votingSessionJuration.id &&
    //             e.votingSessionParticipationId == votingSessionParticipation.id)
    //         .first;
    //     // late final JurorVoting? jurorVoting;
    //     // final eitherVoting = await _jurorVotingRepository
    //     //     .getJurorVotingByVotingSessionJurationIdAndVotingSessionParticipationId(
    //     //         votingSessionJurationId: votingSessionJuration.id,
    //     //         votingSessionParticipationId: votingSessionParticipation.id);
    //     // eitherVoting.fold(
    //     //   (failure) => emit(state.copyWith(status: BlocStatus.failure, message: failure.message)),
    //     //   (success) => jurorVoting = success,
    //     // );
    //     // if (eitherVoting.isLeft()) {
    //     //   return;
    //     // }
    //     // if (jurorVoting == null) {
    //     //   emit(state.copyWith(status: BlocStatus.failure, message: 'Juror voting not found'));
    //     //   return;
    //     // }
    //
    //     final jurorVotes = jurorVotesRawBundle.jurorVotes.where((e) => e.jurorVotingId == jurorVoting.id).toList(growable: false);
    //
    //     // late final List<JurorVote> jurorVotes;
    //     // final eitherVotes =
    //     //     await _jurorVoteRepository.getJurorVotesByJurorVotingId(jurorVotingId: jurorVoting!.id);
    //     // eitherVotes.fold(
    //     //   (failure) => emit(state.copyWith(status: BlocStatus.failure, message: failure.message)),
    //     //   (success) {
    //     //     jurorVotes = success;
    //     //   },
    //     // );
    //     // if (eitherVotes.isLeft()) {
    //     //   return;
    //     // }
    //
    //     final List<JurorVoteBundle> jurorVotesBundles = [];
    //     for (var jurorVote in jurorVotes) {
    //       jurorVotesBundles.add(JurorVoteBundle(
    //           jurorVote: jurorVote,
    //           votingFormField: votingSessionBundle.votingFormBundle.votingFormFields
    //               .where((e) => e.id == jurorVote.votingFormFieldId)
    //               .first));
    //     }
    //
    //     jurorVotesBundles
    //         .sort((a, b) => a.votingFormField.orderIndex.compareTo(b.votingFormField.orderIndex));
    //     participantsVotes.addAll({participationBundle: jurorVotesBundles});
    //   }
    //   participantsVotingsPerJurorMap.addAll({jurationBundle: participantsVotes});
    // }
    //
    // //* Ottengo i voti ricevuti dai singoli partecipanti dai giurati
    // final Map<ParticipationBundle, Map<JurationBundle, List<JurorVoteBundle>?>>
    //     jurorsVotingsPerParticipantMap = {};
    // for (final jurorEntry in participantsVotingsPerJurorMap.entries) {
    //   final jurationBundle = jurorEntry.key;
    //   final participantsVotes = jurorEntry.value;
    //
    //   for (final participantEntry in participantsVotes.entries) {
    //     final participationBundle = participantEntry.key;
    //     final votes = participantEntry.value;
    //
    //     jurorsVotingsPerParticipantMap
    //         .putIfAbsent(participationBundle, () => {})
    //         .addAll({jurationBundle: votes});
    //   }
    // }
    //
    // emit(state.copyWith(
    //   status: BlocStatus.success,
    //   votingSessionProcedureBundle: votingSessionBundle,
    //   participantsVotingsPerJurorMap: participantsVotingsPerJurorMap,
    //   jurorsVotingsPerParticipantMap: jurorsVotingsPerParticipantMap,
    //   jurorsWithoutSubmissionBundles: jurorsWithoutSubmissionBundles,
    // ));
  }

  FutureOr<void> _refresh(
    OrganizerVotingResultDetailsPageRefresh event,
    Emitter<OrganizerVotingResultDetailsPageState> emit,
  ) async {
    emit(state.copyWith(status: BlocStatus.loading, sourceEvent: event));

    late final VotingSessionResultBundle votingSessionBundle;
    final eitherVotingSessionBundle =
    await _organizerRepository.getVotingSessionResultBundle(votingSessionId: event.votingSessionId);
    eitherVotingSessionBundle.fold(
          (failure) => emit(state.copyWith(status: BlocStatus.failure, message: failure.message)),
          (success) => votingSessionBundle = success,
    );

    emit(state.copyWith(
      status: BlocStatus.success,
      votingSessionResultBundle: votingSessionBundle,
    ));



    // emit(state.copyWith(status: BlocStatus.loading, sourceEvent: event));
    //
    // late final VotingSessionProcedureBundle votingSessionBundle;
    // final eitherVotingSessionBundle =
    // await _organizerRepository.getVotingSessionProcedureBundle(votingSessionId: event.votingSessionId);
    // eitherVotingSessionBundle.fold(
    //       (failure) => emit(state.copyWith(status: BlocStatus.failure, message: failure.message)),
    //       (success) => votingSessionBundle = success,
    // );
    //
    // late final JurorVotesRawBundle jurorVotesRawBundle;
    // final eitherJurorVotesRawBundle = await _organizerRepository.getVotingSessionJurorVotes(
    //     votingSessionId: event.votingSessionId);
    // eitherJurorVotesRawBundle.fold(
    //       (failure) => emit(state.copyWith(status: BlocStatus.failure, message: failure.message)),
    //       (success) => jurorVotesRawBundle = success,
    // );
    // if(eitherJurorVotesRawBundle.isLeft()) {
    //   return;
    // }
    //
    // //* Ottengo i voti dei singoli giurati che hanno inviato la votazione per i partecipanti
    // final Map<JurationBundle, Map<ParticipationBundle, List<JurorVoteBundle>?>>
    // participantsVotingsPerJurorMap = {};
    // final List<JurationBundle> jurorsWithoutSubmissionBundles = [];
    // for (var includedVotingSessionJurationBundle
    // in votingSessionBundle.includedVotingSessionJurationsBundles) {
    //   final votingSessionJuration = includedVotingSessionJurationBundle.votingSessionJuration;
    //   final jurationBundle = includedVotingSessionJurationBundle.jurationBundle;
    //   if (!votingSessionJuration.hasSubmitted) {
    //     jurorsWithoutSubmissionBundles.add(jurationBundle);
    //     continue;
    //   }
    //
    //   final Map<ParticipationBundle, List<JurorVoteBundle>?> participantsVotes = {};
    //   for (var includedVotingSessionParticipationBundle
    //   in votingSessionBundle.includedVotingSessionParticipationsBundles) {
    //     final votingSessionParticipation =
    //         includedVotingSessionParticipationBundle.votingSessionParticipation;
    //     final participationBundle = includedVotingSessionParticipationBundle.participationBundle;
    //
    //     //* Se il giurato era escluso lo aggiungo come giurato escluso per il determinato partecipante
    //     final exclusion = votingSessionBundle.votingSessionExclusions
    //         .where((e) =>
    //     e.votingSessionParticipationId == votingSessionParticipation.id &&
    //         e.votingSessionJurationId == votingSessionJuration.id)
    //         .firstOrNull;
    //     if (exclusion != null) {
    //       participantsVotes.addAll({participationBundle: null});
    //       continue;
    //     }
    //
    //     final jurorVoting = jurorVotesRawBundle.jurorVotings
    //         .where((e) =>
    //     e.votingSessionJurationId == votingSessionJuration.id &&
    //         e.votingSessionParticipationId == votingSessionParticipation.id)
    //         .first;
    //     // late final JurorVoting? jurorVoting;
    //     // final eitherVoting = await _jurorVotingRepository
    //     //     .getJurorVotingByVotingSessionJurationIdAndVotingSessionParticipationId(
    //     //         votingSessionJurationId: votingSessionJuration.id,
    //     //         votingSessionParticipationId: votingSessionParticipation.id);
    //     // eitherVoting.fold(
    //     //   (failure) => emit(state.copyWith(status: BlocStatus.failure, message: failure.message)),
    //     //   (success) => jurorVoting = success,
    //     // );
    //     // if (eitherVoting.isLeft()) {
    //     //   return;
    //     // }
    //     // if (jurorVoting == null) {
    //     //   emit(state.copyWith(status: BlocStatus.failure, message: 'Juror voting not found'));
    //     //   return;
    //     // }
    //
    //     final jurorVotes = jurorVotesRawBundle.jurorVotes.where((e) => e.jurorVotingId == jurorVoting.id).toList(growable: false);
    //
    //     // late final List<JurorVote> jurorVotes;
    //     // final eitherVotes =
    //     //     await _jurorVoteRepository.getJurorVotesByJurorVotingId(jurorVotingId: jurorVoting!.id);
    //     // eitherVotes.fold(
    //     //   (failure) => emit(state.copyWith(status: BlocStatus.failure, message: failure.message)),
    //     //   (success) {
    //     //     jurorVotes = success;
    //     //   },
    //     // );
    //     // if (eitherVotes.isLeft()) {
    //     //   return;
    //     // }
    //
    //     final List<JurorVoteBundle> jurorVotesBundles = [];
    //     for (var jurorVote in jurorVotes) {
    //       jurorVotesBundles.add(JurorVoteBundle(
    //           jurorVote: jurorVote,
    //           votingFormField: votingSessionBundle.votingFormBundle.votingFormFields
    //               .where((e) => e.id == jurorVote.votingFormFieldId)
    //               .first));
    //     }
    //
    //     jurorVotesBundles
    //         .sort((a, b) => a.votingFormField.orderIndex.compareTo(b.votingFormField.orderIndex));
    //     participantsVotes.addAll({participationBundle: jurorVotesBundles});
    //   }
    //   participantsVotingsPerJurorMap.addAll({jurationBundle: participantsVotes});
    // }
    //
    // //* Ottengo i voti ricevuti dai singoli partecipanti dai giurati
    // final Map<ParticipationBundle, Map<JurationBundle, List<JurorVoteBundle>?>>
    // jurorsVotingsPerParticipantMap = {};
    // for (final jurorEntry in participantsVotingsPerJurorMap.entries) {
    //   final jurationBundle = jurorEntry.key;
    //   final participantsVotes = jurorEntry.value;
    //
    //   for (final participantEntry in participantsVotes.entries) {
    //     final participationBundle = participantEntry.key;
    //     final votes = participantEntry.value;
    //
    //     jurorsVotingsPerParticipantMap
    //         .putIfAbsent(participationBundle, () => {})
    //         .addAll({jurationBundle: votes});
    //   }
    // }
    //
    // emit(state.copyWith(
    //   status: BlocStatus.success,
    //   votingSessionProcedureBundle: votingSessionBundle,
    //   participantsVotingsPerJurorMap: participantsVotingsPerJurorMap,
    //   jurorsVotingsPerParticipantMap: jurorsVotingsPerParticipantMap,
    //   jurorsWithoutSubmissionBundles: jurorsWithoutSubmissionBundles,
    // ));
  }

  FutureOr<void> _editVotingSessionName(
    OrganizerVotingResultDetailsPageEditVotingSessionName event,
    Emitter<OrganizerVotingResultDetailsPageState> emit,
  ) async {
    emit(state.copyWith(status: BlocStatus.loading, sourceEvent: event));

    final eitherDeleteInvitation = await _organizerRepository.editVotingSessionName(
        votingSessionId: event.votingSessionId, name: event.name);
    eitherDeleteInvitation.fold(
      (failure) => emit(state.copyWith(status: BlocStatus.failure, message: failure.message)),
      (success) => emit(state.copyWith(status: BlocStatus.success)),
    );
  }
}
