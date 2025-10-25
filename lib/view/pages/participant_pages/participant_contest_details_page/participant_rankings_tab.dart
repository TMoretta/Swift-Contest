import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:path/path.dart' as path;
import 'package:swift_contest/utils/functions/save_and_launch_file.dart';
import 'package:swift_contest/view/widgets/overlay_loader.dart';
import 'package:swift_contest/view/widgets/show_snack_bar.dart';
import 'package:swift_contest/view/widgets/void_widget.dart';
import 'package:swift_contest/viewmodel/blocs/pages_blocs/participant_contest_details_page_bloc/participant_contest_details_page_bloc.dart';
import 'package:swift_contest/viewmodel/types/bloc_status.dart';

class ParticipantRankingsTab extends StatefulWidget {
  final String contestId;

  const ParticipantRankingsTab({required this.contestId, super.key});

  @override
  State<ParticipantRankingsTab> createState() => _ParticipantRankingsTabState();
}

class _ParticipantRankingsTabState extends State<ParticipantRankingsTab> {
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
          body: SafeArea(
            child: _buildBody(context, state),
          ),
        );
      },
    );
  }

  Widget _buildBody(BuildContext context, ParticipantContestDetailsPageState state) {
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
        const SizedBox(height: 4),
        Expanded(
          child: RefreshIndicator.adaptive(
              onRefresh: () async => context
                  .read<ParticipantContestDetailsPageBloc>()
                  .add(ParticipantContestDetailsPageFetch(contestId: contestId)),
              child: (state.contestDetailsBundle!.contestRankings.isEmpty)
                  ? ListView(
                children: const [
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
                          BlocListener<ParticipantContestDetailsPageBloc,
                              ParticipantContestDetailsPageState>(
                            listener: (context, state) async {
                              if (state.status.isSuccess &&
                                  state.sourceEvent
                                      is ParticipantContestDetailsPageGetRankingFileUrl) {
                                final url = state.rankingFileUrl!;
                                final dio = Dio();
                                final response = await dio.get<List<int>>(
                                  url,
                                  options: Options(responseType: ResponseType.bytes),
                                );
                                final fileBytes = response.data;

                                if (fileBytes == null) {
                                  if (context.mounted) {
                                    showSnackBar(context: context, text: 'Failed to download file data.');
                                  }
                                  return;
                                }

                                final (_, message) = await saveAndLaunchFile(
                                    fileBytes, path.basename(ranking.filePath));
                                if (context.mounted) {
                                  showSnackBar(
                                      context: context, text: message ?? 'File operation completed.');
                                }
                              }
                            },
                            child: IconButton(
                              onPressed: () {
                                context.read<ParticipantContestDetailsPageBloc>().add(
                                    ParticipantContestDetailsPageGetRankingFileUrl(
                                        filePath: ranking.filePath));
                              },
                              icon: const Icon(Icons.download),
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
