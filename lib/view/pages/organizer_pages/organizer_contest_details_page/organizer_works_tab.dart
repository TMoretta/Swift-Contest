import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:swift_contest/utils/router/go_router.dart';
import 'package:swift_contest/view/widgets/loader.dart';
import 'package:swift_contest/viewmodel/blocs/pages_blocs/organizer_contest_details_page_bloc/organizer_contest_details_page_bloc.dart';
import 'package:swift_contest/viewmodel/enums/bloc_status.dart';

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
  void didChangeDependencies() {
    super.didChangeDependencies();
    final state = context.read<OrganizerContestDetailsPageBloc>().state;
    if (state.status.isInitial) {
      context
          .read<OrganizerContestDetailsPageBloc>()
          .add(OrganizerContestDetailsPageInit(contestId: contestId));
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: BlocBuilder<OrganizerContestDetailsPageBloc, OrganizerContestDetailsPageState>(
        builder: (context, state) {
          switch (state.status) {
            case BlocStatus.initial:
              return SizedBox.shrink();
            case BlocStatus.loading:
              return Loader();
            case BlocStatus.failure:
              if (state.sourceEvent is OrganizerContestDetailsPageInit) {
                return RefreshIndicator.adaptive(
                  onRefresh: () async => context
                      .read<OrganizerContestDetailsPageBloc>()
                      .add(OrganizerContestDetailsPageInit(contestId: contestId)),
                  child: ListView(
                    physics: AlwaysScrollableScrollPhysics(),
                  ),
                );
              } else {
                continue successCase;
              }
            successCase:
            case BlocStatus.success:
              return RefreshIndicator.adaptive(
                onRefresh: () async => context
                    .read<OrganizerContestDetailsPageBloc>()
                    .add(OrganizerContestDetailsPageRefresh(contestId: contestId)),
                child: (state.contestDetailsBundle!.participationsBundles
                        .where((e) => e.work != null)
                        .isNotEmpty)
                    ? ListView.builder(
                        physics: AlwaysScrollableScrollPhysics(),
                        itemCount: state.contestDetailsBundle!.participationsBundles.length,
                        itemBuilder: (context, index) {
                          final participationBundle =
                              state.contestDetailsBundle!.participationsBundles[index];
                          final work = participationBundle.work;
                          final participant = participationBundle.participant;
                          if (work == null) {
                            return SizedBox.shrink();
                          }
                          return Card(
                            clipBehavior: Clip.hardEdge,
                            elevation: 0.2,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            child: InkWell(
                              onTap: () {
                                context.pushNamed(AppRouter.organizerWorkDetails,
                                    extra: participationBundle.toJson());
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
                                      child: Image.network(
                                        work.imagesUrls[0],
                                        width: 65,
                                        fit: BoxFit.cover,
                                        errorBuilder: (context, error, stackTrace) {
                                          return Image.asset(
                                            'assets/images/image_not_found.jpg',
                                            width: 65,
                                            fit: BoxFit.cover,
                                          );
                                        },
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(vertical: 8),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        spacing: 4,
                                        children: [
                                          Text(
                                            work.name,
                                            style: TextStyle(
                                                fontSize: 16, fontWeight: FontWeight.w500),
                                          ),
                                          Text(participant.fullName),
                                        ],
                                      ),
                                    ),
                                  )
                                ],
                              ),
                            ),
                          );
                        },
                      )
                    : RefreshIndicator.adaptive(
                        onRefresh: () async {
                          context
                              .read<OrganizerContestDetailsPageBloc>()
                              .add(OrganizerContestDetailsPageRefresh(contestId: contestId));
                        },
                        child: ListView(
                          children: [Text('No work submitted yet')],
                        ),
                      ),
              );
          }
        },
      ),
    );
  }
}
