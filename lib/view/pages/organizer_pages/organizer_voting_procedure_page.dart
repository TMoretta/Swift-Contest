import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:swift_contest/model/database/types/jury_type.dart';
import 'package:swift_contest/model/database/types/voting_session_status.dart';
import 'package:swift_contest/utils/themes/color_scheme_x.dart';
import 'package:swift_contest/view/widgets/custom_app_bar.dart';
import 'package:swift_contest/view/widgets/overlay_loader.dart';
import 'package:swift_contest/view/widgets/show_snack_bar.dart';
import 'package:swift_contest/view/widgets/void_widget.dart';
import 'package:swift_contest/viewmodel/blocs/pages_blocs/organizer_voting_procedure_page_bloc/organizer_voting_procedure_page_bloc.dart';
import 'package:swift_contest/viewmodel/types/bloc_status.dart';

@RoutePage()
class OrganizerVotingProcedurePage extends StatefulWidget implements AutoRouteWrapper {
  final String votingSessionId;

  const OrganizerVotingProcedurePage({
    @PathParam('votingSessionId') required this.votingSessionId,
    super.key,
  });

  @override
  State<OrganizerVotingProcedurePage> createState() => _OrganizerVotingProcedurePageState();

  @override
  Widget wrappedRoute(BuildContext context) {
    return BlocProvider<OrganizerVotingProcedurePageBloc>(
      create: (context) => OrganizerVotingProcedurePageBloc(
        organizerRepository: context.read(),
      ),
      child: this,
    );
  }
}

class _OrganizerVotingProcedurePageState extends State<OrganizerVotingProcedurePage> {
  late final String votingSessionId;
  bool isFinished = false;

  @override
  void initState() {
    super.initState();
    votingSessionId = widget.votingSessionId;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    context
        .read<OrganizerVotingProcedurePageBloc>()
        .add(OrganizerVotingProcedurePageFetch(votingSessionId: votingSessionId));
  }

