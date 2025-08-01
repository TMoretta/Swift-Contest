import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:swift_contest/model/database/types/voting_session_status.dart';
import 'package:swift_contest/utils/labels/labels.dart';
import 'package:swift_contest/utils/router/app_router.gr.dart';
import 'package:swift_contest/view/widgets/list_view_with_central_label.dart';
import 'package:swift_contest/view/widgets/overlay_loader.dart';
import 'package:swift_contest/view/widgets/show_snack_bar.dart';
import 'package:swift_contest/view/widgets/void_widget.dart';
import 'package:swift_contest/viewmodel/blocs/auth_bloc/auth_bloc.dart';
import 'package:swift_contest/viewmodel/blocs/pages_blocs/juror_contest_details_page_bloc/juror_contest_details_page_bloc.dart';
import 'package:swift_contest/viewmodel/enums/bloc_status.dart';

class JurorVotingTab extends StatefulWidget {
  final String contestId;

  const JurorVotingTab({required this.contestId, super.key});

  @override
  State<JurorVotingTab> createState() => _JurorVotingTabState();
}

class _JurorVotingTabState extends State<JurorVotingTab> {
  late String contestId;
  late String profileId;

  @override
  void initState() {
    super.initState();
    contestId = widget.contestId;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    profileId = context.read<AuthBloc>().state.profile!.id!;
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
          body: Builder(
            builder: (context) {
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
                      onRefresh: () async => context
                          .read<JurorContestDetailsPageBloc>()
                          .add(JurorContestDetailsPageFetch(contestId: contestId)),
                      child: ListViewWithCentralLabel(label: Labels.anErrorOccurred),
                    );
                  } else {
                    continue successCase;
                  }
                successCase:
                case BlocStatus.success:
                  final liveVotingSessionBundle = state.contestDetailsBundle!.votingSessionsBundles.where((e) => !e.votingSession.sessionStatus.isEnded && !e.votingSession.sessionStatus.isCancelled)
                      .firstOrNull;
                  return RefreshIndicator.adaptive(
                    onRefresh: () async => context
                        .read<JurorContestDetailsPageBloc>()
                        .add(JurorContestDetailsPageFetch(contestId: contestId)),
                    child: Builder(
                      builder: (context) {
                        if (liveVotingSessionBundle != null) {
                          return ListViewWithCentralLabel(label: 'Voting session is live');
                        } else {
                          return ListViewWithCentralLabel(label: 'No voting session live');
                        }
                      },
                    ),
                  );
              }
            },
          ),
          floatingActionButton: (state.isInitialized) ? Builder(
            builder: (
              context,
            ) {
              final liveVotingSessionBundle = state.contestDetailsBundle!.votingSessionsBundles.where((e) => !e.votingSession.sessionStatus.isEnded && !e.votingSession.sessionStatus.isCancelled)
                  .firstOrNull;
              return Column(
                mainAxisSize: MainAxisSize.min,
                spacing: 8,
                children: [
                  Text(
                    (liveVotingSessionBundle != null)
                        ? 'Voting session is live'
                        : 'No voting session live',
                    style: Theme.of(context).textTheme.labelMedium,
                  ),
                  FloatingActionButton.extended(
                    onPressed: (liveVotingSessionBundle != null)
                        ? () async {
                            if (liveVotingSessionBundle.votingSession.isGeoRestricted) {
                              showDialog(
                                context: context,
                                builder: (context) {
                                  return AlertDialog(
                                    title: Text('Geo locate'),
                                    content: Text(
                                        'This voting session is restricted to a specific geographic area. '
                                        'It is recommended to verify location before proceed.'),
                                    actions: [
                                      TextButton(
                                        onPressed: () => context.pop(),
                                        child: Text('Cancel'),
                                      ),
                                      TextButton(
                                        onPressed: () async {
                                          try {
                                            final status = await Geolocator.checkPermission();
                                            if (status == LocationPermission.denied) {
                                              final newStatus =
                                                  await Geolocator.requestPermission();
                                              if (newStatus == LocationPermission.denied ||
                                                  newStatus == LocationPermission.deniedForever) {
                                                if (context.mounted) {
                                                  showSnackBar(
                                                      context: context,
                                                      text: 'Location permission denied.');
                                                }
                                                return;
                                              }
                                            }
                                            final currentPosition = await Geolocator.getCurrentPosition();
                                            final geoResPlace = liveVotingSessionBundle.geoResPlace;
                                            final distance = Geolocator.distanceBetween(
                                              geoResPlace!.lat,
                                              geoResPlace.lon,
                                              currentPosition.latitude,
                                              currentPosition.longitude,
                                            );

                                            if (distance > liveVotingSessionBundle.votingSession.geoResRadius!) {
                                              if(context.mounted) {
                                                showSnackBar(context: context, text: 'You are not inside the area of voting:\n${geoResPlace.address}');
                                              }
                                              return;
                                            }
                                          } catch (e) {
                                            if(context.mounted) {
                                              showSnackBar(context: context, text: 'Could not get location');
                                            }
                                            return;
                                          }
                                        },
                                        child: Text('Verify'),
                                      ),
                                      TextButton(
                                        onPressed: () => context.pop(),
                                        child: Text('Proceed'),
                                      ),
                                    ],
                                  );
                                },
                              );
                            }

                            final bool? res = await context.router.push(
                                JurorVotingProcedureRoute(votingSessionId: liveVotingSessionBundle.votingSession.id!));
                            if (res == true) {
                              if (context.mounted) {
                                context
                                    .read<JurorContestDetailsPageBloc>()
                                    .add(JurorContestDetailsPageFetch(contestId: contestId));
                              }
                            }
                          }
                        : null,
                    icon: Icon(Icons.text_snippet),
                    label: Text('Vote'),
                  ),
                ],
              );
            },
          ) : VoidWidget(),
        );
      },
    );
  }
}
