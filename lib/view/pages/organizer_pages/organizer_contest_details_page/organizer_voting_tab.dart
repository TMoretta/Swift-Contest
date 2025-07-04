import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:swift_contest/utils/labels/labels.dart';
import 'package:swift_contest/utils/router/app_router.gr.dart';
import 'package:swift_contest/utils/validators/validators.dart';
import 'package:swift_contest/view/widgets/custom_text_form_field.dart';
import 'package:swift_contest/view/widgets/list_view_with_central_label.dart';
import 'package:swift_contest/view/widgets/overlay_loader.dart';
import 'package:swift_contest/view/widgets/show_snack_bar.dart';
import 'package:swift_contest/view/widgets/void_widget.dart';
import 'package:swift_contest/viewmodel/blocs/pages_blocs/organizer_contest_details_page_bloc/organizer_contest_details_page_bloc.dart';
import 'package:swift_contest/viewmodel/enums/bloc_status.dart';

class OrganizerVotingTab extends StatefulWidget {
  final String contestId;

  const OrganizerVotingTab({required this.contestId, super.key});

  @override
  State<OrganizerVotingTab> createState() => _OrganizerVotingTabState();
}

class _OrganizerVotingTabState extends State<OrganizerVotingTab> {
  late final String contestId;

  @override
  void initState() {
    super.initState();
    contestId = widget.contestId;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final state = context.read<OrganizerContestDetailsPageBloc>().state;
    if (state.status.isInitial) {
      context
          .read<OrganizerContestDetailsPageBloc>()
          .add(OrganizerContestDetailsPageInit(contestId: contestId));
    }
  }

  @override
  void dispose() {
    context.hideLoader();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<OrganizerContestDetailsPageBloc, OrganizerContestDetailsPageState>(
      builder: (context, state) {
        return Scaffold(
          body: SafeArea(
            child: Builder(
              builder: (context) {
                switch (state.status) {
                  case BlocStatus.initial:
                    return VoidWidget();
                  case BlocStatus.loading:
                    if (state.sourceEvent is OrganizerContestDetailsPageInit) {
                      return VoidWidget();
                    } else {
                      continue successCase;
                    }
                  case BlocStatus.failure:
                    if (state.sourceEvent is OrganizerContestDetailsPageInit) {
                      return RefreshIndicator.adaptive(
                        onRefresh: () async => context
                            .read<OrganizerContestDetailsPageBloc>()
                            .add(OrganizerContestDetailsPageInit(contestId: contestId)),
                        child: ListViewWithCentralLabel(label: Labels.anErrorOccurred),
                      );
                    } else {
                      continue successCase;
                    }
                  successCase:
                  case BlocStatus.success:
                    final votingFormBundle = state.contestDetailsBundle!.votingFormBundle;
                    final endedVotingSessions = state.contestDetailsBundle!.endedVotingSessions;
                    return Column(
                      children: [
                        //* Jurors' form
                        Card(
                          elevation: 0.2,
                          color: Theme.of(context).colorScheme.tertiary,
                          child: ListTile(
                            onTap: () {
                              context.router.push(OrganizerVotingFormEditRoute(
                                  votingFormId: votingFormBundle.votingForm.id));
                            },
                            title: Text(
                              'Edit juror\'s form',
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium
                                  ?.copyWith(color: Theme.of(context).colorScheme.onTertiary),
                            ),
                            leading:
                                Icon(Icons.edit, color: Theme.of(context).colorScheme.onTertiary),
                          ),
                        ),
                        SizedBox(height: 16),
                        //* Results
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            'Voting results',
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(color: Theme.of(context).colorScheme.secondary),
                          ),
                        ),
                        SizedBox(height: 4),
                        Expanded(
                          child: RefreshIndicator.adaptive(
                            onRefresh: () async => context
                                .read<OrganizerContestDetailsPageBloc>()
                                .add(OrganizerContestDetailsPageRefresh(contestId: contestId)),
                            child: (endedVotingSessions.isNotEmpty)
                                ? ListView.builder(
                                    itemCount: endedVotingSessions.length,
                                    itemBuilder: (context, index) {
                                      final votingSession = endedVotingSessions[index];
                                      return Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Card(
                                            elevation: 0.05,
                                            child: ListTile(
                                              onTap: () {
                                                context.router.push(
                                                    OrganizerVotingResultDetailsRoute(
                                                        votingSessionId: votingSession.id));
                                              },
                                              title: Text(
                                                votingSession.name,
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                              subtitle: Text(
                                                DateFormat('dd MMM, yyyy | HH:mm')
                                                    .format(votingSession.createdAt),
                                              ),
                                              trailing: IconButton(
                                                onPressed: () async {
                                                  _showEditVotingSessionNameDialog(
                                                      context: context,
                                                      votingSessionId: votingSession.id,
                                                      contestId: contestId);
                                                },
                                                icon: Icon(
                                                  Icons.edit,
                                                ),
                                              ),
                                            ),
                                          ),
                                          if (index == endedVotingSessions.length - 1)
                                            SizedBox(height: 72),
                                        ],
                                      );
                                    },
                                  )
                                : ListView(
                                    children: [
                                      Text(
                                        'No result yet',
                                      ),
                                    ],
                                  ),
                          ),
                        ),
                      ],
                    );
                }
              },
            ),
          ),
          floatingActionButton: Builder(
            builder: (context) {
              switch (state.status) {
                case BlocStatus.initial:
                  return VoidWidget();
                case (BlocStatus.loading || BlocStatus.failure):
                  if (state.sourceEvent is OrganizerContestDetailsPageInit) {
                    return VoidWidget();
                  } else {
                    continue successCase;
                  }
                successCase:
                case BlocStatus.success:
                  if (state.contestDetailsBundle!.liveVotingSession == null) {
                    return FloatingActionButton.extended(
                      onPressed: () async {
                        if (state.contestDetailsBundle!.joinedJurationsBundles.isEmpty) {
                          showSnackBar(
                            context: context,
                            text: 'At least one juror is necessary',
                          );
                          return;
                        }
                        if (state.contestDetailsBundle!.joinedParticipationsBundles
                            .where((e) => e.participation.hasSubmitted)
                            .toList(growable: false)
                            .isEmpty) {
                          showSnackBar(
                            context: context,
                            text: 'At least one participant with submitted work is necessary',
                          );
                          return;
                        }

                        context.router.push(OrganizerVotingSettingsRoute(contestId: contestId));

                        // final String? votingSessionId = await context.router
                        //     .push(OrganizerVotingSettingsRoute(contestId: contestId));
                        //
                        // if (votingSessionId != null) {
                        //   if (context.mounted) {
                        //     final bool? res = await context.router.push(
                        //         OrganizerVotingProcedureRoute(votingSessionId: votingSessionId));
                        //     if (res == true) {
                        //       if (context.mounted) {
                        //         context
                        //             .read<OrganizerContestDetailsPageBloc>()
                        //             .add(OrganizerContestDetailsPageRefresh(contestId: contestId));
                        //       }
                        //     }
                        //   }
                        // }
                      },
                      elevation: 1,
                      label: Text('Start voting'),
                    );
                  } else {
                    return FloatingActionButton.extended(
                      onPressed: () {
                        context.router.push(OrganizerVotingProcedureRoute(
                            votingSessionId: state.contestDetailsBundle!.liveVotingSession!.id));
                      },
                      elevation: 1,
                      label: Text('Continue voting'),
                    );
                  }
              }
            },
          ),
        );
      },
    );
  }
}

