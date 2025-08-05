import 'dart:io';

import 'package:auto_route/auto_route.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:path/path.dart' as path;
import 'package:swift_contest/model/database/types/voting_session_status.dart';
import 'package:swift_contest/utils/router/app_router.gr.dart';
import 'package:swift_contest/view/widgets/overlay_loader.dart';
import 'package:swift_contest/view/widgets/show_snack_bar.dart';
import 'package:swift_contest/view/widgets/void_widget.dart';
import 'package:swift_contest/viewmodel/blocs/pages_blocs/organizer_contest_details_page_bloc/organizer_contest_details_page_bloc.dart';
import 'package:swift_contest/viewmodel/enums/bloc_status.dart';

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
            child: Placeholder(), //todo Aggiungere rankings pubblicate
          ),
        ),
      ],
    );
  }

  Widget _buildFab(BuildContext context, OrganizerContestDetailsPageState state) {
    return FloatingActionButton.extended(
      heroTag: 'publishRanking',
      onPressed: () async {
        final pickedFile = await _showPublishRankingDialog(context);
        if (pickedFile != null && context.mounted) {
          context.read<OrganizerContestDetailsPageBloc>().add(
                OrganizerContestDetailsPagePublishRanking(
                  contestId: contestId,
                  file: File(pickedFile.path!),
                ),
              );
        }
      },
      label: Text('Publish ranking'),
    );
  }

  Future<PlatformFile?> _showPublishRankingDialog(BuildContext context) async {
    return await showDialog(
      context: context,
      builder: (context) {
        final formKey = GlobalKey<FormState>();
        PlatformFile? selectedFile;
        return StatefulBuilder(builder: (context, setState) {
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
                    context.router.pop(selectedFile!);
                  }
                },
                child: Text('Confirm'),
              ),
            ],
          );
        });
      },
    );
  }
}
