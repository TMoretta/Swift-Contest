import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:swift_contest/model/enums/contest_role.dart';
import 'package:swift_contest/utils/labels/labels.dart';
import 'package:swift_contest/utils/router/go_router.dart';
import 'package:swift_contest/utils/validators/validators.dart';
import 'package:swift_contest/view/widgets/contest_card.dart';
import 'package:swift_contest/view/widgets/custom_text_form_field.dart';
import 'package:swift_contest/view/widgets/home_page_app_bar.dart';
import 'package:swift_contest/view/widgets/list_view_with_central_label.dart';
import 'package:swift_contest/view/widgets/obscured_loader.dart';
import 'package:swift_contest/view/widgets/overlay_loader.dart';
import 'package:swift_contest/view/widgets/show_snack_bar.dart';
import 'package:swift_contest/viewmodel/blocs/auth_bloc/auth_bloc.dart';
import 'package:swift_contest/viewmodel/blocs/pages_blocs/juror_home_page_bloc/juror_home_page_bloc.dart';
import 'package:swift_contest/viewmodel/enums/bloc_status.dart';
import 'package:swift_contest/view/widgets/void_widget.dart';

class JurorHomePage extends StatefulWidget {
  const JurorHomePage({super.key});

  @override
  State<JurorHomePage> createState() => _JurorHomePageState();
}

class _JurorHomePageState extends State<JurorHomePage> {
  
  late String profileId;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    profileId = context.read<AuthBloc>().state.profile!.id;
    if (!context.read<JurorHomePageBloc>().state.status.isSuccess) {
      context.read<JurorHomePageBloc>().add(JurorHomePageInit(jurorId: profileId));
    }
  }

  @override
  void dispose() {
    context.hideLoader();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<JurorHomePageBloc, JurorHomePageState>(
      listener: (context, state) {
        if (state.message != null) {
          showSnackBar(context: context, text: state.message!);
        }
        if(state.status.isLoading) {
          context.showLoader();
        } else {
          context.hideLoader();
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
                    return VoidWidget();
                  case BlocStatus.loading:
                    if (state.sourceEvent is JurorHomePageInit) {
                      return VoidWidget();
                    } else {
                      continue successCase;
                    }
                  case BlocStatus.failure:
                    if (state.sourceEvent is JurorHomePageInit) {
                      return RefreshIndicator.adaptive(
                        onRefresh: () async => context
                            .read<JurorHomePageBloc>()
                            .add(JurorHomePageInit(jurorId: profileId)),
                        child: ListViewWithCentralLabel(label: Labels.anErrorOccurred),
                      );
                    } else {
                      continue successCase;
                    }
                  successCase:
                  case BlocStatus.success:
                    return RefreshIndicator.adaptive(
                      onRefresh: () async {
                        context
                            .read<JurorHomePageBloc>()
                            .add(JurorHomePageRefresh(jurorId: profileId));
                        context.read<AuthBloc>().add(AuthFetchProfileMessages());
                      },
                      child: (state.joinedContestsBundles!.isNotEmpty)
                          ? ListView(
                              children: [
                                SizedBox(height: 16),
                                ...state.joinedContestsBundles!.map((homeContestBundle) {
                                  return Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      ContestCard(
                                        homeContestBundle: homeContestBundle,
                                        onTap: () async {
                                          final bool? res = await context.pushNamed(
                                              AppRouter.jurorContestDetails,
                                              extra: homeContestBundle.contest.id);
                                          if (res == true) {
                                            if (context.mounted) {
                                              context.read<JurorHomePageBloc>().add(
                                                  JurorHomePageRefresh(jurorId: profileId));
                                            }
                                          }
                                        },
                                      ),
                                      SizedBox(height: 8),
                                    ],
                                  );
                                }),
                                SizedBox(height: 64),
                              ],
                            )
                          : ListViewWithCentralLabel(label: 'No contest joined yet'),
                    );
                }
              },
            ),
          ),
        ),
        floatingActionButton: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            FilledButton(
              onPressed: () {
                _showVoteAsSimpleJurorDialog(context: context, profileId: profileId);
              },
              style: FilledButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.tertiaryContainer,
                foregroundColor: Theme.of(context).colorScheme.onTertiaryContainer,
              ),
              child: Text('Vote as simple juror'),
            ),
            SizedBox(height: 8),
            FilledButton(
              onPressed: () {
                _showJoinContestDialog(context: context, profileId: profileId);
              },
              child: Text('Vote as simple juror'),
            ),
          ],
        ),
      ),
    );
  }
}

