import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:swift_contest/view/pages/juror_pages/juror_contest_details_page/juror_details_tab.dart';
import 'package:swift_contest/view/pages/juror_pages/juror_contest_details_page/juror_voting_tab.dart';
import 'package:swift_contest/view/widgets/custom_app_bar.dart';
import 'package:swift_contest/view/widgets/overlay_loader.dart';
import 'package:swift_contest/view/widgets/show_snack_bar.dart';
import 'package:swift_contest/view/widgets/void_widget.dart';
import 'package:swift_contest/viewmodel/blocs/auth_bloc/auth_bloc.dart';
import 'package:swift_contest/viewmodel/blocs/pages_blocs/juror_contest_details_page_bloc/juror_contest_details_page_bloc.dart';
import 'package:swift_contest/viewmodel/enums/bloc_status.dart';

class JurorContestDetailsPage extends StatefulWidget {
  final String contestId;

  const JurorContestDetailsPage({required this.contestId, super.key});

  @override
  State<JurorContestDetailsPage> createState() => _JurorContestDetailsPageState();
}

class _JurorContestDetailsPageState extends State<JurorContestDetailsPage> {
  
  late String profileId;
  late String contestId;

  @override
  void initState() {
    super.initState();
    contestId = widget.contestId;
    profileId = context.read<AuthBloc>().state.profile!.id;
  }

  @override
  void dispose() {
    context.hideLoader();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<JurorContestDetailsPageBloc, JurorContestDetailsPageState>(
      listener: (context, state) {
        if (state.message != null) {
          showSnackBar(context: context, text: state.message!);
        }
        if(state.status.isLoading) {
          context.showLoader();
        } else {
          context.hideLoader();
        }
        if (state.status.isSuccess && state.sourceEvent is JurorContestDetailsPageLeaveContest) {
          context.pop(true);
        }
      },
      child: Scaffold(
        appBar: CustomAppBar(
          title: 'Joined contest',
          actions: [
            BlocBuilder<JurorContestDetailsPageBloc, JurorContestDetailsPageState>(
              builder: (context, state) {
                switch (state.status) {
                  case BlocStatus.initial:
                    return VoidWidget();
                  case (BlocStatus.loading || BlocStatus.failure):
                    if (state.sourceEvent is JurorContestDetailsPageInit) {
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
                  BlocBuilder<JurorContestDetailsPageBloc, JurorContestDetailsPageState>(
                    builder: (context, state) {
                      switch (state.status) {
                        case BlocStatus.initial:
                          return VoidWidget();
                        case (BlocStatus.loading || BlocStatus.failure):
                          if (state.sourceEvent is JurorContestDetailsPageInit) {
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
                                Tab(text: 'Voting'),
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
                        JurorDetailsTab(contestId: contestId),
                        JurorVotingTab(contestId: contestId),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
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
            final jurorContestDetailsPageBloc = context.read<JurorContestDetailsPageBloc>();
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
                        jurorContestDetailsPageBloc.add(JurorContestDetailsPageLeaveContest(
                            contestId: contestId, jurorId: profileId));
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
