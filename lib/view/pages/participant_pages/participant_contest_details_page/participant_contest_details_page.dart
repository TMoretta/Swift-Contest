import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:swift_contest/view/pages/participant_pages/participant_contest_details_page/participant_details_tab.dart';
import 'package:swift_contest/view/pages/participant_pages/participant_contest_details_page/participant_work_tab.dart';
import 'package:swift_contest/view/widgets/custom_app_bar.dart';
import 'package:swift_contest/view/widgets/overlay_loader.dart';
import 'package:swift_contest/view/widgets/show_snack_bar.dart';
import 'package:swift_contest/view/widgets/void_widget.dart';
import 'package:swift_contest/viewmodel/blocs/auth_bloc/auth_bloc.dart';
import 'package:swift_contest/viewmodel/blocs/pages_blocs/participant_contest_details_page_bloc/participant_contest_details_page_bloc.dart';
import 'package:swift_contest/viewmodel/enums/bloc_status.dart';

@RoutePage()
class ParticipantContestDetailsPage extends StatefulWidget implements AutoRouteWrapper {
  final String contestId;

  const ParticipantContestDetailsPage({
    @PathParam('contestId') required this.contestId,
    super.key,
  });

  @override
  State<ParticipantContestDetailsPage> createState() => _ParticipantContestDetailsPageState();

  @override
  Widget wrappedRoute(BuildContext context) {
    return BlocProvider<ParticipantContestDetailsPageBloc>(
      create: (context) => ParticipantContestDetailsPageBloc(
        participantRepository: context.read(),
      ),
      child: this,
    );
  }
}

class _ParticipantContestDetailsPageState extends State<ParticipantContestDetailsPage> {
  late String profileId;
  late final String contestId;

  @override
  void initState() {
    super.initState();
    contestId = widget.contestId;
    profileId = context.read<AuthBloc>().state.profile!.id!;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    context
        .read<ParticipantContestDetailsPageBloc>()
        .add(ParticipantContestDetailsPageFetch(contestId: contestId, participantId: profileId));
  }

  @override
  void dispose() {
    context.hideLoader();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ParticipantContestDetailsPageBloc, ParticipantContestDetailsPageState>(
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
            title: 'Joined contest',
            onRefresh: () => context.read<ParticipantContestDetailsPageBloc>().add(ParticipantContestDetailsPageFetch(contestId: contestId, participantId: profileId)),
            actions: [
              Builder(
                builder: (context) {
                  switch (state.status) {
                    case BlocStatus.initial:
                      return VoidWidget();
                    case (BlocStatus.loading || BlocStatus.failure):
                      if (!state.isInitialized) {
                        return VoidWidget();
                      } else {
                        continue successCase;
                      }
                    successCase:
                    case BlocStatus.success:
                      return _Menu(
                        contestId: contestId,
                        profileId: profileId,
                      );
                  }
                },
              ),
            ],
          ),
          body: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: DefaultTabController(
                length: 2,
                child: Column(
                  children: [
                    SizedBox(height: 16),
                    Builder(
                      builder: (context) {
                        switch (state.status) {
                          case BlocStatus.initial:
                            return VoidWidget();
                          case (BlocStatus.loading || BlocStatus.failure):
                            if (!state.isInitialized) {
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
                                Tab(text: 'Work'),
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
        );
      },
    );
  }
}

class _Menu extends StatelessWidget {
  final String contestId;
  final String profileId;

  const _Menu({required this.contestId, required this.profileId});

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      icon: const Icon(Icons.more_vert),
      menuPadding: EdgeInsets.symmetric(vertical: 4),
      onSelected: (option) async {
        switch (option) {
          case 'Leave':
            final participantContestDetailsPageBloc =
                context.read<ParticipantContestDetailsPageBloc>();
            showDialog(
              context: context,
              builder: (context) {
                return BlocProvider.value(
                  value: participantContestDetailsPageBloc,
                  child: BlocConsumer<ParticipantContestDetailsPageBloc,
                      ParticipantContestDetailsPageState>(
                    listener: (context, state) {
                      if (state.status.isSuccess &&
                          state.sourceEvent is ParticipantContestDetailsPageLeaveContest) {
                        context.router.pop();
                        context.router.pop(true);
                      }
                    },
                    builder: (context, state) {
                      return AlertDialog(
                        title: Text('Leave contest'),
                        content: Text('Are you sure you want to leave the contest? '
                            'The organizer will be notified'),
                        actions: [
                          TextButton(
                            onPressed: () {
                              context.router.pop();
                            },
                            child: Text('Cancel'),
                          ),
                          TextButton(
                            onPressed: () {
                              context.read<ParticipantContestDetailsPageBloc>().add(
                                  ParticipantContestDetailsPageLeaveContest(
                                      contestId: contestId, participantId: profileId));
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
            break;
        }
      },
      itemBuilder: (context) => <PopupMenuEntry<String>>[
        PopupMenuItem(
          value: 'Leave',
          child: ListTile(
            leading: Icon(
              Icons.logout_rounded,
              color: Theme.of(context).colorScheme.error,
            ),
            title: Text(
              'Leave',
              style: Theme.of(context)
                  .textTheme
                  .bodyLarge
                  ?.copyWith(color: Theme.of(context).colorScheme.error),
            ),
          ),
        ),
      ],
    );
  }
}
