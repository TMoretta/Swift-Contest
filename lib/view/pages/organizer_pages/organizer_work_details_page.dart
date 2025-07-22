import 'dart:io';

import 'package:auto_route/auto_route.dart';
import 'package:dio/dio.dart';
import 'package:external_path/external_path.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:open_file/open_file.dart';
import 'package:path/path.dart' as p;
import 'package:swift_contest/utils/functions/request_storage_permissions.dart';
import 'package:swift_contest/utils/labels/labels.dart';
import 'package:swift_contest/utils/media_types.dart';
import 'package:swift_contest/view/widgets/custom_app_bar.dart';
import 'package:swift_contest/view/widgets/list_view_with_central_label.dart';
import 'package:swift_contest/view/widgets/loader.dart';
import 'package:swift_contest/view/widgets/overlay_loader.dart';
import 'package:swift_contest/view/widgets/show_snack_bar.dart';
import 'package:swift_contest/view/widgets/void_widget.dart';
import 'package:swift_contest/viewmodel/blocs/pages_blocs/organizer_work_details_page_bloc/organizer_work_details_page_bloc.dart';
import 'package:swift_contest/viewmodel/enums/bloc_status.dart';

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
    context.read<OrganizerWorkDetailsPageBloc>().add(OrganizerWorkDetailsPageInit(
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
          appBar: CustomAppBar(title: 'Work'),
          body: SafeArea(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Builder(
                builder: (context) {
                  switch (state.status) {
                    case BlocStatus.initial:
                      return VoidWidget();
                    case BlocStatus.loading:
                      if (state.sourceEvent is OrganizerWorkDetailsPageInit) {
                        return VoidWidget();
                      } else {
                        continue successCase;
                      }
                    case BlocStatus.failure:
                      if (state.sourceEvent is OrganizerWorkDetailsPageInit) {
                        return RefreshIndicator.adaptive(
                          onRefresh: () async => context
                              .read<OrganizerWorkDetailsPageBloc>()
                              .add(OrganizerWorkDetailsPageInit(participationId: participationId)),
                          child: ListViewWithCentralLabel(label: Labels.anErrorOccurred),
                        );
                      } else {
                        continue successCase;
                      }
                    successCase:
                    case BlocStatus.success:
                      final participationBundle = state.participationBundle!;
                      final work = participationBundle.work!;
                      final participant = participationBundle.participant;
                      return RefreshIndicator.adaptive(
                        onRefresh: () async => context
                            .read<OrganizerWorkDetailsPageBloc>()
                            .add(OrganizerWorkDetailsPageRefresh(participationId: participationId)),
                        child: ListView(
                          children: [
                            SizedBox(height: 16),
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
                                            frameBuilder:
                                                (context, child, frame, wasSynchronouslyLoaded) {
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
                                    participant.fullName,
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
                              elevation: 0.1,
                              color: Theme.of(context).colorScheme.tertiaryContainer,
                              child: ListTile(
                                title: Text(
                                  work.fileUrl.split('/').last,
                                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                      color: Theme.of(context).colorScheme.onTertiaryContainer),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                trailing: IconButton(
                                  onPressed: () async {
                                    try {
                                      if (!await requestStoragePermission()) {
                                        if (context.mounted) {
                                          showSnackBar(context: context, text: 'Permission denied');
                                        }
                                        return;
                                      }

                                      final directory =
                                          await ExternalPath.getExternalStoragePublicDirectory(
                                              ExternalPath.DIRECTORY_DOWNLOAD);

                                      final originalFilename = work.fileUrl.split('/').last;
                                      final baseName = p.basenameWithoutExtension(originalFilename);
                                      final extension = p.extension(originalFilename);

                                      String safeFilename;
                                      int count = 0;
                                      do {
                                        safeFilename = (count == 0)
                                            ? '$baseName$extension'
                                            : '$baseName ($count)$extension';
                                        count++;
                                      } while (await File('$directory/$safeFilename').exists());

                                      final path = '$directory/$safeFilename';

                                      await Dio().download(
                                        work.fileUrl,
                                        path,
                                        onReceiveProgress: (received, total) {
                                          if (total != -1) {
                                            // opzionale: mostra progress %
                                            final pct = (received / total * 100).toStringAsFixed(0);
                                            debugPrint('Download: $pct%');
                                          }
                                        },
                                      );
                                      await OpenFile.open(path,
                                          type: MediaTypes.mapExtension(extension));
                                    } catch (e) {
                                      debugPrint('Download error: $e');
                                    }
                                  },
                                  icon: Icon(
                                    Icons.download_rounded,
                                    color: Theme.of(context).colorScheme.onTertiaryContainer,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                  }
                },
              ),
            ),
          ),
        );
      },
    );
  }
}
