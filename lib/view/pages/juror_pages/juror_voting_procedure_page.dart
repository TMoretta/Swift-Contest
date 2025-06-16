import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_timer_countdown/flutter_timer_countdown.dart';
import 'package:go_router/go_router.dart';
import 'package:swift_contest/model/bundles/contest_details_bundle.dart';
import 'package:swift_contest/model/bundles/voting_session_participation_bundle.dart';
import 'package:swift_contest/model/data_models/user.dart';
import 'package:swift_contest/model/data_models/voting_form_field.dart';
import 'package:swift_contest/model/data_models/voting_session.dart';
import 'package:swift_contest/model/data_models/voting_session_participation.dart';
import 'package:swift_contest/model/enums/voting_session_status.dart';
import 'package:swift_contest/utils/functions/show_snack_bar.dart';
import 'package:swift_contest/view/widgets/custom_app_bar.dart';
import 'package:swift_contest/view/widgets/loader.dart';
import 'package:swift_contest/viewmodel/blocs/auth_bloc/auth_bloc.dart';
import 'package:swift_contest/viewmodel/blocs/pages_blocs/juror_voting_procedure_page_bloc/juror_voting_procedure_page_bloc.dart';
import 'package:swift_contest/viewmodel/enums/bloc_status.dart';
import 'package:swift_contest/viewmodel/enums/bloc_status_failure_type.dart';

class JurorVotingProcedurePage extends StatefulWidget {
  final ContestDetailsBundle contestDetailsBundle;

  const JurorVotingProcedurePage({required this.contestDetailsBundle, super.key});

  @override
  State<JurorVotingProcedurePage> createState() => _JurorVotingProcedurePageState();
}

class _JurorVotingProcedurePageState extends State<JurorVotingProcedurePage> {
  late User user;
  late ContestDetailsBundle contestDetailsBundle;
  VotingSession? votingSessionBackup;
  Map<VotingSessionParticipation, Map<VotingFormField, int>> votesPerParticipantMap = {};

