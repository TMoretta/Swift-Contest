import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:swift_contest/model/data_models/voting_form_field.dart';
import 'package:swift_contest/model/data_models/voting_session_participation.dart';
import 'package:swift_contest/model/enums/voting_session_status.dart';
import 'package:swift_contest/utils/labels/labels.dart';
import 'package:swift_contest/view/widgets/custom_app_bar.dart';
import 'package:swift_contest/view/widgets/custom_text_form_field.dart';
import 'package:swift_contest/view/widgets/custom_timer_countdown.dart';
import 'package:swift_contest/view/widgets/list_view_with_central_label.dart';
import 'package:swift_contest/view/widgets/list_view_with_central_widget.dart';
import 'package:swift_contest/view/widgets/obscured_loader.dart';
import 'package:swift_contest/view/widgets/overlay_loader.dart';
import 'package:swift_contest/view/widgets/show_snack_bar.dart';
import 'package:swift_contest/view/widgets/work_details_view.dart';
import 'package:swift_contest/viewmodel/blocs/auth_bloc/auth_bloc.dart';
import 'package:swift_contest/viewmodel/blocs/pages_blocs/juror_voting_procedure_page_bloc/juror_voting_procedure_page_bloc.dart';
import 'package:swift_contest/viewmodel/enums/bloc_status.dart';
import 'package:swift_contest/view/widgets/void_widget.dart';

class JurorVotingProcedurePage extends StatefulWidget {
  final String votingSessionId;

  const JurorVotingProcedurePage({required this.votingSessionId, super.key});

  @override
  State<JurorVotingProcedurePage> createState() => _JurorVotingProcedurePageState();
}

class _JurorVotingProcedurePageState extends State<JurorVotingProcedurePage> {
  
  late String profileId;
  late final String votingSessionId;
  final reviewFormKey = GlobalKey<FormState>();
  Map<VotingSessionParticipation, Map<VotingFormField, double>> votesPerParticipantMap = {};

