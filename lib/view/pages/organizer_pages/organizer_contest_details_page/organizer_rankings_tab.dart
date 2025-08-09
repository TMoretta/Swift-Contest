import 'dart:io';

import 'package:auto_route/auto_route.dart';
import 'package:dio/dio.dart';
import 'package:external_path/external_path.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path/path.dart' as path;
import 'package:swift_contest/utils/functions/request_storage_permission.dart';
import 'package:swift_contest/view/widgets/overlay_loader.dart';
import 'package:swift_contest/view/widgets/show_snack_bar.dart';
import 'package:swift_contest/view/widgets/void_widget.dart';
import 'package:swift_contest/viewmodel/blocs/pages_blocs/organizer_contest_details_page_bloc/organizer_contest_details_page_bloc.dart';
import 'package:swift_contest/viewmodel/types/bloc_status.dart';

class OrganizerRankingsTab extends StatefulWidget {
  final String contestId;

  const OrganizerRankingsTab({required this.contestId, super.key});

  @override
  State<OrganizerRankingsTab> createState() => _OrganizerRankingsTabState();
}

class _OrganizerRankingsTabState extends State<OrganizerRankingsTab> {
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
    return BlocBuilder<OrganizerContestDetailsPageBloc, OrganizerContestDetailsPageState>(
      builder: (context, state) {
        return Scaffold(
          body: SafeArea(
            child: _buildBody(context, state),
          ),
          floatingActionButton: (state.isInitialized) ? _buildFab(context, state) : null,
        );
      },
    );
  }

  Widget _buildBody(BuildContext context, OrganizerContestDetailsPageState state) {
    if (!state.isInitialized) {
      if (state.status.isFailure) {
        return Center(
          child: FilledButton(
            onPressed: () async => context
                .read<OrganizerContestDetailsPageBloc>()
                .add(OrganizerContestDetailsPageFetch(contestId: contestId)),
            child: Text('Retry'),
          ),
        );
      }
      return VoidWidget();
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Published rankings
        Text(
          'Published rankings',
          style: Theme.of(context)
              .textTheme
              .titleMedium
              ?.copyWith(color: Theme.of(context).colorScheme.secondary),
        ),
        SizedBox(height: 4),
        Expanded(
          child: RefreshIndicator.adaptive(
              onRefresh: () async => context
                  .read<OrganizerContestDetailsPageBloc>()
                  .add(OrganizerContestDetailsPageFetch(contestId: contestId)),
              child: (state.contestDetailsBundle!.contestRankings.isEmpty)
                  ? ListView(
                      children: [
                        Text('No ranking published'),
                      ],
                    )
                  : ListView.builder(
                      itemCount: state.contestDetailsBundle!.contestRankings.length,
                      itemBuilder: (context, index) {
                        final ranking = state.contestDetailsBundle!.contestRankings[index];
                        return Card(
                          elevation: 0,
                          child: ListTile(
                            title: Text(
                              path.basename(ranking.filePath),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                BlocListener<OrganizerContestDetailsPageBloc,
                                    OrganizerContestDetailsPageState>(
                                  listener: (context, state) async {
                                    if (state.status.isSuccess &&
                                        state.sourceEvent
                                            is OrganizerContestDetailsPageGetRankingFileUrl) {
                                      // Download the file
                                      final permission = await requestStoragePermission();
                                      if (!permission) {
                                        if (context.mounted) {
                                          showSnackBar(
                                              context: context, text: 'Storage permission negated');
                                        }
                                        return;
                                      }

                                      try {
                                        final url = state.rankingFileUrl!;

                                        // 2. Trova la cartella di download del dispositivo
                                        final directory =
                                            await ExternalPath.getExternalStoragePublicDirectory(
                                                ExternalPath.DIRECTORY_DOWNLOAD);

                                        final fileName = path.basenameWithoutExtension(ranking.filePath);
                                        final extension = path.extension(ranking.filePath);

                                        String safeFilename;
                                        int count = 0;
                                        do {
                                          safeFilename = (count == 0)
                                              ? '$fileName$extension'
                                              : '$fileName ($count)$extension';
                                          count++;
                                        } while (await File('$directory/$safeFilename').exists());

                                        final safePath = '$directory/$safeFilename';

                                        // 3. Scarica il file con Dio
                                        final dio = Dio();
                                        await dio.download(url, safePath);

                                        // 4. Apri il file scaricato
                                        final result = await OpenFilex.open(safePath);
                                        if (result.type != ResultType.done && context.mounted) {
                                          showSnackBar(
                                              context: context, text: 'Impossible open the file');
                                        }
                                      } catch (e) {
                                        if (context.mounted) {
                                          showSnackBar(context: context, text: 'Download failed');
                                        }
                                      }
                                    }
                                  },
                                  child: IconButton(
                                    onPressed: () {
                                      context.read<OrganizerContestDetailsPageBloc>().add(
                                          OrganizerContestDetailsPageGetRankingFileUrl(
                                              filePath: ranking.filePath));
                                    },
                                    icon: Icon(Icons.download),
                                  ),
                                ),
                                IconButton(
                                  onPressed: () => _showUnpublishRankingDialog(
                                      context: context, contestRankingId: ranking.id!),
                                  icon: Icon(Icons.remove),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    )),
        ),
      ],
    );
  }

  Widget _buildFab(BuildContext context, OrganizerContestDetailsPageState state) {
    return FloatingActionButton.extended(
      heroTag: 'publishRanking',
      onPressed: () {
        _showPublishRankingDialog(context);
      },
      label: Text('Publish ranking'),
    );
  }

  void _showPublishRankingDialog(BuildContext context) async {
    final organizerContestDetailsPageBloc = context.read<OrganizerContestDetailsPageBloc>();

    showDialog(
      context: context,
      builder: (context) {
        final formKey = GlobalKey<FormState>();
        PlatformFile? selectedFile;
        return StatefulBuilder(builder: (context, setState) {
          return BlocProvider.value(
            value: organizerContestDetailsPageBloc,
            child: BlocConsumer<OrganizerContestDetailsPageBloc, OrganizerContestDetailsPageState>(
              listener: (context, state) {
                if (state.status.isSuccess &&
                    state.sourceEvent is OrganizerContestDetailsPagePublishRanking) {
                  context.pop();
                  context
                      .read<OrganizerContestDetailsPageBloc>()
                      .add(OrganizerContestDetailsPageFetch(contestId: contestId));
                  showSnackBar(context: context, text: 'Ranking published successfully');
                }
              },
              builder: (context, state) {
                return AlertDialog(
                  title: Text('Select file'),
                  content: Form(
                    key: formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                            'Published rankings will be available for all jurors and participants in the contest. Only PDF format is allowed.'),
                        SizedBox(height: 12),
                        FormField<PlatformFile>(
                          validator: (value) => (value == null) ? 'Select a file' : null,
                          autovalidateMode: AutovalidateMode.onUserInteraction,
                          builder: (field) {
                            return Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                DecoratedBox(
                                  decoration: BoxDecoration(
                                    color: Theme.of(context).colorScheme.tertiaryContainer,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: ListTile(
                                    onTap: () async {
                                      FilePickerResult? res = await FilePicker.platform.pickFiles(
                                        type: FileType.custom,
                                        allowedExtensions: ['pdf'],
                                        allowMultiple: false,
                                      );

                                      if (res != null) {
                                        setState(() {
                                          selectedFile = res.files.first;
                                          // selectedFile = File(pickedFile.path!);
                                        });
                                        field.didChange(selectedFile);
                                        // return File(pickedFile.path!);
                                      }
                                    },
                                    title: Text(
                                      (selectedFile == null)
                                          ? 'Select file'
                                          : '${selectedFile!.name}${selectedFile!.extension}',
                                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                          color: Theme.of(context).colorScheme.onTertiaryContainer),
                                      overflow: TextOverflow.ellipsis,
                                      maxLines: 1,
                                    ),
                                    trailing: Icon(
                                      Icons.file_open,
                                      color: Theme.of(context).colorScheme.onTertiaryContainer,
                                    ),
                                  ),
                                ),
                                if (field.hasError)
                                  Padding(
                                    padding: const EdgeInsets.only(top: 4),
                                    child: Text(
                                      field.errorText!,
                                      style: Theme.of(context)
                                          .textTheme
                                          .labelLarge
                                          ?.copyWith(color: Theme.of(context).colorScheme.error),
                                    ),
                                  ),
                              ],
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => context.router.pop(),
                      child: Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: () {
                        if (formKey.currentState?.validate() ?? false) {
                          context.read<OrganizerContestDetailsPageBloc>().add(
                                OrganizerContestDetailsPagePublishRanking(
                                  contestId: contestId,
                                  file: File(selectedFile!.path!),
                                ),
                              );
                        }
                      },
                      child: Text('Confirm'),
                    ),
                  ],
                );
              },
            ),
          );
        });
      },
    );
  }

  void _showUnpublishRankingDialog({
    required BuildContext context,
    required String contestRankingId,
  }) {
    final organizerContestDetailsPageBloc = context.read<OrganizerContestDetailsPageBloc>();

    showDialog(
      context: context,
      builder: (context) {
        return BlocProvider.value(
          value: organizerContestDetailsPageBloc,
          child: BlocConsumer<OrganizerContestDetailsPageBloc, OrganizerContestDetailsPageState>(
            listener: (context, state) {
              if (state.status.isSuccess &&
                  state.sourceEvent is OrganizerContestDetailsPageUnpublishRanking) {
                context.pop();
                context
                    .read<OrganizerContestDetailsPageBloc>()
                    .add(OrganizerContestDetailsPageFetch(contestId: contestId));
                showSnackBar(context: context, text: 'Ranking unpublished successfully');
              }
            },
            builder: (context, state) {
              return AlertDialog(
                title: Text('Unpublish ranking'),
                content: Text(
                    'Are you sure you want to unpublish this ranking? It will not be available neither for participants nor for jurors.'),
                actions: [
                  TextButton(
                    onPressed: () => context.pop(),
                    child: Text('Cancel'),
                  ),
                  TextButton(
                    onPressed: () => context.read<OrganizerContestDetailsPageBloc>().add(
                        OrganizerContestDetailsPageUnpublishRanking(
                            contestRankingId: contestRankingId)),
                    child: Text('Confirm'),
                  ),
                ],
              );
            },
          ),
        );
      },
    );
  }
}
