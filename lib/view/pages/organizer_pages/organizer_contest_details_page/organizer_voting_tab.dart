import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:swift_contest/model/data_models/voting_form/voting_form_field.dart';
import 'package:swift_contest/utils/router/go_router.dart';
import 'package:swift_contest/view/widgets/loader.dart';
import 'package:swift_contest/view/widgets/show_snack_bar.dart';
import 'package:swift_contest/viewmodel/blocs/bloc_status.dart';
import 'package:swift_contest/viewmodel/blocs/global_blocs/data_transfer_bloc/data_transfer_bloc.dart';
import 'package:swift_contest/viewmodel/blocs/pages_blocs/organizer_contest_details_page_bloc/organizer_contest_details_page_bloc.dart';

class OrganizerVotingTab extends StatefulWidget {
  final String contestId;

  const OrganizerVotingTab({super.key, required this.contestId});

  @override
  State<OrganizerVotingTab> createState() => _OrganizerVotingTabState();
}

class _OrganizerVotingTabState extends State<OrganizerVotingTab> {
  late final String contestId;

  @override
  void initState() {
    super.initState();
    contestId = widget.contestId;
    // final state = context.read<OrganizerContestDetailsPageBloc>().state;
    // if (state.status.isInitial || state.contest == null) {
    //   context
    //       .read<OrganizerContestDetailsPageBloc>()
    //       .add(OrganizerContestDetailsPageGetExtendedContest(contestId: contestId));
    // }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final state = context.read<OrganizerContestDetailsPageBloc>().state;
    if(state.status.isInitial || state.votingForm == null) {
      context.read<OrganizerContestDetailsPageBloc>().add(OrganizerContestDetailsPageGetVotingForm(contestId: contestId));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.loose,
      children: [
        BlocConsumer<OrganizerContestDetailsPageBloc, OrganizerContestDetailsPageState>(
          listener: (context, state) {
            if (state.status.isFailure) {
              showSnackBar(context: context, text: state.message!);
            }
          },
          builder: (context, state) {
            if (state.status.isLoading) {
              return Loader();
            }
            if (state.status.isSuccess && state.votingForm != null) {
              final votingFormPlusContestIdJson = state.votingForm!.toJson();
              votingFormPlusContestIdJson.addAll({'_contest_id': widget.contestId});
              return Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Jurors\' form'),
                      IconButton(
                        onPressed: () async {
                          final List<VotingFormField>? updatedFields = await context.pushNamed(
                            AppRouter.organizerVotingFormEdit,
                            extra: votingFormPlusContestIdJson,
                          ) as List<VotingFormField>?;
                          if (updatedFields != null) {
                            if (context.mounted) {
                              context.read<OrganizerContestDetailsPageBloc>().add(
                                  OrganizerContestDetailsPageUpdateVotingForm(
                                      contestId: widget.contestId, updatedFields: updatedFields));
                            }
                          }
                        },
                        icon: Icon(Icons.edit),
                      ),
                    ],
                  ),
                  Expanded(
                    child: RefreshIndicator.adaptive(
                      onRefresh: () async {
                        context.read<OrganizerContestDetailsPageBloc>().add(
                            OrganizerContestDetailsPageGetVotingForm(contestId: widget.contestId));
                      },
                      child: (state.votingForm!.fields.isNotEmpty)
                          ? ListView.builder(
                              physics: AlwaysScrollableScrollPhysics(),
                              itemCount: state.votingForm!.fields.length,
                              itemBuilder: (context, index) {
                                final field = state.votingForm!.fields[index];
                                return ListTile(
                                  title: Column(
                                    children: [
                                      Row(
                                        children: [
                                          Text(field.name),
                                          (field.isOptional)
                                              ? Text('[Optional]')
                                              : SizedBox.shrink(),
                                        ],
                                      )
                                    ],
                                  ),
                                );
                              },
                            )
                          : ListView(
                              children: [
                                Text('No field added yet'),
                              ],
                            ),
                    ),
                  )
                ],
              );
            }
            return RefreshIndicator.adaptive(
              onRefresh: () async {
                context
                    .read<OrganizerContestDetailsPageBloc>()
                    .add(OrganizerContestDetailsPageGetVotingForm(contestId: widget.contestId));
              },
              child: ListView(
                children: [
                  Text('An error occurred, please refresh'),
                ],
              ),
            );
          },
        ),
        BlocConsumer<OrganizerContestDetailsPageBloc, OrganizerContestDetailsPageState>(
          listener: (context, state) {
            if (state.status.isFailure) {
              showSnackBar(context: context, text: state.message!);
            }
          },
          builder: (context, state) {
            if (state.status.isLoading) {
              return SizedBox.shrink();
            }
            if (state.status.isSuccess) {
              return Positioned(
                bottom: 32,
                right: 16,
                child: FilledButton(
                  onPressed: () {
                    final participationsMaps =
                    state.participations!.map((e) => e.toJson()).toList(growable: false);
                    final participantsMaps =
                    state.participants!.map((e) => e?.toJson()).toList(growable: false);
                    final worksMaps =
                    state.works!.map((e) => e?.toJson()).toList(growable: false);
                    final jurationsMaps =
                    state.jurations!.map((e) => e.toJson()).toList(growable: false);
                    final jurorsMaps =
                    state.jurors!.map((e) => e?.toJson()).toList(growable: false);

                    // Real data structure: Map<String, List<Map<String, dynamic>?>>
                    final Map<String, dynamic> data = {
                      'participations' : participationsMaps,
                      'participants': participantsMaps,
                      'works': worksMaps,
                      'jurations': jurationsMaps,
                      'jurors': jurorsMaps,
                    };

                    context.pushNamed(AppRouter.organizerVotingSettings,extra: data);

                    // context.read<DataTransferBloc>().add(DataTransferSetData(data: data));
                  },
                  child: Text('Start voting'),
                ),
              );
            }
            return SizedBox.shrink();
          },
        ),
        // BlocConsumer<OrganizerContestDetailsPageBloc,OrganizerContestDetailsPageState>(
        //   listener: (context, state) {
        //     if(state.status == BlocStatus.failure) {
        //       showSnackBar(context: context, text: state.message!);
        //     }
        //   },
        //   builder: (context, state) {
        //     if(state.status == BlocStatus.loading) {
        //       return Loader();
        //     }
        //     if(state.status == BlocStatus.success) {
        //       return Column(
        //         children: [
        //           Text('Results'),
        //           ListView.builder(),
        //         ],
        //       );
        //     }
        //   },
        // ),
      ],
    );
  }
}
