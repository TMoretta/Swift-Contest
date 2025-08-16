import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:swift_contest/model/database/types/storage_bucket.dart';
import 'package:swift_contest/utils/router/app_router.gr.dart';
import 'package:swift_contest/view/widgets/overlay_loader.dart';
import 'package:swift_contest/view/widgets/show_snack_bar.dart';
import 'package:swift_contest/view/widgets/storage_image.dart';
import 'package:swift_contest/view/widgets/void_widget.dart';
import 'package:swift_contest/viewmodel/blocs/pages_blocs/juror_contest_details_page_bloc/juror_contest_details_page_bloc.dart';
import 'package:swift_contest/viewmodel/types/bloc_status.dart';
import 'package:url_launcher/url_launcher.dart';

class JurorDetailsTab extends StatefulWidget {
  final String contestId;

  const JurorDetailsTab({super.key, required this.contestId});

  @override
  State<JurorDetailsTab> createState() => _JurorDetailsTabState();
}

class _JurorDetailsTabState extends State<JurorDetailsTab> {
  late String contestId;

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
    return BlocBuilder<JurorContestDetailsPageBloc, JurorContestDetailsPageState>(
      builder: (context, state) {
        return Scaffold(
          body: Builder(
            builder: (context) {
              if (!state.isInitialized) {
                if (state.status.isFailure) {
                  return Center(
                    child: FilledButton(
                      onPressed: () async => context
                          .read<JurorContestDetailsPageBloc>()
                          .add(JurorContestDetailsPageFetch(contestId: contestId)),
                      child: Text('Retry'),
                    ),
                  );
                }
                return VoidWidget();
              }
              return RefreshIndicator.adaptive(
                onRefresh: () async => context
                    .read<JurorContestDetailsPageBloc>()
                    .add(JurorContestDetailsPageFetch(contestId: contestId)),
                child: ListView(
                  children: [
                    //* Status
                    // Row(
                    //   mainAxisSize: MainAxisSize.min,
                    //   mainAxisAlignment: MainAxisAlignment.start,
                    //   children: [
                    //     Icon(
                    //       Icons.circle,
                    //       size: 18,
                    //       color: switch (state.contestDetailsBundle!.contestBundle.contest.contestStatus) {
                    //         ContestStatus.preparationPhase =>
                    //           Theme.of(context).colorScheme.statusPreparation,
                    //         ContestStatus.participationPhase =>
                    //           Theme.of(context).colorScheme.statusParticipation,
                    //         ContestStatus.votingPhase =>
                    //           Theme.of(context).colorScheme.statusVoting,
                    //         ContestStatus.terminated =>
                    //           Theme.of(context).colorScheme.statusTerminated,
                    //         ContestStatus.deleted =>
                    //           Theme.of(context).colorScheme.statusDeleted,
                    //       },
                    //     ),
                    //     SizedBox(width: 2),
                    //     Text(
                    //       switch (state.contestDetailsBundle!.contestBundle.contest.contestStatus) {
                    //         ContestStatus.preparationPhase => 'Preparation phase',
                    //         ContestStatus.participationPhase => 'Participation phase',
                    //         ContestStatus.votingPhase => 'Voting phase',
                    //         ContestStatus.terminated => 'Terminated',
                    //         ContestStatus.deleted => 'Deleted',
                    //       },
                    //       style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    //             color: switch (
                    //                 state.contestDetailsBundle!.contestBundle.contest.contestStatus) {
                    //               ContestStatus.preparationPhase =>
                    //                 Theme.of(context).colorScheme.statusPreparation,
                    //               ContestStatus.participationPhase =>
                    //                 Theme.of(context).colorScheme.statusParticipation,
                    //               ContestStatus.votingPhase =>
                    //                 Theme.of(context).colorScheme.statusVoting,
                    //               ContestStatus.terminated =>
                    //                 Theme.of(context).colorScheme.statusTerminated,
                    //               ContestStatus.deleted =>
                    //                 Theme.of(context).colorScheme.statusDeleted,
                    //             },
                    //           ),
                    //     ),
                    //   ],
                    // ),
                    //* Images carousel
                    SizedBox(
                      height: 180,
                      child: (state.contestDetailsBundle!.contestBundle.contest.imagesPaths.isEmpty)
                          ? ListView(
                              scrollDirection: Axis.horizontal,
                              children: [
                                Icon(Icons.broken_image_outlined),
                              ],
                            )
                          : ListView.builder(
                              scrollDirection: Axis.horizontal,
                              itemCount: state
                                  .contestDetailsBundle!.contestBundle.contest.imagesPaths.length,
                              itemBuilder: (context, index) {
                                final imageUrl = state
                                    .contestDetailsBundle!.contestBundle.contest.imagesPaths[index];
                                return Padding(
                                  padding: const EdgeInsets.only(right: 8),
                                  child: StorageImage(
                                    bucket: StorageBucket.contestsImages,
                                    path: imageUrl,
                                    fit: BoxFit.contain,
                                  ),
                                  // Image.network(
                                  //   state.contestDetailsBundle!.contestBundle.contest
                                  //       .imagesUrls[index],
                                  //   fit: BoxFit.contain,
                                  //   frameBuilder:
                                  //       (context, child, frame, wasSynchronouslyLoaded) {
                                  //     if (wasSynchronouslyLoaded || frame != null) return child;
                                  //     return const Loader();
                                  //   },
                                  //   errorBuilder: (context, error, stackTrace) {
                                  //     return Image.asset(
                                  //       'assets/images/image_not_found.jpg',
                                  //       fit: BoxFit.cover,
                                  //     );
                                  //   },
                                  // ),
                                );
                              },
                            ),
                    ),
                    SizedBox(height: 8),
                    //* Description
                    Text(
                      'Description',
                      style: Theme.of(context)
                          .textTheme
                          .titleMedium
                          ?.copyWith(color: Theme.of(context).colorScheme.secondary),
                    ),
                    Text(
                      state.contestDetailsBundle!.contestBundle.contest.description,
                    ),
                    SizedBox(height: 20),
                    //* Info
                    Text(
                      'Info',
                      style: Theme.of(context)
                          .textTheme
                          .titleMedium
                          ?.copyWith(color: Theme.of(context).colorScheme.secondary),
                    ),
                    //* Organizer
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.person_rounded,
                          size: 24,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            state.contestDetailsBundle!.contestBundle.organizer.fullName,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 8),
                    //* Members
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.people,
                          size: 24,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        SizedBox(width: 4),
                        Expanded(
                          child: Text(
                              'Participants: ${state.contestDetailsBundle!.participantsNumber} | '
                              'Jurors: ${state.contestDetailsBundle!.jurorsNumber}'),
                        ),
                      ],
                    ),
                    SizedBox(height: 8),
                    //* Place
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.location_on_rounded,
                          size: 24,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        SizedBox(width: 4),
                        Expanded(
                          child: GestureDetector(
                            onTap: () async {
                              final address =
                                  state.contestDetailsBundle!.contestBundle.place.address;
                              final query = Uri.encodeComponent(address);
                              final uri = Uri.parse(
                                  'https://www.google.com/maps/search/?api=1&query=$query');

                              if (await canLaunchUrl(uri)) {
                                await launchUrl(uri, mode: LaunchMode.externalApplication);
                              } else {
                                if (context.mounted) {
                                  showSnackBar(
                                      context: context,
                                      text: 'It has not been possible to open the map');
                                }
                              }
                            },
                            child: Text(
                              state.contestDetailsBundle!.contestBundle.place.address,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium
                                  ?.copyWith(decoration: TextDecoration.underline),
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 8),
                    //* DateTime
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.calendar_month_rounded,
                          size: 24,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            DateFormat('dd MMM, yyyy | HH:mm')
                                .format(state.contestDetailsBundle!.contestBundle.contest.dateTime),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 20),
                    //* Participations
                    Text(
                      'Participation',
                      style: Theme.of(context)
                          .textTheme
                          .titleMedium
                          ?.copyWith(color: Theme.of(context).colorScheme.secondary),
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Text(
                          'Start:',
                          style: Theme.of(context).textTheme.labelMedium,
                        ),
                        SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            DateFormat('dd MMM, yyyy | HH:mm').format(state
                                .contestDetailsBundle!.contestBundle.contest.worksSubmissionStart),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 4),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Text(
                          'End:',
                          style: Theme.of(context).textTheme.labelMedium,
                        ),
                        SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            DateFormat('dd MMM, yyyy | HH:mm').format(state
                                .contestDetailsBundle!.contestBundle.contest.worksSubmissionEnd),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 100),
                  ],
                ),
              );
            },
          ),
          floatingActionButton: (state.isInitialized) ? _buildFab(context, state) : null,
        );
      },
    );
  }

  Widget _buildFab(BuildContext context, JurorContestDetailsPageState state) {
    final liveVotingSessionBundle = state.contestDetailsBundle!.liveVotingSessionBundle;
    return Column(
      mainAxisSize: MainAxisSize.min,
      spacing: 8,
      children: [
        Text(
          (liveVotingSessionBundle != null) ? 'Voting session is live' : 'No voting session live',
          style: Theme.of(context).textTheme.labelMedium,
        ),
        FloatingActionButton.extended(
          onPressed: (liveVotingSessionBundle != null)
              ? () async {
                  bool? proceed = true;
                  if (liveVotingSessionBundle.votingSession.isGeoRestricted) {
                    proceed = await showDialog<bool?>(
                      context: context,
                      builder: (_) {
                        return AlertDialog(
                          title: Text('Geo locate'),
                          content: Text(
                              'This voting session is restricted to a specific geographic area. '
                              'It is recommended to verify location before proceed.'),
                          actions: [
                            TextButton(
                              onPressed: () => context.pop(),
                              child: Text('Cancel'),
                            ),
                            TextButton(
                              onPressed: () async {
                                context
                                    .read<JurorContestDetailsPageBloc>()
                                    .add(JurorContestDetailsPageCheckVotingLocation());
                              },
                              child: Text('Verify'),
                            ),
                            TextButton(
                              onPressed: () => context.router.pop(true),
                              child: Text('Proceed'),
                            ),
                          ],
                        );
                      },
                    );
                  }

                  if (proceed == true && context.mounted) {
                    final bool? res = await context.router.push(JurorVotingProcedureRoute(
                        votingSessionId: liveVotingSessionBundle.votingSession.id!));
                    if (res == true && context.mounted) {
                      context
                          .read<JurorContestDetailsPageBloc>()
                          .add(JurorContestDetailsPageFetch(contestId: contestId));
                    }
                  }
                }
              : null,
          backgroundColor:
              (liveVotingSessionBundle == null) ? Theme.of(context).disabledColor : null,
          icon: Icon(Icons.text_snippet),
          label: Text('Vote'),
        ),
      ],
    );
  }
}
