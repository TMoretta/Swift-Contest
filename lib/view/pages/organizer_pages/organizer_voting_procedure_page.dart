import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_timer_countdown/flutter_timer_countdown.dart';
import 'package:go_router/go_router.dart';
import 'package:swift_contest/model/data_models/user.dart';
import 'package:swift_contest/model/enums/voting_session_procedure_step.dart';
import 'package:swift_contest/utils/functions/show_snack_bar.dart';
import 'package:swift_contest/view/widgets/custom_app_bar.dart';
import 'package:swift_contest/view/widgets/loader.dart';
import 'package:swift_contest/viewmodel/enums/bloc_status.dart';
import 'package:swift_contest/viewmodel/blocs/global_blocs/auth_bloc/auth_bloc.dart';
import 'package:swift_contest/viewmodel/blocs/pages_blocs/organizer_voting_procedure_page_bloc/organizer_voting_procedure_page_bloc.dart';

class OrganizerVotingProcedurePage extends StatefulWidget {
  final String contestId;

  const OrganizerVotingProcedurePage({required this.contestId, super.key});

  @override
  State<OrganizerVotingProcedurePage> createState() => _OrganizerVotingProcedurePageState();
}

class _OrganizerVotingProcedurePageState extends State<OrganizerVotingProcedurePage> {
  late User user;
  String? votingSessionProcedureId;

  @override
  void initState() {
    super.initState();
    user = context.read<AuthBloc>().state.user!;
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<OrganizerVotingProcedurePageBloc>(
      create: (context) => OrganizerVotingProcedurePageBloc(
        votingSessionRepository: context.read(),
        votingSessionProcedureRepository: context.read(),
        votingSessionParticipantRepository: context.read(),
        workRepository: context.read(),
        participationRepository: context.read(),
        profileRepository: context.read(),
      )..add(OrganizerVotingProcedurePageSubscribeToVotingSessionProcedure(
          contestId: widget.contestId)),
      child: Scaffold(
        appBar: CustomAppBar(title: 'Voting'),
        body: BlocConsumer<OrganizerVotingProcedurePageBloc, OrganizerVotingProcedurePageState>(
          listener: (context, state) {

            if (state.status.isFailure) {
              showSnackBar(context: context, text: state.message!);
            }
            if (state.status.isSuccess && state.votingSessionProcedure?.currentStep == VotingSessionProcedureStep.end) {
              showSnackBar(context: context, text: 'Voting session ended successfully');
              context.pop();
            }
            if (state.status.isSuccess && state.votingSessionProcedure?.currentStep == VotingSessionProcedureStep.cancelled) {
              showSnackBar(context: context, text: 'Voting session cancelled successfully');
              context.pop();
            }
          },
          builder: (context, state) {
            if (state.status.isFailure) {
              return FilledButton(
                  onPressed: () {
                    context.read<OrganizerVotingProcedurePageBloc>().add(
                        OrganizerVotingProcedurePageSubscribeToVotingSessionProcedure(
                            contestId: widget.contestId));
                  },
                  child: Text('Reconnect'));
            }

            if (state.status.isSuccess) {
              votingSessionProcedureId = state.votingSessionProcedure!.id;
              final votingSessionProcedure = state.votingSessionProcedure!;
              final currentStep = votingSessionProcedure.currentStep!;
              // final nextParticipant = state.participants![(currentParticipantIndex + 1) % state.participants!.length];
              // final nextWork = state.works![(currentParticipantIndex + 1) % state.works!.length];

              if(currentStep == VotingSessionProcedureStep.preparation) {
                return Column(
                  children: [
                    Text('Simple juror access token: ${state.votingSession!.token}'),
                    FilledButton(onPressed: (){
                      context.read<OrganizerVotingProcedurePageBloc>().add(OrganizerVotingProcedurePageStartVotingSessionProcedure(contestId: widget.contestId));
                    }, child: Text('Start'),),
                  ],
                );
              }

              if (currentStep == VotingSessionProcedureStep.work) {
                final currentStepDeadline = votingSessionProcedure.currentStepDeadline!;
                final currentParticipantIndex = votingSessionProcedure.currentParticipantIndex!;
                final currentParticipant = state.participants![currentParticipantIndex];
                final currentWork = state.works![currentParticipantIndex];
                return Column(
                  key: UniqueKey(),
                  children: [
                    Text('Simple juror access token: ${state.votingSession!.token}'),
                    Text('Jurors are voting'),
                    TimerCountdown(endTime: currentStepDeadline),
                    Text('Current participant: ${currentParticipant.fullName}'),
                    Text('Current work: ${currentWork.name}'),
                    // Text('Deadline: ${currentStepDeadline.toIso8601String()}'),
                    // Text('Step: ${currentStep.name}'),
                    // Text('Participant: ${currentParticipant.fullName}'),
                  ],
                );
              }

              if (currentStep == VotingSessionProcedureStep.intermission) {
                final currentStepDeadline = votingSessionProcedure.currentStepDeadline!;
                return Column(
                  key: UniqueKey(),
                  children: [
                    Text('Simple juror access token: ${state.votingSession!.token}'),
                    Text('Intermission'),
                    TimerCountdown(endTime: currentStepDeadline),
                  ],
                );
              }

              if (currentStep == VotingSessionProcedureStep.review) {
                final currentStepDeadline = votingSessionProcedure.currentStepDeadline!;
                return Column(
                  key: UniqueKey(),
                  children: [
                    Text('Simple juror access token: ${state.votingSession!.token}'),
                    Text('Jurors are reviewing'),
                    TimerCountdown(endTime: currentStepDeadline),
                  ],
                );
              }
            }
            return Loader();
          },
        ),
        floatingActionButton:
            BlocConsumer<OrganizerVotingProcedurePageBloc, OrganizerVotingProcedurePageState>(
          listener: (context, state) {
            if(state.status.isFailure) {
              showSnackBar(context: context, text: state.message!);
            }
          },
          builder: (context, state) {
            return FloatingActionButton(
              onPressed: (state.status.isSuccess || state.status.isFailure)
                  ? () {
                      if (votingSessionProcedureId == null) return;
                      context.read<OrganizerVotingProcedurePageBloc>().add(
                          OrganizerVotingProcedurePageCancelVotingSessionProcedure(
                              votingSessionProcedureId: votingSessionProcedureId!));
                    }
                  : () {},
              child: Text('Cancel procedure'),
            );
          },
        ),
      ),
    );
  }
}
