import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:swift_contest/model/data_models/profile/contest_role.dart';
import 'package:swift_contest/model/data_models/user/user.dart';
import 'package:swift_contest/utils/router/go_router.dart';
import 'package:swift_contest/view/widgets/contest_card.dart';
import 'package:swift_contest/view/widgets/custom_text_form_field.dart';
import 'package:swift_contest/view/widgets/home_page_app_bar.dart';
import 'package:swift_contest/view/widgets/loader.dart';
import 'package:swift_contest/view/widgets/show_snack_bar.dart';
import 'package:swift_contest/viewmodel/blocs/bloc_status.dart';
import 'package:swift_contest/viewmodel/blocs/global_blocs/auth_bloc/auth_bloc.dart';
import 'package:swift_contest/viewmodel/blocs/global_blocs/participant_joined_contests_bloc/participant_joined_contests_bloc.dart';
import 'package:swift_contest/viewmodel/blocs/pages_blocs/participant_home_page_bloc/participant_home_page_bloc.dart';
import 'package:swift_contest/viewmodel/repositories/contest_repository.dart';
import 'package:swift_contest/viewmodel/repositories/juration_repository.dart';
import 'package:swift_contest/viewmodel/repositories/participation_repository.dart';
import 'package:swift_contest/viewmodel/repositories/profile_repository.dart';

class ParticipantHomePage extends StatefulWidget {
  const ParticipantHomePage({super.key});

  @override
  State<ParticipantHomePage> createState() => _ParticipantHomePageState();
}

class _ParticipantHomePageState extends State<ParticipantHomePage> {
  late User user;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final appAuthState = context.read<AuthBloc>().state;
    user = (appAuthState as AuthAuthenticated).user;
    if (!context.read<ParticipantJoinedContestsBloc>().state.status.isSuccess) {
      context
          .read<ParticipantJoinedContestsBloc>()
          .add(ParticipantJoinedContestsGetJoinedContests(participantId: user.id));
    }
  }

  @override
  Widget build(BuildContext context) {
    final joinContestFormKey = GlobalKey<FormState>();
    String? contestToken;
    String? participantToken;

    return Scaffold(
      appBar: HomePageAppBar(contestRole: ContestRole.participant),
      body: BlocConsumer<ParticipantJoinedContestsBloc, ParticipantJoinedContestsState>(
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
                    .read<ParticipantJoinedContestsBloc>()
                    .add(ParticipantJoinedContestsGetJoinedContests(participantId: user.id)),
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
          if (state.status.isLoading) {
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
                    create: (context) => ParticipantHomePageBloc(
                      contestRepository: context.read<ContestRepository>(),
                      participationRepository: context.read<ParticipationRepository>(),
                      profileRepository: context.read<ProfileRepository>(),
                      jurationRepository: context.read<JurationRepository>(),
                    ),
                    child: BlocConsumer<ParticipantHomePageBloc, ParticipantHomePageState>(
                      listener: (context, state) {
                        if (state.status.isFailure) {
                          showSnackBar(context: context, text: state.message!);
                        }
                        if (state.status.isSuccess) {
                          context.pop();
                          showSnackBar(context: context, text: 'Joined contest successfully');
                          context.read<ParticipantJoinedContestsGetJoinedContests>();
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
    );
  }
}

String? noEmptyValidator(String? value) {
  if (value == null || value == '') {
    return '';
  }
  return null;
}
