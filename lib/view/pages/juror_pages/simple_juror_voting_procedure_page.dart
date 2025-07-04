import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:swift_contest/model/data_models/voting_form_field.dart';
import 'package:swift_contest/model/data_models/voting_session_participation.dart';
import 'package:swift_contest/model/enums/voting_session_status.dart';
import 'package:swift_contest/utils/functions/pretty_double.dart';
import 'package:swift_contest/utils/labels/labels.dart';
import 'package:swift_contest/view/widgets/custom_app_bar.dart';
import 'package:swift_contest/view/widgets/custom_text_form_field.dart';
import 'package:swift_contest/view/widgets/custom_timer_countdown.dart';
import 'package:swift_contest/view/widgets/list_view_with_central_label.dart';
import 'package:swift_contest/view/widgets/list_view_with_central_widget.dart';
import 'package:swift_contest/view/widgets/overlay_loader.dart';
import 'package:swift_contest/view/widgets/show_snack_bar.dart';
import 'package:swift_contest/view/widgets/void_widget.dart';
import 'package:swift_contest/view/widgets/work_details_view.dart';
import 'package:swift_contest/viewmodel/blocs/auth_bloc/auth_bloc.dart';
import 'package:swift_contest/viewmodel/blocs/pages_blocs/simple_juror_voting_procedure_page_bloc/simple_juror_voting_procedure_page_bloc.dart';
import 'package:swift_contest/viewmodel/enums/bloc_status.dart';

@RoutePage()
class SimpleJurorVotingProcedurePage extends StatefulWidget {
  final String simpleJurorId;
  final String votingSessionId;

  const SimpleJurorVotingProcedurePage({
    @PathParam('simpleJurorId') required this.simpleJurorId,
    @PathParam('votingSessionId') required this.votingSessionId,
    super.key,
  });

  @override
  State<SimpleJurorVotingProcedurePage> createState() => _SimpleJurorVotingProcedurePageState();
}

class _SimpleJurorVotingProcedurePageState extends State<SimpleJurorVotingProcedurePage> {
  late String? profileId;
  late final String votingSessionId;
  late final String simpleJurorId;
  final reviewFormKey = GlobalKey<FormState>();
  Map<VotingSessionParticipation, Map<VotingFormField, double>> votesPerParticipantMap = {};

  @override
  void initState() {
    super.initState();
    votingSessionId = widget.votingSessionId;
    simpleJurorId = widget.simpleJurorId;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    profileId = context.read<AuthBloc>().state.profile?.id;
  }

