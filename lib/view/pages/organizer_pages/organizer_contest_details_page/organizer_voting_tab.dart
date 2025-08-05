import 'dart:io';

import 'package:auto_route/auto_route.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:swift_contest/model/database/types/voting_session_status.dart';
import 'package:swift_contest/utils/router/app_router.gr.dart';
import 'package:swift_contest/view/widgets/overlay_loader.dart';
import 'package:swift_contest/view/widgets/show_snack_bar.dart';
import 'package:swift_contest/view/widgets/void_widget.dart';
import 'package:swift_contest/viewmodel/blocs/pages_blocs/organizer_contest_details_page_bloc/organizer_contest_details_page_bloc.dart';
import 'package:swift_contest/viewmodel/enums/bloc_status.dart';

class OrganizerVotingTab extends StatefulWidget {
  final String contestId;

  const OrganizerVotingTab({required this.contestId, super.key});

  @override
  State<OrganizerVotingTab> createState() => _OrganizerVotingTabState();
}

class _OrganizerVotingTabState extends State<OrganizerVotingTab> {
  late final String contestId;
  File? selectedFileToPublish;

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
    return BlocBuilder<OrganizerContestDetailsPageBloc, OrganizerContestDetailsPageState>(
      builder: (context, state) {
        return Scaffold(
          body: SafeArea(
            child: _buildBody(context, state),
          ),
          floatingActionButton: (state.isInitialized) ? _buildFab(context, state) : null,
        );
      },
    );
  }

  Widget _buildBody(BuildContext context, OrganizerContestDetailsPageState state) {
    if (!state.isInitialized) {
      if (state.status.isFailure) {
        return Center(
          child: FilledButton(
            onPressed: () async => context
                .read<OrganizerContestDetailsPageBloc>()
                .add(OrganizerContestDetailsPageFetch(contestId: contestId)),
            child: Text('Retry'),
          ),
        );
      }
      return VoidWidget();
    }
    final endedVotingSessions = state.contestDetailsBundle!.votingSessionsBundles
        .map((e) => e.votingSession)
        .where((e) => e.sessionStatus.isEnded)
        .toList(growable: false);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        //* Results
        Text(
          'Voting results',
          style: Theme.of(context)
              .textTheme
              .titleMedium
              ?.copyWith(color: Theme.of(context).colorScheme.secondary),
        ),
        SizedBox(height: 4),
        Expanded(
          child: RefreshIndicator.adaptive(
            onRefresh: () async => context
                .read<OrganizerContestDetailsPageBloc>()
                .add(OrganizerContestDetailsPageFetch(contestId: contestId)),
            child: (endedVotingSessions.isNotEmpty)
                ? ListView.builder(
                    itemCount: endedVotingSessions.length,
                    itemBuilder: (context, index) {
                      final votingSession = endedVotingSessions[index];
                      return Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Card(
                            elevation: 0.05,
                            child: ListTile(
                              onTap: () {
                                context.router.push(OrganizerVotingResultsRoute(
                                    votingSessionId: votingSession.id!));
                              },
                              title: Text(
                                votingSession.name,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              subtitle: Text(
                                DateFormat('dd MMM, yyyy | HH:mm').format(votingSession.createdAt!),
                              ),
                              // trailing: IconButton(
                              //   onPressed: () async {
                              //     _showEditVotingSessionNameDialog(
                              //         context: context,
                              //         votingSessionId: votingSession.id!,
                              //         contestId: contestId);
                              //   },
                              //   icon: Icon(
                              //     Icons.edit,
                              //   ),
                              // ),
                            ),
                          ),
                          if (index == endedVotingSessions.length - 1) SizedBox(height: 72),
                        ],
                      );
                    },
                  )
                : ListView(
                    children: [
                      Text(
                        'No result yet',
                      ),
                    ],
                  ),
          ),
        ),
      ],
    );
  }

  Widget _buildFab(BuildContext context, OrganizerContestDetailsPageState state) {
    final liveVotingSession = state.contestDetailsBundle!.votingSessionsBundles
        .map((e) => e.votingSession)
        .where((e) => !e.sessionStatus.isEnded && !e.sessionStatus.isCancelled)
        .singleOrNull;

    return FloatingActionButton.extended(
      heroTag: 'startVoting',
      onPressed: () async {
        if (liveVotingSession != null) {
          // Session is not null, go to voting management
          context.router
              .push(OrganizerVotingProcedureRoute(votingSessionId: liveVotingSession.id!));
        }
        // There is no live session, start one
        for (var juryBundle in state.contestDetailsBundle!.juriesBundles) {
          if (juryBundle.votingFormBundle.votingFormFields.isEmpty) {
            showSnackBar(
                context: context,
                text: "Voting form of '${juryBundle.jury.name}' is empty. Add at least one field");
            return;
          }
        }

        if (state.contestDetailsBundle!.juriesBundles
            .map((e) => e.jurationsBundles)
            .toList(growable: false)
            .isEmpty) {
          showSnackBar(
            context: context,
            text: 'At least one juror is necessary',
          );
          return;
        }
        if (state.contestDetailsBundle!.participationsBundles
            .where((e) => e.participation.hasSubmitted)
            .toList(growable: false)
            .isEmpty) {
          showSnackBar(
            context: context,
            text: 'At least one participant with submitted work is necessary',
          );
          return;
        }

        context.router.push(OrganizerVotingSettingsRoute(contestId: contestId));
      },
      elevation: 1,
      label: (liveVotingSession == null) ? Text('Start voting') : Text('Manage voting'),
    );
  }
}