  @override
  void initState() {
    super.initState();
    user = context.read<AuthBloc>().state.authBundle!.user;
    contestDetailsBundle = widget.contestDetailsBundle;
    context.read<JurorVotingProcedurePageBloc>().add(
        JurorVotingProcedurePageSubscribeToVotingSessionProcedure(
            jurorId: user.id, contestDetailsBundle: contestDetailsBundle));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: 'Voting'),
      body: BlocConsumer<JurorVotingProcedurePageBloc, JurorVotingProcedurePageState>(
        listener: (context, state) {
          if (state.status.isFailure && state.message != null) {
            showSnackBar(context: context, text: state.message!);
          }
          // if (state.status.isFailure && state.failureType == BlocStatusFailureType.requestPop) {
          //   context.pop();
          // }
          if (state.status.isSuccess &&
              state.votingSessionBundle!.votingSession.sessionStatus ==
                  VotingSessionStatus.ended) {
            showSnackBar(context: context, text: 'Voting session procedure is ended');
            context.pop();
          }
          if (state.status.isSuccess &&
              state.votingSessionBundle!.votingSession.sessionStatus ==
                  VotingSessionStatus.cancelled) {
            showSnackBar(
                context: context,
                text: 'Voting session procedure has been cancelled by the organizer');
            context.pop();
          }
        },
        builder: (context, state) {
          switch (state.status) {
            case BlocStatus.initial:
              return SizedBox.shrink();
            case BlocStatus.loading:
              return Loader();
            case BlocStatus.failure:
              // switch (state.failureType) {
              //   case null:
              //   case BlocStatusFailureType.requestRefresh:
              //     return RefreshIndicator.adaptive(
              //       onRefresh: () async {
              //         context.read<JurorVotingProcedurePageBloc>().add(
              //             JurorVotingProcedurePageSubscribeToVotingSessionProcedure(
              //                 contestDetailsBundle: contestDetailsBundle, jurorId: user.id));
              //       },
              //       child: ListView(physics: AlwaysScrollableScrollPhysics()),
              //     );
              //   case BlocStatusFailureType.requestPop:
              //     return SizedBox.shrink();
              //   case BlocStatusFailureType.showPreviousState:
              //     continue successCase;
              // }
            successCase:
            case BlocStatus.success:
              votingSessionBackup = state.votingSessionBundle!.votingSession;
              final votingSession = state.votingSessionBundle!.votingSession;
              final sessionStatus = votingSession.sessionStatus;

              if (sessionStatus == VotingSessionStatus.initialized) {
                return Text('Await here the beginning of the voting session');
              }

              if (sessionStatus == VotingSessionStatus.work) {
                final currentStepDeadline = votingSession.currentStepDeadline!;
                final currentParticipantIndex = votingSession.currentParticipantIndex!;
                final currentVotingSessionParticipationBundle = state.votingSessionBundle!
                    .votingSessionParticipationsBundles[currentParticipantIndex];
                final votingFormFields =
                    state.votingSessionBundle!.votingFormBundle.votingFormFields;

                if (state.votingSessionBundle!.votingSessionParticipationsExcludedFrom
                    .contains(currentVotingSessionParticipationBundle.votingSessionParticipation)) {
                  votesPerParticipantMap.addAll(
                      {currentVotingSessionParticipationBundle.votingSessionParticipation: {}});
                  return Text('The organizer excluded you from voting to this participant');
                }

                return WorkVotingPage(
                  votingSessionParticipationBundle: currentVotingSessionParticipationBundle,
                  votingFormFields: votingFormFields,
                  sessionStatus: sessionStatus,
                  currentStepDeadline: currentStepDeadline,
                  votesPerParticipantMap: votesPerParticipantMap,
                );
              }

              if (sessionStatus == VotingSessionStatus.intermission) {
                final currentStepDeadline = votingSession.currentStepDeadline!;
                return Column(
                  key: UniqueKey(),
                  children: [
                    Text('Intermission'),
                    TimerCountdown(endTime: currentStepDeadline),
                  ],
                );
              }

              if (sessionStatus == VotingSessionStatus.review) {
                final currentStepDeadline = votingSession.currentStepDeadline!;
                return Column(
                  key: UniqueKey(),
                  children: [
                    Text('Review'),
                    TimerCountdown(endTime: currentStepDeadline),
                    BlocProvider<JurorVotingProcedurePageBloc>(
                      create: (context) => JurorVotingProcedurePageBloc(
                        jurorVotingRepository: context.read(),
                        jurorVoteRepository: context.read(),
                        placeRepository: context.read(),
                        jurationRepository: context.read(),
                        votingSessionExclusionsBundles: context.read(),
                        votingSessionJurationRepository: context.read(),
                        votingSessionParticipationRepository: context.read(),
                        jurorRepository: context.read(),
                      ),
                      child:
                          BlocConsumer<JurorVotingProcedurePageBloc, JurorVotingProcedurePageState>(
                        listener: (context, state) {
                          if (state.status.isSuccess) {
                            showSnackBar(context: context, text: 'Votes submitted successfully');
                            context.pop();
                          }
                        },
                        builder: (context, state) {
                          return FilledButton(
                            onPressed: () {
                              if (votingSessionBackup == null) {
                                return;
                              }
                              context
                                  .read<JurorVotingProcedurePageBloc>()
                                  .add(JurorVotingProcedurePageSubmitVotes(
                                    jurorId: user.id,
                                    votingSession: votingSessionBackup!,
                                    votesPerParticipantMap: votesPerParticipantMap,
                                    contestId: contestDetailsBundle.contest.id,
                                  ));
                            },
                            child: Text('Submit'),
                          );
                        },
                      ),
                    ),
                  ],
                );
              }
              return SizedBox.shrink();
          }
        },
      ),
    );
  }
}

class WorkVotingPage extends StatelessWidget {
  final VotingSessionParticipationBundle votingSessionParticipationBundle;
  final List<VotingFormField> votingFormFields;
  final VotingSessionStatus sessionStatus;
  final DateTime currentStepDeadline;
  final Map<VotingSessionParticipation, Map<VotingFormField, int>> votesPerParticipantMap;

  const WorkVotingPage({
    super.key,
    required this.votingSessionParticipationBundle,
    required this.votingFormFields,
    required this.sessionStatus,
    required this.currentStepDeadline,
    required this.votesPerParticipantMap,
  });

  @override
  Widget build(BuildContext context) {
    final participant = votingSessionParticipationBundle.participationBundle.participant;
    final work = votingSessionParticipationBundle.participationBundle.work!;
    final votingSessionParticipation = votingSessionParticipationBundle.votingSessionParticipation;
    return Column(
      key: UniqueKey(),
      children: [
        TimerCountdown(endTime: currentStepDeadline),
        Text('Current participant: ${participant.fullName}'),
        Text('Current work: ${work.name}'),
        SizedBox(
          height: 200,
          child: ListView.builder(
            itemCount: votingFormFields.length,
            itemBuilder: (context, index) {
              final field = votingFormFields[index];
              if (votesPerParticipantMap[votingSessionParticipation] == null) {
                votesPerParticipantMap.addAll({votingSessionParticipation: {}});
              }
              // votesPerParticipantMap[votingSessionParticipation]!.addAll({field: ''});
              return TextField(
                decoration: InputDecoration(label: Text(field.name)),
                onChanged: (value) {
                  votesPerParticipantMap[votingSessionParticipation]!.addAll({field: int.parse(value)});
                },
              );
            },
          ),
        ),
        // Text('Deadline: ${currentStepDeadline.toIso8601String()}'),
        // Text('Step: ${currentStep.name}'),
        // Text('Participant: ${currentParticipant.fullName}'),
      ],
    );
  }
}
