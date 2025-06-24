import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:swift_contest/model/enums/contest_status.dart';
import 'package:swift_contest/utils/functions/show_snack_bar.dart';
import 'package:swift_contest/utils/themes/color_scheme_x.dart';
import 'package:swift_contest/view/widgets/loader.dart';
import 'package:swift_contest/viewmodel/blocs/pages_blocs/juror_contest_details_page_bloc/juror_contest_details_page_bloc.dart';
import 'package:swift_contest/viewmodel/enums/bloc_status.dart';

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
  void didChangeDependencies() {
    super.didChangeDependencies();
    final state = context.read<JurorContestDetailsPageBloc>().state;
    if (state.status.isInitial) {
      context
          .read<JurorContestDetailsPageBloc>()
          .add(JurorContestDetailsPageInit(contestId: contestId));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocBuilder<JurorContestDetailsPageBloc, JurorContestDetailsPageState>(
        builder: (context, state) {
          switch (state.status) {
            case BlocStatus.initial:
              return SizedBox.shrink();
            case BlocStatus.loading:
              return Loader();
            case BlocStatus.failure:
              if (state.sourceEvent is JurorContestDetailsPageInit) {
                return RefreshIndicator.adaptive(
                  onRefresh: () async => context
                      .read<JurorContestDetailsPageBloc>()
                      .add(JurorContestDetailsPageRefresh(contestId: contestId)),
                  child: ListView(),
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
                child: ListView(
                  children: [
                    //* Title
                    Text(
                      state.contestDetailsBundle!.contest.name,
                      style: Theme.of(context)
                          .textTheme
                          .titleLarge
                          ?.copyWith(color: Theme.of(context).colorScheme.primary),
                    ),
                    SizedBox(height: 6),
                    //* Status
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.circle,
                          size: 18,
                          color: switch (state.contestDetailsBundle!.contest.contestStatus) {
                            ContestStatus.preparationPhase =>
                              Theme.of(context).colorScheme.statusPreparation,
                            ContestStatus.participationPhase =>
                              Theme.of(context).colorScheme.statusParticipation,
                            ContestStatus.votingPhase => Theme.of(context).colorScheme.statusVoting,
                            ContestStatus.terminated =>
                              Theme.of(context).colorScheme.statusTerminated,
                            ContestStatus.deleted => Theme.of(context).colorScheme.statusDeleted,
                          },
                        ),
                        SizedBox(width: 2),
                        Text(
                          switch (state.contestDetailsBundle!.contest.contestStatus) {
                            ContestStatus.preparationPhase => 'Preparation phase',
                            ContestStatus.participationPhase => 'Participation phase',
                            ContestStatus.votingPhase => 'Voting phase',
                            ContestStatus.terminated => 'Terminated',
                            ContestStatus.deleted => 'Deleted',
                          },
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: switch (state.contestDetailsBundle!.contest.contestStatus) {
                                  ContestStatus.preparationPhase =>
                                    Theme.of(context).colorScheme.statusPreparation,
                                  ContestStatus.participationPhase =>
                                    Theme.of(context).colorScheme.statusParticipation,
                                  ContestStatus.votingPhase =>
                                    Theme.of(context).colorScheme.statusVoting,
                                  ContestStatus.terminated =>
                                    Theme.of(context).colorScheme.statusTerminated,
                                  ContestStatus.deleted =>
                                    Theme.of(context).colorScheme.statusDeleted,
                                },
                              ),
                        ),
                      ],
                    ),
                    SizedBox(height: 12),
                    //* Images carousel
                    SizedBox(
                      height: 180,
                      child: (state.contestDetailsBundle!.contest.imagesUrls.isEmpty)
                          ? ListView(
                              scrollDirection: Axis.horizontal,
                              children: [
                                Image.asset('assets/images/image_not_found.jpg',
                                    fit: BoxFit.contain),
                              ],
                            )
                          : ListView.builder(
                              scrollDirection: Axis.horizontal,
                              itemCount: state.contestDetailsBundle!.contest.imagesUrls.length,
                              itemBuilder: (context, index) {
                                return Padding(
                                  padding: const EdgeInsets.only(right: 8),
                                  child: Image.network(
                                    state.contestDetailsBundle!.contest.imagesUrls[index],
                                    fit: BoxFit.contain,
                                    frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
                                      if (wasSynchronouslyLoaded || frame != null) return child;
                                      return const Loader();
                                    },
                                    errorBuilder: (context, error, stackTrace) {
                                      return Image.asset(
                                        'assets/images/image_not_found.jpg',
                                        fit: BoxFit.cover,
                                      );
                                    },
                                  ),
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
                      state.contestDetailsBundle!.contest.description,
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
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.person_rounded,
                          size: 24,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        SizedBox(width: 4),
                        Text(
                          state.contestDetailsBundle!.organizer.fullName,
                        ),
                      ],
                    ),
                    SizedBox(height: 8),
                    //* Members
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.people,
                          size: 24,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        SizedBox(width: 4),
                        Text(
                            'Participants: ${state.contestDetailsBundle!.joinedParticipationsBundles.length} | '
                            'Jurors: ${state.contestDetailsBundle!.joinedJurationsBundles.length}'),
                      ],
                    ),
                    //* Place
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.location_on_rounded,
                          size: 24,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        SizedBox(width: 4),
                        Text(
                          state.contestDetailsBundle!.place.address,
                        ),
                      ],
                    ),
                    SizedBox(height: 8),
                    //* DateTime
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.calendar_month_rounded,
                          size: 24,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        SizedBox(width: 4),
                        Text(
                          DateFormat('dd MMM, yyyy | HH:mm')
                              .format(state.contestDetailsBundle!.contest.dateTime),
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
                        Text(
                          DateFormat('dd MMM, yyyy | HH:mm')
                              .format(state.contestDetailsBundle!.contest.worksSubmissionStart),
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
                        Text(
                          DateFormat('dd MMM, yyyy | HH:mm')
                              .format(state.contestDetailsBundle!.contest.worksSubmissionEnd),
                        ),
                      ],
                    ),
                  ],
                ),
              );
          }
        },
      ),
    );
  }
}
