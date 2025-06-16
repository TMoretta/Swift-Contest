import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_timer_countdown/flutter_timer_countdown.dart';
import 'package:go_router/go_router.dart';
import 'package:swift_contest/model/bundles/organizer_voting_session_bundle.dart';
import 'package:swift_contest/model/data_models/user.dart';
import 'package:swift_contest/model/enums/voting_session_status.dart';
import 'package:swift_contest/utils/functions/show_snack_bar.dart';
import 'package:swift_contest/view/widgets/custom_app_bar.dart';
import 'package:swift_contest/view/widgets/loader.dart';
import 'package:swift_contest/viewmodel/blocs/auth_bloc/auth_bloc.dart';
import 'package:swift_contest/viewmodel/blocs/pages_blocs/organizer_voting_procedure_page_bloc/organizer_voting_procedure_page_bloc.dart';
import 'package:swift_contest/viewmodel/enums/bloc_status.dart';

class OrganizerVotingProcedurePage extends StatefulWidget {
  final OrganizerVotingSessionBundle votingSessionBundle;

  const OrganizerVotingProcedurePage({required this.votingSessionBundle, super.key});

  @override
  State<OrganizerVotingProcedurePage> createState() => _OrganizerVotingProcedurePageState();
}

class _OrganizerVotingProcedurePageState extends State<OrganizerVotingProcedurePage> {
  late User user;
  late OrganizerVotingSessionBundle votingSessionBundle;

