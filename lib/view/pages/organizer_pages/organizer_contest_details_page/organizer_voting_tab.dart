import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:swift_contest/model/db/types/voting_session_status.dart';
import 'package:swift_contest/utils/labels/labels.dart';
import 'package:swift_contest/utils/router/app_router.gr.dart';
import 'package:swift_contest/utils/themes/color_scheme_x.dart';
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
                    if (!state.isInitialized) {
                      return VoidWidget();
                    } else {
                      continue successCase;
                    }
                  case BlocStatus.failure:
                    if (!state.isInitialized) {
                      return RefreshIndicator.adaptive(
                        onRefresh: () async => context
                            .read<OrganizerContestDetailsPageBloc>()
                            .add(OrganizerContestDetailsPageFetch(contestId: contestId)),
                        child: ListViewWithCentralLabel(label: Labels.anErrorOccurred),
                      );
                    } else {
                      continue successCase;
                    }
                  successCase:
                  case BlocStatus.success:
                    final endedVotingSessions = state.contestDetailsBundle!.votingSessionsBundles.map((e) => e.votingSession)
                        .where((e) => e.sessionStatus.isEnded)
                        .toList(growable: false);
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Jurors' form
                        // Card(
                        //   elevation: 0.2,
                        //   color: Theme.of(context).colorScheme.tertiary,
                        //   child: ListTile(
                        //     onTap: () {
                        //       context.router.push(OrganizerVotingFormEditRoute(
                        //           votingFormId: votingFormBundle.votingForm.id));
                        //     },
                        //     title: Text(
                        //       'Edit juror\'s form',
                        //       style: Theme.of(context)
                        //           .textTheme
                        //           .titleMedium
                        //           ?.copyWith(color: Theme.of(context).colorScheme.onTertiary),
                        //     ),
                        //     leading:
                        //         Icon(Icons.edit, color: Theme.of(context).colorScheme.onTertiary),
                        //   ),
                        // ),
                        // SizedBox(height: 16),
                        //* Token
                        // Text('Contest token for simple jurors'),
                        Card(
                          elevation: 0,
                          color: Theme.of(context).colorScheme.tertiaryContainer,
                          child: ListTile(
                            onTap: () {
                              showDialog(
                                context: context,
                                builder: (context) {
                                  final token =
                                      state.contestDetailsBundle!.contestBundle.contest.token!;
                                  return AlertDialog(
                                    title: Text('Token'),
                                    content: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        SizedBox(
                                          width: 200,
                                          height: 200,
                                          child: QrImageView(
                                            data: token,
                                            version: QrVersions.auto,
                                            backgroundColor: Theme.of(context).colorScheme.white,
                                          ),
                                        ),
                                        Row(
                                          mainAxisSize: MainAxisSize.max,
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          spacing: 8,
                                          children: [
                                            Text(token),
                                            IconButton(
                                              onPressed: () {
                                                Clipboard.setData(ClipboardData(text: token));
                                                showSnackBar(
                                                  context: context,
                                                  text: 'Token copied to clipboard!',
                                                );
                                              },
                                              icon: Icon(Icons.copy),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed: () => context.router.pop(),
                                        child: Text('Close'),
                                      ),
                                    ],
                                  );
                                },
                              );
                            },
                            title: Text(
                              'Token for simple jurors',
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: Theme.of(context).colorScheme.onTertiaryContainer),
                            ),
                            subtitle: Text(
                              state.contestDetailsBundle!.contestBundle.contest.token!,
                              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                                  color: Theme.of(context).colorScheme.onTertiaryContainer),
                            ),
                            trailing: IconButton(
                                onPressed: () {
                                  _showRegenerateTokenDialog(
                                      context: context, contestId: contestId);
                                },
                                icon: Icon(
                                  Icons.refresh,
                                  color: Theme.of(context).colorScheme.onTertiaryContainer,
                                )),
                          ),
                        ),
                        SizedBox(height: 16),
                        //* Results
                        Text(
                          'Voting results',
                          style: Theme.of(context)
                              .textTheme
                              .titleMedium
                              ?.copyWith(color: Theme.of(context).colorScheme.secondary),
                        ),
                        SizedBox(height: 4),
                        Expanded(
                          child: RefreshIndicator.adaptive(
                            onRefresh: () async => context
                                .read<OrganizerContestDetailsPageBloc>()
                                .add(OrganizerContestDetailsPageFetch(contestId: contestId)),
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
                                                //todo
                                                // context.router.push(
                                                //     OrganizerVotingResultDetailsRoute(
                                                //         votingSessionId: votingSession.id));
                                              },
                                              title: Text(
                                                votingSession.name,
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                              subtitle: Text(
                                                DateFormat('dd MMM, yyyy | HH:mm')
                                                    .format(votingSession.createdAt!),
                                              ),
                                              trailing: IconButton(
                                                onPressed: () async {
                                                  _showEditVotingSessionNameDialog(
                                                      context: context,
                                                      votingSessionId: votingSession.id!,
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
                  if (!state.isInitialized) {
                    return VoidWidget();
                  } else {
                    continue successCase;
                  }
                successCase:
                case BlocStatus.success:
                  final liveVotingSession = state.contestDetailsBundle!.votingSessionsBundles.map((e) => e.votingSession)
                      .where((e) => !e.sessionStatus.isEnded && !e.sessionStatus.isCancelled)
                      .singleOrNull;
                  if (liveVotingSession == null) {
                    return FloatingActionButton.extended(
                      onPressed: () async {
                        for(var juryBundle in state.contestDetailsBundle!.juriesBundles) {
                          if(juryBundle.votingFormBundle.votingFormFields.isEmpty) {
                            showSnackBar(context: context, text: "Voting form of '${juryBundle.jury.name}' is empty. Add at least one field");
                            return;
                          }
                        }

                        if (state.contestDetailsBundle!.juriesBundles
                            .map((e) => e.jurationsBundles)
                            .toList(growable: false)
                            .isEmpty) {
                          showSnackBar(
                            context: context,
                            text: 'At least one juror is necessary',
                          );
                          return;
                        }
                        if (state.contestDetailsBundle!.participationsBundles
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
                      },
                      elevation: 1,
                      label: Text('Start voting'),
                    );
                  } else {
                    return FloatingActionButton.extended(
                      onPressed: () {
                        context.router.push(OrganizerVotingProcedureRoute(
                            votingSessionId: liveVotingSession.id!));
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

void _showRegenerateTokenDialog({
  required BuildContext context,
  required String contestId,
}) {
  final organizerContestDetailsPageBloc = context.read<OrganizerContestDetailsPageBloc>();

  showDialog(
    context: context,
    builder: (context) {
      return BlocProvider.value(
        value: organizerContestDetailsPageBloc,
        child: BlocConsumer<OrganizerContestDetailsPageBloc, OrganizerContestDetailsPageState>(
          listener: (context, state) {
            if (state.status.isSuccess &&
                state.sourceEvent is OrganizerContestDetailsPageRegenerateToken) {
              context
                  .read<OrganizerContestDetailsPageBloc>()
                  .add(OrganizerContestDetailsPageFetch(contestId: contestId));
              context.router.pop();
              showSnackBar(context: context, text: 'Token regenerated successfully');
            }
          },
          builder: (context, state) {
            return AlertDialog(
              title: Text('Regenerate token'),
              content: Text(
                  'Are you sure you want to regenerate the token associated with the contest? Only the new token will allow simple jurors to vote'),
              actions: [
                TextButton(
                  onPressed: () => context.router.pop(),
                  child: Text('Cancel'),
                ),
                TextButton(
                  onPressed: () {
                    context
                        .read<OrganizerContestDetailsPageBloc>()
                        .add(OrganizerContestDetailsPageRegenerateToken(contestId: contestId));
                  },
                  child: Text('Proceed'),
                ),
              ],
            );
          },
        ),
      );
    },
  );
}

void _showEditVotingSessionNameDialog({
  required BuildContext context,
  required String votingSessionId,
  required String contestId,
}) {
  final organizerContestDetailsPageBloc = context.read<OrganizerContestDetailsPageBloc>();
  final formKey = GlobalKey<FormState>();
  final nameController = TextEditingController();
  final nameFocusNode = FocusNode();

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
                  .add(OrganizerContestDetailsPageFetch(contestId: contestId));
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
                      focusNode: nameFocusNode,
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
