import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:swift_contest/model/data_models/contest/contest_status.dart';
import 'package:swift_contest/utils/themes/color_scheme_extension.dart';
import 'package:swift_contest/view/widgets/loader.dart';
import 'package:swift_contest/view/widgets/show_snack_bar.dart';
import 'package:swift_contest/viewmodel/blocs/organizer_pages_blocs/organizer_contest_details_page_bloc/organizer_contest_details_page_bloc.dart';
import 'package:swift_contest/viewmodel/utils/bloc_status.dart';

class OrganizerDetailsTab extends StatefulWidget {
  final String contestId;

  const OrganizerDetailsTab({super.key, required this.contestId});

  @override
  State<OrganizerDetailsTab> createState() => _OrganizerDetailsTabState();
}

class _OrganizerDetailsTabState extends State<OrganizerDetailsTab> {
  @override
  void initState() {
    super.initState();
    final state = context.read<OrganizerContestDetailsPageBloc>().state;
    if (state.contest == null) {
      context
          .read<OrganizerContestDetailsPageBloc>()
          .add(OrganizerContestDetailsPageGetExtendedContest(contestId: widget.contestId));
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<OrganizerContestDetailsPageBloc, OrganizerContestDetailsPageState>(
      listener: (context, state) {
        if(state.status == BlocStatus.failure) {
          showSnackBar(context: context, text: state.message!);
        }
      },
      builder: (context, state) {
        if (state.status == BlocStatus.loading) {
          return Loader();
        }
        if (state.status == BlocStatus.success) {
          return RefreshIndicator.adaptive(
            onRefresh: () async => context
                .read<OrganizerContestDetailsPageBloc>()
                .add(OrganizerContestDetailsPageGetExtendedContest(contestId: widget.contestId)),
            child: ListView(
              // mainAxisSize: MainAxisSize.min,
              // mainAxisAlignment: MainAxisAlignment.start,
              // crossAxisAlignment: CrossAxisAlignment.start,
              // spacing: 8,
              physics: AlwaysScrollableScrollPhysics(),
              children: [
                //* Title and status
                Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: 2,
                  children: [
                    Text(
                      state.contest!.name,
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
                    ),
                    SizedBox(height: 8),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      spacing: 4,
                      children: [
                        Icon(
                          Icons.circle,
                          size: 20,
                          color: switch (state.contest!.status) {
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
                          switch (state.contest!.status) {
                            ContestStatus.preparationPhase => 'Preparation phase',
                            ContestStatus.participationPhase => 'Participation phase',
                            ContestStatus.votingPhase => 'Voting phase',
                            ContestStatus.terminated => 'Terminated',
                            ContestStatus.deleted => 'Deleted',
                          },
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                            color: switch (state.contest!.status) {
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
                  ],
                ),
                SizedBox(height: 8),
                //* Images carousel
                SizedBox(
                  height: 180,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: state.contest!.imagesUrls.length,
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: Image.network(
                          state.contest!.imagesUrls[index],
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
                SizedBox(height: 8),
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
                    Text(state.contest!.description, style: TextStyle(fontSize: 18)),
                  ],
                ),
                SizedBox(height: 8),
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
                        '${state.organizer!.firstName} ${state.organizer!.lastName}',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 8),
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
                        state.contest!.place.address,
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 8),
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
                        DateFormat('dd MMM, yyyy | HH:mm').format(state.contest!.dateTime),
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 8),
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
                          DateFormat('dd MMM, yyyy | HH:mm').format(state.contest!.worksDateTimeFrom),
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
                          DateFormat('dd MMM, yyyy | HH:mm').format(state.contest!.worksDateTimeTo),
                        ),
                      ],
                    ),
                  ],
                ),
                SizedBox(height: 8),
                //* Works preview for jurors
                Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Works preview for invited jurors',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                    ),
                    Text(
                      (state.contest!.worksPreviewJurors) ? 'At participation\'s closure' : 'Never',
                      style: TextStyle(fontSize: 16),
                    ),
                  ],
                ),
              ],
            ),
          );
        }
        return RefreshIndicator.adaptive(onRefresh: () async {
          context
              .read<OrganizerContestDetailsPageBloc>()
              .add(OrganizerContestDetailsPageGetExtendedContest(contestId: widget.contestId));
        },
        child: ListView(),
        );
      },
    );
  }
}
