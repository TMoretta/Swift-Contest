import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:swift_contest/model/data_models/contest/contest.dart';
import 'package:swift_contest/model/data_models/juration/juration.dart';
import 'package:swift_contest/model/data_models/participation/participation.dart';
import 'package:swift_contest/model/data_models/profile/profile.dart';
import 'package:swift_contest/model/data_models/voting_form/voting_form.dart';
import 'package:swift_contest/model/data_models/voting_form/voting_form_field.dart';
import 'package:swift_contest/model/data_models/work/work.dart';
import 'package:swift_contest/viewmodel/repositories/contest_repository.dart';
import 'package:swift_contest/viewmodel/repositories/edge_repository.dart';
import 'package:swift_contest/viewmodel/repositories/juration_repository.dart';
import 'package:swift_contest/viewmodel/repositories/participation_repository.dart';
import 'package:swift_contest/viewmodel/repositories/profile_repository.dart';
import 'package:swift_contest/viewmodel/repositories/voting_form_repository.dart';
import 'package:swift_contest/viewmodel/repositories/work_repository.dart';
import 'package:swift_contest/viewmodel/utils/bloc_status.dart';

part 'organizer_contest_details_page_event.dart';
part 'organizer_contest_details_page_state.dart';

class OrganizerContestDetailsPageBloc
    extends Bloc<OrganizerContestDetailsPageEvent, OrganizerContestDetailsPageState> {
  final EdgeRepository _edgeRepository;
  final ContestRepository _contestRepository;
  final ProfileRepository _profileRepository;
  final ParticipationRepository _participationRepository;
  final JurationRepository _jurationRepository;
  final WorkRepository _workRepository;
  final VotingFormRepository _votingFormRepository;

  OrganizerContestDetailsPageBloc(
      {required ParticipationRepository participationRepository,
      required JurationRepository jurationRepository,
      required EdgeRepository edgeRepository,
      required ProfileRepository profileRepository,
      required ContestRepository contestRepository,
      required WorkRepository workRepository,
      required VotingFormRepository votingFormRepository})
      : _participationRepository = participationRepository,
        _jurationRepository = jurationRepository,
        _edgeRepository = edgeRepository,
        _profileRepository = profileRepository,
        _contestRepository = contestRepository,
        _workRepository = workRepository,
        _votingFormRepository = votingFormRepository,
        super(OrganizerContestDetailsPageState(status: BlocStatus.initial)) {
    on<OrganizerContestDetailsPageSendParticipantInvite>(_sendParticipantInvite);
    on<OrganizerContestDetailsPageSendJurorInvite>(_sendJurorInvite);
    on<OrganizerContestDetailsPageGetExtendedContest>(_getExtendedContest);
    on<OrganizerContestDetailsPageGetVotingForm>(_getVotingForm);
    on<OrganizerContestDetailsPageUpdateVotingForm>(_updateVotingForm);
    on<OrganizerContestDetailsPageClean>(_clean);
  }

  Future<void> _sendParticipantInvite(
    OrganizerContestDetailsPageSendParticipantInvite event,
    Emitter<OrganizerContestDetailsPageState> emit,
  ) async {
    emit(state.copyWith(status: BlocStatus.loading));
    final participationRes = await _participationRepository.createParticipationInvite(
      contestId: event.contest.id,
      inviteEmail: event.email,
    );
    Participation? participationInvite;
    participationRes.fold(
      (failure) => emit(state.copyWith(status: BlocStatus.failure, message: failure.message)),
      (success) => participationInvite = success,
    );
    if (participationInvite == null) {
      return;
    }
    final inviteRes = await _edgeRepository.sendParticipantInvite(
      email: event.email,
      contestToken: event.contest.token,
      participantToken: participationInvite!.token,
    );
    inviteRes.fold(
      (failure) => emit(state.copyWith(status: BlocStatus.failure, message: failure.message)),
      (unit) => emit(state.copyWith(status: BlocStatus.success)),
    );
  }

  Future<void> _sendJurorInvite(
    OrganizerContestDetailsPageSendJurorInvite event,
    Emitter<OrganizerContestDetailsPageState> emit,
  ) async {
    emit(state.copyWith(status: BlocStatus.loading));
    final jurationRes = await _jurationRepository.createJurationInvite(
      contestId: event.contest.id,
      inviteEmail: event.email,
    );
    Juration? jurationInvite;
    jurationRes.fold(
      (failure) => emit(state.copyWith(status: BlocStatus.failure, message: failure.message)),
      (success) => jurationInvite = success,
    );
    if (jurationInvite == null) {
      return;
    }
    final inviteRes = await _edgeRepository.sendParticipantInvite(
      email: event.email,
      contestToken: event.contest.token,
      participantToken: jurationInvite!.token,
    );
    inviteRes.fold(
      (failure) => emit(state.copyWith(status: BlocStatus.failure, message: failure.message)),
      (unit) => emit(state.copyWith(status: BlocStatus.success)),
    );
  }

  Future<void> _getExtendedContest(
    OrganizerContestDetailsPageGetExtendedContest event,
    Emitter<OrganizerContestDetailsPageState> emit,
  ) async {
    emit(state.copyWith(status: BlocStatus.loading));

    late final Contest contest;
    late final Profile organizer;
    late final List<Participation> participations;
    final List<Profile?> participants = [];
    final List<Work?> works = [];
    late final List<Juration> jurations;
    final List<Profile?> jurors = [];

    //* Ottengo il contest
    final resContest = await _contestRepository.getContestById(id: event.contestId);
    resContest.fold(
      (failure) => emit(state.copyWith(status: BlocStatus.failure, message: failure.message)),
      (success) => contest = success,
    );
    if (resContest.isLeft()) return;

    //* Ottengo l'organizer
    final resOrganizer = await _profileRepository.getProfileById(id: contest.organizerId);
    resOrganizer.fold(
      (failure) => emit(state.copyWith(status: BlocStatus.failure, message: failure.message)),
      (success) => organizer = success,
    );
    if (resOrganizer.isLeft()) return;

    //* Ottengo le participations
    final resParticipations =
        await _participationRepository.getParticipationsByContestId(contestId: contest.id);
    resParticipations.fold(
      (failure) => emit(state.copyWith(status: BlocStatus.failure, message: failure.message)),
      (success) => participations = success,
    );
    if (resParticipations.isLeft()) return;

    //* Ottengo i participants
    for (var participation in participations) {
      if (participation.participantId == null) {
        participants.add(null);
        continue;
      }
      final resParticipant =
          await _profileRepository.getProfileById(id: participation.participantId!);
      resParticipant.fold(
        (failure) => emit(state.copyWith(status: BlocStatus.failure, message: failure.message)),
        (success) => participants.add(success),
      );
      if (resParticipant.isLeft()) return;
    }

    //* Ottengo i works
    for (var participation in participations) {
      if (participation.workId == null) {
        works.add(null);
        continue;
      }
      final resWork = await _workRepository.getWorkById(id: participation.workId!);
      resWork.fold(
        (failure) => emit(state.copyWith(status: BlocStatus.failure, message: failure.message)),
        (success) => works.add(success),
      );
      if (resWork.isLeft()) return;
    }

    //* Ottengo le jurations
    final resJurations = await _jurationRepository.getJurationsByContestId(contestId: contest.id);
    resJurations.fold(
      (failure) => emit(state.copyWith(status: BlocStatus.failure, message: failure.message)),
      (success) => jurations = success,
    );
    if (resJurations.isLeft()) return;

    //* Ottengo i jurors
    for (var juration in jurations) {
      if (juration.jurorId == null) {
        jurors.add(null);
        continue;
      }
      final resJuror = await _profileRepository.getProfileById(id: juration.jurorId!);
      resJuror.fold(
        (failure) => emit(state.copyWith(status: BlocStatus.failure, message: failure.message)),
        (success) => jurors.add(success),
      );
      if (resJuror.isLeft()) return;
    }

    emit(state.copyWith(
      status: BlocStatus.success,
      contest: contest,
      organizer: organizer,
      participations: participations,
      participants: participants,
      works: works,
      jurations: jurations,
      jurors: jurors,
    ));

    //*-------------------------------
    // emit(OrganizerContestDetailsPageLoading());
    // final res = await _contestRepository.getExtendedContestByContestId(contestId: event.contestId);
    // res.fold(
    //   (failure) => emit(OrganizerContestDetailsPageFailure(message: failure.message)),
    //   (extendedContest) =>
    //       emit(OrganizerContestDetailsPageSuccess(extendedContest: extendedContest)),
    // );
  }

  Future<void> _getVotingForm(
    OrganizerContestDetailsPageGetVotingForm event,
    Emitter<OrganizerContestDetailsPageState> emit,
  ) async {
    emit(state.copyWith(status: BlocStatus.loading));

    late final Contest contest;
    late final VotingForm votingForm;

    final resContest = await _contestRepository.getContestById(id: event.contestId);
    resContest.fold(
      (failure) => emit(state.copyWith(status: BlocStatus.failure, message: failure.message)),
      (success) => contest = success,
    );
    if (resContest.isLeft()) return;

    final resVotingForm = await _votingFormRepository.getVotingFormById(id: contest.votingFormId);
    resVotingForm.fold(
      (failure) => emit(state.copyWith(status: BlocStatus.failure, message: failure.message)),
      (success) => votingForm = success,
    );
    if (resVotingForm.isLeft()) return;

    emit(state.copyWith(status: BlocStatus.success, votingForm: votingForm));
  }

  Future<void> _updateVotingForm(OrganizerContestDetailsPageUpdateVotingForm event, Emitter<OrganizerContestDetailsPageState> emit,)async {
    emit(state.copyWith(status: BlocStatus.loading));

    if(state.contest== null) {
      emit(state.copyWith(status: BlocStatus.failure, message: 'An error occurred'));
    }

    final contest = state.contest!;

    final votingFormId = contest.votingFormId;
    final votingFormRes = await _votingFormRepository.updateVotingFormById(id: votingFormId, fields: event.updatedFields);

    votingFormRes.fold(
        (failure) => emit(state.copyWith(status: BlocStatus.failure, message: 'An error occurred')),
        (success) => null,
    );

    if(votingFormRes.isLeft()) return;

    add(OrganizerContestDetailsPageGetVotingForm(contestId: contest.id));
  }

  FutureOr<void> _clean(OrganizerContestDetailsPageClean event, Emitter<OrganizerContestDetailsPageState> emit,) async{
    emit(OrganizerContestDetailsPageState(status: BlocStatus.initial));
  }
}
