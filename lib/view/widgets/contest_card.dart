import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:swift_contest/model/database/bundles/home_contest_bundle.dart';
import 'package:swift_contest/model/database/types/storage_bucket.dart';
import 'package:swift_contest/view/widgets/storage_image.dart';

class ContestCard extends StatefulWidget {
  final HomeContestBundle homeContestBundle;
  final void Function() onTap;

  const ContestCard({
    required this.homeContestBundle,
    required this.onTap,
    super.key,
  });

  @override
  State<ContestCard> createState() => _ContestCardState();
}

class _ContestCardState extends State<ContestCard> {
  @override
  Widget build(BuildContext context) {
    final homeContestBundle = widget.homeContestBundle;
    final contest = homeContestBundle.contestBundle.contest;
    final organizer = homeContestBundle.contestBundle.organizer;
    final place = homeContestBundle.contestBundle.place;

    return ConstrainedBox(
      constraints: BoxConstraints(maxWidth: 600),
      child: Card(
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () {
            widget.onTap();
          },
          child: Padding(
            padding: EdgeInsets.all(8),
            //* Card internal
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 12,
              children: [
                //* First card column
                Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    //* Card image box
                    SizedBox(
                      width: 80,
                      height: 80,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        clipBehavior: Clip.antiAlias,
                        child: FittedBox(
                          fit: BoxFit.cover,
                          clipBehavior: Clip.hardEdge,
                          alignment: Alignment.center,
                          child: (contest.imagesPaths.isNotEmpty)
                              ? StorageImage(
                                  bucket: StorageBucket.contestsImages,
                                  path: contest.imagesPaths[0],
                                  fit: BoxFit.cover,
                                )
                              : Icon(Icons.broken_image_outlined),
                        ),
                      ),
                    ),
                  ],
                ),
                //* Second card column
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    spacing: 4,
                    children: [
                      //* Title and status circle row
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          //* Title
                          Expanded(
                            child: Text(
                              contest.name,
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium
                                  ?.copyWith(color: Theme.of(context).colorScheme.primary),
                            ),
                          ),
                          //* Status circle
                          // Icon(
                          //   Icons.circle,
                          //   size: 20,
                          //   color: switch (contest.contestStatus) {
                          //     ContestStatus.preparationPhase =>
                          //       Theme.of(context).colorScheme.statusPreparation,
                          //     ContestStatus.participationPhase =>
                          //       Theme.of(context).colorScheme.statusParticipation,
                          //     ContestStatus.votingPhase =>
                          //       Theme.of(context).colorScheme.statusVoting,
                          //     ContestStatus.terminated =>
                          //       Theme.of(context).colorScheme.statusTerminated,
                          //     ContestStatus.deleted => Theme.of(context).colorScheme.statusDeleted,
                          //   },
                          // ),
                        ],
                      ),
                      //* Organizer name
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        spacing: 4,
                        children: [
                          Icon(
                            Icons.person_rounded,
                            size: 20,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                          Expanded(
                            flex: 1,
                            child: Text(
                              organizer.fullName,
                              style: DefaultTextStyle.of(context)
                                  .style
                                  .copyWith(color: Theme.of(context).colorScheme.secondary),
                            ),
                          ),
                        ],
                      ),
                      //* Place
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        spacing: 4,
                        children: [
                          Icon(
                            Icons.location_on_rounded,
                            size: 20,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                          Expanded(
                            flex: 1,
                            child: Text(
                              place.address,
                              style: DefaultTextStyle.of(context)
                                  .style
                                  .copyWith(color: Theme.of(context).colorScheme.secondary),
                            ),
                          ),
                        ],
                      ),
                      //* DateTime
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        spacing: 4,
                        children: [
                          Icon(
                            Icons.calendar_month_rounded,
                            size: 20,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                          Expanded(
                            flex: 1,
                            child: Text(
                              DateFormat('dd MMM, yyyy | HH:mm').format(contest.dateTime),
                              style: DefaultTextStyle.of(context)
                                  .style
                                  .copyWith(color: Theme.of(context).colorScheme.secondary),
                            ),
                          ),
                        ],
                      ),
                      //* Members
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        spacing: 4,
                        children: [
                          Icon(
                            Icons.people_alt_rounded,
                            size: 20,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                          Expanded(
                            flex: 1,
                            child: Text(
                              'Participants: ${homeContestBundle.participantsNumber} | Jurors: ${homeContestBundle.jurorsNumber}',
                              style: DefaultTextStyle.of(context)
                                  .style
                                  .copyWith(color: Theme.of(context).colorScheme.secondary),
                            ),
                          ),
                        ],
                      ),
                      //* Status
                      // Text(
                      //   switch (contest.contestStatus) {
                      //     ContestStatus.preparationPhase => 'Preparation phase',
                      //     ContestStatus.participationPhase => 'Participation phase',
                      //     ContestStatus.votingPhase => 'Voting phase',
                      //     ContestStatus.terminated => 'Terminated',
                      //     ContestStatus.deleted => 'Deleted',
                      //   },
                      //   style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      //     color: switch(contest.contestStatus) {
                      //       ContestStatus.preparationPhase =>
                      //       Theme.of(context).colorScheme.statusPreparation,
                      //       ContestStatus.participationPhase =>
                      //       Theme.of(context).colorScheme.statusParticipation,
                      //       ContestStatus.votingPhase => Theme.of(context).colorScheme.statusVoting,
                      //       ContestStatus.terminated =>
                      //       Theme.of(context).colorScheme.statusTerminated,
                      //       ContestStatus.deleted => Theme.of(context).colorScheme.statusDeleted,
                      //     }
                      //   ),
                      // ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
