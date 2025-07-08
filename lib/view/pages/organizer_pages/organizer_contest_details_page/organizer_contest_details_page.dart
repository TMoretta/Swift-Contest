import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:swift_contest/model/enums/contest_status.dart';
import 'package:swift_contest/utils/router/app_router.gr.dart';
import 'package:swift_contest/view/pages/organizer_pages/organizer_contest_details_page/organizer_details_tab.dart';
import 'package:swift_contest/view/pages/organizer_pages/organizer_contest_details_page/organizer_jurors_tab.dart';
import 'package:swift_contest/view/pages/organizer_pages/organizer_contest_details_page/organizer_participants_tab.dart';
import 'package:swift_contest/view/pages/organizer_pages/organizer_contest_details_page/organizer_voting_tab.dart';
import 'package:swift_contest/view/pages/organizer_pages/organizer_contest_details_page/organizer_works_tab.dart';
import 'package:swift_contest/view/widgets/custom_app_bar.dart';
import 'package:swift_contest/view/widgets/overlay_loader.dart';
import 'package:swift_contest/view/widgets/show_snack_bar.dart';
import 'package:swift_contest/view/widgets/void_widget.dart';
import 'package:swift_contest/viewmodel/blocs/pages_blocs/organizer_contest_details_page_bloc/organizer_contest_details_page_bloc.dart';
import 'package:swift_contest/viewmodel/enums/bloc_status.dart';

@RoutePage()
class OrganizerContestDetailsPage extends StatefulWidget {
  final String contestId;

  const OrganizerContestDetailsPage({
    @PathParam('contestId') required this.contestId,
    super.key,
  });

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
  void dispose() {
    context.hideLoader();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<OrganizerContestDetailsPageBloc>(
      create: (context) => OrganizerContestDetailsPageBloc(
        genericRepository: context.read(),
        organizerRepository: context.read(),
      ),
      child: BlocConsumer<OrganizerContestDetailsPageBloc, OrganizerContestDetailsPageState>(
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
              title: 'Your contest',
              actions: [
                Builder(
                  builder: (context) {
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
                      Builder(
                        builder: (context) {
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
                              return TabBar(
                                isScrollable: true,
                                tabAlignment: TabAlignment.center,
                                indicatorSize: TabBarIndicatorSize.label,
                                tabs: [
                                  Tab(text: 'Details'),
                                  Tab(text: 'Participants'),
                                  Tab(text: 'Jurors'),
                                  Tab(text: 'Works'),
                                  Tab(text: 'Voting'),
                                ],
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
          );
        },
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
                await context.router.push(OrganizerContestEditRoute(contestId: contestId));
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
              context.router.pop();
              context
                  .read<OrganizerContestDetailsPageBloc>()
                  .add(OrganizerContestDetailsPageRefresh(contestId: contestId));
            }
          },
          builder: (context, state) {
            return AlertDialog(
              title: Text((state.contestDetailsBundle!.contest.contestStatus.isTerminated)
                  ? 'Set as active'
                  : 'Set as terminated'),
              content: Text((state.contestDetailsBundle!.contest.contestStatus.isTerminated)
                  ? 'Are you sure you want to set this contest as active?'
                  : 'Are you sure you want to set this contest as terminated?'),
              actions: [
                TextButton(
                  onPressed: () {
                    context.router.pop();
                  },
                  child: Text('Cancel'),
                ),
                TextButton(
                  onPressed: () {
                    if (state.contestDetailsBundle!.contest.contestStatus.isTerminated) {
                      context
                          .read<OrganizerContestDetailsPageBloc>()
                          .add(OrganizerContestDetailsPageSetStatusAsActive(contestId: contestId));
                    } else {
                      context.read<OrganizerContestDetailsPageBloc>().add(
                          OrganizerContestDetailsPageSetStatusAsTerminated(contestId: contestId));
                    }
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
