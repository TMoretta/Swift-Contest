import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:swift_contest/model/data_models/profile.dart';
import 'package:swift_contest/model/data_models/voting_form_field.dart';
import 'package:swift_contest/model/data_models/voting_session_participation.dart';
import 'package:swift_contest/model/enums/voting_session_status.dart';
import 'package:swift_contest/view/widgets/custom_app_bar.dart';
import 'package:swift_contest/view/widgets/custom_text_form_field.dart';
import 'package:swift_contest/view/widgets/custom_timer_countdown.dart';
import 'package:swift_contest/view/widgets/loader.dart';
import 'package:swift_contest/view/widgets/show_snack_bar.dart';
import 'package:swift_contest/viewmodel/blocs/auth_bloc/auth_bloc.dart';
import 'package:swift_contest/viewmodel/blocs/pages_blocs/simple_juror_voting_procedure_page_bloc/simple_juror_voting_procedure_page_bloc.dart';
import 'package:swift_contest/viewmodel/enums/bloc_status.dart';

class SimpleJurorVotingProcedurePage extends StatefulWidget {
  final String simpleJurorId;
  final String votingSessionId;

  const SimpleJurorVotingProcedurePage({
    required this.simpleJurorId,
    required this.votingSessionId,
    super.key,
  });

  @override
  State<SimpleJurorVotingProcedurePage> createState() => _SimpleJurorVotingProcedurePageState();
}

