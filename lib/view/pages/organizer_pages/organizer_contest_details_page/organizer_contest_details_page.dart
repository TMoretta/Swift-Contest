import 'package:auto_route/auto_route.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:swift_contest/utils/router/app_router.gr.dart';
import 'package:swift_contest/view/pages/organizer_pages/organizer_contest_details_page/organizer_details_tab.dart';
import 'package:swift_contest/view/pages/organizer_pages/organizer_contest_details_page/organizer_participants_tab.dart';
import 'package:swift_contest/view/pages/organizer_pages/organizer_contest_details_page/organizer_rankings_tab.dart';
import 'package:swift_contest/view/pages/organizer_pages/organizer_contest_details_page/organizer_voting_tab.dart';
import 'package:swift_contest/view/pages/organizer_pages/organizer_contest_details_page/organizer_works_tab.dart';
import 'package:swift_contest/view/widgets/custom_app_bar.dart';
import 'package:swift_contest/view/widgets/overlay_loader.dart';
import 'package:swift_contest/view/widgets/show_snack_bar.dart';
import 'package:swift_contest/viewmodel/blocs/pages_blocs/organizer_contest_details_page_bloc/organizer_contest_details_page_bloc.dart';
import 'package:swift_contest/viewmodel/types/bloc_status.dart';

import 'organizer_juries_tab.dart';

@RoutePage()
class OrganizerContestDetailsPage extends StatefulWidget implements AutoRouteWrapper {
  final String contestId;

  const OrganizerContestDetailsPage({
    @PathParam('contestId') required this.contestId,
    super.key,
  });

  @override
  State<OrganizerContestDetailsPage> createState() => _OrganizerContestDetailsPageState();

  @override
  Widget wrappedRoute(BuildContext context) {
    return BlocProvider<OrganizerContestDetailsPageBloc>(
      create: (context) => OrganizerContestDetailsPageBloc(
        organizerRepository: context.read(),
        storageRepository: context.read(),
      )..add(OrganizerContestDetailsPageFetch(contestId: contestId)),
      child: this,
    );
  }
}

class _OrganizerContestDetailsPageState extends State<OrganizerContestDetailsPage> {
  late String contestId;

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
    return BlocConsumer<OrganizerContestDetailsPageBloc, OrganizerContestDetailsPageState>(
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
              if(state.isInitialized) _Menu(contestId: contestId),
            ],
          ),
          body: SafeArea(
            child: Padding(
              padding: const EdgeInsets.only(left: 16, right: 16, top: 16),
              child: DefaultTabController(
                length: 6,
                child: Column(
                  children: [
                    if(state.isInitialized)
                      TabBar(
                        isScrollable: true,
                        tabAlignment: TabAlignment.center,
                        tabs: [
                          Tab(text: 'Details'),
                          Tab(text: 'Participants'),
                          Tab(text: 'Juries'),
                          Tab(text: 'Works'),
                          Tab(text: 'Voting'),
                          Tab(text: 'Rankings'),
                        ],
                      ),
                    SizedBox(height: 16),
                    Expanded(
                      child: TabBarView(
                        physics: NeverScrollableScrollPhysics(),
                        children: [
                          OrganizerDetailsTab(contestId: contestId),
                          OrganizerParticipantsTab(contestId: contestId),
                          OrganizerJuriesTab(contestId: contestId),
                          OrganizerWorksTab(contestId: contestId),
                          OrganizerVotingTab(contestId: contestId),
                          OrganizerRankingsTab(contestId: contestId),
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
      onSelected: (option) async {
        switch (option) {
          case 'Edit':
            if(kIsWeb) {
              context.router.navigate(OrganizerContestEditRoute(contestId: contestId));
              return;
            }
            final bool? res =
                await context.router.push(OrganizerContestEditRoute(contestId: contestId));
            if (res == true) {
              if (context.mounted) {
                context
                    .read<OrganizerContestDetailsPageBloc>()
                    .add(OrganizerContestDetailsPageFetch(contestId: contestId));
              }
            }
            break;
          case 'Delete':
            _showDeleteContestDialog(context: context, contestId: contestId);
            break;
        }
      },
      itemBuilder: (context) {
        return [
          const PopupMenuItem(
            value: 'Edit',
            child: ListTile(
              leading: Icon(Icons.edit),
              title: Text(
                'Edit',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
          PopupMenuItem(
            value: 'Delete',
            child: ListTile(
              leading: Icon(
                Icons.delete,
                color: Theme.of(context).colorScheme.error,
              ),
              title: Text(
                'Delete',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context)
                    .textTheme
                    .labelLarge
                    ?.copyWith(color: Theme.of(context).colorScheme.error),
              ),
            ),
          ),
        ];
      },
    );
  }
}

void _showDeleteContestDialog({required BuildContext context, required String contestId}) {
  final organizerContestDetailsPageBloc = context.read<OrganizerContestDetailsPageBloc>();
  showDialog(
    context: context,
    builder: (context) {
      return BlocProvider.value(
        value: organizerContestDetailsPageBloc,
        child: BlocConsumer<OrganizerContestDetailsPageBloc, OrganizerContestDetailsPageState>(
          listener: (context, state) {
            if (state.status.isSuccess &&
                state.sourceEvent is OrganizerContestDetailsPageDeleteContest) {
              showSnackBar(context: context, text: 'Contest deleted successfully');
              context.router.pop();
              context.router.pop(true);
            }
          },
          builder: (context, state) {
            return AlertDialog(
              title: Text('Delete contest'),
              content: Text('Are you sure you want to delete this contest? '
                  'All related info will be lost and members will be notified'),
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
                        .add(OrganizerContestDetailsPageDeleteContest(contestId: contestId));
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