  @override
  void dispose() {
    context.hideLoader();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<OrganizerVotingProcedurePageBloc, OrganizerVotingProcedurePageState>(
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
            state.sourceEvent is OrganizerVotingProcedurePageEndVotingSessionProcedure) {
          if (!isFinished) {
            isFinished = true;
            showSnackBar(context: context, text: 'Voting session ended successfully');
            context.router.pop();
          }
        }
        if (state.status.isSuccess &&
            state.sourceEvent is OrganizerVotingProcedurePageCancelVotingSessionProcedure) {
          if (!isFinished) {
            isFinished = true;
            showSnackBar(context: context, text: 'Voting session cancelled successfully');
            context.router.pop();
          }
        }
        if (state.votingSessionProcedureBundle != null &&
            !state.votingSessionProcedureBundle!.votingSessionBundle.votingSession.sessionStatus
                .isLive) {
          if (!isFinished) {
            isFinished = true;
            showSnackBar(context: context, text: 'Voting session has terminated');
            context.router.pop();
          }
        }
      },
      builder: (context, state) {
        return Scaffold(
          appBar: const CustomAppBar(title: 'Voting'),
          body: SafeArea(
            child: Padding(
              padding: const EdgeInsets.only(left: 16, right: 16, top: 16),
              child: Builder(
                builder: (context) {
                  if (!state.isInitialized) {
                    if (state.status.isFailure) {
                      return Center(
                        child: FilledButton(
                          onPressed: () async {
                            context.read<OrganizerVotingProcedurePageBloc>().add(
                                OrganizerVotingProcedurePageFetch(
                                    votingSessionId: votingSessionId));
                          },
                          child: const Text('Retry'),
                        ),
                      );
                    }
                    return const VoidWidget();
                  }
                  return RefreshIndicator.adaptive(
                    onRefresh: () async => context
                        .read<OrganizerVotingProcedurePageBloc>()
                        .add(OrganizerVotingProcedurePageFetch(votingSessionId: votingSessionId)),
                    child: Builder(
                      builder: (context) {
                        final List<({String name, String token})> tokensForSimpleJuries = state
                            .votingSessionProcedureBundle!.votingSessionJuriesBundles
                            .where((e) => e.votingSessionJury.juryType.isSimple)
                            .map((e) => (
                                  name: e.votingSessionJury.juryName,
                                  token: e.votingSessionJury.juryToken
                                ))
                            .toList(growable: false);
                        return ListView(
                          children: [
                            Center(child: Text('Voting Session is Live', style: Theme.of(context).textTheme.headlineMedium?.copyWith(color: Theme.of(context).colorScheme.secondary),),),
                            const SizedBox(height: 16),
                            if(tokensForSimpleJuries.isNotEmpty)
                              ...tokensForSimpleJuries.map((e) {
                                final name = e.name;
                                final token = e.token;
                                return Center(
                                  child: Padding(
                                    padding: const EdgeInsets.only(top: 8),
                                    child: DecoratedBox(
                                      decoration: BoxDecoration(
                                        border: Border.all(color: Theme.of(context).colorScheme.grey),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Padding(
                                        padding: const EdgeInsets.all(12),
                                        child: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Text(
                                              name,
                                              style: Theme.of(context).textTheme.titleLarge,
                                            ),
                                            const SizedBox(height: 4),
                                            QrImageView(
                                                data: token,
                                                size: 250,
                                                backgroundColor: Theme.of(context).colorScheme.white),
                                            const SizedBox(height: 4),
                                            Text(
                                              token,
                                              style: Theme.of(context).textTheme.titleMedium,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              }),
                          ],
                        );
                      },
                    ),
                  );
                },
              ),
            ),
          ),
          floatingActionButton: (state.isInitialized)
              ? Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  spacing: 8,
                  children: [
                    FilledButton(
                      onPressed: () async {
                        final bool res = await showDialog(
                              context: context,
                              builder: (_) {
                                return AlertDialog(
                                  title: const Text('Cancel voting session'),
                                  content: const Text(
                                      'Are you sure you want to cancel this voting session? This action cannot be undone.'),
                                  actions: [
                                    TextButton(
                                      onPressed: () {
                                        context.router.pop(false);
                                      },
                                      child: const Text('No'),
                                    ),
                                    TextButton(
                                      onPressed: () {
                                        context.router.pop(true);
                                      },
                                      child: const Text('Yes'),
                                    ),
                                  ],
                                );
                              },
                            ) ??
                            false;
                        if (!context.mounted || !res) return;

                        context.read<OrganizerVotingProcedurePageBloc>().add(
                              OrganizerVotingProcedurePageCancelVotingSessionProcedure(
                                votingSessionId: state.votingSessionProcedureBundle!
                                    .votingSessionBundle.votingSession.id!,
                              ),
                            );
                      },
                      style: ButtonStyle(
                        backgroundColor:
                            WidgetStateProperty.all<Color>(Theme.of(context).colorScheme.error),
                      ),
                      child: Text(
                        'Cancel procedure',
                        textAlign: TextAlign.center,
                        style: Theme.of(context)
                            .textTheme
                            .bodyMedium
                            ?.copyWith(color: Theme.of(context).colorScheme.onError),
                      ),
                    ),
                    FilledButton(
                      onPressed: () async {
                        final bool res = await showDialog(
                              context: context,
                              builder: (_) {
                                return AlertDialog(
                                  title: const Text('End voting session'),
                                  content: const Text(
                                      'Are you sure you want to end this voting session? Only already submitted votes will be counted.'),
                                  actions: [
                                    TextButton(
                                      onPressed: () {
                                        context.router.pop(false);
                                      },
                                      child: const Text('No'),
                                    ),
                                    TextButton(
                                      onPressed: () {
                                        context.router.pop(true);
                                      },
                                      child: const Text('Yes'),
                                    ),
                                  ],
                                );
                              },
                            ) ??
                            false;
                        if (!context.mounted || !res) return;

                        context.read<OrganizerVotingProcedurePageBloc>().add(
                              OrganizerVotingProcedurePageEndVotingSessionProcedure(
                                votingSessionId: state.votingSessionProcedureBundle!
                                    .votingSessionBundle.votingSession.id!,
                              ),
                            );
                      },
                      style: ButtonStyle(
                        backgroundColor:
                            WidgetStateProperty.all<Color>(Theme.of(context).colorScheme.green),
                      ),
                      child: Text(
                        'End procedure',
                        textAlign: TextAlign.center,
                        style: Theme.of(context)
                            .textTheme
                            .bodyMedium
                            ?.copyWith(color: Theme.of(context).colorScheme.onGreen),
                      ),
                    ),
                  ],
                )
              : const VoidWidget(),
        );
      },
    );
  }
}
