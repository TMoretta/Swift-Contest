import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:swift_contest/model/data_models/voting_form_field.dart';
import 'package:swift_contest/model/data_models/voting_session.dart';
import 'package:swift_contest/model/enums/juror_status.dart';
import 'package:swift_contest/model/enums/participant_status.dart';
import 'package:swift_contest/model/mixed_models/juration_and_juror.dart';
import 'package:swift_contest/model/mixed_models/participation_and_participant.dart';
import 'package:swift_contest/model/mixed_models/participation_and_participant_and_work.dart';
import 'package:swift_contest/utils/functions/show_snack_bar.dart';
import 'package:swift_contest/utils/router/go_router.dart';
import 'package:swift_contest/view/widgets/loader.dart';
import 'package:swift_contest/viewmodel/blocs/bloc_status.dart';
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
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final state = context
        .read<OrganizerContestDetailsPageBloc>()
        .state;
    if (state.status.isInitial || state.votingForm == null) {
      context
          .read<OrganizerContestDetailsPageBloc>()
          .add(OrganizerContestDetailsPageGetVotingTabInfo(contestId: widget.contestId));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocConsumer<OrganizerContestDetailsPageBloc, OrganizerContestDetailsPageState>(
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
            final List<VotingFormFieldRaw> rawVotingFormFields = state.votingFormFields!.map((e) {
              return VotingFormFieldRaw(
                name: e.name,
                minValue: e.minValue,
                maxValue: e.maxValue,
              );
            }).toList(growable: false);
            final rawVotingFormFieldsJson =
            rawVotingFormFields.map((e) => e.toJson()).toList(growable: false);
            return Column(
              children: [
                //* Jurors' form
                Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Jurors\' form'),
                        IconButton(
                          onPressed: () async {
                            final List<Map<String, dynamic>>? updatedFieldsJson =
                            await context.pushNamed(
                              AppRouter.organizerVotingFormEdit,
                              extra: rawVotingFormFieldsJson,
                            ) as List<Map<String, dynamic>>?;
                            final updatedFields = updatedFieldsJson
                                ?.map((e) => VotingFormFieldRaw.fromJson(e))
                                .toList(growable: false);
                            if (updatedFields != null) {
                              if (context.mounted) {
                                context
                                    .read<OrganizerContestDetailsPageBloc>()
                                    .add(OrganizerContestDetailsPageUpdateVotingFormFields(
                                  votingFormId: state.votingForm!.id,
                                  rawVotingFormFields: updatedFields,
                                ));
                              }
                            }
                          },
                          icon: Icon(Icons.edit),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 200,
                      child: RefreshIndicator.adaptive(
                        onRefresh: () async {
                          context.read<OrganizerContestDetailsPageBloc>().add(
                              OrganizerContestDetailsPageGetVotingTabInfo(
                                  contestId: widget.contestId));
                        },
                        child: (state.votingFormFields!.isNotEmpty)
                            ? ListView.builder(
                          physics: AlwaysScrollableScrollPhysics(),
                          itemCount: state.votingFormFields!.length,
                          itemBuilder: (context, index) {
                            final field = state.votingFormFields![index];
                            return ListTile(
                              title: Column(
                                children: [
                                  Row(
                                    children: [
                                      Text(field.name),
                                    ],
                                  )
                                ],
                              ),
                            );
                          },
                        )
                            : ListView(
                          physics: AlwaysScrollableScrollPhysics(),
                          children: [
                            Text('No field added yet'),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                //* Results
                Column(
                  children: [
                    Text('Results'),
                    SizedBox(
                      height: 200,
                      child: RefreshIndicator.adaptive(
                        onRefresh: () async {
                          context.read<OrganizerContestDetailsPageBloc>().add(
                              OrganizerContestDetailsPageGetVotingTabInfo(
                                  contestId: widget.contestId));
                        },
                        child: (state.endedVotingSessions != null &&
                            state.endedVotingSessions!.isNotEmpty)
                            ? ListView.builder(
                          itemCount: state.endedVotingSessions!.length,
                          itemBuilder: (context, index) {
                            final endedVotingSession = state.endedVotingSessions![index];
                            return ListTile(
                              onTap: () {
                                final Map<String,dynamic> data = {
                                  'contest_id' : widget.contestId,
                                  'voting_session_id' : endedVotingSession.id,
                                };
                                context.pushNamed(AppRouter.organizerVotingResults, extra: data);
                              },
                              title: Text(endedVotingSession.name),
                            );
                          },
                        )
                            : ListView(
                          physics: AlwaysScrollableScrollPhysics(),
                          children: [Text('No results yet')],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            );
          }
          return RefreshIndicator.adaptive(
            onRefresh: () async {
              context
                  .read<OrganizerContestDetailsPageBloc>()
                  .add(OrganizerContestDetailsPageGetVotingTabInfo(contestId: widget.contestId));
            },
            child: ListView(
              children: [
                Text('An error occurred, please refresh'),
              ],
            ),
          );
        },
      ),
      floatingActionButton:
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
          if (state.status.isSuccess && state.votingForm != null) {
            if (state.votingSessionLive == null) {
              return FilledButton(
                onPressed: () async {
                  final participations = state.participations!;
                  final participants = state.participants!;
                  final works = state.works!;
                  final jurations = state.jurations!;
                  final jurors = state.jurors!;

                  final List<ParticipationAndParticipantAndWork>
                  joinedParticipationsAndParticipantsWithWorks = [];
                  final List<ParticipationAndParticipant>
                  joinedParticipationsAndParticipantsWithoutWorks = [];
                  final List<JurationAndJuror> joinedJurationsAndJurors = [];

                  for (var i = 0; i < participations.length; i++) {
                    if (participations[i].participantStatus == ParticipantStatus.joined) {
                      if (works[i] != null) {
                        final ppw = ParticipationAndParticipantAndWork(
                          participation: participations[i],
                          participant: participants[i],
                          work: works[i],
                        );
                        joinedParticipationsAndParticipantsWithWorks.add(ppw);
                      } else {
                        final pp = ParticipationAndParticipant(
                          participation: participations[i],
                          participant: participants[i],
                        );
                        joinedParticipationsAndParticipantsWithoutWorks.add(pp);
                      }
                    }
                  }
                  if (joinedParticipationsAndParticipantsWithWorks.isEmpty) {
                    showSnackBar(
                      context: context,
                      text: 'At least one participant with submitted work is necessary',
                    );
                    return;
                  }

                  for (var i = 0; i < jurations.length; i++) {
                    if (jurations[i].jurorStatus == JurorStatus.joined) {
                      final jj = JurationAndJuror(
                        juration: jurations[i],
                        juror: jurors[i],
                      );
                      joinedJurationsAndJurors.add(jj);
                    }
                  }

                  if (joinedJurationsAndJurors.isEmpty) {
                    showSnackBar(
                      context: context,
                      text: 'At least one juror is necessary',
                    );
                    return;
                  }

                  final joinedParticipationsAndParticipantsWithWorksJson =
                  joinedParticipationsAndParticipantsWithWorks
                      .map((e) => e.toJson())
                      .toList(growable: false);
                  final joinedParticipationsAndParticipantsWithoutWorksJson =
                  joinedParticipationsAndParticipantsWithoutWorks
                      .map((e) => e.toJson())
                      .toList(growable: false);
                  final joinedJurationsAndJurorsJson =
                  joinedJurationsAndJurors.map((e) => e.toJson()).toList(growable: false);

                  final Map<String, dynamic> data = {
                    'contest_id': contestId,
                    'voting_form_id': state.votingForm!.id,
                    'joined_participants_with_works':
                    joinedParticipationsAndParticipantsWithWorksJson,
                    'joined_participants_without_works':
                    joinedParticipationsAndParticipantsWithoutWorksJson,
                    'joined_jurors': joinedJurationsAndJurorsJson,
                  };

                  final VotingSession? votingSession =
                  await context.pushNamed(AppRouter.organizerVotingSettings, extra: data);
                  if (votingSession == null) {
                    return;
                  }
                  if (context.mounted) {
                    context.pushNamed(AppRouter.organizerVotingProcedure);
                  }
                },
                child: Text('Start voting'),
              );
            } else {
              return Positioned(
                bottom: 32,
                right: 16,
                child: FilledButton(
                  onPressed: () {
                    //todo: voting procedure already started
                  },
                  child: Text('Continue voting'),
                ),
              );
            }
          }
          return SizedBox.shrink();
        },
      ),
    );

    // return Stack(
    //   fit: StackFit.loose,
    //   children: [
    //     BlocConsumer<OrganizerContestDetailsPageBloc, OrganizerContestDetailsPageState>(
    //       listener: (context, state) {
    //         if (state.status.isFailure) {
    //           showSnackBar(context: context, text: state.message!);
    //         }
    //       },
    //       builder: (context, state) {
    //         if (state.status.isLoading) {
    //           return Loader();
    //         }
    //         if (state.status.isSuccess && state.votingForm != null) {
    //           final List<RawVotingFormField> rawVotingFormFields = state.votingFormFields!.map((e) {
    //             return RawVotingFormField(
    //               name: e.name,
    //               fieldType: e.fieldType,
    //               isOptional: e.isOptional,
    //               minValue: e.minValue,
    //               maxValue: e.maxValue,
    //             );
    //           }).toList(growable: false);
    //           final rawVotingFormFieldsJson =
    //               rawVotingFormFields.map((e) => e.toJson()).toList(growable: false);
    //           return Column(
    //             children: [
    //               Row(
    //                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
    //                 children: [
    //                   Text('Jurors\' form'),
    //                   IconButton(
    //                     onPressed: () async {
    //                       final List<Map<String, dynamic>>? updatedFieldsJson =
    //                           await context.pushNamed(
    //                         AppRouter.organizerVotingFormEdit,
    //                         extra: rawVotingFormFieldsJson,
    //                       ) as List<Map<String, dynamic>>?;
    //                       final updatedFields = updatedFieldsJson
    //                           ?.map((e) => RawVotingFormField.fromJson(e))
    //                           .toList(growable: false);
    //                       if (updatedFields != null) {
    //                         if (context.mounted) {
    //                           context
    //                               .read<OrganizerContestDetailsPageBloc>()
    //                               .add(OrganizerContestDetailsPageUpdateVotingFormFields(
    //                                 votingFormId: state.votingForm!.id,
    //                                 rawVotingFormFields: updatedFields,
    //                               ));
    //                         }
    //                       }
    //                     },
    //                     icon: Icon(Icons.edit),
    //                   ),
    //                 ],
    //               ),
    //               Expanded(
    //                 child: RefreshIndicator.adaptive(
    //                   onRefresh: () async {
    //                     context.read<OrganizerContestDetailsPageBloc>().add(
    //                         OrganizerContestDetailsPageGetVotingTabInfo(
    //                             contestId: widget.contestId));
    //                   },
    //                   child: (state.votingFormFields!.isNotEmpty)
    //                       ? ListView.builder(
    //                           physics: AlwaysScrollableScrollPhysics(),
    //                           itemCount: state.votingFormFields!.length,
    //                           itemBuilder: (context, index) {
    //                             final field = state.votingFormFields![index];
    //                             return ListTile(
    //                               title: Column(
    //                                 children: [
    //                                   Row(
    //                                     children: [
    //                                       Text(field.name),
    //                                       (field.isOptional)
    //                                           ? Text('[Optional]')
    //                                           : SizedBox.shrink(),
    //                                     ],
    //                                   )
    //                                 ],
    //                               ),
    //                             );
    //                           },
    //                         )
    //                       : ListView(
    //                           children: [
    //                             Text('No field added yet'),
    //                           ],
    //                         ),
    //                 ),
    //               )
    //             ],
    //           );
    //         }
    //         return RefreshIndicator.adaptive(
    //           onRefresh: () async {
    //             context
    //                 .read<OrganizerContestDetailsPageBloc>()
    //                 .add(OrganizerContestDetailsPageGetVotingTabInfo(contestId: widget.contestId));
    //           },
    //           child: ListView(
    //             children: [
    //               Text('An error occurred, please refresh'),
    //             ],
    //           ),
    //         );
    //       },
    //     ),
    //     BlocConsumer<OrganizerContestDetailsPageBloc, OrganizerContestDetailsPageState>(
    //       listener: (context, state) {
    //         if (state.status.isFailure) {
    //           showSnackBar(context: context, text: state.message!);
    //         }
    //       },
    //       builder: (context, state) {
    //         if (state.status.isLoading) {
    //           return SizedBox.shrink();
    //         }
    //         if (state.status.isSuccess && state.votingForm != null) {
    //           if (state.votingSessionLive == null) {
    //             return Positioned(
    //               bottom: 32,
    //               right: 16,
    //               child: FilledButton(
    //                 onPressed: () async {
    //                   final participations = state.participations!;
    //                   final participants = state.participants!;
    //                   final works = state.works!;
    //                   final jurations = state.jurations!;
    //                   final jurors = state.jurors!;
    //
    //                   final List<ParticipationAndParticipantAndWork>
    //                       joinedParticipationsAndParticipantsWithWorks = [];
    //                   final List<ParticipationAndParticipant>
    //                       joinedParticipationsAndParticipantsWithoutWorks = [];
    //                   final List<JurationAndJuror> joinedJurationsAndJurors = [];
    //
    //                   for (var i = 0; i < participations.length; i++) {
    //                     if (participations[i].participantStatus == ParticipantStatus.joined) {
    //                       if (works[i] != null) {
    //                         final ppw = ParticipationAndParticipantAndWork(
    //                           participation: participations[i],
    //                           participant: participants[i],
    //                           work: works[i],
    //                         );
    //                         joinedParticipationsAndParticipantsWithWorks.add(ppw);
    //                       } else {
    //                         final pp = ParticipationAndParticipant(
    //                           participation: participations[i],
    //                           participant: participants[i],
    //                         );
    //                         joinedParticipationsAndParticipantsWithoutWorks.add(pp);
    //                       }
    //                     }
    //                   }
    //                   if (joinedParticipationsAndParticipantsWithWorks.isEmpty) {
    //                     showSnackBar(
    //                       context: context,
    //                       text: 'At least one participant with submitted work is necessary',
    //                     );
    //                     return;
    //                   }
    //
    //                   for (var i = 0; i < jurations.length; i++) {
    //                     if (jurations[i].jurorStatus == JurorStatus.joined) {
    //                       final jj = JurationAndJuror(
    //                         juration: jurations[i],
    //                         juror: jurors[i],
    //                       );
    //                       joinedJurationsAndJurors.add(jj);
    //                     }
    //                   }
    //
    //                   if (joinedJurationsAndJurors.isEmpty) {
    //                     showSnackBar(
    //                       context: context,
    //                       text: 'At least one juror is necessary',
    //                     );
    //                     return;
    //                   }
    //
    //                   final joinedParticipationsAndParticipantsWithWorksJson =
    //                       joinedParticipationsAndParticipantsWithWorks
    //                           .map((e) => e.toJson())
    //                           .toList(growable: false);
    //                   final joinedParticipationsAndParticipantsWithoutWorksJson =
    //                       joinedParticipationsAndParticipantsWithoutWorks
    //                           .map((e) => e.toJson())
    //                           .toList(growable: false);
    //                   final joinedJurationsAndJurorsJson =
    //                       joinedJurationsAndJurors.map((e) => e.toJson()).toList(growable: false);
    //
    //                   final Map<String, dynamic> data = {
    //                     'contest_id': contestId,
    //                     'voting_form_id': state.votingForm!.id,
    //                     'joined_participants_with_works':
    //                         joinedParticipationsAndParticipantsWithWorksJson,
    //                     'joined_participants_without_works':
    //                         joinedParticipationsAndParticipantsWithoutWorksJson,
    //                     'joined_jurors': joinedJurationsAndJurorsJson,
    //                   };
    //
    //                   final VotingSession? votingSession =
    //                       await context.pushNamed(AppRouter.organizerVotingSettings, extra: data);
    //                   if (votingSession == null) {
    //                     return;
    //                   }
    //                   if (context.mounted) {
    //                     context.pushNamed(AppRouter.organizerVotingProcedure);
    //                   }
    //                 },
    //                 child: Text('Start voting'),
    //               ),
    //             );
    //           } else {
    //             return Positioned(
    //               bottom: 32,
    //               right: 16,
    //               child: FilledButton(
    //                 onPressed: () {
    //                   //todo: voting procedure already started
    //                 },
    //                 child: Text('Continue voting'),
    //               ),
    //             );
    //           }
    //         }
    //         return SizedBox.shrink();
    //       },
    //     ),
    //     // BlocConsumer<OrganizerContestDetailsPageBloc,OrganizerContestDetailsPageState>(
    //     //   listener: (context, state) {
    //     //     if(state.status == BlocStatus.failure) {
    //     //       showSnackBar(context: context, text: state.message!);
    //     //     }
    //     //   },
    //     //   builder: (context, state) {
    //     //     if(state.status == BlocStatus.loading) {
    //     //       return Loader();
    //     //     }
    //     //     if(state.status == BlocStatus.success) {
    //     //       return Column(
    //     //         children: [
    //     //           Text('Results'),
    //     //           ListView.builder(),
    //     //         ],
    //     //       );
    //     //     }
    //     //   },
    //     // ),
    //   ],
    // );
  }
}