  @override
  void initState() {
    super.initState();
    user = context.read<AuthBloc>().state.authBundle!.user;
    votingSessionBundle = widget.votingSessionBundle;
    context.read<OrganizerVotingProcedurePageBloc>().add(
        OrganizerVotingProcedurePageSubscribeToVotingSessionProcedure(
            votingSessionBundle: votingSessionBundle));
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<OrganizerVotingProcedurePageBloc, OrganizerVotingProcedurePageState>(
      listener: (context, state) {
        if (state.message != null) {
          showSnackBar(context: context, text: state.message!);
        }
        if (state.status.isSuccess &&
            state.votingSessionBundle!.votingSession.sessionStatus == VotingSessionStatus.ended) {
          showSnackBar(context: context, text: 'Voting session ended successfully');
          context.pop(true);
        }
        if (state.status.isSuccess &&
            state.votingSessionBundle!.votingSession.sessionStatus ==
                VotingSessionStatus.cancelled) {
          showSnackBar(context: context, text: 'Voting session cancelled successfully');
          context.pop();
        }
      },
      child: Scaffold(
        appBar: CustomAppBar(title: 'Voting'),
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: BlocBuilder<OrganizerVotingProcedurePageBloc, OrganizerVotingProcedurePageState>(
            builder: (context, state) {
              switch (state.status) {
                case BlocStatus.initial:
                  return SizedBox.shrink();
                case BlocStatus.loading:
                  return Loader();
                case BlocStatus.failure:
                  return FilledButton(
                    onPressed: () {
                      context.read<OrganizerVotingProcedurePageBloc>().add(
                          OrganizerVotingProcedurePageSubscribeToVotingSessionProcedure(
                              votingSessionBundle: votingSessionBundle));
                    },
                    child: Text('Reconnect'),
                  );
                case BlocStatus.success:
                  final votingSessionBundle = state.votingSessionBundle!;
                  final votingSession = votingSessionBundle.votingSession;
                  final sessionStatus = votingSession.sessionStatus;

                  switch (sessionStatus) {
                    case VotingSessionStatus.initialized:
                      return Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'Simple juror access token: ${votingSessionBundle.votingSession.token}',
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                              textAlign: TextAlign.center,
                            ),
                            SizedBox(height: 16),
                            FilledButton(
                              onPressed: () {
                                context.read<OrganizerVotingProcedurePageBloc>().add(
                                    OrganizerVotingProcedurePageStartVotingSessionProcedure(
                                        votingSessionId: votingSessionBundle.votingSession.id));
                              },
                              child: Text('Start'),
                            ),
                          ],
                        ),
                      );
                    case VotingSessionStatus.work:
                      final currentStepDeadline = votingSession.currentStepDeadline!;
                      final currentParticipantIndex = votingSession.currentParticipantIndex!;
                      final currentParticipant = votingSessionBundle
                          .votingSessionParticipationsBundles[currentParticipantIndex]
                          .participationBundle
                          .participant;
                      final currentWork = votingSessionBundle
                          .votingSessionParticipationsBundles[currentParticipantIndex]
                          .participationBundle
                          .work!;
                      return ListView(
                        key: UniqueKey(),
                        children: [
                          Align(
                            alignment: Alignment.center,
                            child: Text(
                              'Simple juror access token: ${votingSessionBundle.votingSession.token}',
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                              textAlign: TextAlign.center,
                            ),
                          ),
                          SizedBox(height: 16),
                          Align(
                            alignment: Alignment.center,
                            child: Card(
                              elevation: 1,
                              child: Padding(
                                padding: EdgeInsets.all(12),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      'Jurors are voting',
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    TimerCountdown(
                                      endTime: currentStepDeadline,
                                      format: CountDownTimerFormat.minutesSeconds,
                                      timeTextStyle:
                                          TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          SizedBox(height: 8),
                          //* Title
                          Text(
                            currentWork.name,
                            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
                          ),
                          SizedBox(height: 8),
                          //* Images carousel
                          SizedBox(
                            height: 180,
                            child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              itemCount: currentWork.imagesUrls.length,
                              itemBuilder: (context, index) {
                                return Padding(
                                  padding: const EdgeInsets.only(right: 8),
                                  child: (currentWork.imagesUrls.isNotEmpty)
                                      ? Image.network(
                                          currentWork.imagesUrls[index],
                                          fit: BoxFit.contain,
                                          errorBuilder: (context, error, stackTrace) {
                                            return Image.asset(
                                              'assets/images/image_not_found.jpg',
                                              fit: BoxFit.cover,
                                            );
                                          },
                                          frameBuilder:
                                              (context, child, frame, wasSynchronouslyLoaded) {
                                            if (wasSynchronouslyLoaded || frame != null) {
                                              return child;
                                            }
                                            return const Loader();
                                          },
                                        )
                                      : Image.asset('assets/images/image_not_found.jpg',
                                          fit: BoxFit.cover),
                                );
                              },
                            ),
                          ),
                          SizedBox(height: 8),
                          //* Description
                          Column(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Description',
                                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                              ),
                              Text(currentWork.description, style: TextStyle(fontSize: 18)),
                            ],
                          ),
                          SizedBox(height: 8),
                          //* Participant name
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            spacing: 4,
                            children: [
                              Icon(
                                Icons.person_rounded,
                                size: 24,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                              Expanded(
                                child: Text(
                                  currentParticipant.fullName,
                                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                                ),
                              ),
                            ],
                          ),
                        ],
                      );
                    case VotingSessionStatus.intermission:
                      final currentStepDeadline = votingSession.currentStepDeadline!;
                      return Center(
                        child: Column(
                          key: UniqueKey(),
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'Simple juror access token: ${votingSessionBundle.votingSession.token}',
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                              textAlign: TextAlign.center,
                            ),
                            Card(
                              elevation: 1,
                              child: Padding(
                                padding: EdgeInsets.all(12),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      'Intermission',
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    TimerCountdown(
                                      endTime: currentStepDeadline,
                                      format: CountDownTimerFormat.minutesSeconds,
                                      timeTextStyle:
                                          TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    case VotingSessionStatus.review:
                      final currentStepDeadline = votingSession.currentStepDeadline!;
                      return Center(
                        child: Column(
                          key: UniqueKey(),
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'Simple juror access token: ${votingSessionBundle.votingSession.token}',
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                              textAlign: TextAlign.center,
                            ),
                            Card(
                              elevation: 1,
                              child: Padding(
                                padding: EdgeInsets.all(12),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      'Jurors are reviewing',
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    TimerCountdown(
                                      endTime: currentStepDeadline,
                                      format: CountDownTimerFormat.minutesSeconds,
                                      timeTextStyle:
                                          TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    case VotingSessionStatus.ended:
                    case VotingSessionStatus.cancelled:
                      return SizedBox.shrink();
                  }
              }
            },
          ),
        ),
        floatingActionButton:
            BlocBuilder<OrganizerVotingProcedurePageBloc, OrganizerVotingProcedurePageState>(
          builder: (context, state) {
            switch (state.status) {
              case BlocStatus.initial:
              case BlocStatus.loading:
                return const SizedBox.shrink();
              case BlocStatus.failure:
              case BlocStatus.success:
                final votingSessionBundle = state.votingSessionBundle!;
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      FilledButton(
                        onPressed: () {
                          context.read<OrganizerVotingProcedurePageBloc>().add(
                                OrganizerVotingProcedurePageCancelVotingSessionProcedure(
                                  votingSessionId: votingSessionBundle.votingSession.id,
                                ),
                              );
                        },
                        style: ButtonStyle(
                          backgroundColor: WidgetStateProperty.all<Color>(Colors.red),
                        ),
                        child: const Text(
                          'Cancel procedure',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                      const SizedBox(width: 4),
                      FilledButton(
                        onPressed: () {
                          context.read<OrganizerVotingProcedurePageBloc>().add(
                                OrganizerVotingProcedurePageEndVotingSessionProcedure(
                                  votingSessionId: votingSessionBundle.votingSession.id,
                                ),
                              );
                        },
                        style: ButtonStyle(
                          backgroundColor: WidgetStateProperty.all<Color>(Colors.green),
                        ),
                        child: const Text(
                          'End procedure',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                );
            }
          },
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      ),
    );
  }
}
