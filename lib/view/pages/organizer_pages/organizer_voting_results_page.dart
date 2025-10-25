import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:swift_contest/utils/router/app_router.gr.dart';
import 'package:swift_contest/utils/validators/validators.dart';
import 'package:swift_contest/view/widgets/custom_app_bar.dart';
import 'package:swift_contest/view/widgets/custom_text_form_field.dart';
import 'package:swift_contest/view/widgets/overlay_loader.dart';
import 'package:swift_contest/view/widgets/show_snack_bar.dart';
import 'package:swift_contest/view/widgets/void_widget.dart';
import 'package:swift_contest/viewmodel/blocs/pages_blocs/organizer_voting_results_page_bloc/organizer_voting_results_page_bloc.dart';
import 'package:swift_contest/viewmodel/types/bloc_status.dart';

@RoutePage()
class OrganizerVotingResultsPage extends StatefulWidget implements AutoRouteWrapper {
  final String votingSessionId;

  const OrganizerVotingResultsPage({
    @PathParam('votingSessionId') required this.votingSessionId,
    super.key,
  });

  @override
  State<OrganizerVotingResultsPage> createState() => _OrganizerVotingResultsPageState();

  @override
  Widget wrappedRoute(BuildContext context) {
    return BlocProvider<OrganizerVotingResultsPageBloc>(
      create: (context) => OrganizerVotingResultsPageBloc(
        organizerRepository: context.read(),
      ),
      child: this,
    );
  }
}

class _OrganizerVotingResultsPageState extends State<OrganizerVotingResultsPage> {
  late String votingSessionId;

  @override
  void initState() {
    super.initState();
    votingSessionId = widget.votingSessionId;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    context
        .read<OrganizerVotingResultsPageBloc>()
        .add(OrganizerVotingResultsPageFetch(votingSessionId: votingSessionId));
  }

  @override
  void dispose() {
    context.hideLoader();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<OrganizerVotingResultsPageBloc, OrganizerVotingResultsPageState>(
      listener: (context, state) {
        if (state.message != null) {
          showSnackBar(context: context, text: state.message!);
        }
        if (state.status.isLoading) {
          context.showLoader();
        } else {
          context.hideLoader();
        }
        if (state.status.isSuccess &&
            state.sourceEvent is OrganizerVotingResultsPageDeleteVotingSession) {
          showSnackBar(context: context, text: 'Voting session deleted successfully');
          context.router.pop(); // Pop the confirmation dialog
          context.router.pop(true); // Pop this page and signal a change to the previous one
        }
      },
      builder: (context, state) {
        return Scaffold(
          appBar: CustomAppBar(
              title: state.votingSessionResultBundle?.votingSessionBundle.votingSession.name ?? ''),
          body: SafeArea(
            child: Padding(
              padding: const EdgeInsets.only(left: 16, top: 16, right: 16),
              child: Builder(
                builder: (context) {
                  if (!state.isInitialized) {
                    if (state.status.isFailure) {
                      return Center(
                        child: FilledButton(
                          onPressed: () async => context.read<OrganizerVotingResultsPageBloc>().add(
                              OrganizerVotingResultsPageFetch(votingSessionId: votingSessionId)),
                          child: const Text('Retry'),
                        ),
                      );
                    }
                    return const VoidWidget();
                  }
                  final votingSession =
                      state.votingSessionResultBundle!.votingSessionBundle.votingSession;
                  return RefreshIndicator.adaptive(
                    onRefresh: () async => context
                        .read<OrganizerVotingResultsPageBloc>()
                        .add(OrganizerVotingResultsPageFetch(votingSessionId: votingSessionId)),
                    child: ListView(
                      children: [
                        Text(
                          'Voting session',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        Card(
                          elevation: 0.5,
                          color: Theme.of(context).colorScheme.tertiaryContainer,
                          child: ListTile(
                            title: Text(
                              votingSession.name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  color: Theme.of(context).colorScheme.onPrimaryContainer),
                            ),
                            subtitle: Text(
                              DateFormat('dd MMM, yyyy | HH:mm').format(votingSession.createdAt!),
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: Theme.of(context).colorScheme.onPrimaryContainer),
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  onPressed: () {
                                    _showEditVotingSessionNameDialog(
                                        context: context, votingSessionId: votingSession.id!);
                                  },
                                  icon: Icon(
                                    Icons.edit,
                                    color: Theme.of(context).colorScheme.onPrimaryContainer,
                                  ),
                                ),
                                IconButton(
                                  onPressed: () {
                                    _showDeleteVotingSessionDialog(
                                        context: context, votingSessionId: votingSession.id!);
                                  },
                                  icon: Icon(
                                    Icons.delete,
                                    color: Theme.of(context).colorScheme.error,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Juries',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        ...state.votingSessionResultBundle!.votingSessionJuriesBundles
                            .map((votingSessionJuryBundle) {
                          return Card(
                            elevation: 0,
                            child: ListTile(
                              onTap: () {
                                context.router.push(OrganizerJuryVotingResultsRoute(
                                    votingSessionJuryId:
                                        votingSessionJuryBundle.votingSessionJury.id!));
                              },
                              title: Text(votingSessionJuryBundle.votingSessionJury.juryName),
                              subtitle: Text(
                                  'Submissions: ${votingSessionJuryBundle.votingSessionJurors.where((e) => e.hasSubmitted).length}'),
                            ),
                          );
                        }),
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

void _showDeleteVotingSessionDialog({
  required BuildContext context,
  required String votingSessionId,
}) {
  final organizerVotingResultsPageBloc = context.read<OrganizerVotingResultsPageBloc>();

  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: const Text('Delete Voting Session'),
        content: const Text(
            'Are you sure you want to delete this voting session? This action cannot be undone and all related data will be lost.'),
        actions: [
          TextButton(
            onPressed: () => context.router.pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              organizerVotingResultsPageBloc
                  .add(OrganizerVotingResultsPageDeleteVotingSession(votingSessionId: votingSessionId));
            },
            child: const Text('Delete'),
          ),
        ],
      );
    },
  );
}

void _showEditVotingSessionNameDialog({
  required BuildContext context,
  required String votingSessionId,
}) {
  final organizerVotingResultsPageBloc = context.read<OrganizerVotingResultsPageBloc>();
  final formKey = GlobalKey<FormState>();
  final nameController = TextEditingController();
  final nameFocusNode = FocusNode();

  showDialog(
    context: context,
    builder: (context) {
      return BlocProvider.value(
        value: organizerVotingResultsPageBloc,
        child: BlocConsumer<OrganizerVotingResultsPageBloc, OrganizerVotingResultsPageState>(
          listener: (context, state) {
            if (state.status.isSuccess &&
                state.sourceEvent is OrganizerVotingResultsPageEditVotingSessionName) {
              context
                  .read<OrganizerVotingResultsPageBloc>()
                  .add(OrganizerVotingResultsPageFetch(votingSessionId: votingSessionId));
              context.router.pop();
            }
          },
          builder: (context, state) {
            return AlertDialog(
              title: const Text('Edit name'),
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
                      validator: titleValidator,
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    context.router.pop();
                  },
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: () {
                    if (formKey.currentState!.validate()) {
                      context.read<OrganizerVotingResultsPageBloc>().add(
                          OrganizerVotingResultsPageEditVotingSessionName(
                              votingSessionId: votingSessionId, name: nameController.text.trim()));
                    }
                  },
                  child: const Text('Edit'),
                ),
              ],
            );
          },
        ),
      );
    },
  );
}
