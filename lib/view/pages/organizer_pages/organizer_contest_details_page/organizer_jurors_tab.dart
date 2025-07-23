import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:swift_contest/model/bundles/juration_bundle.dart';
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

class OrganizerJurorsTab extends StatefulWidget {
  final String contestId;

  const OrganizerJurorsTab({required this.contestId, super.key});

  @override
  State<OrganizerJurorsTab> createState() => _OrganizerJurorsTabState();
}

class _OrganizerJurorsTabState extends State<OrganizerJurorsTab> {
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
              length: 3,
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
                      final List<JurationBundle> joinedJurationsBundles =
                          state.contestDetailsBundle!.joinedJurationsBundles;
                      final List<Invitation> jurorsInvitations =
                          state.contestDetailsBundle!.jurorsInvitations;
                      final List<JurationBundle> outJurationsBundles =
                          state.contestDetailsBundle!.outJurationsBundles;
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
                                          OrganizerContestDetailsPageFetch(contestId: contestId)),
                                  child: (joinedJurationsBundles.isEmpty)
                                      ? ListViewWithCentralLabel(label: 'No juror joined yet')
                                      : ListView.builder(
                                          itemCount: joinedJurationsBundles.length,
                                          itemBuilder: (context, index) {
                                            final jurationBundle = joinedJurationsBundles[index];
                                            return Column(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Card(
                                                  elevation: 0.2,
                                                  child: ListTile(
                                                    trailing: IconButton(
                                                      onPressed: () {
                                                        _showRemoveJurorDialog(
                                                            context: context,
                                                            contestId: contestId,
                                                            jurationId: jurationBundle.juration.id);
                                                      },
                                                      icon: Icon(
                                                        Icons.remove_circle_outline,
                                                        color: Theme.of(context).colorScheme.error,
                                                      ),
                                                    ),
                                                    title: Text(
                                                      jurationBundle.juror.fullName,
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
                                                          jurationBundle.juration.invitationEmail,
                                                          style: Theme.of(context)
                                                              .textTheme
                                                              .bodyMedium,
                                                        ),
                                                        if (jurationBundle.juror.deletedAt != null)
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
                                                if (index == joinedJurationsBundles.length - 1)
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
                                          OrganizerContestDetailsPageFetch(contestId: contestId)),
                                  child: (jurorsInvitations.isEmpty)
                                      ? ListViewWithCentralLabel(label: 'No juror attended')
                                      : ListView.builder(
                                          itemCount: jurorsInvitations.length,
                                          itemBuilder: (context, index) {
                                            final invitation = jurorsInvitations[index];
                                            return Column(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Card(
                                                  elevation: 0.2,
                                                  child: ListTile(
                                                    title: Text(invitation.email),
                                                    trailing: IconButton(
                                                      onPressed: () {
                                                        _showDeleteInvitationDialog(
                                                            context: context,
                                                            contestId: contestId,
                                                            invitationId: invitation.id);
                                                      },
                                                      icon: Icon(
                                                        Icons.remove,
                                                        color: Theme.of(context).colorScheme.error,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                if (index == jurorsInvitations.length - 1)
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
                                          OrganizerContestDetailsPageFetch(contestId: contestId)),
                                  child: (outJurationsBundles.isEmpty)
                                      ? ListViewWithCentralLabel(label: 'No juror out')
                                      : ListView.builder(
                                          itemCount: outJurationsBundles.length,
                                          itemBuilder: (context, index) {
                                            final jurationBundle = outJurationsBundles[index];
                                            return Column(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Card(
                                                  elevation: 0.2,
                                                  child: ListTile(
                                                    title: Text(jurationBundle.juror.fullName),
                                                    subtitle: Text(
                                                        jurationBundle.juration.invitationEmail),
                                                  ),
                                                ),
                                                if (index == outJurationsBundles.length - 1)
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
            onPressed: () {
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
                state.sourceEvent is OrganizerContestDetailsPageSendJurorInvite) {
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
                'Invite a juror',
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
                          .add(OrganizerContestDetailsPageSendJurorInvite(
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

void _showRemoveJurorDialog({
  required BuildContext context,
  required String contestId,
  required String jurationId,
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
                state.sourceEvent is OrganizerContestDetailsPageRemoveJuror) {
              context.router.pop();
              showSnackBar(context: context, text: 'Juror removed successfully');
              context
                  .read<OrganizerContestDetailsPageBloc>()
                  .add(OrganizerContestDetailsPageFetch(contestId: contestId));
            }
          },
          builder: (context, state) {
            return AlertDialog(
              title: Text('Remove juror'),
              content: Text('Are you sure you want to remove this juror?'),
              actions: [
                TextButton(
                  onPressed: () {
                    context.router.pop();
                  },
                  child: Text('Cancel'),
                ),
                TextButton(
                  onPressed: () {
                    context
                        .read<OrganizerContestDetailsPageBloc>()
                        .add(OrganizerContestDetailsPageRemoveJuror(jurationId: jurationId));
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
