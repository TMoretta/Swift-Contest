import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_timer_countdown/flutter_timer_countdown.dart';
import 'package:go_router/go_router.dart';
import 'package:swift_contest/model/data_models/profile.dart';
import 'package:swift_contest/model/enums/voting_session_status.dart';
import 'package:swift_contest/utils/functions/show_snack_bar.dart';
import 'package:swift_contest/utils/themes/color_scheme_x.dart';
import 'package:swift_contest/view/widgets/custom_app_bar.dart';
import 'package:swift_contest/view/widgets/loader.dart';
import 'package:swift_contest/viewmodel/blocs/auth_bloc/auth_bloc.dart';
import 'package:swift_contest/viewmodel/blocs/pages_blocs/organizer_voting_procedure_page_bloc/organizer_voting_procedure_page_bloc.dart';
import 'package:swift_contest/viewmodel/enums/bloc_status.dart';

class OrganizerVotingProcedurePage extends StatefulWidget {
  final String votingSessionId;

  const OrganizerVotingProcedurePage({required this.votingSessionId, super.key});

  @override
  State<OrganizerVotingProcedurePage> createState() => _OrganizerVotingProcedurePageState();
}

class _OrganizerVotingProcedurePageState extends State<OrganizerVotingProcedurePage> {
  late Profile profile;
  late String votingSessionId;

