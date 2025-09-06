import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:swift_contest/model/database/entities/voting_session_juror.dart';
import 'package:swift_contest/model/database/entities/voting_session_participant.dart';
import 'package:swift_contest/utils/router/app_router.gr.dart';
import 'package:swift_contest/view/widgets/custom_app_bar.dart';
import 'package:swift_contest/view/widgets/overlay_loader.dart';
import 'package:swift_contest/view/widgets/show_snack_bar.dart';
import 'package:swift_contest/view/widgets/void_widget.dart';
import 'package:swift_contest/viewmodel/blocs/pages_blocs/organizer_jury_voting_results_page_bloc/organizer_jury_voting_results_page_bloc.dart';
import 'package:swift_contest/viewmodel/types/bloc_status.dart';

@RoutePage()
class OrganizerJuryVotingResultsPage extends StatefulWidget implements AutoRouteWrapper {
  final String votingSessionJuryId;

  const OrganizerJuryVotingResultsPage({
    @PathParam('votingSessionJuryId') required this.votingSessionJuryId,
    super.key,
  });

  @override
  State<OrganizerJuryVotingResultsPage> createState() => _OrganizerJuryVotingResultsPageState();

  @override
  Widget wrappedRoute(BuildContext context) {
    return BlocProvider<OrganizerJuryVotingResultsPageBloc>(
      create: (context) => OrganizerJuryVotingResultsPageBloc(
        organizerRepository: context.read(),
      )..add(OrganizerJuryVotingResultsPageFetch(votingSessionJuryId: votingSessionJuryId)),
      child: this,
    );
  }
}

class _OrganizerJuryVotingResultsPageState extends State<OrganizerJuryVotingResultsPage> {
  late String votingSessionJuryId;
  VotingSessionJuror? chosenVotingSessionJuration;
  VotingSessionParticipant? chosenVotingSessionParticipation;

  @override
  void initState() {
    super.initState();
    votingSessionJuryId = widget.votingSessionJuryId;
  }

  @override
  void dispose() {
    context.hideLoader();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<OrganizerJuryVotingResultsPageBloc, OrganizerJuryVotingResultsPageState>(
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
              title: state.votingSessionJuryResultBundle?.votingSessionJuryBundle.votingSessionJury
                      .juryName ??
                  ''),
          body: SafeArea(
            child: Padding(
              padding: EdgeInsets.only(left: 16, top: 16, right: 16),
              child: Builder(
                builder: (context) {
                  if (!state.isInitialized) {
                    if (state.status.isFailure) {
                      return Center(
                        child: FilledButton(
                          onPressed: () async => context
                              .read<OrganizerJuryVotingResultsPageBloc>()
                              .add(OrganizerJuryVotingResultsPageFetch(
                                  votingSessionJuryId: votingSessionJuryId)),
                          child: Text('Retry'),
                        ),
                      );
                    }
                    return VoidWidget();
                  }

                  final List<VotingSessionJuror> votingSessionJurors = state
                      .votingSessionJuryResultBundle!.votingSessionJuryBundle.votingSessionJurors;
                  return ListView(
                    children: [
                      Text(
                        'Jurors that submitted',
                        style: Theme.of(context)
                            .textTheme
                            .titleMedium
                            ?.copyWith(color: Theme.of(context).colorScheme.secondary),
                      ),
                      if (votingSessionJurors.where((e) => e.hasSubmitted).isNotEmpty)
                        ...votingSessionJurors
                            .where((e) => e.hasSubmitted)
                            .map((votingSessionJuror) {
                          return Card(
                            elevation: 0,
                            child: ListTile(
                              onTap: () {
                                context.router.push(OrganizerJurorVotingResultsRoute(
                                    votingSessionJurorId: votingSessionJuror.id!));
                              },
                              title: Text(votingSessionJuror.jurorFullName),
                            ),
                          );
                        })
                      else
                        Text('No one'),
                      SizedBox(height: 24),
                      Text(
                        "Jurors that didn't submit",
                        style: Theme.of(context)
                            .textTheme
                            .titleMedium
                            ?.copyWith(color: Theme.of(context).colorScheme.secondary),
                      ),
                      if (votingSessionJurors.where((e) => !e.hasSubmitted).isNotEmpty)
                        ...votingSessionJurors
                            .where((e) => !e.hasSubmitted)
                            .map((votingSessionJuror) {
                          return Card(
                            elevation: 0,
                            child: ListTile(
                              title: Text(votingSessionJuror.jurorFullName),
                            ),
                          );
                        })
                      else
                        Text('No one'),
                    ],
                  );
                },
              ),
            ),
          ),
          floatingActionButton: (state.isInitialized && state.votingSessionJuryResultBundle!.votingSessionJuryBundle.votingSessionJurors
              .where((e) => e.hasSubmitted)
              .isNotEmpty) ? _buildFabMenu(context, state) : null,
        );
      },
    );
  }

  Widget _buildFabMenu(BuildContext context, OrganizerJuryVotingResultsPageState state) {
    return PopupMenuButton<String>(
      onSelected: (value) {
              switch (value) {
                case 'generateRanking':
                  context.router.push(OrganizerJuryRankingGenerationRoute(
                      votingSessionJuryId: votingSessionJuryId));
                  break;
                case 'export':
                  context.router.push(OrganizerJuryVotingResultsExportRoute(
                      votingSessionJuryId: votingSessionJuryId));
                  break;
              }
            },
      itemBuilder: (context) {
        return [
          PopupMenuItem(
            value: 'generateRanking',
            child: Text('Generate ranking'),
          ),
          PopupMenuItem(
            value: 'export',
            child: Text('Export'),
          ),
        ];
      },
      shape: RoundedRectangleBorder(),
      iconColor: Theme.of(context).colorScheme.onPrimaryContainer,
      icon: Card(
        color: Theme.of(context).colorScheme.primaryContainer,
        elevation: 0.5,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Icon(
            Icons.add,
            size: 32,
          ),
        ),
      ),
    );
  }
}
