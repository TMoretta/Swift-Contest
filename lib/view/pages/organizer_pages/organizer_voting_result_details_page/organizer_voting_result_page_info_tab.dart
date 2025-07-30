import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:intl/intl.dart';
import 'package:swift_contest/utils/labels/labels.dart';
import 'package:swift_contest/utils/validators/validators.dart';
import 'package:swift_contest/view/widgets/custom_text_form_field.dart';
import 'package:swift_contest/view/widgets/list_view_with_central_label.dart';
import 'package:swift_contest/view/widgets/overlay_loader.dart';
import 'package:swift_contest/view/widgets/void_widget.dart';
import 'package:swift_contest/viewmodel/blocs/pages_blocs/organizer_voting_result_details_page_bloc/organizer_voting_result_details_page_bloc.dart';
import 'package:swift_contest/viewmodel/enums/bloc_status.dart';

class OrganizerVotingResultPageInfoTab extends StatefulWidget {
  final String votingSessionId;

  const OrganizerVotingResultPageInfoTab({required this.votingSessionId, super.key});

  @override
  State<OrganizerVotingResultPageInfoTab> createState() => _OrganizerVotingResultPageInfoTabState();
}

class _OrganizerVotingResultPageInfoTabState extends State<OrganizerVotingResultPageInfoTab> {
  late final String votingSessionId;

  @override
  void initState() {
    super.initState();
    votingSessionId = widget.votingSessionId;
  }

  @override
  void dispose() {
    context.hideLoader();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<OrganizerVotingResultDetailsPageBloc, OrganizerVotingResultDetailsPageState>(
      builder: (context, state) {
        switch (state.status) {
          case BlocStatus.initial:
            return VoidWidget();
          case BlocStatus.loading:
            if (!state.isInitialized) {
              return VoidWidget();
            } else {
              continue successCase;
            }
          case BlocStatus.failure:
            if (!state.isInitialized) {
              return RefreshIndicator.adaptive(
                onRefresh: () async {
                  context
                      .read<OrganizerVotingResultDetailsPageBloc>()
                      .add(OrganizerVotingResultDetailsPageFetch(
                        votingSessionId: votingSessionId,
                      ));
                },
                child: ListViewWithCentralLabel(label: Labels.anErrorOccurred),
              );
            } else {
              continue successCase;
            }
          successCase:
          case BlocStatus.success:
            final votingSessionResultBundle = state.votingSessionResultBundle!;
            final votingSessionBundle = votingSessionResultBundle.votingSessionBundle;
            final votingSession = votingSessionBundle.votingSession;
            final excludedVotingSessionParticipationsBundles = state
                .votingSessionResultBundle!.votingSessionParticipationsBundles
                .where((e) => e.votingSessionParticipation.isExcluded)
                .toList(growable: false);
            final excludedVotingSessionJurationsBundles = state
                .votingSessionResultBundle!.votingSessionJurationsBundles
                .where((e) => e.votingSessionJuration.isExcluded)
                .toList(growable: false);
            final jurorsWithoutSubmissionBundles =
                state.votingSessionResultBundle!.jurorsWithoutSubmission;
            return ListView(
              children: [
                Card(
                  elevation: 0.1,
                  color: Theme.of(context).colorScheme.primaryContainer,
                  child: ListTile(
                    title: Text(
                      votingSession.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context)
                          .textTheme
                          .titleMedium
                          ?.copyWith(color: Theme.of(context).colorScheme.onPrimaryContainer),
                    ),
                    subtitle: Text(
                      DateFormat('dd MMM, yyyy | HH:mm').format(votingSession.createdAt),
                      style: Theme.of(context)
                          .textTheme
                          .bodySmall
                          ?.copyWith(color: Theme.of(context).colorScheme.onPrimaryContainer),
                    ),
                    trailing: IconButton(
                      onPressed: () {
                        _showEditVotingSessionNameDialog(
                            context: context, votingSessionId: votingSessionId);
                      },
                      icon: Icon(
                        Icons.edit,
                        color: Theme.of(context).colorScheme.onPrimaryContainer,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 16),
                //* Excluded participants
                Text(
                  'Excluded participants',
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium
                      ?.copyWith(color: Theme.of(context).colorScheme.secondary),
                ),
                SizedBox(height: 4),
                if (excludedVotingSessionParticipationsBundles.isNotEmpty)
                  ...excludedVotingSessionParticipationsBundles
                      .map((e) => Text(e.participationBundle.participant.fullName))
                else
                  Text('No participant excluded'),
                SizedBox(height: 12),
                //* Excluded jurors
                Text(
                  'Excluded jurors',
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium
                      ?.copyWith(color: Theme.of(context).colorScheme.secondary),
                ),
                SizedBox(height: 4),
                if (excludedVotingSessionJurationsBundles.isNotEmpty)
                  ...excludedVotingSessionJurationsBundles
                      .map((e) => Text(e.jurationBundle.juror.fullName))
                else
                  Text('No juror excluded'),
                SizedBox(height: 12),
                //* Jurors with no submission
                Text(
                  'Jurors that did\'t submit',
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium
                      ?.copyWith(color: Theme.of(context).colorScheme.secondary),
                ),
                if (jurorsWithoutSubmissionBundles.isNotEmpty)
                  ...jurorsWithoutSubmissionBundles.map(
                    (e) => Text(e.juror.fullName),
                  )
                else
                  Text('All jurors submitted'),
              ],
            );
        }
      },
    );
  }
}

void _showEditVotingSessionNameDialog({
  required BuildContext context,
  required String votingSessionId,
}) {
  final organizerContestDetailsPageBloc = context.read<OrganizerVotingResultDetailsPageBloc>();
  final formKey = GlobalKey<FormState>();
  final nameController = TextEditingController();
  final nameFocusNode = FocusNode();

  showDialog(
    context: context,
    builder: (context) {
      return BlocProvider.value(
        value: organizerContestDetailsPageBloc,
        child: BlocConsumer<OrganizerVotingResultDetailsPageBloc,
            OrganizerVotingResultDetailsPageState>(
          listener: (context, state) {
            if (state.status.isSuccess &&
                state.sourceEvent is OrganizerVotingResultDetailsPageEditVotingSessionName) {
              context
                  .read<OrganizerVotingResultDetailsPageBloc>()
                  .add(OrganizerVotingResultDetailsPageFetch(votingSessionId: votingSessionId));
              context.router.pop();
            }
          },
          builder: (context, state) {
            return AlertDialog(
              title: Text('Edit name'),
              content: Form(
                key: formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CustomTextFormField(
                      borderType: InputBorderType.underlined,
                      controller: nameController,
                      focusNode: nameFocusNode,
                      label: 'Name',
                      validator: noEmptyValidator,
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    context.router.pop();
                  },
                  child: Text('Cancel'),
                ),
                TextButton(
                  onPressed: () {
                    if (formKey.currentState!.validate()) {
                      context.read<OrganizerVotingResultDetailsPageBloc>().add(
                          OrganizerVotingResultDetailsPageEditVotingSessionName(
                              votingSessionId: votingSessionId,
                              name: nameController.text.trim()));
                    }
                  },
                  child: Text('Edit'),
                ),
              ],
            );
          },
        ),
      );
    },
  );
}
