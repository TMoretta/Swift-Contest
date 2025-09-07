import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:swift_contest/model/database/types/storage_bucket.dart';
import 'package:swift_contest/view/widgets/images_carousel_full_screen.dart';
import 'package:swift_contest/view/widgets/overlay_loader.dart';
import 'package:swift_contest/view/widgets/show_snack_bar.dart';
import 'package:swift_contest/view/widgets/storage_image.dart';
import 'package:swift_contest/view/widgets/void_widget.dart';
import 'package:swift_contest/viewmodel/blocs/pages_blocs/participant_contest_details_page_bloc/participant_contest_details_page_bloc.dart';
import 'package:swift_contest/viewmodel/types/bloc_status.dart';

class ParticipantDetailsTab extends StatefulWidget {
  final String contestId;

  const ParticipantDetailsTab({
    required this.contestId,
    super.key,
  });

  @override
  State<ParticipantDetailsTab> createState() => _ParticipantDetailsTabState();
}

class _ParticipantDetailsTabState extends State<ParticipantDetailsTab> {
  late final String contestId;

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
    return BlocBuilder<ParticipantContestDetailsPageBloc, ParticipantContestDetailsPageState>(
      builder: (context, state) {
        return Scaffold(
          body: Builder(
            builder: (context) {
              if (!state.isInitialized) {
                if (state.status.isFailure) {
                  return Center(
                    child: FilledButton(
                      onPressed: () async => context.read<ParticipantContestDetailsPageBloc>().add(
                          ParticipantContestDetailsPageFetch(
                              contestId: contestId)),
                      child: Text('Retry'),
                    ),
                  );
                }
                return VoidWidget();
              }
              return RefreshIndicator.adaptive(
                onRefresh: () async => context.read<ParticipantContestDetailsPageBloc>().add(
                    ParticipantContestDetailsPageFetch(
                        contestId: contestId)),
                child: ListView(
                  children: [
                    //* Name
                    Text(
                      state.contestDetailsBundle!.contestBundle.contest.name,
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    SizedBox(height: 12),
                    //* Images carousel
                    SizedBox(
                      height: 180,
                      child:
                      (state.contestDetailsBundle!.contestBundle.contest.imagesPaths.isEmpty)
                          ? ListView(
                        scrollDirection: Axis.horizontal,
                        children: [
                          Icon(Icons.broken_image_outlined),
                        ],
                      )
                          : ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: state.contestDetailsBundle!.contestBundle.contest
                            .imagesPaths.length,
                        itemBuilder: (context, index) {
                          final imageUrl = state.contestDetailsBundle!.contestBundle
                              .contest.imagesPaths[index];
                          return Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: GestureDetector(
                              onTap: () {
                                // Show the full-screen image viewer dialog
                                showDialog(
                                  context: context,
                                  // Use a custom dialog for a better full-screen experience
                                  builder: (_) => ImagesCarouselFullScreen(
                                    bucket: StorageBucket.contestsImages,
                                    imagePaths: state.contestDetailsBundle!.contestBundle
                                        .contest.imagesPaths,
                                    initialIndex: index,
                                  ),
                                );
                              },
                              child: StorageImage(
                                bucket: StorageBucket.contestsImages,
                                path: imageUrl,
                                fit: BoxFit.contain,
                              ),
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
                            onLongPress: () {
                              final address =
                                  state.contestDetailsBundle!.contestBundle.place.address;
                              Clipboard.setData(ClipboardData(text: address));
                              showSnackBar(context: context, text: 'Address copied to clipboard');
                            },
                            child: Text(
                              state.contestDetailsBundle!.contestBundle.place.address,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium,
                            ),
                          ),
                        )
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
                    SizedBox(height: 72),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }
}
