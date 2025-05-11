import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:swift_contest/model/data_models/contest.dart';
import 'package:swift_contest/model/data_models/invitation.dart';
import 'package:swift_contest/model/data_models/juration.dart';
import 'package:swift_contest/model/data_models/participation.dart';
import 'package:swift_contest/model/data_models/profile.dart';
import 'package:swift_contest/model/enums/member_role.dart';
import 'package:swift_contest/model/enums/participant_status.dart';
import 'package:swift_contest/model/enums/work_status.dart';
import 'package:swift_contest/viewmodel/blocs/bloc_status.dart';
import 'package:swift_contest/viewmodel/repositories/contest_repository.dart';
import 'package:swift_contest/viewmodel/repositories/invitation_repository.dart';
import 'package:swift_contest/viewmodel/repositories/participation_repository.dart';

part 'participant_home_page_event.dart';

part 'participant_home_page_state.dart';

class ParticipantHomePageBloc
    extends Bloc<ParticipantHomePageEvent, ParticipantHomePageState> {
  final ContestRepository _contestRepository;
  final ParticipationRepository _participationRepository;
  final InvitationRepository _invitationRepository;

  ParticipantHomePageBloc({
    required ContestRepository contestRepository,
    required ParticipationRepository participationRepository,
    required InvitationRepository invitationRepository,
  })  : _contestRepository = contestRepository,
        _participationRepository = participationRepository,
        _invitationRepository = invitationRepository,
        super(ParticipantHomePageState(status: BlocStatus.initial)) {
    on<ParticipantHomePageJoinContest>(_joinContest);
  }

  Future<void> _joinContest(
    ParticipantHomePageJoinContest event,
    Emitter<ParticipantHomePageState> emit,
  ) async {
    emit(ParticipantHomePageState(status: BlocStatus.loading));

    final eitherContest =
        await _contestRepository.getContestByToken(token: event.contestToken);
    late final Contest contest;
    eitherContest.fold(
      (failure) => emit(ParticipantHomePageState(
          status: BlocStatus.failure, message: failure.message)),
      (success) => contest = success,
    );
    if (eitherContest.isLeft()) return;

    late final List<Invitation> invitations;
    final eitherInvitations =
        await _invitationRepository.getInvitationsByContestIdAndMemberRole(
            contestId: contest.id, memberRole: MemberRole.participant);
    eitherInvitations.fold(
      (failure) => emit(ParticipantHomePageState(
          status: BlocStatus.failure, message: failure.message)),
      (success) => invitations = success,
    );
    if (eitherInvitations.isLeft()) return;

    if(invitations.isEmpty) {
      emit(ParticipantHomePageState(status: BlocStatus.failure,message: 'No invitation found with these credentials'));
    }

    for (var invitation in invitations) {
      if (invitation.token == event.participantToken) {
        late final Participation participation;
        final eitherParticipation =
            await _participationRepository.createParticipation(
                participation: Participation(
          id: invitation.id,
          createdAt: DateTime.now(),
          contestId: contest.id,
          participantId: event.participantId,
          participantStatus: ParticipantStatus.joined,
          workStatus: WorkStatus.attended,
        ));
        eitherParticipation.fold(
          (failure) => emit(ParticipantHomePageState(
              status: BlocStatus.failure, message: failure.message)),
          (success) => participation = success,
        );
        if (eitherParticipation.isLeft()) return;

        final eitherDeleteInvitation =
            await _invitationRepository.deleteInvitationById(id: invitation.id);
        eitherDeleteInvitation.fold(
            (failure) => emit(ParticipantHomePageState(
                status: BlocStatus.failure, message: failure.message)),
            (success) => null);
        if (eitherDeleteInvitation.isLeft()) return;

        emit(ParticipantHomePageState(status: BlocStatus.success, participationJoin: participation));
        break;
      }
    }

    emit(ParticipantHomePageState(status: BlocStatus.failure,message: 'No invitation found with these credentials'));
  }
}
