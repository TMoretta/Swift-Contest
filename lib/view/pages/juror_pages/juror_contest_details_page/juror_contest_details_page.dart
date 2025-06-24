import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:swift_contest/utils/functions/show_snack_bar.dart';
import 'package:swift_contest/view/pages/juror_pages/juror_contest_details_page/juror_details_tab.dart';
import 'package:swift_contest/view/pages/juror_pages/juror_contest_details_page/juror_voting_tab.dart';
import 'package:swift_contest/view/widgets/custom_app_bar.dart';
import 'package:swift_contest/viewmodel/blocs/pages_blocs/juror_contest_details_page_bloc/juror_contest_details_page_bloc.dart';
import 'package:swift_contest/viewmodel/enums/bloc_status.dart';

class JurorContestDetailsPage extends StatefulWidget {
  final String contestId;

  const JurorContestDetailsPage({required this.contestId, super.key});

  @override
  State<JurorContestDetailsPage> createState() => _JurorContestDetailsPageState();
}

class _JurorContestDetailsPageState extends State<JurorContestDetailsPage> {
  late String contestId;

  @override
  void initState() {
    super.initState();
    contestId = widget.contestId;
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<JurorContestDetailsPageBloc, JurorContestDetailsPageState>(
      listener: (context, state) {
        if (state.message != null) {
          showSnackBar(context: context, text: state.message!);
        }
      },
      child: Scaffold(
        appBar: CustomAppBar(title: 'Joined contest'),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: DefaultTabController(
              length: 2,
              child: Column(
                children: [
                  SizedBox(height: 16),
                  Card(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    elevation: 0.6,
                    child: BlocBuilder<JurorContestDetailsPageBloc,
                        JurorContestDetailsPageState>(
                      builder: (context, state) {
                        return (state.status.isInitial || state.status.isLoading)
                            ? SizedBox.shrink()
                            : TabBar(
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
                            // Tab(text: 'Works'),
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
