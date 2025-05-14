import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_timer_countdown/flutter_timer_countdown.dart';
import 'package:go_router/go_router.dart';
import 'package:swift_contest/model/data_models/profile.dart';
import 'package:swift_contest/model/data_models/voting_form_field.dart';
import 'package:swift_contest/model/data_models/voting_session.dart';
import 'package:swift_contest/model/data_models/voting_session_participant.dart';
import 'package:swift_contest/model/data_models/voting_session_simple_juror.dart';
import 'package:swift_contest/model/data_models/work.dart';
import 'package:swift_contest/model/enums/voting_session_procedure_step.dart';
import 'package:swift_contest/utils/functions/show_snack_bar.dart';
import 'package:swift_contest/view/widgets/custom_app_bar.dart';
import 'package:swift_contest/view/widgets/loader.dart';
import 'package:swift_contest/viewmodel/blocs/bloc_status.dart';
import 'package:swift_contest/viewmodel/blocs/pages_blocs/simple_juror_voting_procedure_page_bloc/simple_juror_voting_procedure_page_bloc.dart';

class SimpleJurorVotingProcedurePage extends StatefulWidget {
  final Map<String,dynamic> jsonData;
  const SimpleJurorVotingProcedurePage({required this.jsonData, super.key});

  @override
  State<SimpleJurorVotingProcedurePage> createState() => _SimpleJurorVotingProcedurePageState();
}

class _SimpleJurorVotingProcedurePageState extends State<SimpleJurorVotingProcedurePage> {
  late VotingSession votingSession;
  late VotingSessionSimpleJuror votingSessionSimpleJuror;
  Map<VotingSessionParticipant, Map<VotingFormField, String>> votesPerParticipantMap = {};


