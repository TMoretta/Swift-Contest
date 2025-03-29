import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:swift_contest/model/data_models/voting_form/voting_form_field.dart';
import 'package:swift_contest/utils/router/go_router.dart';
import 'package:swift_contest/view/widgets/loader.dart';
import 'package:swift_contest/view/widgets/show_snack_bar.dart';
import 'package:swift_contest/viewmodel/blocs/organizer_pages_blocs/organizer_contest_details_page_bloc/organizer_contest_details_page_bloc.dart';
import 'package:swift_contest/viewmodel/utils/bloc_status.dart';

class OrganizerVotingTab extends StatefulWidget {
  final String contestId;

  const OrganizerVotingTab({super.key, required this.contestId});

  @override
  State<OrganizerVotingTab> createState() => _OrganizerVotingTabState();
}

class _OrganizerVotingTabState extends State<OrganizerVotingTab> {
  @override
  void initState() {
    super.initState();
    final state = context.read<OrganizerContestDetailsPageBloc>().state;
    if (state.votingForm == null) {
      context
          .read<OrganizerContestDetailsPageBloc>()
          .add(OrganizerContestDetailsPageGetVotingForm(contestId: widget.contestId));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.loose,
      children: [
        BlocConsumer<OrganizerContestDetailsPageBloc, OrganizerContestDetailsPageState>(
          listener: (context, state) {
            if (state.status == BlocStatus.failure) {
              showSnackBar(context: context, text: state.message!);
            }
          },
          builder: (context, state) {
            if (state.status == BlocStatus.loading) {
              return Loader();
            }
            if (state.status == BlocStatus.success && state.votingForm != null) {
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
            if (state.status == BlocStatus.failure) {
              showSnackBar(context: context, text: state.message!);
            }
          },
          builder: (context, state) {
            return Positioned(
              bottom: 32,
              right: 16,
              child: FilledButton(
                  onPressed: (state.status == BlocStatus.loading) ? null : () {
                    context.pushNamed(AppRouter.organizerVotingSettings);
                  },
                  child: Text('Start voting')),
            );
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
