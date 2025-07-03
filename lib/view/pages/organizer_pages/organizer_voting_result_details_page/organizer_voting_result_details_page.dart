import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:swift_contest/view/widgets/obscured_loader.dart';
import 'package:swift_contest/view/widgets/overlay_loader.dart';
import 'package:swift_contest/view/widgets/show_snack_bar.dart';
import 'package:swift_contest/view/pages/organizer_pages/organizer_voting_result_details_page/organizer_voting_result_page_info_tab.dart';
import 'package:swift_contest/view/pages/organizer_pages/organizer_voting_result_details_page/organizer_voting_result_page_jurors_votes_tab.dart';
import 'package:swift_contest/view/pages/organizer_pages/organizer_voting_result_details_page/organizer_voting_result_page_simple_jurors_votes_tab.dart';
import 'package:swift_contest/view/widgets/custom_app_bar.dart';
import 'package:swift_contest/viewmodel/blocs/pages_blocs/organizer_voting_result_details_page_bloc/organizer_voting_result_details_page_bloc.dart';
import 'package:swift_contest/viewmodel/enums/bloc_status.dart';
import 'package:swift_contest/view/widgets/void_widget.dart';

class OrganizerVotingResultDetailsPage extends StatefulWidget {
  final String votingSessionId;

  const OrganizerVotingResultDetailsPage({
    required this.votingSessionId,
    super.key,
  });

  @override
  State<OrganizerVotingResultDetailsPage> createState() => _OrganizerVotingResultDetailsPageState();
}

class _OrganizerVotingResultDetailsPageState extends State<OrganizerVotingResultDetailsPage> {
  
  late String votingSessionId;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    votingSessionId = widget.votingSessionId;
    context
        .read<OrganizerVotingResultDetailsPageBloc>()
        .add(OrganizerVotingResultDetailsPageInit(votingSessionId: votingSessionId));
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<OrganizerVotingResultDetailsPageBloc,
        OrganizerVotingResultDetailsPageState>(
      listener: (context, state) {
        if (state.message != null) {
          showSnackBar(context: context, text: state.message!);
        }
        if(state.status.isLoading) {
          context.showLoader();
        } else {
          context.hideLoader();
        }
      },
      child: Scaffold(
        appBar: CustomAppBar(title: 'Results'),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: DefaultTabController(
              length: 3,
              child: Column(
                children: [
                  SizedBox(height: 16),
                  BlocBuilder<OrganizerVotingResultDetailsPageBloc,
                      OrganizerVotingResultDetailsPageState>(
                    builder: (context, state) {
                      switch (state.status) {
                        case BlocStatus.initial:
                          return VoidWidget();
                        case (BlocStatus.loading || BlocStatus.failure):
                          if (state.sourceEvent is OrganizerVotingResultDetailsPageInit) {
                            return VoidWidget();
                          } else {
                            continue successCase;
                          }
                        successCase:
                        case BlocStatus.success:
                          return Card(
                            shape:
                                RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                            elevation: 0.6,
                            child: BlocBuilder<OrganizerVotingResultDetailsPageBloc,
                                OrganizerVotingResultDetailsPageState>(
                              builder: (context, state) {
                                return (state.status.isInitial || state.status.isLoading)
                                    ? VoidWidget()
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
                                          Tab(text: 'Info'),
                                          Tab(text: 'Jurors'),
                                          Tab(text: 'Simple Jurors'),
                                        ],
                                      );
                              },
                            ),
                          );
                      }
                    },
                  ),
                  SizedBox(height: 16),
                  Expanded(
                    child: TabBarView(
                      physics: NeverScrollableScrollPhysics(),
                      children: [
                        OrganizerVotingResultPageInfoTab(votingSessionId: votingSessionId),
                        OrganizerVotingResultPageJurorsVotesTab(
                            votingSessionId: votingSessionId),
                        OrganizerVotingResultPageSimpleJurorsVotesTab(
                            votingSessionId: votingSessionId),
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
