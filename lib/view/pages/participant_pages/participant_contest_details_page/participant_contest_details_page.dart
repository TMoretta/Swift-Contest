import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:swift_contest/model/bundles/home_contest_bundle.dart';
import 'package:swift_contest/model/data_models/user.dart';
import 'package:swift_contest/utils/themes/color_scheme_x.dart';
import 'package:swift_contest/view/pages/participant_pages/participant_contest_details_page/participant_details_tab.dart';
import 'package:swift_contest/view/pages/participant_pages/participant_contest_details_page/participant_voting_tab.dart';
import 'package:swift_contest/view/pages/participant_pages/participant_contest_details_page/participant_your_work_tab.dart';
import 'package:swift_contest/viewmodel/blocs/auth_bloc/auth_bloc.dart';
import 'package:swift_contest/viewmodel/blocs/pages_blocs/participant_contest_details_page_bloc/participant_contest_details_page_bloc.dart';

class ParticipantContestDetailsPage extends StatefulWidget {
  final String contestId;

  const ParticipantContestDetailsPage({required this.contestId, super.key});

  @override
  State<ParticipantContestDetailsPage> createState() => _ParticipantContestDetailsPageState();
}

class _ParticipantContestDetailsPageState extends State<ParticipantContestDetailsPage> {
  late User user;
  late String contestId;

  @override
  void initState() {
    super.initState();
    contestId = widget.contestId;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    user = context.read<AuthBloc>().state.authBundle!.user;
    context
        .read<ParticipantContestDetailsPageBloc>()
        .add(ParticipantContestDetailsPageInit(contestId: contestId,participantId: user.id));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: FittedBox(
          child: Text(
            'Joined contest',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w800,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
        ),
        actions: [
          IconButton(
            onPressed: () {},
            icon: Icon(Icons.more_vert),
            color: Theme.of(context).colorScheme.secondary,
          ),
        ],
        shadowColor: Theme.of(context).colorScheme.black,
        surfaceTintColor: Theme.of(context).colorScheme.surface,
        elevation: 0.8,
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return BlocBuilder<ParticipantContestDetailsPageBloc,
                ParticipantContestDetailsPageState>(
              builder: (context, state) {
                return SizedBox(
                  width: constraints.maxWidth,
                  height: constraints.maxHeight,
                  child: DefaultTabController(
                    length: 3,
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            spacing: 8,
                            children: [
                              Align(
                                alignment: Alignment.center,
                                child: Card(
                                  elevation: 0.5,
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
                                      color: Theme.of(context).colorScheme.primary,
                                    ),
                                    tabs: [
                                      Tab(text: 'Details'),
                                      Tab(text: 'Your work'),
                                      Tab(text: 'Voting'),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Expanded(
                          child: Padding(
                            padding: EdgeInsets.symmetric(horizontal: 20),
                            child: TabBarView(
                              physics: NeverScrollableScrollPhysics(),
                              children: [
                                ParticipantDetailsTab(contestId: contestId),
                                ParticipantYourWorkTab(contestId: contestId),
                                ParticipantVotingTab(),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
