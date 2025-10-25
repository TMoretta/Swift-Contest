import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:swift_contest/view/pages/participant_pages/participant_contest_details_page/participant_details_tab.dart';
import 'package:swift_contest/view/pages/participant_pages/participant_contest_details_page/participant_rankings_tab.dart';
import 'package:swift_contest/view/pages/participant_pages/participant_contest_details_page/participant_work_tab.dart';
import 'package:swift_contest/view/widgets/custom_app_bar.dart';
import 'package:swift_contest/view/widgets/overlay_loader.dart';
import 'package:swift_contest/view/widgets/show_snack_bar.dart';
import 'package:swift_contest/view/widgets/void_widget.dart';
import 'package:swift_contest/viewmodel/blocs/pages_blocs/participant_contest_details_page_bloc/participant_contest_details_page_bloc.dart';
import 'package:swift_contest/viewmodel/types/bloc_status.dart';

@RoutePage()
class ParticipantContestDetailsPage extends StatefulWidget implements AutoRouteWrapper {
  final String contestId;

  const ParticipantContestDetailsPage({
    @PathParam('contestId') required this.contestId,
    super.key,
  });

  @override
  State<ParticipantContestDetailsPage> createState() => _ParticipantContestDetailsPageState();

  @override
  Widget wrappedRoute(BuildContext context) {
    return BlocProvider<ParticipantContestDetailsPageBloc>(
      create: (context) => ParticipantContestDetailsPageBloc(
        participantRepository: context.read(),
        storageRepository: context.read(),
      ),
      child: this,
    );
  }
}

class _ParticipantContestDetailsPageState extends State<ParticipantContestDetailsPage> {
  late final String contestId;

  @override
  void initState() {
    super.initState();
    contestId = widget.contestId;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    context
        .read<ParticipantContestDetailsPageBloc>()
        .add(ParticipantContestDetailsPageFetch(contestId: contestId));
  }

  @override
  void dispose() {
    context.hideLoader();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ParticipantContestDetailsPageBloc, ParticipantContestDetailsPageState>(
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
              Builder(
                builder: (context) {
                  if (!state.isInitialized) {
                    return const VoidWidget();
                  }
                  return _Menu(
                    contestId: contestId
                  );
                },
              ),
            ],
          ),
          body: SafeArea(
            child: Padding(
              padding: const EdgeInsets.only(top: 16,left: 16,right: 16),
              child: DefaultTabController(
                length: 3,
                child: Column(
                  children: [
                    const SizedBox(height: 16),
                    if (state.isInitialized)
                      const TabBar(
                        isScrollable: true,
                        tabAlignment: TabAlignment.center,
                        indicatorSize: TabBarIndicatorSize.label,
                        tabs: [
                          Tab(text: 'Details'),
                          Tab(text: 'Work'),
                          Tab(text: 'Rankings'),
                        ],
                      ),
                    const SizedBox(height: 16),
                    Expanded(
                      child: TabBarView(
                        physics: const NeverScrollableScrollPhysics(),
                        children: [
                          ParticipantDetailsTab(contestId: contestId),
                          ParticipantWorkTab(contestId: contestId),
                          ParticipantRankingsTab(contestId: contestId),
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
            final participantContestDetailsPageBloc =
                context.read<ParticipantContestDetailsPageBloc>();
            showDialog(
              context: context,
              builder: (context) {
                return BlocProvider.value(
                  value: participantContestDetailsPageBloc,
                  child: BlocConsumer<ParticipantContestDetailsPageBloc,
                      ParticipantContestDetailsPageState>(
                    listener: (context, state) {
                      if (state.status.isSuccess &&
                          state.sourceEvent is ParticipantContestDetailsPageLeaveContest) {
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
                              context.read<ParticipantContestDetailsPageBloc>().add(
                                  ParticipantContestDetailsPageLeaveContest(
                                      contestId: contestId));
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
