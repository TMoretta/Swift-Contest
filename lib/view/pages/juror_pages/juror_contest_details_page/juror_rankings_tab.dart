import 'dart:io';

import 'package:dio/dio.dart';
import 'package:external_path/external_path.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path/path.dart' as path;
import 'package:url_launcher/url_launcher.dart';
import 'package:swift_contest/utils/permissions/permissions.dart';
import 'package:swift_contest/view/widgets/overlay_loader.dart';
import 'package:swift_contest/view/widgets/show_snack_bar.dart';
import 'package:swift_contest/view/widgets/void_widget.dart';
import 'package:swift_contest/viewmodel/blocs/pages_blocs/juror_contest_details_page_bloc/juror_contest_details_page_bloc.dart';
import 'package:swift_contest/viewmodel/types/bloc_status.dart';

class JurorRankingsTab extends StatefulWidget {
  final String contestId;

  const JurorRankingsTab({required this.contestId, super.key});

  @override
  State<JurorRankingsTab> createState() => _JurorRankingsTabState();
}

class _JurorRankingsTabState extends State<JurorRankingsTab> {
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
    return BlocBuilder<JurorContestDetailsPageBloc, JurorContestDetailsPageState>(
      builder: (context, state) {
        return Scaffold(
          body: SafeArea(
            child: _buildBody(context, state),
          ),
        );
      },
    );
  }

  Widget _buildBody(BuildContext context, JurorContestDetailsPageState state) {
    if (!state.isInitialized) {
      if (state.status.isFailure) {
        return Center(
          child: FilledButton(
            onPressed: () async => context
                .read<JurorContestDetailsPageBloc>()
                .add(JurorContestDetailsPageFetch(contestId: contestId)),
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
                  .read<JurorContestDetailsPageBloc>()
                  .add(JurorContestDetailsPageFetch(contestId: contestId)),
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
                          BlocListener<JurorContestDetailsPageBloc,
                              JurorContestDetailsPageState>(
                            listener: (context, state) async {
                              if (state.status.isSuccess &&
                                  state.sourceEvent is JurorContestDetailsPageGetRankingFileUrl) {
                                final url = state.rankingFileUrl!;

                                if (kIsWeb) {
                                  // On web, open the URL in a new tab and let the browser handle it.
                                  final uri = Uri.parse(url);
                                  if (!await launchUrl(uri)) {
                                    if (context.mounted) {
                                      showSnackBar(
                                          context: context,
                                          text: 'Could not open the file link.');
                                    }
                                  }
                                } else {
                                  // On mobile, download the file to the device.
                                  final bool permission =
                                      await requestStoragePermissionForDownloads();
                                  if (!context.mounted) return;
                                  if (!permission) {
                                    showSnackBar(
                                        context: context,
                                        text: 'Storage permission is required to save files.');
                                    return;
                                  }

                                  try {
                                    // 1. Get the downloads directory.
                                    final directory = await ExternalPath
                                        .getExternalStoragePublicDirectory(
                                            ExternalPath.DIRECTORY_DOWNLOAD);

                                    // 2. Create a safe, non-conflicting filename.
                                    final fileName =
                                        path.basenameWithoutExtension(ranking.filePath);
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

                                    // 3. Download the file using Dio.
                                    final dio = Dio();
                                    await dio.download(url, safePath);

                                    // 4. Open the downloaded file.
                                    final result = await OpenFilex.open(safePath);
                                    if (result.type != ResultType.done && context.mounted) {
                                      showSnackBar(
                                          context: context,
                                          text:
                                              'Could not open the file. It is saved in your Downloads folder.');
                                    }
                                  } catch (e) {
                                    if (context.mounted) {
                                      showSnackBar(context: context, text: 'Download failed.');
                                    }
                                  }
                                }
                              }
                            },
                            child: IconButton(
                              onPressed: () {
                                context.read<JurorContestDetailsPageBloc>().add(
                                    JurorContestDetailsPageGetRankingFileUrl(
                                        filePath: ranking.filePath));
                              },
                              icon: Icon(Icons.download),
                            ),
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
}
