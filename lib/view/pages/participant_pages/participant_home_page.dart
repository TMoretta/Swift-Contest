import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:swift_contest/model/data_models/profile/contest_role.dart';
import 'package:swift_contest/model/data_models/user/user.dart';
import 'package:swift_contest/utils/di/di.dart';
import 'package:swift_contest/utils/router/go_router.dart';
import 'package:swift_contest/view/widgets/contest_card.dart';
import 'package:swift_contest/view/widgets/custom_text_form_field.dart';
import 'package:swift_contest/view/widgets/home_page_app_bar.dart';
import 'package:swift_contest/view/widgets/loader.dart';
import 'package:swift_contest/view/widgets/show_snack_bar.dart';
import 'package:swift_contest/viewmodel/blocs/app_auth_bloc/app_auth_bloc.dart';
import 'package:swift_contest/viewmodel/blocs/participant_pages_blocs/participant_home_page_bloc/participant_home_page_bloc.dart';

class ParticipantHomePage extends StatefulWidget {
  const ParticipantHomePage({super.key});

  @override
  State<ParticipantHomePage> createState() => _ParticipantHomePageState();
}

class _ParticipantHomePageState extends State<ParticipantHomePage> {
  late User user;

  @override
  void initState() {
    super.initState();
    final appAuthState = context.read<AppAuthBloc>().state;
    user = (appAuthState as AppAuthAuthenticated).user;
    final participantHomePageBloc = context.read<ParticipantHomePageBloc>();
    final participantHomePageState = participantHomePageBloc.state;
    if (participantHomePageState is! ParticipantHomePageSuccess) {
      participantHomePageBloc
          .add(ParticipantHomePageGetJoinedContestsExtended(participantId: user.id));
    }
  }

  @override
  Widget build(BuildContext context) {
    final joinContestFormKey = GlobalKey<FormState>();
    String? contestToken;
    String? participantToken;

    return BlocProvider(
      create: (context) => getIt<ParticipantHomePageBloc>()
        ..add(ParticipantHomePageGetJoinedContestsExtended(participantId: user.id)),
      child: Scaffold(
        appBar: HomePageAppBar(contestRole: ContestRole.participant),
        body: BlocConsumer<ParticipantHomePageBloc, ParticipantHomePageState>(
          listener: (context, state) {
            if (state is ParticipantHomePageFailure) {
              showSnackBar(context: context, text: state.message);
            }
          },
          builder: (context, state) {
            if (state is ParticipantHomePageSuccess) {
              final contests = state.contests!;
              return Padding(
                padding: EdgeInsets.only(left: 16, right: 16),
                child: RefreshIndicator.adaptive(
                  onRefresh: () async => context
                      .read<ParticipantHomePageBloc>()
                      .add(ParticipantHomePageGetJoinedContestsExtended(participantId: user.id)),
                  child: ListView.builder(
                    itemCount: contests.length,
                    itemBuilder: (context, index) {
                      final contest = contests[index];
                      return Column(
                        children: [
                          ContestCard(
                            contest: state.contests![index],
                            organizer: state.organizers![index],
                            participations: state.participations![index],
                            jurations: state.jurations![index],
                            onTap: () {
                              context.pushNamed(AppRouter.participantContestDetails,
                                  extra: contest.id);
                            },
                          ),
                          SizedBox(height: 8),
                        ],
                      );
                    },
                  ),
                ),
              );
            }
            if (state is ParticipantHomePageLoading) {
              return Loader();
            }
            return Container();
          },
        ),
        floatingActionButton: FilledButton(
          onPressed: () {
            showDialog(
              context: context,
              builder: (context) {
                return AlertDialog(
                  title: Text('Join as participant'),
                  content: Form(
                    key: joinContestFormKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        CustomTextFormFieldUnderlined(
                          label: 'Contest token',
                          onChanged: (value) => contestToken = value,
                          validator: (value) => noEmptyValidator(value?.trim()),
                        ),
                        CustomTextFormFieldUnderlined(
                          label: 'Invitation token',
                          onChanged: (value) => participantToken = value,
                          validator: (value) => noEmptyValidator(value?.trim()),
                        ),
                      ],
                    ),
                  ),
                  actions: [
                    BlocProvider(
                      create: (context) => getIt<ParticipantHomePageBloc>(),
                      child: BlocConsumer<ParticipantHomePageBloc, ParticipantHomePageState>(
                        listener: (context, state) {
                          if (state is ParticipantHomePageFailure) {
                            showSnackBar(context: context, text: state.message);
                          }
                          if (state is ParticipantHomePageSuccess) {
                            context.pop();
                            showSnackBar(context: context, text: 'Joined contest successfully');
                          }
                        },
                        builder: (context, state) {
                          if (state is ParticipantHomePageLoading) {
                            return Loader();
                          }
                          return Row(
                            mainAxisSize: MainAxisSize.max,
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              TextButton(
                                onPressed: () {
                                  context.pop();
                                },
                                child: Text('Cancel'),
                              ),
                              TextButton(
                                onPressed: () {
                                  if (joinContestFormKey.currentState?.validate() ?? false) {
                                    context.read<ParticipantHomePageBloc>().add(
                                          ParticipantHomePageJoinContest(
                                            participantId: user.id,
                                            contestToken: contestToken!,
                                            participantToken: participantToken!,
                                          ),
                                        );
                                  }
                                },
                                child: Text('Ok'),
                              ),
                            ],
                          );
                        },
                      ),
                    )
                  ],
                );
              },
            );
          },
          child: Text('Join a contest'),
        ),
      ),
    );
  }
}