  @override
  void initState() {
    super.initState();
    votingSession = widget.jsonData['voting_session'];
    votingSessionSimpleJuror = widget.jsonData['voting_session_simple_juror'];
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<SimpleJurorVotingProcedurePageBloc>(
      create: (context) => SimpleJurorVotingProcedurePageBloc(
        votingSessionRepository: context.read(),
        votingSessionProcedureRepository: context.read(),
        votingSessionParticipantRepository: context.read(),
        workRepository: context.read(),
        participationRepository: context.read(),
        profileRepository: context.read(),
        votingFormRepository: context.read(),
        votingFormFieldRepository: context.read(),
        votingSessionJurorRepository: context.read(),
        jurorVotingRepository: context.read(),
        jurorVoteRepository: context.read(),
        simpleJurorVotingRepository: context.read(),
        votingSessionSimpleJurorRepository: context.read(),
        simpleJurorVoteRepository: context.read(),
      )..add(SimpleJurorVotingProcedurePageSubscribeToVotingSessionProcedure(votingSession: votingSession,votingSessionSimpleJuror: votingSessionSimpleJuror)),
      child: Scaffold(
        appBar: CustomAppBar(title: 'Voting'),
        body: BlocConsumer<SimpleJurorVotingProcedurePageBloc,
            SimpleJurorVotingProcedurePageState>(
          listener: (context, state) {
            if (state.status.isFailure) {
              showSnackBar(context: context, text: state.message!);
            }
            if (state.status.isSuccess &&
                state.votingSessionProcedure?.currentStep ==
                    VotingSessionProcedureStep.end) {
              showSnackBar(
                  context: context, text: 'Voting session procedure is ended');
              context.pop();
            }
            if (state.status.isSuccess &&
                state.votingSessionProcedure?.currentStep ==
                    VotingSessionProcedureStep.cancelled) {
              showSnackBar(
                  context: context,
                  text:
                  'Voting session procedure has been cancelled by the organizer');
              context.pop();
            }
          },
          builder: (context, state) {
            if (state.status.isFailure) {
              return FilledButton(
                  onPressed: () {
                    context.read<SimpleJurorVotingProcedurePageBloc>().add(
                        SimpleJurorVotingProcedurePageSubscribeToVotingSessionProcedure(votingSession: votingSession,votingSessionSimpleJuror: votingSessionSimpleJuror));
                  },
                  child: Text('Reconnect'));
            }

            if (state.status.isSuccess) {
              // if (state.votingSession != null) {
              //   votingSessionId = state.votingSession!.id;
              // }
              // votingSessionProcedureId = state.votingSessionProcedure!.id;
              final votingSessionProcedure = state.votingSessionProcedure!;
              final currentStep = votingSessionProcedure.currentStep!;
              // final nextParticipant = state.participants![(currentParticipantIndex + 1) % state.participants!.length];
              // final nextWork = state.works![(currentParticipantIndex + 1) % state.works!.length];

              if (currentStep == VotingSessionProcedureStep.preparation) {
                return Text('Await here the beginning of the voting session');
              }

              if (currentStep == VotingSessionProcedureStep.work) {
                final currentStepDeadline =
                votingSessionProcedure.currentStepDeadline!;
                final currentParticipantIndex =
                votingSessionProcedure.currentParticipantIndex!;
                final currentParticipant =
                state.participants![currentParticipantIndex];
                final currentVotingSessionParticipant =
                state.votingSessionParticipants![currentParticipantIndex];
                final currentWork = state.works![currentParticipantIndex];
                final currentVotingSessionParticipantId = state
                    .votingSessionParticipants![currentParticipantIndex].id;
                final votingFormFields = state.votingFormFields!;

                return WorkVotingPage(
                  votingSessionParticipant: currentVotingSessionParticipant,
                  participant: currentParticipant,
                  work: currentWork,
                  votingFormFields: votingFormFields,
                  currentStep: currentStep,
                  currentStepDeadline: currentStepDeadline,
                  votesPerParticipantMap: votesPerParticipantMap,
                );
              }

              if (currentStep == VotingSessionProcedureStep.intermission) {
                final currentStepDeadline =
                votingSessionProcedure.currentStepDeadline!;
                return Column(
                  key: UniqueKey(),
                  children: [
                    Text('Intermission'),
                    TimerCountdown(endTime: currentStepDeadline),
                  ],
                );
              }

              if (currentStep == VotingSessionProcedureStep.review) {
                final currentStepDeadline =
                votingSessionProcedure.currentStepDeadline!;
                return Column(
                  key: UniqueKey(),
                  children: [
                    Text('Review'),
                    TimerCountdown(endTime: currentStepDeadline),
                    BlocProvider<SimpleJurorVotingProcedurePageBloc>(
                      create: (context) => SimpleJurorVotingProcedurePageBloc(
                        votingSessionRepository: context.read(),
                        votingSessionProcedureRepository: context.read(),
                        votingSessionParticipantRepository: context.read(),
                        workRepository: context.read(),
                        participationRepository: context.read(),
                        profileRepository: context.read(),
                        votingFormRepository: context.read(),
                        votingFormFieldRepository: context.read(),
                        jurorVotingRepository: context.read(),
                        jurorVoteRepository: context.read(),
                        votingSessionJurorRepository: context.read(),
                        simpleJurorVotingRepository: context.read(),
                        votingSessionSimpleJurorRepository: context.read(),
                        simpleJurorVoteRepository: context.read(),
                      ),
                      child: BlocConsumer<SimpleJurorVotingProcedurePageBloc,
                          SimpleJurorVotingProcedurePageState>(
                        listener: (context, state) {
                          if (state.status.isSuccess) {
                            showSnackBar(
                                context: context,
                                text: 'Votes submitted successfully');
                            context.pop();
                          }
                        },
                        builder: (context, state) {
                          return FilledButton(
                            onPressed: () {
                              context
                                  .read<SimpleJurorVotingProcedurePageBloc>()
                                  .add(SimpleJurorVotingProcedurePageSubmitVotes(
                                votingSessionSimpleJuror: votingSessionSimpleJuror,
                                votingSessionId: votingSession.id,
                                votesPerParticipantMap: votesPerParticipantMap,
                              ));
                              // for (var v in votesPerParticipantMap.entries) {
                              //   final votes = v.value.entries;
                              //   for (var vote in votes) {
                              //     debugPrint(
                              //         'PARTICIPANT: ${v.key.fullName}, FIELD: ${vote.key.name}, VALUE: ${vote.value}');
                              //   }
                              // }
                            },
                            child: Text('Submit'),
                          );
                        },
                      ),
                    ),
                  ],
                );
              }

              if (currentStep == VotingSessionProcedureStep.end) {}
            }
            return Loader();
          },
        ),
      ),
    );
  }
}

class WorkVotingPage extends StatelessWidget {
  final VotingSessionParticipant votingSessionParticipant;
  final Participant participant;
  final Work work;
  final List<VotingFormField> votingFormFields;
  final VotingSessionProcedureStep currentStep;
  final DateTime currentStepDeadline;
  final Map<VotingSessionParticipant, Map<VotingFormField, String>>
  votesPerParticipantMap;

  const WorkVotingPage({
    super.key,
    required this.votingSessionParticipant,
    required this.participant,
    required this.work,
    required this.votingFormFields,
    required this.currentStep,
    required this.currentStepDeadline,
    required this.votesPerParticipantMap,
  });

  @override
  Widget build(BuildContext context) {
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
              if (votesPerParticipantMap[votingSessionParticipant] == null) {
                votesPerParticipantMap.addAll({votingSessionParticipant: {}});
              }
              votesPerParticipantMap[votingSessionParticipant]!
                  .addAll({field: ''});
              return TextField(
                decoration: InputDecoration(label: Text(field.name)),
                onChanged: (value) {
                  votesPerParticipantMap[votingSessionParticipant]!
                      .addAll({field: value});
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

