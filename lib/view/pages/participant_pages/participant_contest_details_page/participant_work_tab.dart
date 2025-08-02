import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:swift_contest/utils/functions/now.dart';
import 'package:swift_contest/utils/labels/labels.dart';
import 'package:swift_contest/utils/router/app_router.gr.dart';
import 'package:swift_contest/view/widgets/list_view_with_central_label.dart';
import 'package:swift_contest/view/widgets/loader.dart';
import 'package:swift_contest/view/widgets/overlay_loader.dart';
import 'package:swift_contest/view/widgets/void_widget.dart';
import 'package:swift_contest/viewmodel/blocs/auth_bloc/auth_bloc.dart';
import 'package:swift_contest/viewmodel/blocs/pages_blocs/participant_contest_details_page_bloc/participant_contest_details_page_bloc.dart';
import 'package:swift_contest/viewmodel/enums/bloc_status.dart';

class ParticipantWorkTab extends StatefulWidget {
  final String contestId;

  const ParticipantWorkTab({
    required this.contestId,
    super.key,
  });

  @override
  State<ParticipantWorkTab> createState() => _ParticipantWorkTabState();
}

class _ParticipantWorkTabState extends State<ParticipantWorkTab> {
  late String profileId;
  late final String contestId;

  @override
  void initState() {
    super.initState();
    contestId = widget.contestId;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    profileId = context.read<AuthBloc>().state.profile!.id!;
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
                              contestId: contestId, participantId: profileId)),
                      child: Text('Retry'),
                    ),
                  );
                }
                return VoidWidget();
              }
              return LayoutBuilder(
                builder: (context, constraints) {
                  final work = state.ownParticipationBundle!.work;
                  return RefreshIndicator.adaptive(
                    onRefresh: () async => context
                        .read<ParticipantContestDetailsPageBloc>()
                        .add(ParticipantContestDetailsPageFetch(
                        contestId: contestId, participantId: profileId)),
                    child: (work != null)
                        ? ListView(
                      children: [
                        //* Title
                        Text(
                          work.name,
                          style: Theme.of(context)
                              .textTheme
                              .titleLarge
                              ?.copyWith(color: Theme.of(context).colorScheme.primary),
                        ),
                        SizedBox(height: 8),
                        //* Images carousel
                        SizedBox(
                          height: 180,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: work.imagesUrls.length,
                            itemBuilder: (context, index) {
                              return Padding(
                                padding: const EdgeInsets.only(right: 8),
                                child: (work.imagesUrls.isNotEmpty)
                                    ? Image.network(
                                  work.imagesUrls[index],
                                  fit: BoxFit.contain,
                                  errorBuilder: (context, error, stackTrace) {
                                    return Image.asset(
                                      'assets/images/image_not_found.jpg',
                                      fit: BoxFit.cover,
                                    );
                                  },
                                  frameBuilder: (context, child, frame,
                                      wasSynchronouslyLoaded) {
                                    if (wasSynchronouslyLoaded || frame != null) {
                                      return child;
                                    }
                                    return const Loader();
                                  },
                                )
                                    : Image.asset('assets/images/image_not_found.jpg',
                                    fit: BoxFit.cover),
                              );
                            },
                          ),
                        ),
                        SizedBox(height: 12),
                        //* Description
                        Text(
                          'Description',
                          style: Theme.of(context)
                              .textTheme
                              .titleMedium
                              ?.copyWith(color: Theme.of(context).colorScheme.secondary),
                        ),
                        Text(work.description),
                        SizedBox(height: 16),
                        //* File
                        // Text(
                        //   'File',
                        //   style: Theme.of(context)
                        //       .textTheme
                        //       .titleMedium
                        //       ?.copyWith(color: Theme.of(context).colorScheme.secondary),
                        // ),
                        // Card(
                        //   elevation: 0.1,
                        //   color: Theme.of(context).colorScheme.tertiaryContainer,
                        //   child: ListTile(
                        //     title: Text(
                        //       work!.fileUrl.split('/').last,
                        //       style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        //           color:
                        //               Theme.of(context).colorScheme.onTertiaryContainer),
                        //       maxLines: 1,
                        //       overflow: TextOverflow.ellipsis,
                        //     ),
                        //     trailing: IconButton(
                        //       onPressed: () async {
                        //         if (!await requestStoragePermission()) {
                        //           if (context.mounted) {
                        //             showSnackBar(
                        //                 context: context, text: 'Permission denied');
                        //           }
                        //           return;
                        //         }
                        //
                        //         final directory =
                        //             await ExternalPath.getExternalStoragePublicDirectory(
                        //                 ExternalPath.DIRECTORY_DOWNLOAD);
                        //
                        //         final originalFilename =
                        //             work!.fileUrl.split('/').last;
                        //         final baseName =
                        //             p.basenameWithoutExtension(originalFilename);
                        //         final extension = p.extension(originalFilename);
                        //
                        //         String safeFilename;
                        //         int count = 0;
                        //         do {
                        //           safeFilename = (count == 0)
                        //               ? originalFilename
                        //               : '$baseName ($count)$extension';
                        //           count++;
                        //         } while (await File('$directory/$safeFilename').exists());
                        //
                        //         final path = '$directory/$safeFilename';
                        //
                        //         try {
                        //           await Dio().download(
                        //             work!.fileUrl,
                        //             path,
                        //             onReceiveProgress: (received, total) {
                        //               if (total != -1) {
                        //                 // opzionale: mostra progress %
                        //                 final pct =
                        //                     (received / total * 100).toStringAsFixed(0);
                        //                 debugPrint('Download: $pct%');
                        //               }
                        //             },
                        //           );
                        //         } catch (e) {
                        //           debugPrint('Download error: $e');
                        //           if (context.mounted) {
                        //             showSnackBar(
                        //                 context: context, text: Labels.anErrorOccurred);
                        //           }
                        //           return;
                        //         }
                        //
                        //         if (context.mounted) {
                        //           showSnackBar(
                        //               context: context,
                        //               text:
                        //                   'File successfully downloaded in "Downloads" directory');
                        //         }
                        //
                        //         await OpenFile.open(path,
                        //             type: MediaTypes.mapExtension(extension));
                        //       },
                        //       icon: Icon(
                        //         Icons.download_rounded,
                        //         color: Theme.of(context).colorScheme.onTertiaryContainer,
                        //       ),
                        //     ),
                        //   ),
                        // ),
                      ],
                    )
                        : ListViewWithCentralLabel(
                        label: (state.contestDetailsBundle!.contestBundle.contest.worksSubmissionStart
                            .isBefore(now()) &&
                            state.contestDetailsBundle!.contestBundle.contest.worksSubmissionEnd
                                .isAfter(now()))
                            ? 'No work submitted yet'
                            : 'No work submitted.\n Period of participation is passed'),
                  );
                },
              );
            },
          ),
          floatingActionButton: Builder(
            builder: (context) {
              final bool isInParticipationPhase =
                  state.contestDetailsBundle!.contestBundle.contest.worksSubmissionStart.isBefore(now()) &&
                      state.contestDetailsBundle!.contestBundle.contest.worksSubmissionEnd.isAfter(now());
              if (state.status.isSuccess && state.ownParticipationBundle!.work == null && isInParticipationPhase) {
                return FloatingActionButton.extended(
                  onPressed: () async {
                    final bool? res =
                        await context.router.push(ParticipantWorkSubmitRoute(contestId: contestId));
                    if (res == true) {
                      if (context.mounted) {
                        context.read<ParticipantContestDetailsPageBloc>().add(
                            ParticipantContestDetailsPageFetch(
                                contestId: contestId, participantId: profileId));
                      }
                    }
                  },
                  elevation: 1,
                  label: Text('Submit work'),
                );
              }
              return VoidWidget();
            },
          ),
        );
      },
    );
  }
}
