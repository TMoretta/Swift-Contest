import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:swift_contest/model/data_models/contest/contest.dart';
import 'package:swift_contest/model/data_models/participation/participation_status.dart';
import 'package:swift_contest/model/mixed_models/participation_and_participant.dart';
import 'package:swift_contest/utils/di/di.dart';
import 'package:swift_contest/utils/themes/color_scheme_extension.dart';
import 'package:swift_contest/view/widgets/custom_text_form_field.dart';
import 'package:swift_contest/view/widgets/loader.dart';
import 'package:swift_contest/view/widgets/show_snack_bar.dart';
import 'package:swift_contest/viewmodel/blocs/organizer_pages_blocs/organizer_contest_details_page_bloc/organizer_contest_details_page_bloc.dart';
import 'package:swift_contest/viewmodel/utils/bloc_status.dart';

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
  Contest? contest;

  @override
  void initState() {
    super.initState();
    final state = context.read<OrganizerContestDetailsPageBloc>().state;
    if (state.contest == null) {
      context
          .read<OrganizerContestDetailsPageBloc>()
          .add(OrganizerContestDetailsPageGetExtendedContest(contestId: widget.contestId));
    }
  }


  @override
  Widget build(BuildContext context) {
    return BlocConsumer<OrganizerContestDetailsPageBloc, OrganizerContestDetailsPageState>(
      listener: (context, state) {
        if(state.status == BlocStatus.failure) {
          showSnackBar(context: context, text: state.message!);
        }
      },
      builder: (context, state) {
        if (state.status == BlocStatus.loading) {
          return Loader();
        }
        if (state.status == BlocStatus.success) {
          contest = state.contest!;
          final invitationFormKey = GlobalKey<FormState>();
          String? email;

          final List<ParticipationAndParticipant> participationsAndParticipantsJoined = [];
          final List<ParticipationAndParticipant> participationsAndParticipantsAttended = [];
          final List<ParticipationAndParticipant> participationsAndParticipantsLeft = [];

          for (var i = 0; i < state.participations!.length; i++) {
            final participation = state.participations![i];
            final participant = state.participants![i];
            switch (participation.status) {
              case ParticipationStatus.joined:
                participationsAndParticipantsJoined.add(
                    ParticipationAndParticipant(participation: participation, participant: participant));
                break;
              case ParticipationStatus.attended:
                participationsAndParticipantsAttended.add(
                    ParticipationAndParticipant(participation: participation, participant: participant));
                break;
              case ParticipationStatus.left:
                participationsAndParticipantsLeft.add(
                    ParticipationAndParticipant(participation: participation, participant: participant));
                break;
            }
          }

          return Stack(
            fit: StackFit.loose,
            children: [
              DefaultTabController(
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
                          (participationsAndParticipantsJoined.isEmpty)
                              ? RefreshIndicator.adaptive(
                              onRefresh: () async => context
                                  .read<OrganizerContestDetailsPageBloc>()
                                  .add(OrganizerContestDetailsPageGetExtendedContest(
                                  contestId: widget.contestId)),
                              child: ListView(children: [Text('No participant joined yet.')]))
                              : RefreshIndicator.adaptive(
                            onRefresh: () async => context
                                .read<OrganizerContestDetailsPageBloc>()
                                .add(OrganizerContestDetailsPageGetExtendedContest(
                                contestId: widget.contestId)),
                            child: ListView.builder(
                              itemCount: participationsAndParticipantsJoined.length,
                              itemBuilder: (context, index) {
                                if (participationsAndParticipantsJoined[index]
                                    .participation
                                    .status ==
                                    ParticipationStatus.joined) {
                                  return Container(
                                    decoration: BoxDecoration(
                                      border: Border(
                                        // top: BorderSide(color: Colors.grey),
                                        bottom: BorderSide(color: Colors.grey),
                                      ),
                                    ),
                                    child: ListTile(
                                      title: Text(
                                          '${participationsAndParticipantsJoined[index].participant!.firstName} '
                                              '${participationsAndParticipantsJoined[index].participant!.lastName}'),
                                      subtitle: Text(
                                          'Invite email: ${participationsAndParticipantsJoined[index].participation.inviteEmail}'),
                                    ),
                                  );
                                }
                                return SizedBox.shrink();
                              },
                            ),
                          ),

                          //* Attended
                          (participationsAndParticipantsAttended.isEmpty)
                              ? RefreshIndicator.adaptive(
                              onRefresh: () async => context
                                  .read<OrganizerContestDetailsPageBloc>()
                                  .add(OrganizerContestDetailsPageGetExtendedContest(
                                  contestId: widget.contestId)),
                              child:
                              ListView(children: [Text('No participant attended. Invite one')]))
                              : RefreshIndicator.adaptive(
                            onRefresh: () async => context
                                .read<OrganizerContestDetailsPageBloc>()
                                .add(OrganizerContestDetailsPageGetExtendedContest(
                                contestId: widget.contestId)),
                            child: ListView.builder(
                              itemCount: participationsAndParticipantsAttended.length,
                              itemBuilder: (context, index) {
                                if (participationsAndParticipantsAttended[index]
                                    .participation
                                    .status ==
                                    ParticipationStatus.attended) {
                                  return Container(
                                    decoration: BoxDecoration(
                                      border: Border(
                                        // top: BorderSide(color: Colors.grey),
                                        bottom: BorderSide(color: Colors.grey),
                                      ),
                                    ),
                                    child: ListTile(
                                      title: Text(participationsAndParticipantsAttended[index]
                                          .participation
                                          .inviteEmail),
                                    ),
                                  );
                                }
                                return SizedBox.shrink();
                              },
                            ),
                          ),

                          //* Left
                          (participationsAndParticipantsLeft.isEmpty)
                              ? RefreshIndicator.adaptive(
                              onRefresh: () async => context
                                  .read<OrganizerContestDetailsPageBloc>()
                                  .add(OrganizerContestDetailsPageGetExtendedContest(
                                  contestId: widget.contestId)),
                              child: ListView(children: [Text('No participant left')]))
                              : RefreshIndicator.adaptive(
                            onRefresh: () async => context
                                .read<OrganizerContestDetailsPageBloc>()
                                .add(OrganizerContestDetailsPageGetExtendedContest(
                                contestId: widget.contestId)),
                            child: ListView.builder(
                              itemCount: participationsAndParticipantsLeft.length,
                              itemBuilder: (context, index) {
                                if (participationsAndParticipantsLeft[index].participation.status ==
                                    ParticipationStatus.left) {
                                  return Container(
                                    decoration: BoxDecoration(
                                      border: Border(
                                        // top: BorderSide(color: Colors.grey),
                                        bottom: BorderSide(color: Colors.grey),
                                      ),
                                    ),
                                    child: ListTile(
                                      title: Text(
                                          '${participationsAndParticipantsLeft[index].participant!.firstName} ${participationsAndParticipantsLeft[index].participant!.lastName}'),
                                      subtitle: Text(
                                          'Invite email: ${participationsAndParticipantsLeft[index].participation.inviteEmail}'),
                                    ),
                                  );
                                }
                                return SizedBox.shrink();
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
              Positioned(
                bottom: 0,
                right: 0,
                child: FilledButton(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (context) {
                        return AlertDialog(
                          title: Text(
                            'Invite a participant',
                          ),
                          content: Form(
                            key: invitationFormKey,
                            child: CustomTextFormFieldUnderlined(
                              label: 'Email',
                              onChanged: (value) => email = value,
                              validator: _emailValidator,
                            ),
                          ),
                          actions: [
                            BlocProvider<OrganizerContestDetailsPageBloc>(
                              create: (context) => getIt<OrganizerContestDetailsPageBloc>(),
                              child: BlocConsumer<OrganizerContestDetailsPageBloc,
                                  OrganizerContestDetailsPageState>(
                                listener: (context, state) {
                                  if (state.status == BlocStatus.success) {
                                    context.pop();
                                    showSnackBar(context: context, text: 'Email sent successfully');
                                  }
                                  if (state.status == BlocStatus.failure) {
                                    showSnackBar(
                                        context: context,
                                        text: 'Email not sent. Error: ${state.message}');
                                  }
                                },
                                builder: (context, state) {
                                  if (state.status == BlocStatus.loading) {
                                    return Loader();
                                  }
                                  return Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
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
                                              contest: contest!,
                                              email: email!,
                                            ));
                                          }
                                        },
                                        child: const Text('Ok'),
                                      ),
                                    ],
                                  );
                                },
                              ),
                            ),
                          ],
                        );
                      },
                    );
                  },
                  child: Text('Invite'),
                ),
              ),
            ],
          );
        }
        return RefreshIndicator.adaptive(onRefresh: () async {
          context
              .read<OrganizerContestDetailsPageBloc>()
              .add(OrganizerContestDetailsPageGetExtendedContest(contestId: widget.contestId));
        },
          child: ListView(),
        );
      },
    );
  }
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
