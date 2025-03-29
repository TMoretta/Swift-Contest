import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:swift_contest/model/data_models/user/user.dart';
import 'package:swift_contest/utils/di/di.dart';
import 'package:swift_contest/utils/themes/color_scheme_extension.dart';
import 'package:swift_contest/view/pages/juror_pages/juror_contest_details_page/juror_details_tab.dart';
import 'package:swift_contest/view/pages/juror_pages/juror_contest_details_page/juror_voting_tab.dart';
import 'package:swift_contest/viewmodel/blocs/app_auth_bloc/app_auth_bloc.dart';
import 'package:swift_contest/viewmodel/blocs/juror_pages_blocs/juror_contest_details_page_bloc/juror_contest_details_page_bloc.dart';

class JurorContestDetailsPage extends StatefulWidget {
  final String contestId;

  const JurorContestDetailsPage({required this.contestId, super.key});

  @override
  State<JurorContestDetailsPage> createState() => _JurorContestDetailsPageState();
}

class _JurorContestDetailsPageState extends State<JurorContestDetailsPage> {
  late User user;

  @override
  void initState() {
    super.initState();
    final appAuthState = context.read<AppAuthBloc>().state;
    user = (appAuthState as AppAuthAuthenticated).user;
  }

  @override
  Widget build(BuildContext context) {
    final contestId = widget.contestId;
    return BlocProvider<JurorContestDetailsPageBloc>(
      create: (context) => getIt<JurorContestDetailsPageBloc>(),
      child: Scaffold(
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
                              JurorDetailsTab(contestId: contestId),
                              JurorVotingTab(),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