void _showEditVotingSessionNameDialog({
  required BuildContext context,
  required String votingSessionId,
  required String contestId,
}) {
  final organizerContestDetailsPageBloc = context.read<OrganizerContestDetailsPageBloc>();
  final formKey = GlobalKey<FormState>();
  final nameController = TextEditingController();

  showDialog(
    context: context,
    builder: (context) {
      return BlocProvider.value(
        value: organizerContestDetailsPageBloc,
        child: BlocConsumer<OrganizerContestDetailsPageBloc, OrganizerContestDetailsPageState>(
          listener: (context, state) {
            if (state.status.isSuccess &&
                state.sourceEvent is OrganizerContestDetailsPageEditVotingSessionName) {
              context
                  .read<OrganizerContestDetailsPageBloc>()
                  .add(OrganizerContestDetailsPageRefresh(contestId: contestId));
              context.router.pop();
            }
          },
          builder: (context, state) {
            return AlertDialog(
              title: Text('Edit name'),
              content: Form(
                key: formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CustomTextFormField(
                      borderType: InputBorderType.underlined,
                      controller: nameController,
                      label: 'Name',
                      validator: noEmptyValidator,
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => context.router.pop(),
                  child: Text('Cancel'),
                ),
                TextButton(
                  onPressed: () {
                    if (formKey.currentState!.validate()) {
                      context.read<OrganizerContestDetailsPageBloc>().add(
                          OrganizerContestDetailsPageEditVotingSessionName(
                              votingSessionId: votingSessionId, name: nameController.text.trim()));
                    }
                  },
                  child: Text('Edit'),
                ),
              ],
            );
          },
        ),
      );
    },
  );
}
