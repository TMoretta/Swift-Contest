import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:swift_contest/model/data_models/user.dart';
import 'package:swift_contest/model/enums/contest_role.dart';
import 'package:swift_contest/utils/functions/show_snack_bar.dart';
import 'package:swift_contest/utils/router/go_router.dart';
import 'package:swift_contest/view/widgets/contest_card.dart';
import 'package:swift_contest/view/widgets/custom_text_form_field.dart';
import 'package:swift_contest/view/widgets/home_page_app_bar.dart';
import 'package:swift_contest/view/widgets/loader.dart';
import 'package:swift_contest/viewmodel/blocs/bloc_status.dart';
import 'package:swift_contest/viewmodel/blocs/global_blocs/auth_bloc/auth_bloc.dart';
import 'package:swift_contest/viewmodel/blocs/global_blocs/juror_joined_contests_bloc/juror_joined_contests_bloc.dart';
import 'package:swift_contest/viewmodel/blocs/pages_blocs/juror_home_page_bloc/juror_home_page_bloc.dart';
import 'package:swift_contest/viewmodel/repositories/contest_repository.dart';
import 'package:swift_contest/viewmodel/repositories/invitation_repository.dart';
import 'package:swift_contest/viewmodel/repositories/juration_repository.dart';

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
    if (!context.read<JurorJoinedContestsBloc>().state.status.isSuccess) {
      context
          .read<JurorJoinedContestsBloc>()
          .add(JurorJoinedContestsGetJoinedContests(jurorId: user.id));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: HomePageAppBar(contestRole: ContestRole.juror),
      body: BlocConsumer<JurorJoinedContestsBloc, JurorJoinedContestsState>(
        listener: (context, state) {
          if (state.status.isFailure) {
            showSnackBar(context: context, text: state.message!);
          }
        },
        builder: (context, state) {
          if (state.status.isSuccess) {
            final contests = state.contests!;
            return Padding(
              padding: EdgeInsets.only(left: 16, right: 16),
              child: RefreshIndicator.adaptive(
                onRefresh: () async => context
                    .read<JurorJoinedContestsBloc>()
                    .add(
                        JurorJoinedContestsGetJoinedContests(jurorId: user.id)),
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
                          place: state.places![index],
                          onTap: () {
                            context.pushNamed(AppRouter.jurorContestDetails,
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
          if (state.status.isLoading) {
            return Loader();
          }
          return Container();
        },
      ),
      floatingActionButton: Column(
        children: [
          FilledButton(
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) {
                  final votingContestFormKey = GlobalKey<FormState>();
                  final votingTokenController = TextEditingController();
                  return AlertDialog(
                    title: Text('Vote as a simple juror'),
                    content: Form(
                      key: votingContestFormKey,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          CustomTextFormFieldUnderlined(
                            controller: votingTokenController,
                            label: 'Voting token',
                            validator: (value) =>
                                noEmptyValidator(value?.trim()),
                          ),
                        ],
                      ),
                    ),
                    actions: [
                      BlocProvider(
                        create: (context) => JurorHomePageBloc(
                          jurationRepository:
                              context.read<JurationRepository>(),
                          contestRepository: context.read<ContestRepository>(),
                          invitationRepository:
                              context.read<InvitationRepository>(),
                        ),
                        child:
                            BlocConsumer<JurorHomePageBloc, JurorHomePageState>(
                          listener: (context, state) {
                            if (state.status.isFailure) {
                              showSnackBar(
                                  context: context, text: state.message!);
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
                                    if (votingContestFormKey.currentState?.validate() ?? false) {
                                      //todo
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
            child: Text('Vote only'),
          ),
          FilledButton(
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) {
                  final joinContestFormKey = GlobalKey<FormState>();
                  final contestTokenController = TextEditingController();
                  final jurorTokenController = TextEditingController();
                  return AlertDialog(
                    title: Text('Join as juror'),
                    content: Form(
                      key: joinContestFormKey,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          CustomTextFormFieldUnderlined(
                            controller: contestTokenController,
                            label: 'Contest token',
                            validator: (value) =>
                                noEmptyValidator(value?.trim()),
                          ),
                          CustomTextFormFieldUnderlined(
                            controller: jurorTokenController,
                            label: 'Invitation token',
                            validator: (value) =>
                                noEmptyValidator(value?.trim()),
                          ),
                        ],
                      ),
                    ),
                    actions: [
                      BlocProvider(
                        create: (context) => JurorHomePageBloc(
                          jurationRepository:
                              context.read<JurationRepository>(),
                          contestRepository: context.read<ContestRepository>(),
                          invitationRepository:
                              context.read<InvitationRepository>(),
                        ),
                        child:
                            BlocConsumer<JurorHomePageBloc, JurorHomePageState>(
                          listener: (context, state) {
                            if (state.status.isFailure) {
                              showSnackBar(
                                  context: context, text: state.message!);
                            }
                            if (state.status.isSuccess) {
                              context.pop();
                              showSnackBar(
                                  context: context,
                                  text: 'Joined contest successfully');
                              context
                                  .read<JurorJoinedContestsGetJoinedContests>();
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
                                    if (joinContestFormKey.currentState
                                            ?.validate() ??
                                        false) {
                                      context.read<JurorHomePageBloc>().add(
                                            JurorHomePageJoinContest(
                                              jurorId: user.id,
                                              contestToken:
                                                  contestTokenController.text
                                                      .trim(),
                                              jurorToken: jurorTokenController
                                                  .text
                                                  .trim(),
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
        ],
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
