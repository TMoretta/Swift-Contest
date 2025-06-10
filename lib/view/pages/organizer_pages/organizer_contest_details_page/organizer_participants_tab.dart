import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:swift_contest/model/bundles/participation_bundle.dart';
import 'package:swift_contest/model/data_models/contest.dart';
import 'package:swift_contest/model/data_models/invitation.dart';
import 'package:swift_contest/utils/functions/show_snack_bar.dart';
import 'package:swift_contest/utils/themes/color_scheme_x.dart';
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
  Contest? contest;

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
    return BlocConsumer<OrganizerContestDetailsPageBloc, OrganizerContestDetailsPageState>(
      listener: (context, state) {
        if (state.status.isFailure) {
          showSnackBar(context: context, text: state.message!);
        }
      },
      builder: (context, state) {
        switch (state.status) {
          case BlocStatus.initial:
            return Container();
          case BlocStatus.loading:
            return Loader();
          case BlocStatus.failure:
            return RefreshIndicator.adaptive(
              onRefresh: () async {
                context
                    .read<OrganizerContestDetailsPageBloc>()
                    .add(OrganizerContestDetailsPageInit(contestId: contestId));
              },
              child: ListView(),
            );
          case BlocStatus.success:
            contest = state.contestDetailsBundle!.contest;
            final List<ParticipationBundle> joinedParticipationsBundles =
                state.contestDetailsBundle!.joinedParticipationsBundles;
            final List<Invitation> participantsInvitations =
                state.contestDetailsBundle!.participantsInvitations;
            final List<ParticipationBundle> leftParticipationsBundles =
                state.contestDetailsBundle!.leftParticipationsBundles;
            return Scaffold(
              body: DefaultTabController(
                length: 3,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Participants',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                    ),
                    Align(
                      alignment: Alignment.center,
                      child: Card(
                        elevation: 0,
                        child: SizedBox(
                          height: 30,
                          child: TabBar(
                            labelColor: Theme.of(context).colorScheme.white,
                            unselectedLabelColor: Theme.of(context).colorScheme.grey7,
                            isScrollable: true,
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
                              Tab(text: 'Left'),
                            ],
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 16),
                    Expanded(
                      child: TabBarView(
                        physics: NeverScrollableScrollPhysics(),
                        children: [
                          //* Joined
                          (joinedParticipationsBundles.isEmpty)
                              ? RefreshIndicator.adaptive(
                                  onRefresh: () async => context
                                      .read<OrganizerContestDetailsPageBloc>()
                                      .add(OrganizerContestDetailsPageInit(contestId: contestId)),
                                  child: ListView(
                                    physics: AlwaysScrollableScrollPhysics(),
                                    children: [
                                      Text('No participant joined yet.'),
                                    ],
                                  ),
                                )
                              : RefreshIndicator.adaptive(
                                  onRefresh: () async => context
                                      .read<OrganizerContestDetailsPageBloc>()
                                      .add(OrganizerContestDetailsPageInit(contestId: contestId)),
                                  child: ListView.builder(
                                    physics: AlwaysScrollableScrollPhysics(),
                                    itemCount: joinedParticipationsBundles.length,
                                    itemBuilder: (context, index) {
                                      return Container(
                                        decoration: BoxDecoration(
                                          border: Border(
                                            // top: BorderSide(color: Colors.grey),
                                            bottom: BorderSide(color: Colors.grey),
                                          ),
                                        ),
                                        child: ListTile(
                                          title: Text(joinedParticipationsBundles[index]
                                              .participant
                                              .fullName),
                                        ),
                                      );
                                    },
                                  ),
                                ),

                          //* Attended
                          (participantsInvitations.isEmpty)
                              ? RefreshIndicator.adaptive(
                                  onRefresh: () async => context
                                      .read<OrganizerContestDetailsPageBloc>()
                                      .add(OrganizerContestDetailsPageInit(contestId: contestId)),
                                  child: ListView(
                                    physics: AlwaysScrollableScrollPhysics(),
                                    children: [
                                      Text('No participant attended. Invite one'),
                                    ],
                                  ),
                                )
                              : RefreshIndicator.adaptive(
                                  onRefresh: () async => context
                                      .read<OrganizerContestDetailsPageBloc>()
                                      .add(OrganizerContestDetailsPageInit(contestId: contestId)),
                                  child: ListView.builder(
                                    physics: AlwaysScrollableScrollPhysics(),
                                    itemCount: participantsInvitations.length,
                                    itemBuilder: (context, index) {
                                      return Container(
                                        decoration: BoxDecoration(
                                          border: Border(
                                            // top: BorderSide(color: Colors.grey),
                                            bottom: BorderSide(color: Colors.grey),
                                          ),
                                        ),
                                        child: ListTile(
                                          title: Text(participantsInvitations[index].email),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                          //* Left
                          (leftParticipationsBundles.isEmpty)
                              ? RefreshIndicator.adaptive(
                                  onRefresh: () async => context
                                      .read<OrganizerContestDetailsPageBloc>()
                                      .add(OrganizerContestDetailsPageInit(contestId: contestId)),
                                  child: ListView(children: [Text('No participant left')]))
                              : RefreshIndicator.adaptive(
                                  onRefresh: () async => context
                                      .read<OrganizerContestDetailsPageBloc>()
                                      .add(OrganizerContestDetailsPageInit(contestId: contestId)),
                                  child: ListView.builder(
                                    itemCount: leftParticipationsBundles.length,
                                    itemBuilder: (context, index) {
                                      return Container(
                                        decoration: BoxDecoration(
                                          border: Border(
                                            // top: BorderSide(color: Colors.grey),
                                            bottom: BorderSide(color: Colors.grey),
                                          ),
                                        ),
                                        child: ListTile(
                                          title: Text(leftParticipationsBundles[index]
                                              .participant
                                              .fullName),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                        ],
                      ),
                    ),
                    SizedBox(height: 52),
                  ],
                ),
              ),
              floatingActionButton: FilledButton(
                onPressed: () {
                  _showInviteDialog(context: context, contestId: contestId);
                },
                child: Text('Invite'),
              ),
            );
        }
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
            if (state.message != null) {
              showSnackBar(context: context, text: state.message!);
            }
            if (state.status.isSuccess &&
                state.sourceEvent is OrganizerContestDetailsPageSendParticipantInvite) {
              showSnackBar(context: context, text: 'Email sent successfully');
              context.pop();
            }
          },
          builder: (context, state) {
            switch (state.status) {
              case BlocStatus.initial:
                return SizedBox.shrink();
              case BlocStatus.loading:
                return Loader();
              case BlocStatus.failure:
              case BlocStatus.success:
                return AlertDialog(
                  title: Text(
                    'Invite a juror',
                  ),
                  content: Form(
                    key: invitationFormKey,
                    child: CustomTextFormFieldUnderlined(
                      controller: emailController,
                      label: 'Email',
                      validator: _emailValidator,
                    ),
                  ),
                  actions: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
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
                                    // context.pop();
                                  }
                                }
                              : null,
                          child: const Text('Ok'),
                        ),
                      ],
                    )
                  ],
                );
            }
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