  @override
  void initState() {
    super.initState();
    profile = context.read<AuthBloc>().state.profile!;
    votingSessionId = widget.votingSessionId;
    context.read<OrganizerVotingProcedurePageBloc>().add(
        OrganizerVotingProcedurePageSubscribeToVotingSessionProcedure(
            votingSessionId: votingSessionId));
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<OrganizerVotingProcedurePageBloc, OrganizerVotingProcedurePageState>(
      listener: (context, state) {
        if (state.message != null) {
          showSnackBar(context: context, text: state.message!);
        }
        if (state.status.isSuccess &&
            state.votingSessionProcedureBundle!.votingSessionBundle.votingSession.sessionStatus == VotingSessionStatus.ended) {
          showSnackBar(context: context, text: 'Voting session ended successfully');
          context.pop(true);
        }
        if (state.status.isSuccess &&
            state.votingSessionProcedureBundle!.votingSessionBundle.votingSession.sessionStatus ==
                VotingSessionStatus.cancelled) {
          showSnackBar(context: context, text: 'Voting session cancelled successfully');
          context.pop(true);
        }
      },
      child: Scaffold(
        appBar: CustomAppBar(title: 'Voting'),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: BlocBuilder<OrganizerVotingProcedurePageBloc, OrganizerVotingProcedurePageState>(
              builder: (context, state) {
                switch (state.status) {
                  case BlocStatus.initial:
                    return SizedBox.shrink();
                  case BlocStatus.loading:
                    return Loader();
                  case BlocStatus.failure:
                    if (state.sourceEvent
                        is OrganizerVotingProcedurePageSubscribeToVotingSessionProcedure) {
                      return RefreshIndicator.adaptive(
                        onRefresh: () async => context.read<OrganizerVotingProcedurePageBloc>().add(
                            OrganizerVotingProcedurePageSubscribeToVotingSessionProcedure(
                                votingSessionId: votingSessionId)),
                        child: ListView(),
                      );
                    } else {
                      continue successCase;
                    }
                  successCase:
                  case BlocStatus.success:
                    final votingSessionProcedureBundle = state.votingSessionProcedureBundle!;
                    final votingSessionBundle = votingSessionProcedureBundle.votingSessionBundle;
                    final sessionStatus = votingSessionBundle.votingSession.sessionStatus;

                    switch (sessionStatus) {
                      case VotingSessionStatus.initialized:
                        return Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                'Simple juror access token:\n${votingSessionProcedureBundle.votingSessionBundle.votingSession.token}',
                                textAlign: TextAlign.center,
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                              SizedBox(height: 16),
                              FilledButton(
                                onPressed: () {
                                  context.read<OrganizerVotingProcedurePageBloc>().add(
                                      OrganizerVotingProcedurePageStartVotingSessionProcedure(
                                          votingSessionId: votingSessionProcedureBundle.votingSessionBundle.votingSession.id));
                                },
                                child: Text('Start'),
                              ),
                            ],
                          ),
                        );
                      case VotingSessionStatus.work:
                        final currentStepDeadline = votingSessionBundle.votingSession.currentStepDeadline!;
                        final currentParticipantIndex = votingSessionBundle.votingSession.currentParticipantIndex!;
                        final currentParticipant = votingSessionProcedureBundle
                            .includedVotingSessionParticipationsBundles[currentParticipantIndex]
                            .participationBundle
                            .participant;
                        final currentWork = votingSessionProcedureBundle
                            .includedVotingSessionParticipationsBundles[currentParticipantIndex]
                            .participationBundle
                            .work!;
                        return ListView(
                          key: UniqueKey(),
                          children: [
                            SizedBox(height: 16),
                            Align(
                              alignment: Alignment.center,
                              child: Text(
                                'Simple juror access token:\n${votingSessionProcedureBundle.votingSessionBundle.votingSession.token}',
                                textAlign: TextAlign.center,
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                            ),
                            SizedBox(height: 16),
                            Align(
                              alignment: Alignment.center,
                              child: Card(
                                elevation: 1,
                                child: Padding(
                                  padding: EdgeInsets.all(20),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        'Jurors are voting',
                                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                            color: Theme.of(context).colorScheme.primary),
                                      ),
                                      SizedBox(height: 8),
                                      TimerCountdown(
                                        endTime: currentStepDeadline,
                                        format: CountDownTimerFormat.minutesSeconds,
                                        timeTextStyle: Theme.of(context)
                                            .textTheme
                                            .titleLarge
                                            ?.copyWith(
                                                color: Theme.of(context).colorScheme.primary),
                                        enableDescriptions: false,
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
                              style: Theme.of(context).textTheme.titleLarge,
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
                        final currentStepDeadline = votingSessionBundle.votingSession.currentStepDeadline!;
                        return Center(
                          child: Column(
                            key: UniqueKey(),
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                'Simple juror access token:\n${votingSessionProcedureBundle.votingSessionBundle.votingSession.token}',
                                style: Theme.of(context).textTheme.titleMedium,
                                textAlign: TextAlign.center,
                              ),
                              SizedBox(height: 12),
                              Card(
                                elevation: 1,
                                child: Padding(
                                  padding: EdgeInsets.all(20),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        'Intermission',
                                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                            color: Theme.of(context).colorScheme.primary),
                                      ),
                                      SizedBox(height: 8),
                                      TimerCountdown(
                                        endTime: currentStepDeadline,
                                        format: CountDownTimerFormat.minutesSeconds,
                                        timeTextStyle: Theme.of(context)
                                            .textTheme
                                            .titleLarge
                                            ?.copyWith(
                                                color: Theme.of(context).colorScheme.primary),
                                        enableDescriptions: false,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      case VotingSessionStatus.review:
                        final currentStepDeadline = votingSessionBundle.votingSession.currentStepDeadline!;
                        return Center(
                          child: Column(
                            key: UniqueKey(),
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                'Simple juror access token:\n${votingSessionProcedureBundle.votingSessionBundle.votingSession.token}',
                                style: Theme.of(context).textTheme.titleMedium,
                                textAlign: TextAlign.center,
                              ),
                              SizedBox(height: 12),
                              Card(
                                elevation: 1,
                                child: Padding(
                                  padding: EdgeInsets.all(20),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        'Jurors are reviewing',
                                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                            color: Theme.of(context).colorScheme.primary),
                                      ),
                                      SizedBox(height: 8),
                                      TimerCountdown(
                                        endTime: currentStepDeadline,
                                        format: CountDownTimerFormat.minutesSeconds,
                                        timeTextStyle: Theme.of(context)
                                            .textTheme
                                            .titleLarge
                                            ?.copyWith(
                                                color: Theme.of(context).colorScheme.primary),
                                        enableDescriptions: false,
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
        ),
        floatingActionButton:
            BlocBuilder<OrganizerVotingProcedurePageBloc, OrganizerVotingProcedurePageState>(
          builder: (context, state) {
            switch (state.status) {
              case BlocStatus.initial:
              case BlocStatus.loading:
                return const SizedBox.shrink();
              case BlocStatus.failure:
                if (state.sourceEvent
                    is OrganizerVotingProcedurePageSubscribeToVotingSessionProcedure) {
                  return SizedBox.shrink();
                } else {
                  continue successCase;
                }
              successCase:
              case BlocStatus.success:
                final votingSessionBundle = state.votingSessionProcedureBundle!.votingSessionBundle;
                return Column(
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
                        backgroundColor: WidgetStateProperty.all<Color>(
                            Theme.of(context).colorScheme.error),
                      ),
                      child: Text(
                        'Cancel procedure',
                        textAlign: TextAlign.center,
                        style: Theme.of(context)
                            .textTheme
                            .bodyMedium
                            ?.copyWith(color: Theme.of(context).colorScheme.onError),
                      ),
                    ),
                    if (votingSessionBundle.votingSession.sessionStatus.isReview) const SizedBox(width: 8),
                    if (votingSessionBundle.votingSession.sessionStatus.isReview)
                      FilledButton(
                        onPressed: () {
                          context.read<OrganizerVotingProcedurePageBloc>().add(
                                OrganizerVotingProcedurePageEndVotingSessionProcedure(
                                  votingSessionId: votingSessionBundle.votingSession.id,
                                ),
                              );
                        },
                        style: ButtonStyle(
                          backgroundColor: WidgetStateProperty.all<Color>(Theme.of(context).colorScheme.green),
                        ),
                        child: Text(
                          'End procedure',
                          textAlign: TextAlign.center,
                          style: Theme.of(context)
                              .textTheme
                              .bodyMedium
                              ?.copyWith(color: Theme.of(context).colorScheme.onGreen),
                        ),
                      ),
                  ],
                );
            }
          },
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      ),
    );
  }
}
