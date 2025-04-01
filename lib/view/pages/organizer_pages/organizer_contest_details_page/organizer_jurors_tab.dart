import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:swift_contest/model/data_models/contest/contest.dart';
import 'package:swift_contest/model/data_models/juration/juration_status.dart';
import 'package:swift_contest/model/mixed_models/juration_and_juror.dart';
import 'package:swift_contest/utils/themes/color_scheme_extension.dart';
import 'package:swift_contest/view/widgets/custom_text_form_field.dart';
import 'package:swift_contest/view/widgets/loader.dart';
import 'package:swift_contest/view/widgets/show_snack_bar.dart';
import 'package:swift_contest/viewmodel/blocs/bloc_status.dart';
import 'package:swift_contest/viewmodel/blocs/pages_blocs/organizer_contest_details_page_bloc/organizer_contest_details_page_bloc.dart';
import 'package:swift_contest/viewmodel/repositories/contest_repository.dart';
import 'package:swift_contest/viewmodel/repositories/edge_repository.dart';
import 'package:swift_contest/viewmodel/repositories/juration_repository.dart';
import 'package:swift_contest/viewmodel/repositories/participation_repository.dart';
import 'package:swift_contest/viewmodel/repositories/profile_repository.dart';
import 'package:swift_contest/viewmodel/repositories/voting_form_repository.dart';
import 'package:swift_contest/viewmodel/repositories/work_repository.dart';

class OrganizerJurorsTab extends StatefulWidget {
  final String contestId;

  const OrganizerJurorsTab({super.key, required this.contestId});

  @override
  State<OrganizerJurorsTab> createState() => _OrganizerJurorsTabState();
}

class _OrganizerJurorsTabState extends State<OrganizerJurorsTab> {
  late final String contestId;
  Contest? contest;

