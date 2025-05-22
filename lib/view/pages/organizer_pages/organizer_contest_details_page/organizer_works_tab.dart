import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:swift_contest/model/mixed_models/participant_and_work.dart';
import 'package:swift_contest/utils/functions/show_snack_bar.dart';
import 'package:swift_contest/utils/router/go_router.dart';
import 'package:swift_contest/view/widgets/loader.dart';
import 'package:swift_contest/viewmodel/enums/bloc_status.dart';
import 'package:swift_contest/viewmodel/blocs/pages_blocs/organizer_contest_details_page_bloc/organizer_contest_details_page_bloc.dart';

class OrganizerWorksTab extends StatefulWidget {
  final String contestId;

  const OrganizerWorksTab({super.key, required this.contestId});

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
    if (state.status.isInitial || state.works == null) {
      context
          .read<OrganizerContestDetailsPageBloc>()
          .add(OrganizerContestDetailsPageGetContestMainInfo(contestId: contestId));
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: LayoutBuilder(
        builder: (context, constraints) {
          return SizedBox(
            width: constraints.maxWidth,
            height: constraints.maxHeight,
            child: BlocConsumer<OrganizerContestDetailsPageBloc,
                OrganizerContestDetailsPageState>(
              listener: (context, state) {
                if (state.status.isFailure) {
                  showSnackBar(context: context, text: state.message!);
                }
              },
              builder: (context, state) {
                if (state.status.isLoading) {
                  return Loader();
                }
                if (state.status.isSuccess && state.works != null) {
                  return RefreshIndicator.adaptive(
                    onRefresh: () async => context
                        .read<OrganizerContestDetailsPageBloc>()
                        .add(OrganizerContestDetailsPageGetContestMainInfo(contestId: contestId)),
                    child: (state.works!.isNotEmpty)
                        ? ListView.builder(
                            physics: AlwaysScrollableScrollPhysics(),
                            itemCount: state.works!.length,
                            itemBuilder: (context, index) {
                              final work = state.works![index];
                              final participant = state.participants![index];
                              if (work == null || participant == null) {
                                return SizedBox.shrink();
                              }
                              return Card(
                                clipBehavior: Clip.hardEdge,
                                elevation: 0.2,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12)),
                                child: InkWell(
                                  onTap: () {
                                    final participantAndWork =
                                        ParticipantAndWork(
                                      participant: state.participants![index]!,
                                      work: state.works![index]!,
                                    );
                                    context.pushNamed(
                                        AppRouter.organizerWorkDetails,
                                        extra: participantAndWork.toJson());
                                  },
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
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
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 8),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            spacing: 4,
                                            children: [
                                              Text(
                                                work.name,
                                                style: TextStyle(
                                                    fontSize: 16,
                                                    fontWeight:
                                                        FontWeight.w500),
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
                                  .add(OrganizerContestDetailsPageGetContestMainInfo(contestId: contestId));
                            },
                            child: ListView(
                              children: [Text('No work submitted yet')],
                            ),
                          ),
                  );
                }
                return RefreshIndicator.adaptive(
                  onRefresh: () async => context
                      .read<OrganizerContestDetailsPageBloc>()
                      .add(OrganizerContestDetailsPageGetContestMainInfo(contestId: contestId)),
                  child: ListView(),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
