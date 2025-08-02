import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:swift_contest/model/database/entities/voting_form_field.dart';
import 'package:swift_contest/model/database/entities/voting_session_participant.dart';
import 'package:swift_contest/model/database/types/voting_form_field_scope.dart';
import 'package:swift_contest/model/database/types/voting_form_field_type.dart';
import 'package:swift_contest/model/database/types/voting_session_status.dart';
import 'package:swift_contest/utils/labels/labels.dart';
import 'package:swift_contest/view/widgets/custom_app_bar.dart';
import 'package:swift_contest/view/widgets/list_view_with_central_label.dart';
import 'package:swift_contest/view/widgets/overlay_loader.dart';
import 'package:swift_contest/view/widgets/show_snack_bar.dart';
import 'package:swift_contest/view/widgets/void_widget.dart';
import 'package:swift_contest/view/widgets/voting_procedure_form_and_work_view.dart';
import 'package:swift_contest/viewmodel/blocs/auth_bloc/auth_bloc.dart';
import 'package:swift_contest/viewmodel/blocs/pages_blocs/juror_voting_procedure_page_bloc/juror_voting_procedure_page_bloc.dart';
import 'package:swift_contest/viewmodel/enums/bloc_status.dart';

@RoutePage()
class JurorVotingProcedurePage extends StatefulWidget implements AutoRouteWrapper {
  final String votingSessionId;

  const JurorVotingProcedurePage({
    @PathParam('votingSessionId') required this.votingSessionId,
    super.key,
  });

  @override
  State<JurorVotingProcedurePage> createState() => _JurorVotingProcedurePageState();

  @override
  Widget wrappedRoute(BuildContext context) {
    return BlocProvider<JurorVotingProcedurePageBloc>(
      create: (context) => JurorVotingProcedurePageBloc(
        jurorRepository: context.read(),
      ),
      child: this,
    );
  }
}

class _JurorVotingProcedurePageState extends State<JurorVotingProcedurePage> {
  late String profileId;
  late final String votingSessionId;
  final formKey = GlobalKey<FormState>();
  final List<VotingFormAndWorkView> votingFormAndWorkViews = [];
  final Map<VotingSessionParticipant, Map<VotingFormField, TextEditingController>> votesMap = {};
  bool isPageInitialized = false;

  @override
  void initState() {
    super.initState();
    votingSessionId = widget.votingSessionId;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    profileId = context.read<AuthBloc>().state.profile!.id!;
    context
        .read<JurorVotingProcedurePageBloc>()
        .add(JurorVotingProcedurePageFetch(votingSessionId: votingSessionId));
  }

