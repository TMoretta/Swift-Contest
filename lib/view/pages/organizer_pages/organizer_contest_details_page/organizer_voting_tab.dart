import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:swift_contest/model/data_models/voting_session.dart';
import 'package:swift_contest/utils/functions/show_snack_bar.dart';
import 'package:swift_contest/utils/router/go_router.dart';
import 'package:swift_contest/view/widgets/loader.dart';
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

  @override
  void initState() {
    super.initState();
    contestId = widget.contestId;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final state = context.read<OrganizerContestDetailsPageBloc>().state;
    if (state.status.isInitial) {
      context
          .read<OrganizerContestDetailsPageBloc>()
          .add(OrganizerContestDetailsPageInit(contestId: contestId));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: BlocBuilder<OrganizerContestDetailsPageBloc, OrganizerContestDetailsPageState>(
          builder: (context, state) {
            switch (state.status) {
              case BlocStatus.initial:
                return SizedBox.shrink();
              case BlocStatus.loading:
                return Loader();
              case BlocStatus.failure:
                if (state.sourceEvent is OrganizerContestDetailsPageInit) {
                  return RefreshIndicator.adaptive(
                    onRefresh: () async => context
                        .read<OrganizerContestDetailsPageBloc>()
                        .add(OrganizerContestDetailsPageInit(contestId: contestId)),
                    child: ListView(
                      physics: AlwaysScrollableScrollPhysics(),
                    ),
                  );
                } else {
                  continue successCase;
                }
              successCase:
              case BlocStatus.success:
                final votingFormBundle = state.contestDetailsBundle!.votingFormBundle;
                final endedVotingSessions = state.contestDetailsBundle!.endedVotingSessions;
                return Column(
                  children: [
                    //* Jurors' form
                    Card(
                      elevation: 0.2,
                      color: Theme.of(context).colorScheme.tertiaryFixedDim,
                      child: ListTile(
                        onTap: () async {
                          final bool? res = await context.pushNamed(
                            AppRouter.organizerVotingFormEdit,
                            extra: votingFormBundle.toJson(),
                          );
                          if (context.mounted && res != null && res) {
                            context
                                .read<OrganizerContestDetailsPageBloc>()
                                .add(OrganizerContestDetailsPageInit(contestId: contestId));
                          }
                        },
                        title: Text(
                          'Edit juror\'s form',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              color: Theme.of(context).colorScheme.onTertiaryFixedVariant),
                        ),
                        leading: Icon(Icons.edit,
                            color: Theme.of(context).colorScheme.onTertiaryFixedVariant),
                      ),
                    ),
                    SizedBox(height: 16),
                    // Column(
                    //   children: [
                    //     Row(
                    //       mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    //       children: [
                    //         Text('Jurors\' form'),
                    //         IconButton(
                    //           onPressed: () async {
                    //             final bool? res = await context.pushNamed(
                    //               AppRouter.organizerVotingFormEdit,
                    //               extra: votingFormBundle.toJson(),
                    //             );
                    //             if (context.mounted && res != null && res) {
                    //               context.read<OrganizerContestDetailsPageBloc>().add(
                    //                   OrganizerContestDetailsPageInit(
                    //                       contestId: contestId));
                    //             }
                    //           },
                    //           icon: Icon(Icons.edit),
                    //         ),
                    //       ],
                    //     ),
                    //     SizedBox(
                    //       height: 200,
                    //       child: RefreshIndicator.adaptive(
                    //         onRefresh: () async {
                    //           context.read<OrganizerContestDetailsPageBloc>().add(
                    //               OrganizerContestDetailsPageInit(contestId: contestId));
                    //         },
                    //         child: (votingFormFields.isNotEmpty)
                    //             ? ListView.builder(
                    //                 physics: AlwaysScrollableScrollPhysics(),
                    //                 itemCount: votingFormFields.length,
                    //                 itemBuilder: (context, index) {
                    //                   final field = votingFormFields[index];
                    //                   return ListTile(
                    //                     title: Column(
                    //                       children: [
                    //                         Row(
                    //                           children: [
                    //                             Text(field.name),
                    //                           ],
                    //                         )
                    //                       ],
                    //                     ),
                    //                   );
                    //                 },
                    //               )
                    //             : ListView(
                    //                 physics: AlwaysScrollableScrollPhysics(),
                    //                 children: [
                    //                   Text('No field added yet'),
                    //                 ],
                    //               ),
                    //       ),
                    //     ),
                    //   ],
                    // ),
                    //* Results
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Voting results',
                        style: Theme.of(context)
                            .textTheme
                            .titleMedium
                            ?.copyWith(color: Theme.of(context).colorScheme.secondary),
                      ),
                    ),
                    SizedBox(height: 4),
                    Expanded(
                      child: RefreshIndicator.adaptive(
                        onRefresh: () async => context
                            .read<OrganizerContestDetailsPageBloc>()
                            .add(OrganizerContestDetailsPageRefresh(contestId: contestId)),
                        child: (endedVotingSessions.isNotEmpty)
                            ? ListView.builder(
                                itemCount: endedVotingSessions.length,
                                itemBuilder: (context, index) {
                                  final endedVotingSession = endedVotingSessions[index];
                                  return ListTile(
                                    onTap: () {
                                      final dataJson = {
                                        'voting_session': endedVotingSession.toJson(),
                                        'contest_details_bundle':
                                            state.contestDetailsBundle!.toJson(),
                                      };
                                      context.pushNamed(AppRouter.organizerVotingResultDetails,
                                          extra: dataJson);
                                    },
                                    title: Text(endedVotingSession.name),
                                  );
                                },
                              )
                            : LayoutBuilder(
                                builder: (context, constraints) {
                                  return ListView(
                                    children: [
                                      Text(
                                        'No result yet',
                                      ),
                                    ],
                                  );
                                },
                              ),
                      ),
                    ),
                  ],
                );
            }
          },
        ),
      ),
      floatingActionButton:
          BlocConsumer<OrganizerContestDetailsPageBloc, OrganizerContestDetailsPageState>(
        listener: (context, state) {
          if (state.status.isFailure && state.message != null) {
            showSnackBar(context: context, text: state.message!);
          }
        },
        builder: (context, state) {
          if (state.status.isInitial) {
            return SizedBox.shrink();
          }
          if (state.contestDetailsBundle!.liveVotingSession == null) {
            return FloatingActionButton.extended(
              onPressed: (!state.status.isLoading)
                  ? () async {
                      if (state.contestDetailsBundle!.joinedJurationsBundles.isEmpty) {
                        showSnackBar(
                          context: context,
                          text: 'At least one juror is necessary',
                        );
                        return;
                      }
                      if (state.contestDetailsBundle!.joinedParticipationsBundles
                          .where((e) => e.participation.hasSubmitted)
                          .toList(growable: false)
                          .isEmpty) {
                        showSnackBar(
                          context: context,
                          text: 'At least one participant with submitted work is necessary',
                        );
                        return;
                      }

                      final contestDetailsBundleJson = state.contestDetailsBundle!.toJson();

                      final VotingSession? votingSession = await context.pushNamed(
                          AppRouter.organizerVotingSettings,
                          extra: contestDetailsBundleJson);
                      if (votingSession == null) {
                        return;
                      }
                      if (context.mounted) {
                        context.pushNamed(AppRouter.organizerVotingProcedure);
                      }
                    }
                  : null,
              elevation: 1,
              label: Text('Start voting'),
            );
          } else {
            return FloatingActionButton.extended(
              onPressed: (!state.status.isLoading)
                  ? () {
                      context.pushNamed(AppRouter.organizerVotingProcedure);
                    }
                  : null,
              elevation: 1,
              label: Text('Continue voting'),
            );
          }
        },
      ),
    );
  }
}
