import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:swift_contest/utils/router/app_router.gr.dart';
import 'package:swift_contest/view/pages/organizer_pages/organizer_voting_result_details_page/organizer_voting_result_page_info_tab.dart';
import 'package:swift_contest/view/pages/organizer_pages/organizer_voting_result_details_page/organizer_voting_result_page_jurors_votes_tab.dart';
import 'package:swift_contest/view/pages/organizer_pages/organizer_voting_result_details_page/organizer_voting_result_page_simple_jurors_votes_tab.dart';
import 'package:swift_contest/view/widgets/custom_app_bar.dart';
import 'package:swift_contest/view/widgets/overlay_loader.dart';
import 'package:swift_contest/view/widgets/show_snack_bar.dart';
import 'package:swift_contest/view/widgets/void_widget.dart';
import 'package:swift_contest/viewmodel/blocs/pages_blocs/organizer_voting_result_details_page_bloc/organizer_voting_result_details_page_bloc.dart';
import 'package:swift_contest/viewmodel/enums/bloc_status.dart';

@RoutePage()
class OrganizerVotingResultDetailsPage extends StatefulWidget implements AutoRouteWrapper {
  final String votingSessionId;

  const OrganizerVotingResultDetailsPage({
    @PathParam('votingSessionId') required this.votingSessionId,
    super.key,
  });

  @override
  State<OrganizerVotingResultDetailsPage> createState() => _OrganizerVotingResultDetailsPageState();

  @override
  Widget wrappedRoute(BuildContext context) {
    return BlocProvider<OrganizerVotingResultDetailsPageBloc>(
      create: (context) => OrganizerVotingResultDetailsPageBloc(
        organizerRepository: context.read(),
      ),
      child: this,
    );
  }
}

class _OrganizerVotingResultDetailsPageState extends State<OrganizerVotingResultDetailsPage> {
  late String votingSessionId;

  @override
  void initState() {
    super.initState();
    votingSessionId = widget.votingSessionId;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    context
        .read<OrganizerVotingResultDetailsPageBloc>()
        .add(OrganizerVotingResultDetailsPageInit(votingSessionId: votingSessionId));
  }

  @override
  void dispose() {
    context.hideLoader();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<OrganizerVotingResultDetailsPageBloc,
        OrganizerVotingResultDetailsPageState>(
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
          appBar: CustomAppBar(title: 'Results'),
          body: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: DefaultTabController(
                length: 3,
                child: Column(
                  children: [
                    SizedBox(height: 16),
                    Builder(
                      builder: (context) {
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
                              child: TabBar(
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
                          OrganizerVotingResultPageJurorsVotesTab(votingSessionId: votingSessionId),
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
          floatingActionButton: Builder(
            builder: (context) {
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
                  return FloatingActionButton.extended(
                    onPressed: () {
                      context.router
                          .push(OrganizerVotingResultExportRoute(votingSessionId: votingSessionId));
                    },
                    elevation: 1,
                    label: Text('Export'),
                  );
              }
            },
          ),
        );
      },
    );
  }
}
