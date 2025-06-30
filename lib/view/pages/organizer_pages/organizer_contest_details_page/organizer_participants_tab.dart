import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:swift_contest/model/bundles/participation_bundle.dart';
import 'package:swift_contest/model/data_models/invitation.dart';
import 'package:swift_contest/view/widgets/show_snack_bar.dart';
import 'package:swift_contest/view/widgets/custom_text_form_field.dart';
import 'package:swift_contest/view/widgets/loader.dart';
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
  Widget build(BuildContext context) {
    return BlocListener<OrganizerContestDetailsPageBloc, OrganizerContestDetailsPageState>(
      listener: (context, state) {
        if (state.status.isSuccess &&
            state.sourceEvent is OrganizerContestDetailsPageDeleteInvitation) {
          showSnackBar(context: context, text: 'Invitation deleted successfully');
          context
              .read<OrganizerContestDetailsPageBloc>()
              .add(OrganizerContestDetailsPageRefresh(contestId: contestId));
        }
        if (state.status.isSuccess &&
            state.sourceEvent is OrganizerContestDetailsPageRemoveParticipant) {
          showSnackBar(context: context, text: 'Participant removed successfully');
          context
              .read<OrganizerContestDetailsPageBloc>()
              .add(OrganizerContestDetailsPageRefresh(contestId: contestId));
        }
      },
      child: Scaffold(
        body: SafeArea(
          child: DefaultTabController(
            length: 3,
            child: BlocBuilder<OrganizerContestDetailsPageBloc, OrganizerContestDetailsPageState>(
              builder: (context, state) {
                switch (state.status) {
                  case BlocStatus.initial:
                    return SizedBox.shrink();
                  case BlocStatus.loading:
                    return Loader();
                  case BlocStatus.failure:
                    if (state.sourceEvent is OrganizerContestDetailsPageInit) {
                      return RefreshIndicator.adaptive(
                        onRefresh: () async => context
                            .read<OrganizerContestDetailsPageBloc>()
                            .add(OrganizerContestDetailsPageInit(contestId: contestId)),
                        child: ListView(),
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
                      // mainAxisSize: MainAxisSize.min,
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
                                    .add(OrganizerContestDetailsPageRefresh(contestId: contestId)),
                                child: (joinedParticipationsBundles.isEmpty)
                                    ? LayoutBuilder(
                                        builder: (context, constraints) {
                                          return ListView(
                                            children: [
                                              SizedBox(
                                                height: constraints.maxHeight,
                                                child: Center(
                                                  child: Text(
                                                    'No participant joined yet',
                                                  ),
                                                ),
                                              )
                                            ],
                                          );
                                        },
                                      )
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
                                                      final contestDetailsBundle =
                                                      state.contestDetailsBundle!;
                                                      final messageTitle = 'Out from contest';
                                                      final messageBody = 'You have been expelled from'
                                                          ' "${contestDetailsBundle.contest.name}"'
                                                          ' by "${contestDetailsBundle.organizer.fullName}".';
                                                      context
                                                          .read<OrganizerContestDetailsPageBloc>()
                                                          .add(
                                                          OrganizerContestDetailsPageRemoveParticipant(
                                                            participationId:
                                                            participationBundle.participation.id,
                                                            messageTitle: messageTitle,
                                                            messageBody: messageBody,
                                                          ));
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
                                                  subtitle: Column(
                                                    mainAxisSize: MainAxisSize.min,
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    mainAxisAlignment: MainAxisAlignment.start,
                                                    spacing: 4,
                                                    children: [
                                                      Text(
                                                        participationBundle
                                                            .participation.invitationEmail,
                                                        style: Theme.of(context).textTheme.bodyMedium,
                                                      ),
                                                      if (participationBundle.participant.deletedAt !=
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
                                                SizedBox(height: 64),
                                            ],
                                          );
                                        },
                                      ),
                              ),
                              //* Attended
                              RefreshIndicator.adaptive(
                                onRefresh: () async => context
                                    .read<OrganizerContestDetailsPageBloc>()
                                    .add(OrganizerContestDetailsPageRefresh(contestId: contestId)),
                                child: (participantsInvitations.isEmpty)
                                    ? LayoutBuilder(
                                        builder: (context, constraints) {
                                          return ListView(
                                            children: [
                                              SizedBox(
                                                height: constraints.maxHeight,
                                                child: Center(
                                                  child: Text(
                                                    'No participant attended',
                                                  ),
                                                ),
                                              )
                                            ],
                                          );
                                        },
                                      )
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
                                                    style: Theme.of(context).textTheme.titleMedium,
                                                  ),
                                                  trailing: IconButton(
                                                    onPressed: () {
                                                      context.read<OrganizerContestDetailsPageBloc>().add(
                                                          OrganizerContestDetailsPageDeleteInvitation(
                                                              invitationId: invitation.id));
                                                    },
                                                    icon: Icon(
                                                      Icons.remove,
                                                      color: Theme.of(context).colorScheme.error,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              if (index == participantsInvitations.length - 1)
                                                SizedBox(height: 64),
                                            ],
                                          );
                                        },
                                      ),
                              ),
                              //* Out
                              RefreshIndicator.adaptive(
                                onRefresh: () async => context
                                    .read<OrganizerContestDetailsPageBloc>()
                                    .add(OrganizerContestDetailsPageRefresh(contestId: contestId)),
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
                                                    style: Theme.of(context).textTheme.titleMedium,
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
                                                        style: Theme.of(context).textTheme.bodyMedium,
                                                      ),
                                                      if (participationBundle.participant.deletedAt !=
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
                                                SizedBox(height: 64),
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
            final bool? res = await _showInviteDialog(context: context, contestId: contestId);
            if (res == true) {
              if (context.mounted) {
                context
                    .read<OrganizerContestDetailsPageBloc>()
                    .add(OrganizerContestDetailsPageRefresh(contestId: contestId));
              }
            }
          },
          child: Text('Invite'),
        ),
      ),
    );
  }
}

Future<bool?> _showInviteDialog({required BuildContext context, required String contestId}) async {
  final organizerContestDetailsPageBloc = context.read<OrganizerContestDetailsPageBloc>();
  return await showDialog(
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
              context.pop(true);
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
                    (!state.status.isLoading)
                        ? CustomTextFormFieldUnderlined(
                            controller: emailController,
                            label: 'Email',
                            validator: _emailValidator,
                          )
                        : Loader(),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: (!state.status.isLoading)
                      ? () {
                          context.pop();
                        }
                      : null,
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: (!state.status.isLoading)
                      ? () {
                          if (invitationFormKey.currentState?.validate() ?? false) {
                            context
                                .read<OrganizerContestDetailsPageBloc>()
                                .add(OrganizerContestDetailsPageSendParticipantInvite(
                                  contestId: contestId,
                                  email: emailController.text.trim(),
                                ));
                          }
                        }
                      : null,
                  child: const Text('Ok'),
                ),
              ],
            );
          },
        ),
      );
    },
  );
}

//* Email validator
String? _emailValidator(String? value) {
  String? valueTrm = value?.trim();
  if (valueTrm == null || valueTrm.isEmpty) {
    return 'Please enter your email';
  }
  final emailRegex = RegExp(
    r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
  );
  if (!emailRegex.hasMatch(valueTrm)) {
    return 'Please enter a valid email';
  }
  return null;
}