  @override
  void initState() {
    super.initState();
    contestId = widget.contestId;
    // final state = context.read<OrganizerContestDetailsPageBloc>().state;
    // if(state.status.isInitial ||state.contest == null) {
    //   context.read<OrganizerContestDetailsPageBloc>().add(OrganizerContestDetailsPageGetExtendedContest(contestId: contestId));
    // }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final state = context.read<OrganizerContestDetailsPageBloc>().state;
    if(state.status.isInitial || state.contest == null) {
      context.read<OrganizerContestDetailsPageBloc>().add(OrganizerContestDetailsPageGetExtendedContest(contestId: contestId));
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
        if (state.status.isLoading) {
          return Loader();
        }
        if (state.status.isSuccess) {
          contest = state.contest!;
          final invitationFormKey = GlobalKey<FormState>();
          String? email;

          final List<JurationAndJuror> jurationsAndJurorsJoined = [];
          final List<JurationAndJuror> jurationsAndJurorsAttended = [];
          final List<JurationAndJuror> jurationsAndJurorsLeft = [];

          for (var i = 0; i < state.jurations!.length; i++) {
            final juration = state.jurations![i];
            final juror = state.jurors![i];
            switch (juration.status) {
              case JurationStatus.joined:
                jurationsAndJurorsJoined.add(JurationAndJuror(juration: juration, juror: juror));
                break;
              case JurationStatus.attended:
                jurationsAndJurorsAttended.add(JurationAndJuror(juration: juration, juror: juror));
                break;
              case JurationStatus.left:
                jurationsAndJurorsLeft.add(JurationAndJuror(juration: juration, juror: juror));
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
                      'Jurors',
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
                          (jurationsAndJurorsJoined.isEmpty)
                              ? RefreshIndicator.adaptive(
                                  onRefresh: () async => context
                                      .read<OrganizerContestDetailsPageBloc>()
                                      .add(OrganizerContestDetailsPageGetExtendedContest(
                                          contestId: widget.contestId)),
                                  child: ListView(children: [Text('No juror joined yet')]))
                              : RefreshIndicator.adaptive(
                                  onRefresh: () async => context
                                      .read<OrganizerContestDetailsPageBloc>()
                                      .add(OrganizerContestDetailsPageGetExtendedContest(
                                          contestId: widget.contestId)),
                                  child: ListView.builder(
                                    itemCount: jurationsAndJurorsJoined.length,
                                    itemBuilder: (context, index) {
                                      if (jurationsAndJurorsJoined[index].juration.status ==
                                          JurationStatus.joined) {
                                        return Container(
                                          decoration: BoxDecoration(
                                            border: Border(
                                              // top: BorderSide(color: Colors.grey),
                                              bottom: BorderSide(color: Colors.grey),
                                            ),
                                          ),
                                          child: ListTile(
                                            title: Text(
                                                '${jurationsAndJurorsJoined[index].juror!.firstName} '
                                                '${jurationsAndJurorsJoined[index].juror!.lastName}'),
                                            subtitle: Text(
                                                'Invite email: ${jurationsAndJurorsJoined[index].juration.inviteEmail}'),
                                          ),
                                        );
                                      }
                                      return SizedBox.shrink();
                                    },
                                  ),
                                ),
                          //* Attended
                          (jurationsAndJurorsAttended.isEmpty)
                              ? RefreshIndicator.adaptive(
                                  onRefresh: () async => context
                                      .read<OrganizerContestDetailsPageBloc>()
                                      .add(OrganizerContestDetailsPageGetExtendedContest(
                                          contestId: widget.contestId)),
                                  child:
                                      ListView(children: [Text('No juror attended. Invite one')]))
                              : RefreshIndicator.adaptive(
                                  onRefresh: () async => context
                                      .read<OrganizerContestDetailsPageBloc>()
                                      .add(OrganizerContestDetailsPageGetExtendedContest(
                                          contestId: widget.contestId)),
                                  child: ListView.builder(
                                    itemCount: jurationsAndJurorsAttended.length,
                                    itemBuilder: (context, index) {
                                      if (jurationsAndJurorsAttended[index].juration.status ==
                                          JurationStatus.attended) {
                                        return Container(
                                          decoration: BoxDecoration(
                                            border: Border(
                                              // top: BorderSide(color: Colors.grey),
                                              bottom: BorderSide(color: Colors.grey),
                                            ),
                                          ),
                                          child: ListTile(
                                            title: Text(jurationsAndJurorsAttended[index]
                                                .juration
                                                .inviteEmail),
                                          ),
                                        );
                                      }
                                      return SizedBox.shrink();
                                    },
                                  ),
                                ),
                          //* Left
                          (jurationsAndJurorsLeft.isEmpty)
                              ? RefreshIndicator.adaptive(
                                  onRefresh: () async => context
                                      .read<OrganizerContestDetailsPageBloc>()
                                      .add(OrganizerContestDetailsPageGetExtendedContest(
                                          contestId: widget.contestId)),
                                  child: ListView(children: [Text('No juror left')]))
                              : RefreshIndicator.adaptive(
                                  onRefresh: () async => context
                                      .read<OrganizerContestDetailsPageBloc>()
                                      .add(OrganizerContestDetailsPageGetExtendedContest(
                                          contestId: widget.contestId)),
                                  child: ListView.builder(
                                    itemCount: jurationsAndJurorsLeft.length,
                                    itemBuilder: (context, index) {
                                      if (jurationsAndJurorsLeft[index].juration.status ==
                                          JurationStatus.left) {
                                        return Container(
                                          decoration: BoxDecoration(
                                            border: Border(
                                              // top: BorderSide(color: Colors.grey),
                                              bottom: BorderSide(color: Colors.grey),
                                            ),
                                          ),
                                          child: ListTile(
                                            title: Text(
                                                '${jurationsAndJurorsLeft[index].juror!.firstName} ${jurationsAndJurorsLeft[index].juror!.lastName}'),
                                            subtitle: Text(
                                                'Invite email: ${jurationsAndJurorsLeft[index].juration.inviteEmail}'),
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
                            'Invite a juror',
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
                              create: (context) => OrganizerContestDetailsPageBloc(
                                participationRepository: context.read<ParticipationRepository>(),
                                jurationRepository: context.read<JurationRepository>(),
                                edgeRepository: context.read<EdgeRepository>(),
                                profileRepository: context.read<ProfileRepository>(),
                                contestRepository: context.read<ContestRepository>(),
                                workRepository: context.read<WorkRepository>(),
                                votingFormRepository: context.read<VotingFormRepository>(),
                              ),
                              child: BlocConsumer<OrganizerContestDetailsPageBloc,
                                  OrganizerContestDetailsPageState>(
                                listener: (context, state) {
                                  if (state.status.isSuccess) {
                                    context.pop();
                                    showSnackBar(context: context, text: 'Email sent successfully');
                                  }
                                  if (state.status.isFailure) {
                                    showSnackBar(
                                        context: context,
                                        text: 'Email not sent. Error: ${state.message}');
                                  }
                                },
                                builder: (context, state) {
                                  if (state.status.isLoading) {
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
                                                .add(OrganizerContestDetailsPageSendJurorInvite(
                                                  contest: contest!,
                                                  email: email!,
                                                ));
                                            // context.pop();
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
        return RefreshIndicator.adaptive(
          onRefresh: () async {
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