void _showJoinContestDialog({
  required BuildContext context,
  required String profileId,
}) {
  final jurorHomePageBloc = context.read<JurorHomePageBloc>();
  showDialog(
    context: context,
    builder: (context) {
      final joinContestFormKey = GlobalKey<FormState>();
      final tokenController = TextEditingController();
      return BlocProvider.value(
        value: jurorHomePageBloc,
        child: BlocListener<JurorHomePageBloc, JurorHomePageState>(
          listener: (context, state) {
            if (state.status.isSuccess && state.sourceEvent is JurorHomePageJoinContest) {
              showSnackBar(context: context, text: 'Joined contest successfully');
              jurorHomePageBloc.add(JurorHomePageRefresh(jurorId: profileId));
              context.pop(true);
            }
          },
          child: AlertDialog(
            title: Text('Join as juror'),
            content: Form(
              key: joinContestFormKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  CustomTextFormField(
                    borderType: InputBorderType.underlined,
                    controller: tokenController,
                    label: 'Token',
                    validator: (value) => noEmptyValidator(value?.trim()),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  context.pop();
                },
                child: Text('Cancel'),
              ),
              TextButton(
                onPressed: () {
                  if (joinContestFormKey.currentState?.validate() ?? false) {
                    jurorHomePageBloc.add(
                      JurorHomePageJoinContest(
                        jurorId: profileId,
                        token: tokenController.text.trim(),
                      ),
                    );
                  }
                },
                child: Text('Proceed'),
              ),
            ],
          ),
        ),
      );
    },
  );
}

void _showVoteAsSimpleJurorDialog({
  required BuildContext context,
  required String profileId,
}) {
  final jurorHomePageBloc = context.read<JurorHomePageBloc>();
  showDialog(
    context: context,
    builder: (context) {
      final votingAccessFormKey = GlobalKey<FormState>();
      final fullNameController = TextEditingController();
      final tokenController = TextEditingController();
      return BlocProvider.value(
        value: jurorHomePageBloc,
        child: BlocListener<JurorHomePageBloc, JurorHomePageState>(
          listener: (context, state) {
            if (state.status.isSuccess && state.sourceEvent is JurorHomePageVoteAsSimpleJuror) {
              context.pop();
              context.pushNamed(AppRouter.simpleJurorVotingProcedure,
                  extra: state.simpleJurorAndVotingSessionBundle!.toJson());
            }
          },
          child: AlertDialog(
            title: Text('Vote as simple juror'),
            content: Form(
              key: votingAccessFormKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CustomTextFormField(
                    borderType: InputBorderType.underlined,
                    controller: fullNameController,
                    label: 'Full name',
                    validator: (value) => noEmptyValidator(value?.trim()),
                  ),
                  CustomTextFormField(
                    borderType: InputBorderType.underlined,
                    controller: tokenController,
                    label: 'Token',
                    validator: (value) => noEmptyValidator(value?.trim()),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  context.pop();
                },
                child: Text('Cancel'),
              ),
              TextButton(
                onPressed: () {
                  if (votingAccessFormKey.currentState?.validate() ?? false) {
                    context.read<JurorHomePageBloc>().add(
                          JurorHomePageVoteAsSimpleJuror(
                            fullName: fullNameController.text.trim(),
                            token: tokenController.text.trim(),
                            jurorId: profileId,
                          ),
                        );
                  }
                },
                child: Text('Proceed'),
              ),
            ],
          ),
        ),
      );
    },
  );
}
