import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:swift_contest/model/database/types/storage_bucket.dart';
import 'package:swift_contest/utils/router/app_router.gr.dart';
import 'package:swift_contest/view/widgets/list_view_with_central_label.dart';
import 'package:swift_contest/view/widgets/overlay_loader.dart';
import 'package:swift_contest/view/widgets/storage_image.dart';
import 'package:swift_contest/view/widgets/void_widget.dart';
import 'package:swift_contest/viewmodel/blocs/pages_blocs/organizer_contest_details_page_bloc/organizer_contest_details_page_bloc.dart';
import 'package:swift_contest/viewmodel/types/bloc_status.dart';

class OrganizerWorksTab extends StatefulWidget {
  final String contestId;

  const OrganizerWorksTab({required this.contestId, super.key});

  @override
  State<OrganizerWorksTab> createState() => _OrganizerWorksTabState();
}

class _OrganizerWorksTabState extends State<OrganizerWorksTab> {
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
            child: DefaultTabController(
              length: 2,
              child: Builder(
                builder: (context) {
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
                  final participationsWithWorksBundles =
                  state.contestDetailsBundle!.participationsBundles.where((e) => e.work !=null).toList(growable: false);
                  final participationsWithoutWorksBundles =
                  state.contestDetailsBundle!.participationsBundles.where((e) => e.work == null).toList(growable: false);
                  return Column(
                    children: [
                      Card(
                        elevation: 0.4,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        child: SizedBox(
                          height: 30,
                          child: TabBar(
                            labelColor: Theme.of(context).colorScheme.onTertiary,
                            isScrollable: false,
                            dividerColor: Colors.transparent,
                            tabAlignment: TabAlignment.center,
                            splashBorderRadius: BorderRadius.circular(16),
                            indicatorSize: TabBarIndicatorSize.tab,
                            indicator: BoxDecoration(
                              borderRadius: BorderRadius.circular(16),
                              color: Theme.of(context).colorScheme.tertiary,
                            ),
                            tabs: [
                              Tab(text: 'Submitted'),
                              Tab(text: 'Attended'),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(height: 8),
                      Expanded(
                        child: TabBarView(
                          children: [
                            //* Submitted works
                            RefreshIndicator.adaptive(
                              onRefresh: () async => context
                                  .read<OrganizerContestDetailsPageBloc>()
                                  .add(
                                  OrganizerContestDetailsPageFetch(contestId: contestId)),
                              child: (participationsWithWorksBundles.isEmpty)
                                  ? ListViewWithCentralLabel(label: 'No work submitted yet')
                                  : ListView.builder(
                                itemCount: participationsWithWorksBundles.length,
                                itemBuilder: (context, index) {
                                  final participationBundle =
                                  participationsWithWorksBundles[index];
                                  return Card(
                                    clipBehavior: Clip.hardEdge,
                                    elevation: 0.2,
                                    shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12)),
                                    child: InkWell(
                                      onTap: () {
                                        context.router.push(OrganizerWorkDetailsRoute(
                                            participationId:
                                            participationBundle.participation.id!));
                                      },
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        spacing: 16,
                                        children: [
                                          SizedBox(
                                            width: 65,
                                            height: 65,
                                            child: ClipRRect(
                                              borderRadius: BorderRadius.all(
                                                Radius.circular(12),
                                              ),
                                              clipBehavior: Clip.hardEdge,
                                              child: StorageImage(
                                              bucket: StorageBucket.worksImages,
                                              path: participationBundle.work!.imagesPaths[0],
                                              fit: BoxFit.cover,
                                            ),
                                            ),
                                          ),
                                          Expanded(
                                            child: Padding(
                                              padding:
                                              const EdgeInsets.symmetric(vertical: 8),
                                              child: Column(
                                                crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                                spacing: 4,
                                                children: [
                                                  Text(
                                                    participationBundle.work!.name,
                                                    style: TextStyle(
                                                        fontSize: 16,
                                                        fontWeight: FontWeight.w500),
                                                  ),
                                                  Text(participationBundle
                                                      .participant.fullName),
                                                ],
                                              ),
                                            ),
                                          )
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                            //* Attended
                            RefreshIndicator.adaptive(
                              onRefresh: () async => context
                                  .read<OrganizerContestDetailsPageBloc>()
                                  .add(
                                  OrganizerContestDetailsPageFetch(contestId: contestId)),
                              child: (participationsWithoutWorksBundles.isEmpty)
                                  ? ListViewWithCentralLabel(
                                  label: 'No work attended from joined participants')
                                  : ListView.builder(
                                itemCount: participationsWithWorksBundles.length,
                                itemBuilder: (context, index) {
                                  final participationBundle =
                                  participationsWithoutWorksBundles[index];
                                  return Card(
                                    elevation: 0.2,
                                    child: ListTile(
                                      title:
                                      Text(participationBundle.participant.fullName),
                                      subtitle: Text(participationBundle
                                          .participation.invitationEmail),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
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