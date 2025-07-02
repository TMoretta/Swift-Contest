import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:swift_contest/model/enums/contest_status.dart';
import 'package:swift_contest/utils/router/go_router.dart';
import 'package:swift_contest/view/widgets/obscured_loader.dart';
import 'package:swift_contest/view/widgets/show_snack_bar.dart';
import 'package:swift_contest/view/pages/organizer_pages/organizer_contest_details_page/organizer_details_tab.dart';
import 'package:swift_contest/view/pages/organizer_pages/organizer_contest_details_page/organizer_jurors_tab.dart';
import 'package:swift_contest/view/pages/organizer_pages/organizer_contest_details_page/organizer_participants_tab.dart';
import 'package:swift_contest/view/pages/organizer_pages/organizer_contest_details_page/organizer_voting_tab.dart';
import 'package:swift_contest/view/pages/organizer_pages/organizer_contest_details_page/organizer_works_tab.dart';
import 'package:swift_contest/view/widgets/custom_app_bar.dart';
import 'package:swift_contest/viewmodel/blocs/pages_blocs/organizer_contest_details_page_bloc/organizer_contest_details_page_bloc.dart';
import 'package:swift_contest/viewmodel/enums/bloc_status.dart';
import 'package:swift_contest/view/widgets/void_widget.dart';

class OrganizerContestDetailsPage extends StatefulWidget {
  final String contestId;

  const OrganizerContestDetailsPage({required this.contestId, super.key});

  @override
  State<OrganizerContestDetailsPage> createState() => _OrganizerContestDetailsPageState();
}

class _OrganizerContestDetailsPageState extends State<OrganizerContestDetailsPage> {
  late String contestId;