String? noEmptyValidator(String? value) {
  if (value == null || value == '') {
    return '';
  }
  return null;
}

// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:go_router/go_router.dart';
// import 'package:swift_contest/model/models/enums/contest_role.dart';
// import 'package:swift_contest/model/models/user.dart';
// import 'package:swift_contest/utils/di/di.dart';
// import 'package:swift_contest/view/widgets/contest_card.dart';
// import 'package:swift_contest/view/widgets/custom_text_form_field.dart';
// import 'package:swift_contest/view/widgets/home_page_app_bar.dart';
// import 'package:swift_contest/view/widgets/loader.dart';
// import 'package:swift_contest/view/widgets/show_snack_bar.dart';
// import 'package:swift_contest/viewmodel/blocs/app_auth_bloc/app_auth_bloc.dart';
// import 'package:swift_contest/viewmodel/blocs/home_participant_bloc/home_participant_bloc.dart';
//
// class HomeParticipantPage extends StatefulWidget {
//   const HomeParticipantPage({super.key});
//
//   @override
//   State<HomeParticipantPage> createState() => _HomeParticipantPageState();
// }
//
// class _HomeParticipantPageState extends State<HomeParticipantPage> {
//   late User user;
//
//   @override
//   void initState() {
//     super.initState();
//     context.read<AppAuthBloc>().add(AppAuthCurrentUserAndProfile());
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final joinContestFormKey = GlobalKey<FormState>();
//     String? contestToken;
//     String? participantToken;
//
//     return BlocProvider(
//       create: (context) => getIt<HomeParticipantBloc>(),
//       child: BlocListener<AppAuthBloc, AppAuthState>(
//         listener: (context, state) {
//           if (state is AppAuthFailure) {
//             context.go('/signin');
//           }
//           if (state is AppAuthSuccess) {
//             user = state.user;
//             context
//                 .read<HomeParticipantBloc>()
//                 .add(HomeParticipantGetJoinedContestsExtended(participantId: user.id));
//           }
//         },
//         child: Scaffold(
//           appBar: HomePageAppBar(appUserRole: ContestRole.participant),
//           body: BlocConsumer<HomeParticipantBloc, HomeParticipantState>(
//             listener: (context, state) {
//               if (state is HomeParticipantFailure) {
//                 showSnackBar(context: context, text: state.message);
//               }
//             },
//             builder: (context, state) {
//               if (state is HomeParticipantSuccess) {
//                 return Padding(
//                   padding: EdgeInsets.only(left: 16, right: 16),
//                   child: RefreshIndicator.adaptive(
//                     onRefresh: () async => context
//                         .read<HomeParticipantBloc>()
//                         .add(HomeParticipantGetJoinedContestsExtended(participantId: user.id)),
//                     child: ListView.builder(
//                       itemCount: state.extendedContests!.length,
//                       itemBuilder: (context, index) {
//                         return Column(
//                           children: [
//                             ContestCard(
//                               contestExtended: state.extendedContests![index],
//                               appUserRole: ContestRole.participant,
//                             ),
//                             SizedBox(height: 8),
//                           ],
//                         );
//                       },
//                     ),
//                   ),
//                 );
//               }
//               if (state is HomeParticipantLoading) {
//                 return Loader();
//               }
//               return Container();
//             },
//           ),
//           floatingActionButton: FilledButton(
//             onPressed: () {
//               showDialog(
//                 context: context,
//                 builder: (context) {
//                   return AlertDialog(
//                     title: Text('Join as participant'),
//                     content: Form(
//                       key: joinContestFormKey,
//                       child: Column(
//                         mainAxisSize: MainAxisSize.min,
//                         mainAxisAlignment: MainAxisAlignment.start,
//                         crossAxisAlignment: CrossAxisAlignment.center,
//                         children: [
//                           CustomTextFormFieldUnderlined(
//                             label: 'Contest token',
//                             onChanged: (value) => contestToken = value,
//                             validator: (value) => noEmptyValidator(value?.trim(), 10),
//                           ),
//                           CustomTextFormFieldUnderlined(
//                             label: 'Invitation token',
//                             onChanged: (value) => participantToken = value,
//                             validator: (value) => noEmptyValidator(value?.trim(), 10),
//                           ),
//                         ],
//                       ),
//                     ),
//                     actions: [
//                       BlocProvider(
//                         create: (context) => getIt<HomeParticipantBloc>(),
//                         child: BlocConsumer<HomeParticipantBloc, HomeParticipantState>(
//                           listener: (context, state) {
//                             if (state is HomeParticipantFailure) {
//                               showSnackBar(context: context, text: state.message);
//                             }
//                             if (state is HomeParticipantSuccess) {
//                               context.pop();
//                               showSnackBar(context: context, text: 'Joined contest successfully');
//                             }
//                           },
//                           builder: (context, state) {
//                             if (state is HomeParticipantLoading) {
//                               return Loader();
//                             }
//                             return Row(
//                               mainAxisSize: MainAxisSize.max,
//                               mainAxisAlignment: MainAxisAlignment.end,
//                               children: [
//                                 TextButton(
//                                   onPressed: () {
//                                     context.pop();
//                                   },
//                                   child: Text('Cancel'),
//                                 ),
//                                 TextButton(
//                                   onPressed: () {
//                                     if (joinContestFormKey.currentState?.validate() ?? false) {
//                                       context.read<HomeParticipantBloc>().add(
//                                             HomeParticipantJoinContest(
//                                               participantId: user.id,
//                                               contestToken: contestToken!,
//                                               participantToken: participantToken!,
//                                             ),
//                                           );
//                                     }
//                                   },
//                                   child: Text('Ok'),
//                                 ),
//                               ],
//                             );
//                           },
//                         ),
//                       )
//                     ],
//                   );
//                 },
//               );
//             },
//             child: Text('Join a contest'),
//           ),
//         ),
//       ),
//     );
//
//     // return Scaffold(
//     //   appBar: HomePageAppBar(appUserRole: AppUserRole.participant),
//     //   floatingActionButton: FilledButton(
//     //     onPressed: () {
//     //       showDialog(
//     //         context: context,
//     //         builder: (context) {
//     //           return AlertDialog(
//     //             title: Text('Join as participant'),
//     //             content: Form(
//     //               key: joinContestFormKey,
//     //               child: Column(
//     //                 mainAxisSize: MainAxisSize.min,
//     //                 mainAxisAlignment: MainAxisAlignment.start,
//     //                 crossAxisAlignment: CrossAxisAlignment.center,
//     //                 children: [
//     //                   CustomTextFormFieldUnderlined(
//     //                     label: 'Contest token',
//     //                     onChanged: (value) => contestToken = value,
//     //                     validator: (value) => noEmptyValidator(value?.trim(), 10),
//     //                   ),
//     //                   CustomTextFormFieldUnderlined(
//     //                     label: 'Invitation token',
//     //                     onChanged: (value) => invitationToken = value,
//     //                     validator: (value) => noEmptyValidator(value?.trim(), 10),
//     //                   ),
//     //                 ],
//     //               ),
//     //             ),
//     //             actions: [
//     //               BlocProvider<ContestParticipantBloc>(
//     //                 create: (context) => getIt<ContestParticipantBloc>(),
//     //                 child: BlocConsumer<ContestParticipantBloc, ContestParticipantState>(
//     //                   listener: (context, state) {
//     //                     if (state is ContestParticipantFailure) {
//     //                       showSnackBar(context: context, text: state.message);
//     //                     }
//     //                     if (state is ContestParticipantSuccess) {
//     //                       context.pop();
//     //                       showSnackBar(context: context, text: 'Joined contest successfully');
//     //                     }
//     //                   },
//     //                   builder: (context, state) {
//     //                     if (state is ContestParticipantLoading) {
//     //                       return Loader();
//     //                     }
//     //                     return Row(
//     //                       mainAxisSize: MainAxisSize.max,
//     //                       mainAxisAlignment: MainAxisAlignment.end,
//     //                       children: [
//     //                         TextButton(
//     //                             onPressed: () {
//     //                               context.pop();
//     //                             },
//     //                             child: Text('Cancel')),
//     //                         TextButton(
//     //                             onPressed: () {
//     //                               if (joinContestFormKey.currentState?.validate() ?? false) {
//     //                                 context
//     //                                     .read<ContestParticipantBloc>()
//     //                                     .add(ContestParticipantJoinContest(
//     //                                       user: widget.user,
//     //                                       contestToken: contestToken!,
//     //                                       invitationToken: invitationToken!,
//     //                                     ));
//     //                               }
//     //                             },
//     //                             child: Text('Ok')),
//     //                       ],
//     //                     );
//     //                   },
//     //                 ),
//     //               )
//     //             ],
//     //           );
//     //         },
//     //       );
//     //     },
//     //     child: Text('Join a contest'),
//     //   ),
//     //   body: BlocConsumer<ContestParticipantBloc, ContestParticipantState>(
//     //     listener: (context, state) {},
//     //     builder: (context, state) {
//     //       if (state is ContestParticipantSuccess) {
//     //         return Padding(
//     //           padding: EdgeInsets.only(left: 16, right: 16),
//     //           child: RefreshIndicator.adaptive(
//     //             onRefresh: () async => context
//     //                 .read<ContestParticipantBloc>()
//     //                 .add(ContestParticipantRetrieveJoinedContests(participantId: widget.user.id)),
//     //             child: ListView.builder(
//     //               itemCount: state.contestsAndOrganizers!.length,
//     //               itemBuilder: (context, index) {
//     //                 return Column(
//     //                   children: [
//     //                     ContestCard(contestAndOrganizer: state.contestsAndOrganizers![index]),
//     //                     SizedBox(height: 8),
//     //                   ],
//     //                 );
//     //               },
//     //             ),
//     //           ),
//     //         );
//     //       }
//     //       return Loader();
//     //     },
//     //   ),
//     // );
//   }
// }
//
// String? noEmptyValidator(String? value, int length) {
//   if (value == null || value.length != length) {
//     return '';
//   }
//   return null;
// }
