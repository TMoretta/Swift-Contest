import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:swift_contest/model/data_models/profile.dart';
import 'package:swift_contest/model/enums/contest_role.dart';
import 'package:swift_contest/utils/functions/show_snack_bar.dart';
import 'package:swift_contest/utils/router/go_router.dart';
import 'package:swift_contest/utils/validators/validators.dart';
import 'package:swift_contest/view/widgets/contest_card.dart';
import 'package:swift_contest/view/widgets/custom_text_form_field.dart';
import 'package:swift_contest/view/widgets/home_page_app_bar.dart';
import 'package:swift_contest/view/widgets/loader.dart';
import 'package:swift_contest/viewmodel/blocs/auth_bloc/auth_bloc.dart';
import 'package:swift_contest/viewmodel/blocs/pages_blocs/juror_home_page_bloc/juror_home_page_bloc.dart';
import 'package:swift_contest/viewmodel/enums/bloc_status.dart';

class JurorHomePage extends StatefulWidget {
  const JurorHomePage({super.key});

  @override
  State<JurorHomePage> createState() => _JurorHomePageState();
}

class _JurorHomePageState extends State<JurorHomePage> {
  late Profile profile;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    profile = context.read<AuthBloc>().state.profile!;
    if (!context.read<JurorHomePageBloc>().state.status.isSuccess) {
      context.read<JurorHomePageBloc>().add(JurorHomePageInit(jurorId: profile.id));
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<JurorHomePageBloc, JurorHomePageState>(
      listener: (context, state) {
        if (state.message != null) {
          showSnackBar(context: context, text: state.message!);
        }
      },
      child: Scaffold(
        appBar: HomePageAppBar(contestRole: ContestRole.juror),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: BlocBuilder<JurorHomePageBloc, JurorHomePageState>(
              builder: (context, state) {
                switch (state.status) {
                  case BlocStatus.initial:
                    return SizedBox.shrink();
                  case BlocStatus.loading:
                    return Loader();
                  case BlocStatus.failure:
                    if (state.sourceEvent is JurorHomePageInit) {
                      return RefreshIndicator.adaptive(
                        onRefresh: () async => context
                            .read<JurorHomePageBloc>()
                            .add(JurorHomePageInit(jurorId: profile.id)),
                        child: ListView(),
                      );
                    } else {
                      continue successCase;
                    }
                  successCase:
                  case BlocStatus.success:
                    return LayoutBuilder(
                      builder: (context, constraints) {
                        return RefreshIndicator.adaptive(
                          onRefresh: () async => context
                              .read<JurorHomePageBloc>()
                              .add(JurorHomePageRefresh(jurorId: profile.id)),
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
                                            context.pushNamed(AppRouter.jurorContestDetails,
                                                extra: contestCardBundle.contest.id);
                                          },
                                        ),
                                        SizedBox(
                                            height:
                                                (index == state.joinedContestsBundles!.length - 1)
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
                      },
                    );
                }
              },
            ),
          ),
        ),
        floatingActionButton: BlocBuilder<JurorHomePageBloc, JurorHomePageState>(
          builder: (context, state) {
            switch (state.status) {
              case BlocStatus.initial:
              case BlocStatus.loading:
                return SizedBox.shrink();
              case BlocStatus.failure:
              case BlocStatus.success:
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  spacing: 4,
                  children: [
                    FilledButton(
                      onPressed: () async {
                        await _showVoteAsSimpleJurorDialog(buildContext: context, profileId: profile.id);
                      },
                      style: FilledButton.styleFrom(
                          backgroundColor: Theme.of(context).colorScheme.tertiaryContainer,
                          foregroundColor: Theme.of(context).colorScheme.onTertiaryContainer),
                      child: Text('Vote as simple juror'),
                    ),
                    FilledButton(
                      onPressed: () async {
                        final bool? res =
                            await _showJoinContestDialog(context: context, profileId: profile.id);
                        if (res == true) {
                          if (context.mounted) {
                            context
                                .read<JurorHomePageBloc>()
                                .add(JurorHomePageInit(jurorId: profile.id));
                          }
                        }
                      },
                      child: Text('Join a contest'),
                    ),
                  ],
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
  required String profileId,
}) async {
  final jurorHomePageBloc = context.read<JurorHomePageBloc>();
  return await showDialog(
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
                                  jurorId: profileId,
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

Future<bool?> _showVoteAsSimpleJurorDialog({
  required BuildContext buildContext,
  required String profileId,
}) async {
  final jurorHomePageBloc = buildContext.read<JurorHomePageBloc>();
  return await showDialog(
    context: buildContext,
    builder: (context) {
      final joinContestFormKey = GlobalKey<FormState>();
      final fullNameController = TextEditingController();
      final tokenController = TextEditingController();
      return BlocProvider.value(
        value: jurorHomePageBloc,
        child: AlertDialog(
          title: Text('Vote as simple juror'),
          content: Form(
            key: joinContestFormKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                CustomTextFormFieldUnderlined(
                  controller: fullNameController,
                  label: 'Full name',
                  validator: (value) => noEmptyValidator(value?.trim()),
                ),
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
                if (state.status.isSuccess && state.sourceEvent is JurorHomePageVoteAsAuthenticatedSimpleJuror) {
                  context.pop();
                  buildContext.pushNamed(AppRouter.simpleJurorVotingProcedure, extra: state.simpleJurorAndVotingSessionBundle!.toJson());
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
                            JurorHomePageVoteAsAuthenticatedSimpleJuror(
                              fullName: fullNameController.text.trim(),
                                  token: tokenController.text.trim(),
                                  jurorId: profileId,
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
