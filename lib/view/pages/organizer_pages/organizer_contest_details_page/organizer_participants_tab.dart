import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:swift_contest/utils/labels/labels.dart';
import 'package:swift_contest/utils/validators/validators.dart';
import 'package:swift_contest/view/widgets/custom_text_form_field.dart';
import 'package:swift_contest/view/widgets/list_view_with_central_label.dart';
import 'package:swift_contest/view/widgets/overlay_loader.dart';
import 'package:swift_contest/view/widgets/show_snack_bar.dart';
import 'package:swift_contest/view/widgets/void_widget.dart';
import 'package:swift_contest/viewmodel/blocs/pages_blocs/organizer_contest_details_page_bloc/organizer_contest_details_page_bloc.dart';
import 'package:swift_contest/viewmodel/enums/bloc_status.dart';

class OrganizerParticipantsTab extends StatefulWidget {
  final String contestId;

  const OrganizerParticipantsTab({
    required this.contestId,
    super.key,
  });

  @override
  State<OrganizerParticipantsTab> createState() => _OrganizerParticipantsTabState();
}

class _OrganizerParticipantsTabState extends State<OrganizerParticipantsTab> {
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
            child: DefaultTabController(
              length: 2,
              child: Builder(
                builder: (context) {
                  if (!state.isInitialized) {
                    if (state.status.isFailure) {
                      return Center(
                        child: FilledButton(
                          onPressed: () async => context
                              .read<OrganizerContestDetailsPageBloc>()
                              .add(OrganizerContestDetailsPageFetch(contestId: contestId)),
                          child: Text('Retry'),
                        ),
                      );
                    }
                    return VoidWidget();
                  }
                  final participations = state.contestDetailsBundle!.participationsBundles;
                  final invitations = state.contestDetailsBundle!.participantsInvitations;
                  return Column(
                    children: [
                      Card(
                        elevation: 0.4,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        child: SizedBox(
                          height: 30,
                          child: TabBar(
                            labelColor: Theme.of(context).colorScheme.onTertiary,
                            isScrollable: false,
                            dividerColor: Colors.transparent,
                            tabAlignment: TabAlignment.center,
                            splashBorderRadius: BorderRadius.circular(16),
                            indicatorSize: TabBarIndicatorSize.tab,
                            indicator: BoxDecoration(
                              borderRadius: BorderRadius.circular(16),
                              color: Theme.of(context).colorScheme.tertiary,
                            ),
                            tabs: [
                              Tab(text: 'Joined'),
                              Tab(text: 'Attended'),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(height: 8),
                      Expanded(
                        child: TabBarView(
                          children: [
                            //* Joined
                            RefreshIndicator.adaptive(
                              onRefresh: () async => context
                                  .read<OrganizerContestDetailsPageBloc>()
                                  .add(OrganizerContestDetailsPageFetch(contestId: contestId)),
                              child: (participations.isEmpty)
                                  ? ListViewWithCentralLabel(label: 'No participant joined yet')
                                  : ListView.builder(
                                      itemCount: participations.length,
                                      itemBuilder: (context, index) {
                                        final participationBundle = participations[index];
                                        return Column(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Card(
                                              elevation: 0.2,
                                              child: ListTile(
                                                trailing: IconButton(
                                                  onPressed: () {
                                                    _showRemoveParticipantDialog(
                                                        context: context,
                                                        contestId: contestId,
                                                        participationId:
                                                            participationBundle.participation.id!);
                                                  },
                                                  icon: Icon(
                                                    Icons.remove_circle_outline,
                                                    color: Theme.of(context).colorScheme.error,
                                                  ),
                                                ),
                                                title: Text(
                                                  participationBundle.participant.fullName,
                                                  style: Theme.of(context).textTheme.titleMedium,
                                                ),
                                                subtitle: Text(
                                                  participationBundle.participation.invitationEmail,
                                                  style: Theme.of(context).textTheme.bodyMedium,
                                                ),
                                              ),
                                            ),
                                            if (index == participations.length - 1)
                                              SizedBox(height: 72),
                                          ],
                                        );
                                      },
                                    ),
                            ),
                            //* Attended
                            RefreshIndicator.adaptive(
                              onRefresh: () async => context
                                  .read<OrganizerContestDetailsPageBloc>()
                                  .add(OrganizerContestDetailsPageFetch(contestId: contestId)),
                              child: (invitations.isEmpty)
                                  ? ListViewWithCentralLabel(label: 'No participant attended')
                                  : ListView.builder(
                                      itemCount: invitations.length,
                                      itemBuilder: (context, index) {
                                        final invitation = invitations[index];
                                        return Column(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Card(
                                              elevation: 0.2,
                                              child: ListTile(
                                                title: Text(
                                                  invitation.email,
                                                  style: Theme.of(context).textTheme.titleMedium,
                                                ),
                                                trailing: IconButton(
                                                  onPressed: () {
                                                    _showDeleteInvitationDialog(
                                                        context: context,
                                                        contestId: contestId,
                                                        invitationId: invitation.id!);
                                                  },
                                                  icon: Icon(
                                                    Icons.remove,
                                                    color: Theme.of(context).colorScheme.error,
                                                  ),
                                                ),
                                              ),
                                            ),
                                            if (index == invitations.length - 1)
                                              SizedBox(height: 72),
                                          ],
                                        );
                                      },
                                    ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () async {
              _showInviteDialog(context: context, contestId: contestId);
            },
            icon: Icon(Icons.email),
            label: Text('Invite'),
          ),
        );
      },
    );
  }
}

void _showInviteDialog({required BuildContext context, required String contestId}) {
  final organizerContestDetailsPageBloc = context.read<OrganizerContestDetailsPageBloc>();
  final invitationFormKey = GlobalKey<FormState>();
  final emailController = TextEditingController();
  final emailFocusNode = FocusNode();

  showDialog(
    context: context,
    builder: (context) {
      return BlocProvider.value(
        value: organizerContestDetailsPageBloc,
        child: BlocConsumer<OrganizerContestDetailsPageBloc, OrganizerContestDetailsPageState>(
          listener: (context, state) {
            if (state.status.isSuccess &&
                state.sourceEvent is OrganizerContestDetailsPageSendParticipantInvite) {
              showSnackBar(context: context, text: 'Email sent successfully');
              context
                  .read<OrganizerContestDetailsPageBloc>()
                  .add(OrganizerContestDetailsPageFetch(contestId: contestId));
              context.router.pop();
            }
          },
          builder: (context, state) {
            return AlertDialog(
              title: Text(
                'Invite a participant',
              ),
              content: Form(
                key: invitationFormKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CustomTextFormField(
                      borderType: InputBorderType.underlined,
                      controller: emailController,
                      focusNode: emailFocusNode,
                      label: 'Email',
                      validator: emailValidator,
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    context.router.pop();
                  },
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: () {
                    if (invitationFormKey.currentState?.validate() ?? false) {
                      context
                          .read<OrganizerContestDetailsPageBloc>()
                          .add(OrganizerContestDetailsPageSendParticipantInvite(
                            contestId: contestId,
                            email: emailController.text.trim(),
                          ));
                    }
                  },
                  child: const Text('Proceed'),
                ),
              ],
            );
          },
        ),
      );
    },
  );
}

void _showRemoveParticipantDialog({
  required BuildContext context,
  required String contestId,
  required String participationId,
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
                state.sourceEvent is OrganizerContestDetailsPageRemoveParticipant) {
              context.router.pop();
              showSnackBar(context: context, text: 'Participant removed successfully');
              context
                  .read<OrganizerContestDetailsPageBloc>()
                  .add(OrganizerContestDetailsPageFetch(contestId: contestId));
            }
          },
          builder: (context, state) {
            return AlertDialog(
              title: Text('Remove participant'),
              content: Text('Are you sure you want to remove this participant?'),
              actions: [
                TextButton(
                  onPressed: () {
                    context.router.pop();
                  },
                  child: Text('Cancel'),
                ),
                TextButton(
                  onPressed: () {
                    context.read<OrganizerContestDetailsPageBloc>().add(
                        OrganizerContestDetailsPageRemoveParticipant(
                            participationId: participationId));
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

void _showDeleteInvitationDialog({
  required BuildContext context,
  required String contestId,
  required String invitationId,
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
                state.sourceEvent is OrganizerContestDetailsPageDeleteParticipantInvitation) {
              context.router.pop();
              showSnackBar(context: context, text: 'Invitation deleted successfully');
              context
                  .read<OrganizerContestDetailsPageBloc>()
                  .add(OrganizerContestDetailsPageFetch(contestId: contestId));
            }
          },
          builder: (context, state) {
            return AlertDialog(
              title: Text('Delete invitation'),
              content: Text('Are you sure you want to delete this invitation?'),
              actions: [
                TextButton(
                  onPressed: () {
                    context.router.pop();
                  },
                  child: Text('Cancel'),
                ),
                TextButton(
                  onPressed: () {
                    context.read<OrganizerContestDetailsPageBloc>().add(
                        OrganizerContestDetailsPageDeleteParticipantInvitation(
                            participantInvitationId: invitationId));
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
