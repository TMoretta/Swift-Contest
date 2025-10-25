import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:swift_contest/view/pages/juror_pages/juror_contest_details_page/juror_details_tab.dart';
import 'package:swift_contest/view/pages/juror_pages/juror_contest_details_page/juror_rankings_tab.dart';
import 'package:swift_contest/view/widgets/custom_app_bar.dart';
import 'package:swift_contest/view/widgets/overlay_loader.dart';
import 'package:swift_contest/view/widgets/show_snack_bar.dart';
import 'package:swift_contest/viewmodel/blocs/pages_blocs/juror_contest_details_page_bloc/juror_contest_details_page_bloc.dart';
import 'package:swift_contest/viewmodel/types/bloc_status.dart';

@RoutePage()
class JurorContestDetailsPage extends StatefulWidget implements AutoRouteWrapper {
  final String contestId;

  const JurorContestDetailsPage({
    @PathParam('contestId') required this.contestId,
    super.key,
  });

  @override
  State<JurorContestDetailsPage> createState() => _JurorContestDetailsPageState();

  @override
  Widget wrappedRoute(BuildContext context) {
    return BlocProvider<JurorContestDetailsPageBloc>(
      create: (context) => JurorContestDetailsPageBloc(
        jurorRepository: context.read(),
        storageRepository: context.read(),
      ),
      child: this,
    );
  }
}

class _JurorContestDetailsPageState extends State<JurorContestDetailsPage> {
  late String contestId;

  @override
  void initState() {
    super.initState();
    contestId = widget.contestId;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    context
        .read<JurorContestDetailsPageBloc>()
        .add(JurorContestDetailsPageFetch(contestId: contestId));
  }

  @override
  void dispose() {
    context.hideLoader();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<JurorContestDetailsPageBloc, JurorContestDetailsPageState>(
      listener: (context, state) {
        if (state.message != null) {
          showSnackBar(context: context, text: state.message!);
        }
        if (state.status.isLoading) {
          context.showLoader();
        } else {
          context.hideLoader();
        }
      },
      builder: (context, state) {
        return Scaffold(
          appBar: CustomAppBar(
            title: state.contestDetailsBundle?.contestBundle.contest.name ?? '',
            actions: [
              if (state.isInitialized)
                _Menu(
                  contestId: contestId,
                ),
            ],
          ),
          body: SafeArea(
            child: Padding(
              padding: const EdgeInsets.only(left: 16, right: 16, top: 16),
              child: DefaultTabController(
                length: 2,
                child: Column(
                  children: [
                    if (state.isInitialized)
                      const TabBar(
                        isScrollable: true,
                        tabAlignment: TabAlignment.center,
                        indicatorSize: TabBarIndicatorSize.label,
                        tabs: [
                          Tab(text: 'Details'),
                          // Tab(text: 'Voting'),
                          Tab(text: 'Rankings'),
                        ],
                      ),
                    const SizedBox(height: 16),
                    Expanded(
                      child: TabBarView(
                        physics: const NeverScrollableScrollPhysics(),
                        children: [
                          JurorDetailsTab(contestId: contestId),
                          // JurorVotingTab(contestId: contestId),
                          JurorRankingsTab(contestId: contestId),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _Menu extends StatelessWidget {
  final String contestId;

  const _Menu({required this.contestId});

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      icon: const Icon(Icons.more_vert),
      menuPadding: const EdgeInsets.symmetric(vertical: 4),
      onSelected: (option) async {
        switch (option) {
          case 'Leave':
            final jurorContestDetailsPageBloc = context.read<JurorContestDetailsPageBloc>();
            showDialog(
              context: context,
              builder: (context) {
                return BlocProvider.value(
                  value: jurorContestDetailsPageBloc,
                  child: BlocConsumer<JurorContestDetailsPageBloc, JurorContestDetailsPageState>(
                    listener: (context, state) {
                      if (state.status.isSuccess &&
                          state.sourceEvent is JurorContestDetailsPageLeaveContest) {
                        context.router.pop();
                        context.router.pop(true);
                      }
                    },
                    builder: (context, state) {
                      return AlertDialog(
                        title: const Text('Leave contest'),
                        content: const Text('Are you sure you want to leave the contest? '
                            'The organizer will be notified'),
                        actions: [
                          TextButton(
                            onPressed: () {
                              context.router.pop();
                            },
                            child: const Text('Cancel'),
                          ),
                          TextButton(
                            onPressed: () {
                              context
                                  .read<JurorContestDetailsPageBloc>()
                                  .add(JurorContestDetailsPageLeaveContest(contestId: contestId));
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
            break;
        }
      },
      itemBuilder: (context) {
        return [
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
        ];
      },
    );
  }
}
