import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:swift_contest/utils/functions/show_snack_bar.dart';
import 'package:swift_contest/view/pages/participant_pages/participant_contest_details_page/participant_details_tab.dart';
import 'package:swift_contest/view/pages/participant_pages/participant_contest_details_page/participant_work_tab.dart';
import 'package:swift_contest/view/widgets/custom_app_bar.dart';
import 'package:swift_contest/viewmodel/blocs/pages_blocs/participant_contest_details_page_bloc/participant_contest_details_page_bloc.dart';
import 'package:swift_contest/viewmodel/enums/bloc_status.dart';

class ParticipantContestDetailsPage extends StatefulWidget {
  final String contestId;

  const ParticipantContestDetailsPage({required this.contestId, super.key});

  @override
  State<ParticipantContestDetailsPage> createState() => _ParticipantContestDetailsPageState();
}

class _ParticipantContestDetailsPageState extends State<ParticipantContestDetailsPage> {
  late String contestId;

  @override
  void initState() {
    super.initState();
    contestId = widget.contestId;
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<ParticipantContestDetailsPageBloc, ParticipantContestDetailsPageState>(
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
            child:DefaultTabController(
              length: 2,
              child: Column(
                children: [
                  SizedBox(height: 16),
                  Card(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    elevation: 0.6,
                    child: BlocBuilder<ParticipantContestDetailsPageBloc,
                        ParticipantContestDetailsPageState>(
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
                            Tab(text: 'Work'),
                            // Tab(text: 'Voting'),
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
                        ParticipantDetailsTab(contestId: contestId),
                        ParticipantWorkTab(contestId: contestId),
                        // ParticipantVotingTab(contestId: contestId),
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
