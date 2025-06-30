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
import 'package:swift_contest/viewmodel/blocs/pages_blocs/juror_voting_procedure_page_bloc/juror_voting_procedure_page_bloc.dart';
import 'package:swift_contest/viewmodel/enums/bloc_status.dart';

class JurorVotingProcedurePage extends StatefulWidget {
  final String votingSessionId;

  const JurorVotingProcedurePage({required this.votingSessionId, super.key});

  @override
  State<JurorVotingProcedurePage> createState() => _JurorVotingProcedurePageState();
}

class _JurorVotingProcedurePageState extends State<JurorVotingProcedurePage> {
  late Profile profile;
  late String votingSessionId;
  Map<VotingSessionParticipation, Map<VotingFormField, double>> votesPerParticipantMap = {};
  final _reviewFormKey = GlobalKey<FormState>();

  // final List<TextEditingController> fieldsControllers = [];
  // bool areFieldsControllersInitialized = false;

  @override
  void initState() {
    super.initState();
    profile = context.read<AuthBloc>().state.profile!;
    votingSessionId = widget.votingSessionId;
    context.read<JurorVotingProcedurePageBloc>().add(
        JurorVotingProcedurePageSubscribeToVotingSessionProcedure(
            jurorId: profile.id, votingSessionId: votingSessionId));
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<JurorVotingProcedurePageBloc, JurorVotingProcedurePageState>(
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
        if (state.status.isSuccess && state.sourceEvent is JurorVotingProcedurePageSubmitVotes) {
          showSnackBar(context: context, text: 'Votes submitted successfully');
          context.pop();
        }
        if (state.status.isSuccess) {
          final isExcludedFromTheSession = (state
                      .votingSessionProcedureBundle!.excludedVotingSessionJurationsBundles
                      .where((e) => e.jurationBundle.juror.id == profile.id)
                      .firstOrNull !=
                  null)
              ? true
              : false;
          if (isExcludedFromTheSession) {
            showSnackBar(
                context: context, text: 'The organizer excluded you from voting to this session');
            context.pop();
          }
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
                    return SizedBox.shrink();
                  case BlocStatus.loading:
                    if (state.sourceEvent
                            is JurorVotingProcedurePageSubscribeToVotingSessionProcedure ||
                        state.sourceEvent
                            is JurorVotingProcedurePageResubscribeToVotingSessionProcedure) {
                      return Loader();
                    } else {
                      continue successCase;
                    }
                  case BlocStatus.failure:
                    if (state.sourceEvent
                        is JurorVotingProcedurePageSubscribeToVotingSessionProcedure) {
                      return RefreshIndicator.adaptive(
                        onRefresh: () async => context.read<JurorVotingProcedurePageBloc>().add(
                            JurorVotingProcedurePageSubscribeToVotingSessionProcedure(
                                votingSessionId: votingSessionId, jurorId: profile.id)),
                        child: ListView(),
                      );
                    } else {
                      continue successCase;
                    }
                  successCase:
                  case BlocStatus.success:
                    final votingSessionProcedureBundle = state.votingSessionProcedureBundle!;
                    final votingSessionBundle = votingSessionProcedureBundle.votingSessionBundle;
                    final votingSession = votingSessionBundle.votingSession;
                    final sessionStatus = votingSessionBundle.votingSession.sessionStatus;
                    final votingFormFields =
                        votingSessionProcedureBundle.votingFormBundle.votingFormFields;
                    final isExcludedFromTheSession = (votingSessionProcedureBundle
                                .excludedVotingSessionJurationsBundles
                                .where((e) => e.jurationBundle.juror.id == profile.id)
                                .firstOrNull !=
                            null)
                        ? true
                        : false;

                    // if(!areFieldsControllersInitialized) {
                    //   for(int i=0; i<votingSessionProcedureBundle.votingSessionParticipationsBundles.length; i++) {
                    //     for(int j=0; j<votingFormFields.length; j++) {
                    //       fieldsControllers.add(TextEditingController());
                    //     }
                    //   }
                    //   areFieldsControllersInitialized = true;
                    // }

                    if (isExcludedFromTheSession) {
                      return SizedBox.shrink();
                    }

                    final thisVotingSessionJuration = votingSessionProcedureBundle
                        .includedVotingSessionJurationsBundles
                        .where((e) => e.jurationBundle.juror.id == profile.id)
                        .first
                        .votingSessionJuration;

                    return LayoutBuilder(
                      builder: (context, constraints) {
                        return RefreshIndicator.adaptive(
                          onRefresh: () async => context.read<JurorVotingProcedurePageBloc>().add(
                              JurorVotingProcedurePageResubscribeToVotingSessionProcedure(
                                  votingSessionId: votingSessionId, jurorId: profile.id)),
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
                                      votesPerParticipantMap
                                          .addAll({votingSessionParticipation: {}});
                                      return Column(
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

                                    return Column(
                                      children: [
                                        SizedBox(height: 16),
                                        CustomTimerCountdown(
                                          label: 'Jurors are voting',
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
                                    final participantsExcludedFrom = votingSessionProcedureBundle
                                        .votingSessionExclusions
                                        .where((e) =>
                                            e.votingSessionJurationId ==
                                            thisVotingSessionJuration.id)
                                        .map((e) => e.votingSessionParticipationId)
                                        .toList(growable: false);
                                    final excludedSet = participantsExcludedFrom.toSet();

                                    final votingSessionParticipationsBundles = state
                                        .votingSessionProcedureBundle!
                                        .includedVotingSessionParticipationsBundles
                                        .where((bundle) => !excludedSet
                                            .contains(bundle.votingSessionParticipation.id))
                                        .toList();

                                    return Column(
                                      children: [
                                        CustomTimerCountdown(
                                          label: 'Reviewing',
                                          endTime: currentStepDeadline,
                                        ),
                                        Divider(height: 24),
                                        Form(
                                          key: _reviewFormKey,
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
                                  case VotingSessionStatus.ended:
                                  case VotingSessionStatus.cancelled:
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
            BlocBuilder<JurorVotingProcedurePageBloc, JurorVotingProcedurePageState>(
          builder: (context, state) {
            if (state.votingSessionProcedureBundle == null) {
              return SizedBox.shrink();
            }
            final isExcludedFromTheSession = (state
                        .votingSessionProcedureBundle!.excludedVotingSessionJurationsBundles
                        .where((e) => e.jurationBundle.juror.id == profile.id)
                        .firstOrNull !=
                    null)
                ? true
                : false;
            if (isExcludedFromTheSession) {
              return SizedBox.shrink();
            }
            final votingSession =
                state.votingSessionProcedureBundle!.votingSessionBundle.votingSession;
            if (!votingSession.sessionStatus.isReview) {
              return SizedBox.shrink();
            }
            return FilledButton(
              onPressed: (!state.status.isLoading)
                  ? () {
                      if (_reviewFormKey.currentState?.validate() ?? false) {
                        context
                            .read<JurorVotingProcedurePageBloc>()
                            .add(JurorVotingProcedurePageSubmitVotes(
                              jurorId: profile.id,
                              votingSession: votingSession,
                              geoResPlace: state
                                  .votingSessionProcedureBundle!.votingSessionBundle.geoResPlace,
                              votesPerParticipantMap: votesPerParticipantMap,
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