  @override
  void dispose() {
    context.hideLoader();
    votesMap.forEach((key, value) {
      value.forEach((key, value) {
        value.dispose();
      });
    });
    formKey.currentState?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<JurorVotingProcedurePageBloc, JurorVotingProcedurePageState>(
      listener: (context, state) {
        if (state.message != null) {
          showSnackBar(context: context, text: state.message!);
        }
        if (state.status.isLoading) {
          context.showLoader();
        } else {
          context.hideLoader();
        }
        if (state.votingSessionProcedureBundle!.votingSessionBundle.votingSession.sessionStatus
            .isEnded) {
          showSnackBar(context: context, text: 'Voting session procedure is ended');
          context.router.pop(true);
        }
        if (state.votingSessionProcedureBundle!.votingSessionBundle.votingSession.sessionStatus
            .isCancelled) {
          showSnackBar(context: context, text: 'Voting session procedure has been cancelled');
          context.router.pop(true);
        }
        if (state.status.isSuccess && state.sourceEvent is JurorVotingProcedurePageSubmitVotes) {
          showSnackBar(context: context, text: 'Votes submitted successfully');
          context.router.pop();
        }
      },
      builder: (context, state) {
        return Scaffold(
          appBar: CustomAppBar(title: 'Voting'),
          body: SafeArea(
            child: Padding(
              padding: const EdgeInsets.only(left: 16, right: 16, top: 16),
              child: Builder(
                builder: (context) {
                  switch (state.status) {
                    case BlocStatus.initial:
                      return VoidWidget();
                    case BlocStatus.loading:
                      if (!state.isInitialized) {
                        return VoidWidget();
                      } else {
                        continue successCase;
                      }
                    case BlocStatus.failure:
                      if (!state.isInitialized) {
                        return RefreshIndicator.adaptive(
                          onRefresh: () async => context
                              .read<JurorVotingProcedurePageBloc>()
                              .add(JurorVotingProcedurePageFetch(votingSessionId: votingSessionId)),
                          child: ListViewWithCentralLabel(label: Labels.anErrorOccurred),
                        );
                      } else {
                        continue successCase;
                      }
                    successCase:
                    case BlocStatus.success:
                      final votingSessionProcedureBundle = state.votingSessionProcedureBundle!;
                      final votingSessionBundle = votingSessionProcedureBundle.votingSessionBundle;
                      final votingSession = votingSessionBundle.votingSession;
                      final votingSessionParticipants =
                          votingSessionProcedureBundle.votingSessionParticipants;
                      final headerVotingFormFields = votingSessionProcedureBundle
                          .votingFormBundle.votingFormFields
                          .where((e) => e.scope.isHeader)
                          .toList(growable: false);
                      final participantVotingFormFields = votingSessionProcedureBundle
                          .votingFormBundle.votingFormFields
                          .where((e) => e.scope.isParticipant)
                          .toList(growable: false);
                      final footerVotingFormFields = votingSessionProcedureBundle
                          .votingFormBundle.votingFormFields
                          .where((e) => e.scope.isFooter)
                          .toList(growable: false);

                      if (!isPageInitialized) {
                        for (var votingSessionParticipants in votingSessionParticipants) {
                          final Map<VotingFormField, TextEditingController> fieldsControllers = {};
                          for (var votingFormField in participantVotingFormFields) {
                            switch (votingFormField.type) {
                              case VotingFormFieldType.textual:
                                fieldsControllers
                                    .addAll({votingFormField: TextEditingController()});
                                break;
                              case VotingFormFieldType.slider:
                                fieldsControllers.addAll({
                                  votingFormField: TextEditingController(
                                      text: votingFormField.sliderMinValue!.toString())
                                });
                                break;
                            }
                          }
                          votesMap.addAll({votingSessionParticipants: fieldsControllers});
                          final isExcludedFromParticipant = votingSessionProcedureBundle
                              .votingSessionParticipantsExclusionsIds
                              .contains(votingSessionParticipants.id);
                          votingFormAndWorkViews.add(VotingFormAndWorkView(
                              isExcludedFromParticipant: isExcludedFromParticipant,
                              votingSessionParticipation: votingSessionParticipants,
                              votingFormFields: participantVotingFormFields,
                              votesMap: votesMap));
                        }
                        isPageInitialized = true;
                      }

                      return RefreshIndicator.adaptive(
                        onRefresh: () async => context
                            .read<JurorVotingProcedurePageBloc>()
                            .add(JurorVotingProcedurePageFetch(votingSessionId: votingSessionId)),
                        child: Form(
                          key: formKey,
                          child: ListView.builder(
                            itemCount: votingFormAndWorkViews.length,
                            itemBuilder: (context, index) {
                              return Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  votingFormAndWorkViews[index],
                                  if (index == votingFormAndWorkViews.length - 1)
                                    SizedBox(height: 100),
                                ],
                              );
                            },
                          ),
                        ),
                      );
                  }
                },
              ),
            ),
          ),
          floatingActionButton: (state.isInitialized)
              ? FilledButton(
                  onPressed: () {
                    if (formKey.currentState?.validate() ?? false) {
                      final Map<VotingSessionParticipant, Map<VotingFormField, String>>
                          votesPerParticipantMap = {};
                      for (var entry in votesMap.entries) {
                        final votingSessionParticipation = entry.key;
                        final votingFormFieldAndController = entry.value;
                        final Map<VotingFormField, String> votes = {};
                        for (var votingFormFieldAndControllerEntry
                            in votingFormFieldAndController.entries) {
                          final votingFormField = votingFormFieldAndControllerEntry.key;
                          final controller = votingFormFieldAndControllerEntry.value;
                          if (controller.text.trim().isNotEmpty) {
                            votes.addAll({votingFormField: controller.text.trim()});
                          }
                        }
                        if (votes.isNotEmpty) {
                          votesPerParticipantMap.addAll({votingSessionParticipation: votes});
                        }
                      }

                      // Invia il nuovo evento semplificato.
                      context
                          .read<JurorVotingProcedurePageBloc>()
                          .add(JurorVotingProcedurePageSubmitVotes(
                            votesPerParticipantMap: votesPerParticipantMap,
                          ));
                    } else {
                      showSnackBar(context: context, text: 'Fill all the fields');
                    }
                  },
                  child: Text('Submit'),
                )
              : null,
        );
      },
    );
  }
}