  @override
  void dispose() {
    context.hideLoader();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<SimpleJurorVotingProcedurePageBloc>(
      create: (context) => SimpleJurorVotingProcedurePageBloc(
        genericRepository: context.read(),
        jurorRepository: context.read(),
      )..add(SimpleJurorVotingProcedurePageSubscribeToVotingSessionProcedure(
          votingSessionId: votingSessionId)),
      child: BlocConsumer<SimpleJurorVotingProcedurePageBloc, SimpleJurorVotingProcedurePageState>(
        listener: (context, state) {
          if (state.message != null) {
            showSnackBar(context: context, text: state.message!);
          }
          if (state.status.isLoading) {
            context.showLoader();
          } else {
            context.hideLoader();
          }
          if (state.status.isSuccess &&
              state.votingSessionProcedureBundle!.votingSessionBundle.votingSession.sessionStatus ==
                  VotingSessionStatus.ended) {
            showSnackBar(context: context, text: 'Voting session procedure is ended');
            context.router.pop(true);
          }
          if (state.status.isSuccess &&
              state.votingSessionProcedureBundle!.votingSessionBundle.votingSession.sessionStatus ==
                  VotingSessionStatus.cancelled) {
            showSnackBar(
                context: context,
                text: 'Voting session procedure has been cancelled by the organizer');
            context.router.pop(true);
          }
          if (state.status.isSuccess &&
              state.sourceEvent is SimpleJurorVotingProcedurePageSubmitVotes) {
            showSnackBar(context: context, text: 'Votes submitted successfully');
            context.router.pop(true);
          }
        },
        builder: (context, state) {
          return Scaffold(
            appBar: CustomAppBar(title: 'Voting'),
            body: SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Builder(
                  builder: (context) {
                    switch (state.status) {
                      case BlocStatus.initial:
                        return VoidWidget();
                      case BlocStatus.loading:
                        if (state.sourceEvent
                            is SimpleJurorVotingProcedurePageSubscribeToVotingSessionProcedure) {
                          return VoidWidget();
                        } else {
                          continue successCase;
                        }
                      case BlocStatus.failure:
                        if (state.sourceEvent
                            is SimpleJurorVotingProcedurePageSubscribeToVotingSessionProcedure) {
                          return RefreshIndicator.adaptive(
                            onRefresh: () async => context
                                .read<SimpleJurorVotingProcedurePageBloc>()
                                .add(
                                    SimpleJurorVotingProcedurePageSubscribeToVotingSessionProcedure(
                                        votingSessionId: votingSessionId)),
                            child: ListViewWithCentralLabel(label: Labels.anErrorOccurred),
                          );
                        } else {
                          continue successCase;
                        }
                      successCase:
                      case BlocStatus.success:
                        final votingSessionProcedureBundle = state.votingSessionProcedureBundle!;
                        final votingSessionBundle =
                            state.votingSessionProcedureBundle!.votingSessionBundle;
                        final votingSession = votingSessionBundle.votingSession;
                        final sessionStatus = votingSession.sessionStatus;
                        final votingFormFields =
                            state.votingSessionProcedureBundle!.votingFormBundle.votingFormFields;

                        return RefreshIndicator.adaptive(
                          onRefresh: () async => context
                              .read<SimpleJurorVotingProcedurePageBloc>()
                              .add(
                                  SimpleJurorVotingProcedurePageResubscribeToVotingSessionProcedure(
                                      votingSessionId: votingSessionId)),
                          child: Builder(
                            builder: (context) {
                              switch (sessionStatus) {
                                case VotingSessionStatus.initialized:
                                  return ListViewWithCentralLabel(
                                    label: 'Await here the beginning of the voting session',
                                  );
                                case VotingSessionStatus.work:
                                  final currentStepDeadline = votingSession.currentStepDeadline!;
                                  final currentParticipantIndex =
                                      votingSession.currentParticipantIndex!;
                                  final currentParticipant = votingSessionProcedureBundle
                                      .votingSessionParticipationsBundles[currentParticipantIndex]
                                      .participationBundle
                                      .participant;
                                  final currentWork = votingSessionProcedureBundle
                                      .votingSessionParticipationsBundles[currentParticipantIndex]
                                      .participationBundle
                                      .work!;
                                  final votingSessionParticipation = votingSessionProcedureBundle
                                      .votingSessionParticipationsBundles[currentParticipantIndex]
                                      .votingSessionParticipation;

                                  return ListView(
                                    children: [
                                      SizedBox(height: 16),
                                      CustomTimerCountdown(
                                        label: 'Voting phase',
                                        endTime: currentStepDeadline,
                                      ),
                                      Divider(height: 24),
                                      Column(
                                        mainAxisSize: MainAxisSize.min,
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'Form',
                                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                                color: Theme.of(context).colorScheme.primary),
                                          ),
                                          SizedBox(height: 12),
                                          for (var votingFormField in votingFormFields)
                                            Builder(
                                              builder: (context) {
                                                if (votesPerParticipantMap[
                                                        votingSessionParticipation] ==
                                                    null) {
                                                  votesPerParticipantMap
                                                      .addAll({votingSessionParticipation: {}});
                                                }
                                                return CustomTextFormField(
                                                  borderType: InputBorderType.outlined,
                                                  label: votingFormField.name,
                                                  suffixIcon: Row(
                                                    mainAxisSize: MainAxisSize.min,
                                                    children: [
                                                      SizedBox(width: 12),
                                                      Text(
                                                        '${prettyDouble(votingFormField.minValue)} - ${prettyDouble(votingFormField.maxValue)}',
                                                        // textAlign: TextAlign.center,
                                                        style:
                                                            Theme.of(context).textTheme.labelLarge,
                                                      ),
                                                      SizedBox(width: 12),
                                                    ],
                                                  ),
                                                  onChanged: (value) => votesPerParticipantMap[
                                                          votingSessionParticipation]!
                                                      .addAll(
                                                          {votingFormField: double.parse(value)}),
                                                  keyboardType: TextInputType.number,
                                                );
                                              },
                                            ),
                                        ],
                                      ),
                                      Divider(height: 32),
                                      WorkDetailsView(
                                          work: currentWork, participant: currentParticipant),
                                      SizedBox(height: 72),
                                    ],
                                  );
                                case VotingSessionStatus.intermission:
                                  final currentStepDeadline = votingSession.currentStepDeadline!;
                                  return ListViewWithCentralWidget(
                                    centralWidget: CustomTimerCountdown(
                                      label: 'Intermission',
                                      endTime: currentStepDeadline,
                                    ),
                                  );
                                case VotingSessionStatus.review:
                                  final currentStepDeadline = votingSession.currentStepDeadline!;
                                  final votingSessionParticipationsBundles = state
                                      .votingSessionProcedureBundle!
                                      .includedVotingSessionParticipationsBundles;

                                  return ListView(
                                    children: [
                                      CustomTimerCountdown(
                                        label: 'Review',
                                        endTime: currentStepDeadline,
                                      ),
                                      Divider(height: 24),
                                      Form(
                                        key: reviewFormKey,
                                        child: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            for (var votingSessionParticipationBundle
                                                in votingSessionParticipationsBundles) ...[
                                              Text(
                                                '${votingSessionParticipationBundle.participationBundle.work!.name} '
                                                '(${votingSessionParticipationBundle.participationBundle.participant.fullName})',
                                                style: Theme.of(context).textTheme.titleMedium,
                                              ),
                                              SizedBox(height: 12),

                                              // ---- INIZIO annidamento ----
                                              for (var votingFormField in votingFormFields) ...[
                                                Builder(builder: (context) {
                                                  return CustomTextFormField(
                                                    borderType: InputBorderType.outlined,
                                                    label: votingFormField.name,
                                                    suffixIcon: Row(
                                                      mainAxisSize: MainAxisSize.min,
                                                      children: [
                                                        SizedBox(width: 12),
                                                        Text(
                                                          '${prettyDouble(votingFormField.minValue)} - ${prettyDouble(votingFormField.maxValue)}',
                                                          // textAlign: TextAlign.center,
                                                          style: Theme.of(context)
                                                              .textTheme
                                                              .labelLarge,
                                                        ),
                                                        SizedBox(width: 12),
                                                      ],
                                                    ),
                                                    keyboardType: TextInputType.number,
                                                    validator: (value) {
                                                      if (value == null || value.trim().isEmpty) {
                                                        return 'Required';
                                                      }
                                                      if (double.tryParse(value) == null) {
                                                        return 'Must be a number';
                                                      }
                                                      final number = double.parse(value);
                                                      if (!(number >= votingFormField.minValue &&
                                                          number <= votingFormField.maxValue)) {
                                                        return 'The vote does not respect the boundaries';
                                                      }
                                                      return null;
                                                    },
                                                    initialValue: votesPerParticipantMap[
                                                                votingSessionParticipationBundle
                                                                    .votingSessionParticipation]
                                                            ?[votingFormField]
                                                        ?.toString(),
                                                    onChanged: (value) {
                                                      votesPerParticipantMap[
                                                              votingSessionParticipationBundle
                                                                  .votingSessionParticipation]![
                                                          votingFormField] = double.parse(value);
                                                    },
                                                  );
                                                }),
                                                SizedBox(height: 8),
                                              ],
                                              // ---- FINE annidamento ----
                                            ],
                                          ],
                                        ),
                                      ),
                                      SizedBox(height: 72),
                                    ],
                                  );
                                case VotingSessionStatus.cancelled:
                                case VotingSessionStatus.ended:
                                  return VoidWidget();
                              }
                            },
                          ),
                        );
                    }
                  },
                ),
              ),
            ),
            floatingActionButton: Builder(
              builder: (context) {
                switch (state.status) {
                  case BlocStatus.initial:
                    return VoidWidget();
                  case (BlocStatus.loading || BlocStatus.failure):
                    if (state.sourceEvent
                        is SimpleJurorVotingProcedurePageSubscribeToVotingSessionProcedure) {
                      return VoidWidget();
                    } else {
                      continue successCase;
                    }
                  successCase:
                  case BlocStatus.success:
                    final votingSessionBundle =
                        state.votingSessionProcedureBundle!.votingSessionBundle;
                    final votingSession = votingSessionBundle.votingSession;
                    if (!votingSession.sessionStatus.isReview) {
                      return VoidWidget();
                    }
                    return FilledButton(
                      onPressed: () {
                        if (reviewFormKey.currentState?.validate() ?? false) {
                          context
                              .read<SimpleJurorVotingProcedurePageBloc>()
                              .add(SimpleJurorVotingProcedurePageSubmitVotes(
                                simpleJurorId: simpleJurorId,
                                votingSession: votingSessionBundle.votingSession,
                                geoResPlace: state
                                    .votingSessionProcedureBundle!.votingSessionBundle.geoResPlace,
                                votesPerParticipantMap: votesPerParticipantMap,
                                jurorId: profileId,
                              ));
                        }
                      },
                      child: Text('Submit'),
                    );
                }
              },
            ),
          );
        },
      ),
    );
  }
}
