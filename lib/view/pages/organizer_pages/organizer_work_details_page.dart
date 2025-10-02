import 'package:auto_route/auto_route.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:path/path.dart' as path;
import 'package:swift_contest/model/database/types/storage_bucket.dart';
import 'package:swift_contest/utils/functions/save_and_launch_file.dart';
import 'package:swift_contest/view/widgets/custom_app_bar.dart';
import 'package:swift_contest/view/widgets/images_carousel_full_screen.dart';
import 'package:swift_contest/view/widgets/overlay_loader.dart';
import 'package:swift_contest/view/widgets/show_snack_bar.dart';
import 'package:swift_contest/view/widgets/storage_image.dart';
import 'package:swift_contest/view/widgets/void_widget.dart';
import 'package:swift_contest/viewmodel/blocs/pages_blocs/organizer_work_details_page_bloc/organizer_work_details_page_bloc.dart';
import 'package:swift_contest/viewmodel/types/bloc_status.dart';

@RoutePage()
class OrganizerWorkDetailsPage extends StatefulWidget implements AutoRouteWrapper {
  final String participationId;

  const OrganizerWorkDetailsPage({
    @PathParam('participationId') required this.participationId,
    super.key,
  });

  @override
  State<OrganizerWorkDetailsPage> createState() => _OrganizerWorkDetailsPageState();

  @override
  Widget wrappedRoute(BuildContext context) {
    return BlocProvider<OrganizerWorkDetailsPageBloc>(
      create: (context) => OrganizerWorkDetailsPageBloc(
        organizerRepository: context.read(),
        storageRepository: context.read(),
      ),
      child: this,
    );
  }
}

class _OrganizerWorkDetailsPageState extends State<OrganizerWorkDetailsPage> {
  late final String participationId;

  @override
  void initState() {
    super.initState();
    participationId = widget.participationId;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    context.read<OrganizerWorkDetailsPageBloc>().add(OrganizerWorkDetailsPageFetch(
          participationId: participationId,
        ));
  }

  @override
  void dispose() {
    context.hideLoader();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<OrganizerWorkDetailsPageBloc, OrganizerWorkDetailsPageState>(
      listener: (context, state) {
        if (state.status.isLoading) {
          context.showLoader();
        } else {
          context.hideLoader();
        }
      },
      builder: (context, state) {
        return Scaffold(
          appBar: CustomAppBar(
            title: state.participationBundle?.work?.name ?? '',
          ),
          body: SafeArea(
            child: Padding(
              padding: EdgeInsets.only(left: 16, right: 16, top: 16),
              child: Builder(
                builder: (context) {
                  if (!state.isInitialized) {
                    if (state.status.isFailure) {
                      return Center(
                        child: FilledButton(
                          onPressed: () async => context
                              .read<OrganizerWorkDetailsPageBloc>()
                              .add(OrganizerWorkDetailsPageFetch(participationId: participationId)),
                          child: Text('Retry'),
                        ),
                      );
                    }
                    return VoidWidget();
                  }
                  final participationBundle = state.participationBundle!;
                  final work = participationBundle.work!;
                  return RefreshIndicator.adaptive(
                    onRefresh: () async => context
                        .read<OrganizerWorkDetailsPageBloc>()
                        .add(OrganizerWorkDetailsPageFetch(participationId: participationId)),
                    child: ListView(
                      children: [
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
                                    : Icon(Icons.broken_image_outlined),
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
                        //* Participant name
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(
                              Icons.person_rounded,
                              size: 24,
                              color: Theme.of(context).colorScheme.secondary,
                            ),
                            SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                participationBundle.participantBundle.profile.fullName,
                                // style: Theme.of(context)
                                //     .textTheme
                                //     .titleMedium,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 12),
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
                                BlocListener<OrganizerWorkDetailsPageBloc,
                                    OrganizerWorkDetailsPageState>(
                                  listener: (context, state) async {
                                    if (state.status.isSuccess &&
                                        state.sourceEvent
                                            is OrganizerWorkDetailsPageGetWorkFileUrl) {
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
                                      context.read<OrganizerWorkDetailsPageBloc>().add(
                                          OrganizerWorkDetailsPageGetWorkFileUrl(
                                              filePath: work.filePath!));
                                    },
                                    icon: Icon(Icons.download),
                                    color: Theme.of(context).colorScheme.onTertiaryContainer,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
        );
      },
    );
  }
}