  @override
  void initState() {
    super.initState();
    votingSessionId = widget.votingSessionId;
    context.read<JurorVotingProcedurePageBloc>().add(
        JurorVotingProcedurePageSubscribeToVotingSessionProcedure(
            votingSessionId: votingSessionId));
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    profileId = context.read<AuthBloc>().state.profile!.id;
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<JurorVotingProcedurePageBloc, JurorVotingProcedurePageState>(
      listener: (context, state) {
        if (state.message != null) {
          showSnackBar(context: context, text: state.message!);
        }
        if(state.status.isLoading) {
          context.showLoader();
        } else {
          context.hideLoader();
        }
        if (state.status.isSuccess &&
            state.votingSessionProcedureBundle!.votingSessionBundle.votingSession.sessionStatus ==
                VotingSessionStatus.ended) {
          showSnackBar(context: context, text: 'Voting session procedure is ended');
          context.pop(true);
        }
        if (state.status.isSuccess &&
            state.votingSessionProcedureBundle!.votingSessionBundle.votingSession.sessionStatus ==
                VotingSessionStatus.cancelled) {
          showSnackBar(
              context: context,
              text: 'Voting session procedure has been cancelled by the organizer');
          context.pop(true);
        }
        if (state.status.isSuccess && state.sourceEvent is JurorVotingProcedurePageSubmitVotes) {
          showSnackBar(context: context, text: 'Votes submitted successfully');
          context.pop(true);
        }
      },
      child: Scaffold(
        appBar: CustomAppBar(title: 'Voting'),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: BlocBuilder<JurorVotingProcedurePageBloc, JurorVotingProcedurePageState>(
              builder: (context, state) {
                switch (state.status) {
                  case BlocStatus.initial:
                    return VoidWidget();
                  case BlocStatus.loading:
                    if (state.sourceEvent
                        is JurorVotingProcedurePageSubscribeToVotingSessionProcedure) {
                      return VoidWidget();
                    } else {
                      continue successCase;
                    }
                  case BlocStatus.failure:
                    if (state.sourceEvent
                        is JurorVotingProcedurePageSubscribeToVotingSessionProcedure) {
                      return RefreshIndicator.adaptive(
                        onRefresh: () async => context.read<JurorVotingProcedurePageBloc>().add(
                            JurorVotingProcedurePageSubscribeToVotingSessionProcedure(
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
                        votingSessionProcedureBundle.votingSessionBundle;
                    final votingSession = votingSessionBundle.votingSession;
                    final sessionStatus = votingSessionBundle.votingSession.sessionStatus;
                    final votingFormFields =
                        votingSessionProcedureBundle.votingFormBundle.votingFormFields;

                    final thisVotingSessionJuration = votingSessionProcedureBundle
                        .includedVotingSessionJurationsBundles
                        .where((e) => e.jurationBundle.juror.id == profileId)
                        .first
                        .votingSessionJuration;

                    return RefreshIndicator.adaptive(
                      onRefresh: () async => context.read<JurorVotingProcedurePageBloc>().add(
                          JurorVotingProcedurePageResubscribeToVotingSessionProcedure(
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

                              final isExcludedFromParticipant = (votingSessionProcedureBundle
                                          .votingSessionExclusions
                                          .where((e) =>
                                              e.votingSessionJurationId ==
                                                  thisVotingSessionJuration.id &&
                                              e.votingSessionParticipationId ==
                                                  votingSessionParticipation.id)
                                          .firstOrNull !=
                                      null)
                                  ? true
                                  : false;

                              if (isExcludedFromParticipant) {
                                votesPerParticipantMap.addAll({votingSessionParticipation: {}});
                                return ListView(
                                  children: [
                                    SizedBox(height: 16),
                                    CustomTimerCountdown(
                                      label: 'Jurors are voting',
                                      endTime: currentStepDeadline,
                                    ),
                                    Divider(height: 24),
                                    Text(
                                        'The organizer excluded you from voting to this participant')
                                  ],
                                );
                              }

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
                              final participantsExcludedFrom = votingSessionProcedureBundle
                                  .votingSessionExclusions
                                  .where((e) =>
                                      e.votingSessionJurationId == thisVotingSessionJuration.id)
                                  .map((e) => e.votingSessionParticipationId)
                                  .toList(growable: false);
                              final excludedSet = participantsExcludedFrom.toSet();

                              final votingSessionParticipationsBundles = state
                                  .votingSessionProcedureBundle!
                                  .includedVotingSessionParticipationsBundles
                                  .where((bundle) => !excludedSet
                                      .contains(bundle.votingSessionParticipation.id))
                                  .toList();

                              return ListView(
                                children: [
                                  CustomTimerCountdown(
                                    label: 'Reviewing',
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
                                                keyboardType: TextInputType.number,
                                                validator: (value) {
                                                  if (value == null || value.trim().isEmpty) {
                                                    return 'Required';
                                                  }
                                                  if (double.tryParse(value) == null) {
                                                    return 'Must be a number';
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
                            case VotingSessionStatus.ended:
                            case VotingSessionStatus.cancelled:
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
        floatingActionButton:
            BlocBuilder<JurorVotingProcedurePageBloc, JurorVotingProcedurePageState>(
          builder: (context, state) {
            switch (state.status) {
              case BlocStatus.initial:
                return VoidWidget();
              case (BlocStatus.loading || BlocStatus.failure):
                if (state.sourceEvent
                    is JurorVotingProcedurePageSubscribeToVotingSessionProcedure) {
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
                          .read<JurorVotingProcedurePageBloc>()
                          .add(JurorVotingProcedurePageSubmitVotes(
                            jurorId: profileId,
                            votingSession: votingSession,
                            geoResPlace: votingSessionBundle.geoResPlace,
                            votesPerParticipantMap: votesPerParticipantMap,
                          ));
                    }
                  },
                  child: Text('Submit'),
                );
            }
          },
        ),
      ),
    );
  }
}
