import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:swift_contest/model/data_models/contest/contest_status.dart';
import 'package:swift_contest/utils/themes/color_scheme_extension.dart';
import 'package:swift_contest/view/widgets/loader.dart';
import 'package:swift_contest/view/widgets/show_snack_bar.dart';
import 'package:swift_contest/viewmodel/blocs/participant_pages_blocs/participant_contest_details_page_bloc/participant_contest_details_page_bloc.dart';
import 'package:swift_contest/viewmodel/utils/bloc_status.dart';

class ParticipantDetailsTab extends StatefulWidget {
  final String contestId;

  const ParticipantDetailsTab({super.key, required this.contestId});

  @override
  State<ParticipantDetailsTab> createState() => _ParticipantDetailsTabState();
}

class _ParticipantDetailsTabState extends State<ParticipantDetailsTab> {
  @override
  void initState() {
    super.initState();
    final state = context.read<ParticipantContestDetailsPageBloc>().state;
    if(state.contest == null) {
      context
          .read<ParticipantContestDetailsPageBloc>()
          .add(ParticipantContestDetailsPageGetExtendedContest(contestId: widget.contestId));
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ParticipantContestDetailsPageBloc, ParticipantContestDetailsPageState>(
      listener: (context, state) {
        if (state.status == BlocStatus.failure) {
          showSnackBar(context: context, text: state.message!);
        }
      },
      builder: (context, state) {
        if (state.status == BlocStatus.loading) {
          return Loader();
        }
        if (state.status == BlocStatus.success) {
          final contest = state.contest!;
          final organizer = state.organizer!;
          return RefreshIndicator.adaptive(
            onRefresh: () async {
              context.read<ParticipantContestDetailsPageBloc>().add(
                  ParticipantContestDetailsPageGetExtendedContest(contestId: widget.contestId));
            },
            child: ListView(
              children: [
                //* Title and status
                Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: 2,
                  children: [
                    Text(
                      contest.name,
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      spacing: 4,
                      children: [
                        Icon(
                          Icons.circle,
                          size: 20,
                          color: switch (contest.status) {
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
                        Text(
                          switch (contest.status) {
                            ContestStatus.preparationPhase => 'Preparation phase',
                            ContestStatus.participationPhase => 'Participation phase',
                            ContestStatus.votingPhase => 'Voting phase',
                            ContestStatus.terminated => 'Terminated',
                            ContestStatus.deleted => 'Deleted',
                          },
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                            color: switch (contest.status) {
                              ContestStatus.preparationPhase =>
                                Theme.of(context).colorScheme.statusPreparation,
                              ContestStatus.participationPhase =>
                                Theme.of(context).colorScheme.statusParticipation,
                              ContestStatus.votingPhase =>
                                Theme.of(context).colorScheme.statusVoting,
                              ContestStatus.terminated =>
                                Theme.of(context).colorScheme.statusTerminated,
                              ContestStatus.deleted => Theme.of(context).colorScheme.statusDeleted,
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                //* Images carousel
                SizedBox(
                  height: 180,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: contest.imagesUrls.length,
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: Image.network(
                          contest.imagesUrls[index],
                          fit: BoxFit.contain,
                          frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
                            if (wasSynchronouslyLoaded || frame != null) return child;
                            return const Loader();
                          },
                        ),
                      );
                    },
                  ),
                ),
                // CarouselSlider(
                //   options: CarouselOptions(
                //     height: 200,
                //     enableInfiniteScroll: false,
                //     clipBehavior: Clip.none,
                //   ),
                //   items: contestAndOrganizer.imagesUrls.map((imageUrl) {
                //     return Builder(
                //       builder: (BuildContext context) {
                //         return Image.network(
                //           imageUrl,
                //           fit: BoxFit.contain,
                //           // width: 10,
                //           frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
                //             if (wasSynchronouslyLoaded || frame != null) return child;
                //             return const Loader();
                //           },
                //         );
                //       },
                //     );
                //   }).toList(),
                // ),
                //* Description
                Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Description',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                    ),
                    Text(contest.description, style: TextStyle(fontSize: 18)),
                  ],
                ),
                //* Organizer name
                Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: 4,
                  children: [
                    Icon(
                      Icons.person_rounded,
                      size: 24,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    Expanded(
                      child: Text(
                        '${organizer.firstName} ${organizer.lastName}',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                      ),
                    ),
                  ],
                ),
                //* Place
                Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: 4,
                  children: [
                    Icon(
                      Icons.location_on_rounded,
                      size: 24,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    Expanded(
                      child: Text(
                        contest.place.address,
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                      ),
                    ),
                  ],
                ),
                //* DateTime
                Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: 4,
                  children: [
                    Icon(
                      Icons.calendar_month_rounded,
                      size: 24,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    Expanded(
                      child: Text(
                        // '12Jan, 2025 | 15:00',
                        DateFormat('dd MMM, yyyy | HH:mm').format(contest.dateTime),
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                      ),
                    ),
                  ],
                ),
                //* Work upload deadline
                Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Work upload deadline for participants',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      spacing: 8,
                      children: [
                        Text('From:'),
                        Text(
                          DateFormat('dd MMM, yyyy | HH:mm').format(contest.worksDateTimeFrom),
                        ),
                      ],
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      spacing: 8,
                      children: [
                        Text('To:'),
                        Text(
                          DateFormat('dd MMM, yyyy | HH:mm').format(contest.worksDateTimeTo),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          );
        }
        return RefreshIndicator.adaptive(
          onRefresh: () async {
            context
                .read<ParticipantContestDetailsPageBloc>()
                .add(ParticipantContestDetailsPageGetExtendedContest(contestId: widget.contestId));
          },
          child: ListView(),
        );
      },
    );
  }
}