class _SimpleJurorVotingProcedurePageState extends State<SimpleJurorVotingProcedurePage> {
  late Profile? profile;
  late String votingSessionId;
  late String simpleJurorId;
  Map<VotingSessionParticipation, Map<VotingFormField, double>> votesPerParticipantMap = {};
  final reviewFormKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    votingSessionId = widget.votingSessionId;
    simpleJurorId = widget.simpleJurorId;
    profile = context.read<AuthBloc>().state.profile;
    context.read<SimpleJurorVotingProcedurePageBloc>().add(
        SimpleJurorVotingProcedurePageSubscribeToVotingSessionProcedure(
            votingSessionId: votingSessionId));
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<SimpleJurorVotingProcedurePageBloc, SimpleJurorVotingProcedurePageState>(
      listener: (context, state) {
        if (state.message != null) {
          showSnackBar(context: context, text: state.message!);
        }
        if (state.status.isSuccess &&
            state.votingSessionProcedureBundle!.votingSessionBundle.votingSession.sessionStatus ==
                VotingSessionStatus.ended) {
          showSnackBar(context: context, text: 'Voting session procedure is ended');
          context.pop();
        }
        if (state.status.isSuccess &&
            state.votingSessionProcedureBundle!.votingSessionBundle.votingSession.sessionStatus ==
                VotingSessionStatus.cancelled) {
          showSnackBar(
              context: context,
              text: 'Voting session procedure has been cancelled by the organizer');
          context.pop();
        }
        if (state.status.isSuccess &&
            state.sourceEvent is SimpleJurorVotingProcedurePageSubmitVotes) {
          showSnackBar(context: context, text: 'Votes submitted successfully');
          context.pop();
        }
      },
      child: Scaffold(
        appBar: CustomAppBar(title: 'Voting'),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: BlocBuilder<SimpleJurorVotingProcedurePageBloc,
                SimpleJurorVotingProcedurePageState>(
              builder: (context, state) {
                switch (state.status) {
                  case BlocStatus.initial:
                    return SizedBox.shrink();
                  case BlocStatus.loading:
                    if (state.sourceEvent is SimpleJurorVotingProcedurePageSubmitVotes) {
                      continue successCase;
                    }
                    return Loader();
                  case BlocStatus.failure:
                    if (state.sourceEvent
                        is SimpleJurorVotingProcedurePageSubscribeToVotingSessionProcedure) {
                      return RefreshIndicator.adaptive(
                        onRefresh: () async => context
                            .read<SimpleJurorVotingProcedurePageBloc>()
                            .add(SimpleJurorVotingProcedurePageSubscribeToVotingSessionProcedure(
                                votingSessionId: votingSessionId)),
                        child: ListView(),
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

                    return LayoutBuilder(
                      builder: (context, constraints) {
                        return RefreshIndicator.adaptive(
                          onRefresh: () async => context
                              .read<SimpleJurorVotingProcedurePageBloc>()
                              .add(
                                  SimpleJurorVotingProcedurePageResubscribeToVotingSessionProcedure(
                                      votingSessionId: votingSessionId)),
                          child: SingleChildScrollView(
                            child: Builder(
                              builder: (context) {
                                switch (sessionStatus) {
                                  case VotingSessionStatus.initialized:
                                    return SizedBox(
                                      height: constraints.maxHeight,
                                      child: Center(
                                        child: Text(
                                          'Await here the beginning of the voting session',
                                          style: Theme.of(context).textTheme.bodyLarge,
                                        ),
                                      ),
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

                                    return Column(
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
                                                            errorBuilder:
                                                                (context, error, stackTrace) {
                                                              return Image.asset(
                                                                'assets/images/image_not_found.jpg',
                                                                fit: BoxFit.cover,
                                                              );
                                                            },
                                                            frameBuilder: (context, child, frame,
                                                                wasSynchronouslyLoaded) {
                                                              if (wasSynchronouslyLoaded ||
                                                                  frame != null) {
                                                                return child;
                                                              }
                                                              return const Loader();
                                                            },
                                                          )
                                                        : Image.asset(
                                                            'assets/images/image_not_found.jpg',
                                                            fit: BoxFit.cover),
                                                  );
                                                },
                                              ),
                                            ),
                                            SizedBox(height: 8),
                                            //* Description
                                            Text(
                                              'Description',
                                              style: TextStyle(
                                                  fontSize: 18, fontWeight: FontWeight.w500),
                                            ),
                                            Text(currentWork.description,
                                                style: TextStyle(fontSize: 18)),

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
                                                    style: TextStyle(
                                                        fontSize: 18, fontWeight: FontWeight.w500),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                        Divider(height: 32),
                                        Column(
                                          mainAxisSize: MainAxisSize.min,
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              'Form',
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .titleLarge
                                                  ?.copyWith(
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
                                                  return CustomTextFormFieldOutlined(
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
                                      ],
                                    );
                                  case VotingSessionStatus.intermission:
                                    final currentStepDeadline = votingSession.currentStepDeadline!;
                                    return SizedBox(
                                      height: constraints.maxHeight,
                                      child: Center(
                                        child: CustomTimerCountdown(
                                          label: 'Intermission',
                                          endTime: currentStepDeadline,
                                        ),
                                      ),
                                    );
                                  case VotingSessionStatus.review:
                                    final currentStepDeadline = votingSession.currentStepDeadline!;
                                    final votingSessionParticipationsBundles = state
                                        .votingSessionProcedureBundle!
                                        .includedVotingSessionParticipationsBundles;

                                    return Column(
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
                                                    return CustomTextFormFieldOutlined(
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
                                              SizedBox(height: 72),
                                            ],
                                          ),
                                        )
                                      ],
                                    );
                                  case VotingSessionStatus.cancelled:
                                  case VotingSessionStatus.ended:
                                    return SizedBox.shrink();
                                }
                              },
                            ),
                          ),
                        );
                      },
                    );
                }
              },
            ),
          ),
        ),
        floatingActionButton:
            BlocBuilder<SimpleJurorVotingProcedurePageBloc, SimpleJurorVotingProcedurePageState>(
          builder: (context, state) {
            if (state.votingSessionProcedureBundle == null) {
              return SizedBox.shrink();
            }
            final votingSessionBundle = state.votingSessionProcedureBundle!.votingSessionBundle;
            if (!votingSessionBundle.votingSession.sessionStatus.isReview) {
              return SizedBox.shrink();
            }
            return FilledButton(
              onPressed: (!state.status.isLoading)
                  ? () {
                      if (reviewFormKey.currentState?.validate() ?? false) {
                        context
                            .read<SimpleJurorVotingProcedurePageBloc>()
                            .add(SimpleJurorVotingProcedurePageSubmitVotes(
                              simpleJurorId: simpleJurorId,
                              votingSession: votingSessionBundle.votingSession,
                              geoResPlace: state
                                  .votingSessionProcedureBundle!.votingSessionBundle.geoResPlace,
                              votesPerParticipantMap: votesPerParticipantMap,
                              jurorId: profile?.id,
                            ));
                      }
                    }
                  : null,
              child: (!state.status.isLoading)
                  ? Text('Submit')
                  : SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
            );
          },
        ),
      ),
    );
  }
}
