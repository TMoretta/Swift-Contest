import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:swift_contest/view/pages/participant_pages/participant_contest_details_page/participant_details_tab.dart';
import 'package:swift_contest/view/pages/participant_pages/participant_contest_details_page/participant_work_tab.dart';
import 'package:swift_contest/view/widgets/custom_app_bar.dart';
import 'package:swift_contest/view/widgets/obscured_loader.dart';
import 'package:swift_contest/view/widgets/show_snack_bar.dart';
import 'package:swift_contest/viewmodel/blocs/auth_bloc/auth_bloc.dart';
import 'package:swift_contest/viewmodel/blocs/pages_blocs/participant_contest_details_page_bloc/participant_contest_details_page_bloc.dart';
import 'package:swift_contest/viewmodel/enums/bloc_status.dart';
import 'package:swift_contest/view/widgets/void_widget.dart';

class ParticipantContestDetailsPage extends StatefulWidget {
  final String contestId;

  const ParticipantContestDetailsPage({required this.contestId, super.key});

  @override
  State<ParticipantContestDetailsPage> createState() => _ParticipantContestDetailsPageState();
}

class _ParticipantContestDetailsPageState extends State<ParticipantContestDetailsPage> {
  late String profileId;
  late final String contestId;

  @override
  void initState() {
    super.initState();
    contestId = widget.contestId;
    profileId = context.read<AuthBloc>().state.profile!.id;
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<ParticipantContestDetailsPageBloc, ParticipantContestDetailsPageState>(
      listener: (context, state) {
        if (state.message != null) {
          showSnackBar(context: context, text: state.message!);
        }
        if (state.status.isSuccess &&
            state.sourceEvent is ParticipantContestDetailsPageLeaveContest) {
          context.pop(true);
        }
      },
      child: Stack(
        children: [
          Scaffold(
            appBar: CustomAppBar(
              title: 'Joined contest',
              actions: [
                BlocBuilder<ParticipantContestDetailsPageBloc, ParticipantContestDetailsPageState>(
                  builder: (context, state) {
                    switch (state.status) {
                      case BlocStatus.initial:
                        return VoidWidget();
                      case (BlocStatus.loading || BlocStatus.failure):
                        if (state.sourceEvent is ParticipantContestDetailsPageInit) {
                          return VoidWidget();
                        } else {
                          continue successCase;
                        }
                      successCase:
                      case BlocStatus.success:
                        return _Menu(
                          contestId: contestId,
                          profileId: profileId,
                        );
                    }
                  },
                ),
              ],
            ),
            body: SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: DefaultTabController(
                  length: 2,
                  child: Column(
                    children: [
                      SizedBox(height: 16),
                      BlocBuilder<ParticipantContestDetailsPageBloc,
                          ParticipantContestDetailsPageState>(
                        builder: (context, state) {
                          switch (state.status) {
                            case BlocStatus.initial:
                              return VoidWidget();
                            case (BlocStatus.loading || BlocStatus.failure):
                              if (state.sourceEvent is ParticipantContestDetailsPageInit) {
                                return VoidWidget();
                              } else {
                                continue successCase;
                              }
                            successCase:
                            case BlocStatus.success:
                              return Card(
                                shape:
                                    RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                elevation: 0.6,
                                child: TabBar(
                                  labelColor: Theme.of(context).colorScheme.onPrimary,
                                  isScrollable: false,
                                  dividerColor: Colors.transparent,
                                  tabAlignment: TabAlignment.center,
                                  splashBorderRadius: BorderRadius.circular(16),
                                  indicatorSize: TabBarIndicatorSize.tab,
                                  indicator: BoxDecoration(
                                    borderRadius: BorderRadius.circular(16),
                                    color: Theme.of(context).colorScheme.primary,
                                  ),
                                  tabs: [
                                    Tab(text: 'Details'),
                                    Tab(text: 'Work'),
                                    // Tab(text: 'Voting'),
                                  ],
                                ),
                              );
                          }
                        },
                      ),
                      SizedBox(height: 16),
                      Expanded(
                        child: TabBarView(
                          physics: NeverScrollableScrollPhysics(),
                          children: [
                            ParticipantDetailsTab(contestId: contestId),
                            ParticipantWorkTab(contestId: contestId),
                            // ParticipantVotingTab(contestId: contestId),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          BlocBuilder<ParticipantContestDetailsPageBloc, ParticipantContestDetailsPageState>(
            builder: (context, state) {
              if (state.status.isLoading) {
                return ObscuredLoader();
              }
              return VoidWidget();
            },
          )
        ],
      ),
    );
  }
}

class _Menu extends StatelessWidget {
  final String contestId;
  final String profileId;

  const _Menu({required this.contestId, required this.profileId});

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      icon: const Icon(Icons.more_vert),
      menuPadding: EdgeInsets.symmetric(vertical: 4),
      onSelected: (option) async {
        switch (option) {
          case 'Leave':
            final participantContestDetailsPageBloc =
                context.read<ParticipantContestDetailsPageBloc>();
            showDialog(
              context: context,
              builder: (context) {
                return AlertDialog(
                  title: Text('Leave contest'),
                  content: Text('Are you sure you want to leave the contest? '
                      'The organizer will be notified'),
                  actions: [
                    TextButton(
                      onPressed: () {
                        context.pop();
                      },
                      child: Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: () {
                        participantContestDetailsPageBloc.add(
                            ParticipantContestDetailsPageLeaveContest(
                                contestId: contestId, participantId: profileId));
                        context.pop();
                      },
                      child: Text('Proceed'),
                    ),
                  ],
                );
              },
            );
            break;
        }
      },
      itemBuilder: (context) => <PopupMenuEntry<String>>[
        PopupMenuItem(
          value: 'Leave',
          child: ListTile(
            leading: Icon(
              Icons.logout_rounded,
              color: Theme.of(context).colorScheme.error,
            ),
            title: Text(
              'Leave',
              style: Theme.of(context)
                  .textTheme
                  .bodyLarge
                  ?.copyWith(color: Theme.of(context).colorScheme.error),
            ),
          ),
        ),
      ],
    );
  }
}
