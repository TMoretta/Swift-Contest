import 'package:auto_route/auto_route.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:path/path.dart' as path;
import 'package:swift_contest/model/database/types/storage_bucket.dart';
import 'package:swift_contest/utils/functions/now.dart';
import 'package:swift_contest/utils/functions/save_and_launch_file.dart';
import 'package:swift_contest/utils/router/app_router.gr.dart';
import 'package:swift_contest/view/widgets/images_carousel_full_screen.dart';
import 'package:swift_contest/view/widgets/list_view_with_central_label.dart';
import 'package:swift_contest/view/widgets/overlay_loader.dart';
import 'package:swift_contest/view/widgets/show_snack_bar.dart';
import 'package:swift_contest/view/widgets/storage_image.dart';
import 'package:swift_contest/view/widgets/void_widget.dart';
import 'package:swift_contest/viewmodel/blocs/pages_blocs/participant_contest_details_page_bloc/participant_contest_details_page_bloc.dart';
import 'package:swift_contest/viewmodel/types/bloc_status.dart';

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
                      onPressed: () async => context
                          .read<ParticipantContestDetailsPageBloc>()
                          .add(ParticipantContestDetailsPageFetch(contestId: contestId)),
                      child: const Text('Retry'),
                    ),
                  );
                }
                return const VoidWidget();
              }
              return LayoutBuilder(
                builder: (context, constraints) {
                  final work = state.contestDetailsBundle!.ownWork;
                  return RefreshIndicator.adaptive(
                    onRefresh: () async => context
                        .read<ParticipantContestDetailsPageBloc>()
                        .add(ParticipantContestDetailsPageFetch(contestId: contestId)),
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
                              const SizedBox(height: 8),
                              //* Images carousel
                              SizedBox(
                                height: 180,
                                child: ListView.builder(
                                  scrollDirection: Axis.horizontal,
                                  itemCount: work.imagesPaths.length,
                                  itemBuilder: (context, index) {
                                    return Padding(
                                      padding: const EdgeInsets.only(right: 8),
                                      child: (work.imagesPaths.isNotEmpty)
                                          ? GestureDetector(
                                              onTap: () {
                                                // Show the full-screen image viewer dialog
                                                showDialog(
                                                  context: context,
                                                  // Use a custom dialog for a better full-screen experience
                                                  builder: (_) => ImagesCarouselFullScreen(
                                                    bucket: StorageBucket.worksImages,
                                                    imagePaths: work.imagesPaths,
                                                    initialIndex: index,
                                                  ),
                                                );
                                              },
                                              child: StorageImage(
                                                bucket: StorageBucket.worksImages,
                                                path: work.imagesPaths[index],
                                                fit: BoxFit.cover,
                                              ),
                                            )
                                          : const Icon(Icons.broken_image_outlined),
                                    );
                                  },
                                ),
                              ),
                              const SizedBox(height: 12),
                              //* Description
                              Text(
                                'Description',
                                style: Theme.of(context)
                                    .textTheme
                                    .titleMedium
                                    ?.copyWith(color: Theme.of(context).colorScheme.secondary),
                              ),
                              Text(work.description),
                              const SizedBox(height: 16),
                              //* File
                              Text(
                                'File',
                                style: Theme.of(context)
                                    .textTheme
                                    .titleMedium
                                    ?.copyWith(color: Theme.of(context).colorScheme.secondary),
                              ),
                              Card(
                                color: Theme.of(context).colorScheme.tertiaryContainer,
                                elevation: 0,
                                child: ListTile(
                                  title: Text(
                                    path.basename(work.filePath!),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                        color: Theme.of(context).colorScheme.onTertiaryContainer),
                                  ),
                                  trailing: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      BlocListener<ParticipantContestDetailsPageBloc,
                                          ParticipantContestDetailsPageState>(
                                        listener: (context, state) async {
                                          if (state.status.isSuccess &&
                                              state.sourceEvent
                                              is ParticipantContestDetailsPageGetWorkFileUrl) {
                                            final url = state.workFileUrl!;
                                            final dio = Dio();
                                            try {
                                              final response = await dio.get<List<int>>(
                                                url,
                                                options: Options(responseType: ResponseType.bytes),
                                              );
                                              final fileBytes = response.data;

                                              if (fileBytes == null) {
                                                if (context.mounted) {
                                                  showSnackBar(
                                                      context: context,
                                                      text: 'Failed to download file data.');
                                                }
                                                return;
                                              }

                                              final (_, message) = await saveAndLaunchFile(
                                                  fileBytes, path.basename(work.filePath!));
                                              if (context.mounted) {
                                                showSnackBar(
                                                    context: context,
                                                    text: message ?? 'File operation completed.');
                                              }
                                            } catch (e) {
                                              if (context.mounted) {
                                                showSnackBar(context: context, text: 'Download failed.');
                                              }
                                            }
                                          }
                                        },
                                        child: IconButton(
                                          onPressed: () {
                                            context.read<ParticipantContestDetailsPageBloc>().add(
                                                ParticipantContestDetailsPageGetWorkFileUrl(
                                                    filePath: work.filePath!));
                                          },
                                          icon: const Icon(Icons.download),
                                          color: Theme.of(context).colorScheme.onTertiaryContainer,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          )
                        : ListViewWithCentralLabel(
                            label: (state.contestDetailsBundle!.contestBundle.contest
                                        .worksSubmissionStart
                                        .isBefore(now()) &&
                                    state.contestDetailsBundle!.contestBundle.contest
                                        .worksSubmissionEnd
                                        .isAfter(now()))
                                ? 'No work submitted yet'
                                : 'No work submitted.\n Submission period is not on'),
                  );
                },
              );
            },
          ),
          floatingActionButton: Builder(
            builder: (context) {
              final bool isInParticipationPhase = state
                      .contestDetailsBundle!.contestBundle.contest.worksSubmissionStart
                      .isBefore(now()) &&
                  state.contestDetailsBundle!.contestBundle.contest.worksSubmissionEnd
                      .isAfter(now());
              if (state.status.isSuccess &&
                  state.contestDetailsBundle!.ownWork == null &&
                  isInParticipationPhase) {
                return FloatingActionButton.extended(
                  onPressed: () async {
                    final bool? res =
                        await context.router.push(ParticipantWorkSubmitRoute(contestId: contestId));
                    if (res == true) {
                      if (context.mounted) {
                        context
                            .read<ParticipantContestDetailsPageBloc>()
                            .add(ParticipantContestDetailsPageFetch(contestId: contestId));
                      }
                    }
                  },
                  elevation: 1,
                  label: const Text('Submit work'),
                );
              }
              return const VoidWidget();
            },
          ),
        );
      },
    );
  }
}
