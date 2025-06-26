import 'dart:io';

import 'package:dio/dio.dart';
import 'package:external_path/external_path.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:open_file/open_file.dart';
import 'package:path/path.dart' as p;
import 'package:swift_contest/model/data_models/profile.dart';
import 'package:swift_contest/model/data_models/user.dart';
import 'package:swift_contest/utils/functions/request_storage_permissions.dart';
import 'package:swift_contest/utils/functions/show_snack_bar.dart';
import 'package:swift_contest/utils/media_types.dart';
import 'package:swift_contest/utils/router/go_router.dart';
import 'package:swift_contest/view/widgets/loader.dart';
import 'package:swift_contest/viewmodel/blocs/auth_bloc/auth_bloc.dart';
import 'package:swift_contest/viewmodel/blocs/pages_blocs/participant_contest_details_page_bloc/participant_contest_details_page_bloc.dart';
import 'package:swift_contest/viewmodel/enums/bloc_status.dart';

class ParticipantWorkTab extends StatefulWidget {
  final String contestId;

  const ParticipantWorkTab({required this.contestId, super.key});

  @override
  State<ParticipantWorkTab> createState() => _ParticipantWorkTabState();
}

class _ParticipantWorkTabState extends State<ParticipantWorkTab> {
  late Profile profile;
  late String contestId;

  @override
  void initState() {
    super.initState();
    contestId = widget.contestId;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final state = context.read<ParticipantContestDetailsPageBloc>().state;
    profile = context.read<AuthBloc>().state.profile!;
    if (state.status.isInitial) {
      context
          .read<ParticipantContestDetailsPageBloc>()
          .add(ParticipantContestDetailsPageInit(contestId: contestId, participantId: profile.id));
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<ParticipantContestDetailsPageBloc, ParticipantContestDetailsPageState>(
      listener: (context, state) {},
      child: Scaffold(
        body: BlocBuilder<ParticipantContestDetailsPageBloc, ParticipantContestDetailsPageState>(
          builder: (context, state) {
            switch (state.status) {
              case BlocStatus.initial:
                return SizedBox.shrink();
              case BlocStatus.loading:
                return Loader();
              case BlocStatus.failure:
                if (state.sourceEvent is ParticipantContestDetailsPageInit) {
                  return RefreshIndicator.adaptive(
                    onRefresh: () async => context.read<ParticipantContestDetailsPageBloc>().add(
                        ParticipantContestDetailsPageInit(
                            contestId: contestId, participantId: profile.id)),
                    child: ListView(),
                  );
                } else {
                  continue successCase;
                }
              successCase:
              case BlocStatus.success:
                return LayoutBuilder(
                  builder: (context, constraints) {
                    return RefreshIndicator.adaptive(
                      onRefresh: () async => context.read<ParticipantContestDetailsPageBloc>().add(
                          ParticipantContestDetailsPageRefresh(
                              contestId: contestId, participantId: profile.id)),
                      child: (state.submittedWork != null)
                          ? ListView(
                              children: [
                                //* Title
                                Text(
                                  state.submittedWork!.name,
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
                                    itemCount: state.submittedWork!.imagesUrls.length,
                                    itemBuilder: (context, index) {
                                      return Padding(
                                        padding: const EdgeInsets.only(right: 8),
                                        child: (state.submittedWork!.imagesUrls.isNotEmpty)
                                            ? Image.network(
                                                state.submittedWork!.imagesUrls[index],
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
                                Text(state.submittedWork!.description),
                                SizedBox(height: 16),
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
                                      state.submittedWork!.fileUrl.split('/').last,
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

                                          final originalFilename =
                                              state.submittedWork!.fileUrl.split('/').last;
                                          final baseName =
                                              p.basenameWithoutExtension(originalFilename);
                                          final extension = p.extension(originalFilename);

                                          String safeFilename;
                                          int count = 0;
                                          do {
                                            safeFilename = (count == 0)
                                                ? originalFilename
                                                : '$baseName ($count)$extension';
                                            count++;
                                          } while (await File('$directory/$safeFilename').exists());

                                          final path = '$directory/$safeFilename';

                                          await Dio().download(
                                            state.submittedWork!.fileUrl,
                                            path,
                                            onReceiveProgress: (received, total) {
                                              if (total != -1) {
                                                // opzionale: mostra progress %
                                                final pct =
                                                    (received / total * 100).toStringAsFixed(0);
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
                            )
                          : ListView(
                              children: [
                                SizedBox(
                                  height: constraints.maxHeight,
                                  child: Center(
                                    child: Text('No work submitted yet'),
                                  ),
                                )
                              ],
                            ),
                    );
                  },
                );
            }
          },
        ),
        floatingActionButton:
            BlocBuilder<ParticipantContestDetailsPageBloc, ParticipantContestDetailsPageState>(
          builder: (context, state) {
            if (state.status.isSuccess && state.submittedWork == null) {
              return FloatingActionButton.extended(
                onPressed: () async {
                  final bool? res =
                      await context.pushNamed(AppRouter.participantWorkSubmit, extra: contestId);
                  if (res == true) {
                    if (context.mounted) {
                      context.read<ParticipantContestDetailsPageBloc>().add(
                          ParticipantContestDetailsPageRefresh(
                              contestId: contestId, participantId: profile.id));
                    }
                  }
                },
                elevation: 1,
                label: Text('Submit work'),
              );
            }
            return SizedBox.shrink();
          },
        ),
      ),
    );
  }
}
