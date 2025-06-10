import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:swift_contest/model/data_models/user.dart';
import 'package:swift_contest/model/enums/contest_role.dart';
import 'package:swift_contest/utils/functions/show_snack_bar.dart';
import 'package:swift_contest/utils/router/go_router.dart';
import 'package:swift_contest/utils/validators/validators.dart';
import 'package:swift_contest/view/widgets/contest_card.dart';
import 'package:swift_contest/view/widgets/custom_text_form_field.dart';
import 'package:swift_contest/view/widgets/home_page_app_bar.dart';
import 'package:swift_contest/view/widgets/loader.dart';
import 'package:swift_contest/viewmodel/blocs/auth_bloc/auth_bloc.dart';
import 'package:swift_contest/viewmodel/enums/bloc_status.dart';
import 'package:swift_contest/viewmodel/blocs/pages_blocs/juror_home_page_bloc/juror_home_page_bloc.dart';

class JurorHomePage extends StatefulWidget {
  const JurorHomePage({super.key});

  @override
  State<JurorHomePage> createState() => _JurorHomePageState();
}

class _JurorHomePageState extends State<JurorHomePage> {
  late User user;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    user = context.read<AuthBloc>().state.user!;
    if (!context.read<JurorHomePageBloc>().state.status.isSuccess) {
      context.read<JurorHomePageBloc>().add(JurorHomePageGetJoinedContests(jurorId: user.id));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: HomePageAppBar(contestRole: ContestRole.juror),
      body: SafeArea(
        child: BlocConsumer<JurorHomePageBloc, JurorHomePageState>(
          listener: (context, state) {
            if (state.message != null) {
              showSnackBar(context: context, text: state.message!);
            }
          },
          builder: (context, state) {
            switch (state.status) {
              case BlocStatus.initial:
                return SizedBox.shrink();
              case BlocStatus.loading:
                return Loader();
              case BlocStatus.failure:
                if (state.sourceEvent is JurorHomePageGetJoinedContests) {
                  return RefreshIndicator.adaptive(
                    onRefresh: () async => context
                        .read<JurorHomePageBloc>()
                        .add(JurorHomePageGetJoinedContests(jurorId: user.id)),
                    child: ListView(
                      physics: AlwaysScrollableScrollPhysics(),
                    ),
                  );
                } else {
                  continue successCase;
                }
              successCase:
              case BlocStatus.success:
                final contestsBundles = state.joinedContestsBundles!;
                return Padding(
                  padding: EdgeInsets.only(left: 16, right: 16),
                  child: RefreshIndicator.adaptive(
                    onRefresh: () async => context
                        .read<JurorHomePageBloc>()
                        .add(JurorHomePageGetJoinedContests(jurorId: user.id)),
                    child: ListView.builder(
                      itemCount: contestsBundles.length,
                      itemBuilder: (context, index) {
                        final contestBundle = contestsBundles[index];
                        return Column(
                          children: [
                            ContestCard(
                              contestCardBundle: contestBundle,
                              onTap: () {
                                context.pushNamed(AppRouter.jurorContestDetails,
                                    extra: contestBundle.contest.id);
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
          },
        ),
      ),
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // FilledButton(
          //   onPressed: () async {
          //     final res = await showDialog<bool?>(
          //       context: context,
          //       builder: (context) {
          //         final votingOnlyFormKey = GlobalKey<FormState>();
          //         final fullNameController = TextEditingController();
          //         final votingTokenController = TextEditingController();
          //         return AlertDialog(
          //           title: Text('Vote as a simple juror'),
          //           content: Form(
          //             key: votingOnlyFormKey,
          //             child: Column(
          //               mainAxisSize: MainAxisSize.min,
          //               mainAxisAlignment: MainAxisAlignment.start,
          //               crossAxisAlignment: CrossAxisAlignment.center,
          //               children: [
          //                 CustomTextFormFieldUnderlined(
          //                   controller: fullNameController,
          //                   label: 'Your full name',
          //                   validator: (value) =>
          //                       noEmptyValidator(value?.trim()),
          //                 ),
          //                 CustomTextFormFieldUnderlined(
          //                   controller: votingTokenController,
          //                   label: 'Voting token',
          //                   validator: (value) =>
          //                       noEmptyValidator(value?.trim()),
          //                 ),
          //               ],
          //             ),
          //           ),
          //           actions: [
          //             BlocProvider(
          //               create: (context) => JurorHomePageBloc(
          //                 jurationRepository: context.read(),
          //                 contestRepository: context.read(),
          //                 invitationRepository: context.read(),
          //                 placeRepository: context.read(),
          //                 profileRepository: context.read(),
          //                 participationRepository: context.read(),
          //               ),
          //               child:
          //                   BlocConsumer<JurorHomePageBloc, JurorHomePageState>(
          //                 listener: (context, state) {
          //                   if (state.status.isFailure) {
          //                     showSnackBar(
          //                         context: context, text: state.message!);
          //                   }
          //                   if (state.status.isSuccess) {
          //                     final Map<String,dynamic> jsonData = {
          //                       'voting_session' : state.votingSession!,
          //                       'voting_session_simple_juror' : state.votingSessionSimpleJuror!,
          //                     };
          //                     context.pushNamed(AppRouter.simpleJurorVotingProcedure, extra: jsonData);
          //                   }
          //                 },
          //                 builder: (context, state) {
          //                   if (state.status.isLoading) {
          //                     return Loader();
          //                   }
          //                   return Row(
          //                     mainAxisSize: MainAxisSize.max,
          //                     mainAxisAlignment: MainAxisAlignment.end,
          //                     children: [
          //                       TextButton(
          //                         onPressed: () {
          //                           context.pop();
          //                         },
          //                         child: Text('Cancel'),
          //                       ),
          //                       TextButton(
          //                         onPressed: () async {
          //                           if (votingOnlyFormKey.currentState?.validate() ?? false) {
          //                             if(context.mounted) {
          //                               context.read<JurorHomePageBloc>().add(
          //                                   JurorHomePageVoteAsSimpleJuror(
          //                                       fullName: fullNameController.text.trim(),
          //                                       votingSessionToken:
          //                                       votingTokenController.text
          //                                           .trim()));
          //                             }
          //                           }
          //                         },
          //                         child: Text('Ok'),
          //                       ),
          //                     ],
          //                   );
          //                 },
          //               ),
          //             )
          //           ],
          //         );
          //       },
          //     );
          //   },
          //   child: Text('Vote only'),
          // ),
          FilledButton(
            onPressed: () async {
              final bool? res = await _showJoinContestDialog(context: context, userId: user.id);
              if (res == true) {
                if (context.mounted) {
                  context
                      .read<JurorHomePageBloc>()
                      .add(JurorHomePageGetJoinedContests(jurorId: user.id));
                }
              }
            },
            child: Text('Join a contest'),
          ),
        ],
      ),
    );
  }
}

Future<bool?> _showJoinContestDialog({
  required BuildContext context,
  required String userId,
}) async {
  final jurorHomePageBloc = context.read<JurorHomePageBloc>();
  return showDialog(
    context: context,
    builder: (context) {
      final joinContestFormKey = GlobalKey<FormState>();
      final tokenController = TextEditingController();
      return BlocProvider.value(
        value: jurorHomePageBloc,
        child: AlertDialog(
          title: Text('Join as juror'),
          content: Form(
            key: joinContestFormKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                CustomTextFormFieldUnderlined(
                  controller: tokenController,
                  label: 'Token',
                  validator: (value) => noEmptyValidator(value?.trim()),
                ),
              ],
            ),
          ),
          actions: [
            BlocConsumer<JurorHomePageBloc, JurorHomePageState>(
              listener: (context, state) {
                if (state.status.isFailure) {
                  showSnackBar(context: context, text: state.message!);
                }
                if (state.status.isSuccess && state.sourceEvent is JurorHomePageJoinContest) {
                  showSnackBar(context: context, text: 'Joined contest successfully');
                  context.pop(true);
                }
              },
              builder: (context, state) {
                if (state.status.isLoading) {
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
                          context.read<JurorHomePageBloc>().add(
                                JurorHomePageJoinContest(
                                  jurorId: userId,
                                  token: tokenController.text.trim(),
                                ),
                              );
                        }
                      },
                      child: Text('Ok'),
                    ),
                  ],
                );
              },
            )
          ],
        ),
      );
    },
  );
}
