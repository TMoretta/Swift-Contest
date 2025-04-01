import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:swift_contest/model/data_models/contest/contest.dart';
import 'package:swift_contest/model/data_models/contest/contest_status.dart';
import 'package:swift_contest/model/data_models/juration/juration.dart';
import 'package:swift_contest/model/data_models/juration/juration_status.dart';
import 'package:swift_contest/model/data_models/participation/participation.dart';
import 'package:swift_contest/model/data_models/participation/participation_status.dart';
import 'package:swift_contest/model/data_models/profile/profile.dart';
import 'package:swift_contest/utils/themes/color_scheme_extension.dart';

class ContestCard extends StatefulWidget {
  final Contest contest;
  final Profile organizer;
  final List<Participation> participations;
  final List<Juration> jurations;
  final void Function() onTap;

  const ContestCard({
    required this.contest,
    required this.organizer,
    required this.participations,
    required this.jurations,
    required this.onTap,
    super.key,
  });

  @override
  State<ContestCard> createState() => _ContestCardState();
}

class _ContestCardState extends State<ContestCard> {
  @override
  Widget build(BuildContext context) {
    int participationsJoinedCount = 0;
    for (var participation in widget.participations) {
      if (participation.status == ParticipationStatus.joined) {
        ++participationsJoinedCount;
      }
    }
    int jurationsJoinedCount = 0;
    for (var juration in widget.jurations) {
      if (juration.status == JurationStatus.joined) {
        ++jurationsJoinedCount;
      }
    }
    return Card(
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
                        clipBehavior: Clip.antiAlias,
                        alignment: Alignment.center,
                        child: (widget.contest.imagesUrls.isNotEmpty)
                            ? Image.network(
                                widget.contest.imagesUrls[0],
                                errorBuilder: (context, error, stackTrace) {
                                  return Image.asset(
                                    'assets/images/image_not_found.jpg',
                                    fit: BoxFit.cover,
                                  );
                                },
                              )
                            : Image.asset('assets/images/image_not_found.jpg', fit: BoxFit.cover),
                      ),
                    ),
                  ),
                ],
              ),
              //* Second card column
              Expanded(
                flex: 1,
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
                          flex: 1,
                          child: Text(
                            widget.contest.name,
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                          ),
                        ),
                        //* Status circle
                        Icon(
                          Icons.circle,
                          size: 20,
                          color: switch (widget.contest.status) {
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
                            '${widget.organizer.firstName} ${widget.organizer.lastName}',
                            style: TextStyle(fontSize: 16),
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
                            widget.contest.place.address,
                            style: TextStyle(fontSize: 16),
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
                            // '12Jan, 2025 | 15:00',
                            DateFormat('dd MMM, yyyy | HH:mm')
                                .format(widget.contest.dateTime),
                            style: TextStyle(fontSize: 16),
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
                            'Participants: $participationsJoinedCount | Jurors: $jurationsJoinedCount',
                            style: TextStyle(fontSize: 16),
                          ),
                        ),
                      ],
                    ),
                    //* Status
                    Text(
                      switch (widget.contest.status) {
                        ContestStatus.preparationPhase => 'Preparation phase',
                        ContestStatus.participationPhase => 'Participation phase',
                        ContestStatus.votingPhase => 'Voting phase',
                        ContestStatus.terminated => 'Terminated',
                        ContestStatus.deleted => 'Deleted',
                      },
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: switch (widget.contest.status) {
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
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
