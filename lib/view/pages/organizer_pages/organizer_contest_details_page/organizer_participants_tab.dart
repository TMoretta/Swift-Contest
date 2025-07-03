import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:swift_contest/model/bundles/participation_bundle.dart';
import 'package:swift_contest/model/data_models/invitation.dart';
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
            child: DefaultTabController(
              length: 3,
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
                      final List<ParticipationBundle> joinedParticipationsBundles =
                          state.contestDetailsBundle!.joinedParticipationsBundles;
                      final List<Invitation> participantsInvitations =
                          state.contestDetailsBundle!.participantsInvitations;
                      final List<ParticipationBundle> outParticipationsBundles =
                          state.contestDetailsBundle!.outParticipationsBundles;
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
                                  Tab(text: 'Out'),
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
                                      .add(
                                          OrganizerContestDetailsPageRefresh(contestId: contestId)),
                                  child: (joinedParticipationsBundles.isEmpty)
                                      ? ListViewWithCentralLabel(label: 'No participant joined yet')
                                      : ListView.builder(
                                          itemCount: joinedParticipationsBundles.length,
                                          itemBuilder: (context, index) {
                                            final participationBundle =
                                                joinedParticipationsBundles[index];
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
                                                            participationId: participationBundle
                                                                .participation.id);
                                                      },
                                                      icon: Icon(
                                                        Icons.remove_circle_outline,
                                                        color: Theme.of(context).colorScheme.error,
                                                      ),
                                                    ),
                                                    title: Text(
                                                      participationBundle.participant.fullName,
                                                      style:
                                                          Theme.of(context).textTheme.titleMedium,
                                                    ),
                                                    subtitle: Column(
                                                      mainAxisSize: MainAxisSize.min,
                                                      crossAxisAlignment: CrossAxisAlignment.start,
                                                      mainAxisAlignment: MainAxisAlignment.start,
                                                      spacing: 4,
                                                      children: [
                                                        Text(
                                                          participationBundle
                                                              .participation.invitationEmail,
                                                          style: Theme.of(context)
                                                              .textTheme
                                                              .bodyMedium,
                                                        ),
                                                        if (participationBundle
                                                                .participant.deletedAt !=
                                                            null)
                                                          Text(
                                                            'Deleted account',
                                                            style: Theme.of(context)
                                                                .textTheme
                                                                .labelLarge
                                                                ?.copyWith(
                                                                    color: Theme.of(context)
                                                                        .colorScheme
                                                                        .error),
                                                          ),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                                if (index == joinedParticipationsBundles.length - 1)
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
                                      .add(
                                          OrganizerContestDetailsPageRefresh(contestId: contestId)),
                                  child: (participantsInvitations.isEmpty)
                                      ? ListViewWithCentralLabel(label: 'No participant attended')
                                      : ListView.builder(
                                          itemCount: participantsInvitations.length,
                                          itemBuilder: (context, index) {
                                            final invitation = participantsInvitations[index];
                                            return Column(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Card(
                                                  elevation: 0.2,
                                                  child: ListTile(
                                                    title: Text(
                                                      invitation.email,
                                                      style:
                                                          Theme.of(context).textTheme.titleMedium,
                                                    ),
                                                    trailing: IconButton(
                                                      onPressed: () {
                                                        _showDeleteInvitationDialog(context: context, contestId: contestId, invitationId: invitation.id);
                                                      },
                                                      icon: Icon(
                                                        Icons.remove,
                                                        color: Theme.of(context).colorScheme.error,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                if (index == participantsInvitations.length - 1)
                                                  SizedBox(height: 72),
                                              ],
                                            );
                                          },
                                        ),
                                ),
                                //* Out
                                RefreshIndicator.adaptive(
                                  onRefresh: () async => context
                                      .read<OrganizerContestDetailsPageBloc>()
                                      .add(
                                          OrganizerContestDetailsPageRefresh(contestId: contestId)),
                                  child: (outParticipationsBundles.isEmpty)
                                      ? LayoutBuilder(
                                          builder: (context, constraints) {
                                            return ListView(
                                              children: [
                                                SizedBox(
                                                  height: constraints.maxHeight,
                                                  child: Center(
                                                    child: Text(
                                                      'No participant out',
                                                    ),
                                                  ),
                                                )
                                              ],
                                            );
                                          },
                                        )
                                      : ListView.builder(
                                          itemCount: outParticipationsBundles.length,
                                          itemBuilder: (context, index) {
                                            final participationBundle =
                                                outParticipationsBundles[index];
                                            return Column(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Card(
                                                  elevation: 0.2,
                                                  child: ListTile(
                                                    title: Text(
                                                      participationBundle.participant.fullName,
                                                      style:
                                                          Theme.of(context).textTheme.titleMedium,
                                                    ),
                                                    subtitle: Column(
                                                      mainAxisSize: MainAxisSize.min,
                                                      crossAxisAlignment: CrossAxisAlignment.start,
                                                      mainAxisAlignment: MainAxisAlignment.start,
                                                      spacing: 4,
                                                      children: [
                                                        Text(
                                                          participationBundle
                                                              .participation.invitationEmail,
                                                          style: Theme.of(context)
                                                              .textTheme
                                                              .bodyMedium,
                                                        ),
                                                        if (participationBundle
                                                                .participant.deletedAt !=
                                                            null)
                                                          Text(
                                                            'Deleted account',
                                                            style: Theme.of(context)
                                                                .textTheme
                                                                .labelLarge
                                                                ?.copyWith(
                                                                    color: Theme.of(context)
                                                                        .colorScheme
                                                                        .error),
                                                          ),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                                if (index == outParticipationsBundles.length - 1)
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
                  }
                },
              ),
            ),
          ),
          floatingActionButton: FilledButton(
            onPressed: () async {
              _showInviteDialog(context: context, contestId: contestId);
            },
            child: Text('Invite'),
          ),
        );
      },
    );
  }
}

void _showInviteDialog({required BuildContext context, required String contestId}) {
  final organizerContestDetailsPageBloc = context.read<OrganizerContestDetailsPageBloc>();
  showDialog(
    context: context,
    builder: (context) {
      final invitationFormKey = GlobalKey<FormState>();
      final emailController = TextEditingController();
      return BlocProvider.value(
        value: organizerContestDetailsPageBloc,
        child: BlocConsumer<OrganizerContestDetailsPageBloc, OrganizerContestDetailsPageState>(
          listener: (context, state) {
            if (state.status.isSuccess &&
                state.sourceEvent is OrganizerContestDetailsPageSendParticipantInvite) {
              showSnackBar(context: context, text: 'Email sent successfully');
              context
                  .read<OrganizerContestDetailsPageBloc>()
                  .add(OrganizerContestDetailsPageRefresh(contestId: contestId));
              context.pop();
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
                      label: 'Email',
                      validator: emailValidator,
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    context.pop();
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
              context.pop();
              showSnackBar(context: context, text: 'Participant removed successfully');
              context
                  .read<OrganizerContestDetailsPageBloc>()
                  .add(OrganizerContestDetailsPageRefresh(contestId: contestId));
            }
          },
          builder: (context, state) {
            return AlertDialog(
              title: Text('Remove participant'),
              content: Text('Are you sure you want to remove this participant?'),
              actions: [
                TextButton(
                  onPressed: () {
                    context.pop();
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
                state.sourceEvent is OrganizerContestDetailsPageDeleteInvitation) {
              context.pop();
              showSnackBar(context: context, text: 'Invitation deleted successfully');
              context
                  .read<OrganizerContestDetailsPageBloc>()
                  .add(OrganizerContestDetailsPageRefresh(contestId: contestId));
            }
          },
          builder: (context, state) {
            return AlertDialog(
              title: Text('Delete invitation'),
              content: Text('Are you sure you want to delete this invitation?'),
              actions: [
                TextButton(
                  onPressed: () {
                    context.pop();
                  },
                  child: Text('Cancel'),
                ),
                TextButton(
                  onPressed: () {
                    context.read<OrganizerContestDetailsPageBloc>().add(
                        OrganizerContestDetailsPageDeleteInvitation(invitationId: invitationId));
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
