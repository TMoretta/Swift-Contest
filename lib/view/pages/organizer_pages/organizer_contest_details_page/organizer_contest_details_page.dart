import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:swift_contest/utils/functions/show_snack_bar.dart';
import 'package:swift_contest/view/pages/organizer_pages/organizer_contest_details_page/organizer_details_tab.dart';
import 'package:swift_contest/view/pages/organizer_pages/organizer_contest_details_page/organizer_jurors_tab.dart';
import 'package:swift_contest/view/pages/organizer_pages/organizer_contest_details_page/organizer_participants_tab.dart';
import 'package:swift_contest/view/pages/organizer_pages/organizer_contest_details_page/organizer_voting_tab.dart';
import 'package:swift_contest/view/pages/organizer_pages/organizer_contest_details_page/organizer_works_tab.dart';
import 'package:swift_contest/view/widgets/custom_app_bar.dart';
import 'package:swift_contest/viewmodel/blocs/pages_blocs/organizer_contest_details_page_bloc/organizer_contest_details_page_bloc.dart';
import 'package:swift_contest/viewmodel/enums/bloc_status.dart';

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
        if (state.status.isSuccess &&
            state.sourceEvent is OrganizerContestDetailsPageDeleteContest) {
          context.pop(true);
        }
      },
      child: Scaffold(
        appBar: CustomAppBar(
          title: 'Your contest',
          actions: [
            BlocBuilder<OrganizerContestDetailsPageBloc, OrganizerContestDetailsPageState>(
              builder: (context, state) {
                return PopupMenuButton<String>(
                  icon: const Icon(Icons.more_vert),
                  onSelected: (option) async {
                    switch (option) {
                      case 'Edit':
                        break;
                      case 'Delete':
                        final bool? res = await showDialog(
                          useRootNavigator: false,
                          context: context,
                          builder: (context) {
                            return AlertDialog(
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
                                    context.pop(true);
                                  },
                                  child: Text('Proceed'),
                                ),
                              ],
                            );
                          },
                        );
                        if (res == true) {
                          if (context.mounted) {
                            context.read<OrganizerContestDetailsPageBloc>().add(
                                OrganizerContestDetailsPageDeleteContest(contestId: contestId));
                          }
                        }
                        break;
                    }
                  },
                  itemBuilder: (context) => <PopupMenuEntry<String>>[
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
                  ],
                );
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
                  Card(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    elevation: 0.6,
                    child: BlocBuilder<OrganizerContestDetailsPageBloc,
                        OrganizerContestDetailsPageState>(
                      builder: (context, state) {
                        return (state.status.isInitial || state.status.isLoading)
                            ? SizedBox.shrink()
                            : TabBar(
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
                              );
                      },
                    ),
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
    );
  }
}
