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
import 'package:swift_contest/view/widgets/show_snack_bar.dart';
import 'package:swift_contest/viewmodel/blocs/auth_bloc/auth_bloc.dart';
import 'package:swift_contest/viewmodel/blocs/pages_blocs/participant_home_page_bloc/participant_home_page_bloc.dart';
import 'package:swift_contest/viewmodel/enums/bloc_status.dart';
import 'package:swift_contest/view/widgets/void_widget.dart';

class ParticipantHomePage extends StatefulWidget {
  const ParticipantHomePage({super.key});

  @override
  State<ParticipantHomePage> createState() => _ParticipantHomePageState();
}

class _ParticipantHomePageState extends State<ParticipantHomePage> {
  late String profileId;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    profileId = context.read<AuthBloc>().state.profile!.id;
    context.read<ParticipantHomePageBloc>().add(ParticipantHomePageInit(participantId: profileId));
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<ParticipantHomePageBloc, ParticipantHomePageState>(
      listener: (context, state) {
        if (state.message != null) {
          showSnackBar(context: context, text: state.message!);
        }
      },
      child: Stack(
        children: [
          Scaffold(
            appBar: HomePageAppBar(contestRole: ContestRole.participant),
            body: SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: BlocBuilder<ParticipantHomePageBloc, ParticipantHomePageState>(
                  builder: (context, state) {
                    switch (state.status) {
                      case BlocStatus.initial:
                        return VoidWidget();
                      case BlocStatus.loading:
                        if (state.sourceEvent is ParticipantHomePageInit) {
                          return VoidWidget();
                        } else {
                          continue successCase;
                        }
                      case BlocStatus.failure:
                        if (state.status.isFailure &&
                            state.sourceEvent is ParticipantHomePageInit) {
                          return RefreshIndicator.adaptive(
                            onRefresh: () async => context
                                .read<ParticipantHomePageBloc>()
                                .add(ParticipantHomePageInit(participantId: profileId)),
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
                                .read<ParticipantHomePageBloc>()
                                .add(ParticipantHomePageRefresh(participantId: profileId));
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
                                                  AppRouter.participantContestDetails,
                                                  extra: homeContestBundle.contest.id);
                                              if (res == true) {
                                                if (context.mounted) {
                                                  context.read<ParticipantHomePageBloc>().add(
                                                      ParticipantHomePageRefresh(
                                                          participantId: profileId));
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
            floatingActionButton: FilledButton(
              onPressed: () {
                _showJoinContestDialog(context: context, profileId: profileId);
              },
              child: Text('Join a contest'),
            ),
          ),
          BlocBuilder<ParticipantHomePageBloc, ParticipantHomePageState>(
            builder: (context, state) {
              if (state.status.isLoading) {
                return ObscuredLoader();
              }
              return VoidWidget();
            },
          ),
        ],
      ),
    );
  }
}

void _showJoinContestDialog({
  required BuildContext context,
  required String profileId,
}) {
  final participantHomePageBloc = context.read<ParticipantHomePageBloc>();
  showDialog(
    context: context,
    builder: (context) {
      final joinContestFormKey = GlobalKey<FormState>();
      final tokenController = TextEditingController();
      return BlocProvider.value(
        value: participantHomePageBloc,
        child: BlocListener<ParticipantHomePageBloc, ParticipantHomePageState>(
          listener: (context, state) {
            if (state.status.isSuccess && state.sourceEvent is ParticipantHomePageJoinContest) {
              showSnackBar(context: context, text: 'Joined contest successfully');
              participantHomePageBloc.add(ParticipantHomePageRefresh(participantId: profileId));
              context.pop();
            }
          },
          child: Stack(
            children: [
              AlertDialog(
                title: Text('Join as participant'),
                content: Form(
                  key: joinContestFormKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
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
                  TextButton(
                    onPressed: () {
                      context.pop();
                    },
                    child: Text('Cancel'),
                  ),
                  TextButton(
                    onPressed: () {
                      if (joinContestFormKey.currentState?.validate() ?? false) {
                        participantHomePageBloc.add(
                          ParticipantHomePageJoinContest(
                            participantId: profileId,
                            token: tokenController.text.trim(),
                          ),
                        );
                      }
                    },
                    child: Text('Proceed'),
                  ),
                ],
              ),
              BlocBuilder<ParticipantHomePageBloc, ParticipantHomePageState>(
                builder: (context, state) {
                  if (state.status.isLoading) {
                    return ObscuredLoader();
                  }
                  return VoidWidget();
                },
              ),
            ],
          ),
        ),
      );
    },
  );
}