  @override
  void initState() {
    super.initState();
    contestId = widget.contestId;
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<OrganizerContestDetailsPageBloc, OrganizerContestDetailsPageState>(
      listener: (context, state) {
        if (state.message != null) {
          showSnackBar(context: context, text: state.message!);
        }
      },
      child: Stack(
        children: [
          Scaffold(
            appBar: CustomAppBar(
              title: 'Your contest',
              actions: [
                BlocBuilder<OrganizerContestDetailsPageBloc, OrganizerContestDetailsPageState>(
                  builder: (context, state) {
                    switch (state.status) {
                      case BlocStatus.initial:
                        return VoidWidget();
                      case (BlocStatus.loading || BlocStatus.failure):
                        if (state.sourceEvent is OrganizerContestDetailsPageInit) {
                          return VoidWidget();
                        } else {
                          continue successCase;
                        }
                      successCase:
                      case BlocStatus.success:
                        return _Menu(contestId: contestId);
                    }
                  },
                ),
              ],
            ),
            body: SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: DefaultTabController(
                  length: 5,
                  child: Column(
                    children: [
                      SizedBox(height: 16),
                      BlocBuilder<OrganizerContestDetailsPageBloc,
                          OrganizerContestDetailsPageState>(
                        builder: (context, state) {
                            switch (state.status) {
                              case BlocStatus.initial:
                                return VoidWidget();
                              case (BlocStatus.loading || BlocStatus.failure):
                                if (state.sourceEvent is OrganizerContestDetailsPageInit) {
                                  return VoidWidget();
                                } else {
                                  continue successCase;
                                }
                              successCase:
                              case BlocStatus.success:
                                return Card(
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                  elevation: 0.6,
                                  child: TabBar(
                                    labelColor: Theme.of(context).colorScheme.onPrimary,
                                    isScrollable: true,
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
                                      Tab(text: 'Participants'),
                                      Tab(text: 'Jurors'),
                                      Tab(text: 'Works'),
                                      Tab(text: 'Voting'),
                                    ],
                                  )
                                );
                            }
                        },
                      ),
                      SizedBox(height: 16),
                      Expanded(
                        child: TabBarView(
                          physics: NeverScrollableScrollPhysics(),
                          children: [
                            OrganizerDetailsTab(contestId: contestId),
                            OrganizerParticipantsTab(contestId: contestId),
                            OrganizerJurorsTab(contestId: contestId),
                            OrganizerWorksTab(contestId: contestId),
                            OrganizerVotingTab(contestId: contestId),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          BlocBuilder<OrganizerContestDetailsPageBloc, OrganizerContestDetailsPageState>(
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

  const _Menu({required this.contestId});

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      icon: const Icon(Icons.more_vert),
      onSelected: (option) async {
        switch (option) {
          case 'Switch status':
            _showSwitchStatusDialog(context: context, contestId: contestId);
            break;
          case 'Edit':
            final bool? res =
                await context.pushNamed(AppRouter.organizerContestEdit, extra: contestId);
            if (res == true) {
              if (context.mounted) {
                context
                    .read<OrganizerContestDetailsPageBloc>()
                    .add(OrganizerContestDetailsPageRefresh(contestId: contestId));
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
            value: 'Switch status',
            child: ListTile(
              leading: Icon(Icons.circle),
              title: Text('Switch status'),
            ),
          ),
          const PopupMenuItem(
            value: 'Edit',
            child: ListTile(
              leading: Icon(Icons.edit),
              title: Text('Edit'),
            ),
          ),
          const PopupMenuItem(
            value: 'Delete',
            child: ListTile(
              leading: Icon(Icons.delete),
              title: Text('Delete'),
            ),
          ),
        ];
      },
    );
  }
}

void _showSwitchStatusDialog({required BuildContext context, required String contestId}) {
  final organizerContestDetailsPageBloc = context.read<OrganizerContestDetailsPageBloc>();
  showDialog(
    context: context,
    builder: (context) {
      return BlocProvider.value(
        value: organizerContestDetailsPageBloc,
        child: BlocConsumer<OrganizerContestDetailsPageBloc, OrganizerContestDetailsPageState>(
          listener: (context, state) {
            if (state.status.isSuccess &&
                (state.sourceEvent is OrganizerContestDetailsPageSetStatusAsActive ||
                    state.sourceEvent is OrganizerContestDetailsPageSetStatusAsTerminated)) {
              context.pop();
              organizerContestDetailsPageBloc
                  .add(OrganizerContestDetailsPageRefresh(contestId: contestId));
            }
          },
          builder: (context, state) {
            return Stack(
              children: [
                AlertDialog(
                  title: Text((state.contestDetailsBundle!.contest.contestStatus.isTerminated)
                      ? 'Set as active'
                      : 'Set as terminated'),
                  content: Text((state.contestDetailsBundle!.contest.contestStatus.isTerminated)
                      ? 'Are you sure you want to set this contest as active?'
                      : 'Are you sure you want to set this contest as terminated?'),
                  actions: [
                    TextButton(
                      onPressed: () {
                        context.pop();
                      },
                      child: Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: () {
                        if (state.contestDetailsBundle!.contest.contestStatus.isTerminated) {
                          organizerContestDetailsPageBloc.add(
                              OrganizerContestDetailsPageSetStatusAsActive(contestId: contestId));
                        } else {
                          organizerContestDetailsPageBloc.add(
                              OrganizerContestDetailsPageSetStatusAsTerminated(
                                  contestId: contestId));
                        }
                      },
                      child: Text('Proceed'),
                    ),
                  ],
                ),
                if (state.status.isLoading) ObscuredLoader(),
              ],
            );
          },
        ),
      );
    },
  );
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
              context.pop();
              context.pop(true);
            }
          },
          builder: (context, state) {
            return Stack(
              children: [
                AlertDialog(
                  title: Text('Delete contest'),
                  content: Text('Are you sure you want to delete this contest? '
                      'All related info will be lost and members will be notified'),
                  actions: [
                    TextButton(
                      onPressed: () {
                        context.pop();
                      },
                      child: Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: () {
                        organizerContestDetailsPageBloc
                            .add(OrganizerContestDetailsPageDeleteContest(contestId: contestId));
                      },
                      child: Text('Proceed'),
                    ),
                  ],
                ),
                if (state.status.isLoading) ObscuredLoader(),
              ],
            );
          },
        ),
      );
    },
  );
}
