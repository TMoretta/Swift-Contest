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
import 'package:swift_contest/viewmodel/blocs/pages_blocs/participant_home_page_bloc/participant_home_page_bloc.dart';
import 'package:swift_contest/viewmodel/enums/bloc_status.dart';

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
    user = context.read<AuthBloc>().state.user!;
    context.read<ParticipantHomePageBloc>().add(ParticipantHomePageInit(participantId: user.id));
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<ParticipantHomePageBloc, ParticipantHomePageState>(
      listener: (context, state) {
        if (state.message != null) {
          showSnackBar(context: context, text: state.message!);
        }
      },
      child: Scaffold(
        appBar: HomePageAppBar(contestRole: ContestRole.participant),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: BlocBuilder<ParticipantHomePageBloc, ParticipantHomePageState>(
              builder: (context, state) {
                switch (state.status) {
                  case BlocStatus.initial:
                    return SizedBox.shrink();
                  case BlocStatus.loading:
                    return Loader();
                  case BlocStatus.failure:
                    if (state.status.isFailure && state.sourceEvent is ParticipantHomePageInit) {
                      return RefreshIndicator.adaptive(
                        onRefresh: () async => context
                            .read<ParticipantHomePageBloc>()
                            .add(ParticipantHomePageInit(participantId: user.id)),
                        child: ListView(),
                      );
                    } else {
                      continue successCase;
                    }
                  successCase:
                  case BlocStatus.success:
                    return LayoutBuilder(builder: (context, constraints) {
                      return RefreshIndicator.adaptive(
                        onRefresh: () async => context
                            .read<ParticipantHomePageBloc>()
                            .add(ParticipantHomePageRefresh(participantId: user.id)),
                        child: (state.joinedContestsBundles!.isNotEmpty)
                            ? ListView.builder(
                                itemCount: state.joinedContestsBundles!.length,
                                itemBuilder: (context, index) {
                                  final contestCardBundle = state.joinedContestsBundles![index];
                                  return Column(
                                    children: [
                                      SizedBox(height: (index == 0) ? 16 : 0),
                                      ContestCard(
                                        contestCardBundle: contestCardBundle,
                                        onTap: () {
                                          context.pushNamed(AppRouter.participantContestDetails,
                                              extra: contestCardBundle.contest.id);
                                        },
                                      ),
                                      SizedBox(
                                          height: (index == state.joinedContestsBundles!.length - 1)
                                              ? 80
                                              : 8),
                                    ],
                                  );
                                },
                              )
                            : ListView(
                                children: [
                                  SizedBox(
                                    height: constraints.maxHeight,
                                    child: Center(
                                      child: Text(
                                        'No contest joined yet',
                                        style: Theme.of(context).textTheme.bodyLarge,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                      );
                    },);
                }
              },
            ),
          ),
        ),
        floatingActionButton: BlocBuilder<ParticipantHomePageBloc, ParticipantHomePageState>(
          builder: (context, state) {
            switch (state.status) {
              case BlocStatus.initial:
              case BlocStatus.loading:
                return SizedBox.shrink();
              case BlocStatus.failure:
              case BlocStatus.success:
                return FilledButton(
                  onPressed: () async {
                    final bool? res =
                        await _showJoinContestDialog(context: context, userId: user.id);
                    if (res == true) {
                      if (context.mounted) {
                        context
                            .read<ParticipantHomePageBloc>()
                            .add(ParticipantHomePageInit(participantId: user.id));
                      }
                    }
                  },
                  child: Text('Join a contest'),
                );
            }
          },
        ),
      ),
    );
  }
}

Future<bool?> _showJoinContestDialog({
  required BuildContext context,
  required String userId,
}) async {
  final participantHomePageBloc = context.read<ParticipantHomePageBloc>();
  return await showDialog(
    context: context,
    builder: (context) {
      final joinContestFormKey = GlobalKey<FormState>();
      final tokenController = TextEditingController();
      return BlocProvider.value(
        value: participantHomePageBloc,
        child: AlertDialog(
          title: Text('Join as participant'),
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
            BlocConsumer<ParticipantHomePageBloc, ParticipantHomePageState>(
              listener: (context, state) {
                if (state.status.isFailure) {
                  showSnackBar(context: context, text: state.message!);
                }
                if (state.status.isSuccess && state.sourceEvent is ParticipantHomePageJoinContest) {
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
                          context.read<ParticipantHomePageBloc>().add(
                                ParticipantHomePageJoinContest(
                                  participantId: userId,
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
