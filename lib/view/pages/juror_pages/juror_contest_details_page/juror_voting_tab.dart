import 'package:auto_route/auto_route.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:swift_contest/utils/labels/labels.dart';
import 'package:swift_contest/utils/router/app_router.gr.dart';
import 'package:swift_contest/view/widgets/list_view_with_central_label.dart';
import 'package:swift_contest/view/widgets/overlay_loader.dart';
import 'package:swift_contest/view/widgets/void_widget.dart';
import 'package:swift_contest/viewmodel/blocs/auth_bloc/auth_bloc.dart';
import 'package:swift_contest/viewmodel/blocs/pages_blocs/juror_contest_details_page_bloc/juror_contest_details_page_bloc.dart';
import 'package:swift_contest/viewmodel/enums/bloc_status.dart';

class JurorVotingTab extends StatefulWidget {
  final String contestId;

  const JurorVotingTab({required this.contestId, super.key});

  @override
  State<JurorVotingTab> createState() => _JurorVotingTabState();
}

class _JurorVotingTabState extends State<JurorVotingTab> {
  late String contestId;
  late String profileId;

  @override
  void initState() {
    super.initState();
    contestId = widget.contestId;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    profileId = context.read<AuthBloc>().state.profile!.id;
    final state = context.read<JurorContestDetailsPageBloc>().state;
    if (state.status.isInitial) {
      context
          .read<JurorContestDetailsPageBloc>()
          .add(JurorContestDetailsPageInit(contestId: contestId));
    }
  }

  @override
  void dispose() {
    context.hideLoader();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<JurorContestDetailsPageBloc, JurorContestDetailsPageState>(
      builder: (context, state) {
        return Scaffold(
          body: Builder(
            builder: (context) {
              switch (state.status) {
                case BlocStatus.initial:
                  return VoidWidget();
                case BlocStatus.loading:
                  if (state.sourceEvent is JurorContestDetailsPageInit) {
                    return VoidWidget();
                  } else {
                    continue successCase;
                  }
                case BlocStatus.failure:
                  if (state.sourceEvent is JurorContestDetailsPageInit) {
                    return RefreshIndicator.adaptive(
                      onRefresh: () async => context
                          .read<JurorContestDetailsPageBloc>()
                          .add(JurorContestDetailsPageInit(contestId: contestId)),
                      child: ListViewWithCentralLabel(label: Labels.anErrorOccurred),
                    );
                  } else {
                    continue successCase;
                  }
                successCase:
                case BlocStatus.success:
                  return RefreshIndicator.adaptive(
                    onRefresh: () async => context
                        .read<JurorContestDetailsPageBloc>()
                        .add(JurorContestDetailsPageRefresh(contestId: contestId)),
                    child: Builder(
                      builder: (context) {
                        if (state.contestDetailsBundle!.liveVotingSession == null) {
                          return ListViewWithCentralLabel(label: 'No voting session live');
                        }
                        final isExcludedFromTheSession = state
                            .votingSessionProcedureBundle!.excludedVotingSessionJurationsBundles
                            .any((e) => e.jurationBundle.juror.id == profileId);

                        if (isExcludedFromTheSession) {
                          return ListViewWithCentralLabel(
                              label: 'Voting session is live, but the '
                                  'organizer excluded you from voting to this session');
                        }

                        return ListViewWithCentralLabel(label: 'Voting session is live');
                      },
                    ),
                  );
              }
            },
          ),
          floatingActionButton: Builder(
            builder: (
              context,
            ) {
              if (state.contestDetailsBundle!.liveVotingSession == null) {
                return FilledButton(
                  onPressed: null,
                  child: Text('Vote'),
                );
              }
              final isExcludedFromTheSession = (state
                          .votingSessionProcedureBundle?.excludedVotingSessionJurationsBundles
                          .where((e) => e.jurationBundle.juror.id == profileId)
                          .firstOrNull !=
                      null)
                  ? true
                  : false;
              if (isExcludedFromTheSession) {
                return FilledButton(
                  onPressed: null,
                  child: Text('Vote'),
                );
              } else {
                return FilledButton(
                  onPressed: (state.contestDetailsBundle!.liveVotingSession != null &&
                          !isExcludedFromTheSession)
                      ? () async {
                          final bool? res = await context.router.push(JurorVotingProcedureRoute(
                              votingSessionId: state.contestDetailsBundle!.liveVotingSession!.id));
                          if (res == true) {
                            if (context.mounted) {
                              context
                                  .read<JurorContestDetailsPageBloc>()
                                  .add(JurorContestDetailsPageRefresh(contestId: contestId));
                            }
                          }
                        }
                      : null,
                  child: Text('Vote'),
                );
              }
            },
          ),
        );
      },
    );
  }
}
