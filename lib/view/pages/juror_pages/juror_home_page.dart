import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:swift_contest/model/db/types/contest_role.dart';
import 'package:swift_contest/utils/labels/labels.dart';
import 'package:swift_contest/utils/router/app_router.gr.dart';
import 'package:swift_contest/utils/validators/validators.dart';
import 'package:swift_contest/view/widgets/contest_card.dart';
import 'package:swift_contest/view/widgets/custom_search_bar.dart';
import 'package:swift_contest/view/widgets/custom_text_form_field.dart';
import 'package:swift_contest/view/widgets/home_page_app_bar.dart';
import 'package:swift_contest/view/widgets/list_view_with_central_label.dart';
import 'package:swift_contest/view/widgets/overlay_loader.dart';
import 'package:swift_contest/view/widgets/show_snack_bar.dart';
import 'package:swift_contest/view/widgets/void_widget.dart';
import 'package:swift_contest/viewmodel/blocs/auth_bloc/auth_bloc.dart';
import 'package:swift_contest/viewmodel/blocs/pages_blocs/juror_home_page_bloc/juror_home_page_bloc.dart';
import 'package:swift_contest/viewmodel/enums/bloc_status.dart';

@RoutePage()
class JurorHomePage extends StatefulWidget implements AutoRouteWrapper {
  const JurorHomePage({super.key});

  @override
  State<JurorHomePage> createState() => _JurorHomePageState();

  @override
  Widget wrappedRoute(BuildContext context) {
    return BlocProvider<JurorHomePageBloc>(
      create: (context) => JurorHomePageBloc(
        jurorRepository: context.read(),
      ),
      child: this,
    );
  }
}

class _JurorHomePageState extends State<JurorHomePage> {
  late String profileId;
  late final FocusNode _searchFocusNode;
  late final TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    _searchFocusNode = FocusNode();
    _searchController = TextEditingController();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    profileId = context.read<AuthBloc>().state.profile!.id!;
    context.read<JurorHomePageBloc>().add(JurorHomePageFetch());
  }

  @override
  void dispose() {
    context.hideLoader();
    _searchFocusNode.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<JurorHomePageBloc, JurorHomePageState>(
      listener: (context, state) {
        if (state.message != null) {
          showSnackBar(context: context, text: state.message!);
        }
        if (state.status.isLoading) {
          context.showLoader();
        } else {
          context.hideLoader();
        }
      },
      builder: (context, state) {
        return Scaffold(
          appBar: HomePageAppBar(
            contestRole: ContestRole.juror,
              onRefresh: () async
                 => context.read<JurorHomePageBloc>().add(JurorHomePageFetch())

          ),
          body: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Builder(
                builder: (context) {
                  switch (state.status) {
                    case BlocStatus.initial:
                      return VoidWidget();
                    case BlocStatus.loading:
                      if (!state.isInitialized) {
                        return VoidWidget();
                      } else {
                        continue successCase;
                      }
                    case BlocStatus.failure:
                      if (!state.isInitialized) {
                        return RefreshIndicator.adaptive(
                          onRefresh: () async =>
                              context.read<JurorHomePageBloc>().add(JurorHomePageFetch()),
                          child: ListViewWithCentralLabel(label: Labels.anErrorOccurred),
                        );
                      } else {
                        continue successCase;
                      }
                    successCase:
                    case BlocStatus.success:
                      return Column(
                        children: [
                          SizedBox(height: 16),
                          CustomSearchBar(
                            controller: _searchController,
                            focusNode: _searchFocusNode,
                            onChanged: (value) {
                              context
                                  .read<JurorHomePageBloc>()
                                  .add(JurorHomePageFilterResults(query: value));
                            },
                          ),
                          Expanded(
                            child: RefreshIndicator.adaptive(
                              onRefresh: () async {
                                context.read<JurorHomePageBloc>().add(JurorHomePageFetch());
                                context.read<AuthBloc>().add(AuthFetch());
                              },
                              child: (state.filteredContestsBundles!.isNotEmpty)
                                  ? ListView(
                                      children: [
                                        SizedBox(height: 16),
                                        ...state.filteredContestsBundles!.map((homeContestBundle) {
                                          return Column(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              ContestCard(
                                                homeContestBundle: homeContestBundle,
                                                onTap: () async {
                                                  final bool? res = await context.router.push(
                                                      JurorContestDetailsRoute(
                                                          contestId: homeContestBundle.contestBundle.contest.id!));
                                                  if (res == true) {
                                                    if (context.mounted) {
                                                      context
                                                          .read<JurorHomePageBloc>()
                                                          .add(JurorHomePageFetch());
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
                                  : ListViewWithCentralLabel(label: 'No contest'),
                            ),
                          ),
                        ],
                      );
                  }
                },
              ),
            ),
          ),
          floatingActionButton: (state.isInitialized) ? Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.end,
            spacing: 8,
            children: [
              FloatingActionButton.extended(
                heroTag: 'voteAsSimpleJuror',
                onPressed: () {
                  //todo _showVoteAsSimpleJurorDialog(context: context, profileId: profileId);
                },
                backgroundColor: Theme.of(context).colorScheme.tertiaryContainer,
                foregroundColor: Theme.of(context).colorScheme.onTertiaryContainer,
                // style: FilledButton.styleFrom(
                //   backgroundColor: Theme.of(context).colorScheme.tertiaryContainer,
                //   foregroundColor: Theme.of(context).colorScheme.onTertiaryContainer,
                // ),
                label: Text('Vote as simple juror'),
              ),
              FloatingActionButton.extended(
                heroTag: 'joinContest',
                onPressed: () {
                  _showJoinContestDialog(context: context, profileId: profileId);
                },
                icon: Icon(Icons.login),
                label: Text('Join contest'),
              ),
            ],
          ) : VoidWidget(),
        );
      },
    );
  }
}

void _showJoinContestDialog({
  required BuildContext context,
  required String profileId,
}) {
  final jurorHomePageBloc = context.read<JurorHomePageBloc>();
  final joinContestFormKey = GlobalKey<FormState>();
  final tokenController = TextEditingController();
  final tokenFocusNode = FocusNode();

  showDialog(
    context: context,
    builder: (context) {
      return BlocProvider.value(
        value: jurorHomePageBloc,
        child: BlocConsumer<JurorHomePageBloc, JurorHomePageState>(
          listener: (context, state) {
            if (state.status.isSuccess && state.sourceEvent is JurorHomePageJoinContest) {
              showSnackBar(context: context, text: 'Joined contest successfully');
              context.read<JurorHomePageBloc>().add(JurorHomePageFetch());
              context.router.pop(true);
            }
          },
          builder: (context, state) {
            return AlertDialog(
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
                      focusNode: tokenFocusNode,
                      label: 'Token',
                      validator: (value) => noEmptyValidator(value?.trim()),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    context.router.pop();
                  },
                  child: Text('Cancel'),
                ),
                TextButton(
                  onPressed: () {
                    if (joinContestFormKey.currentState?.validate() ?? false) {
                      context.read<JurorHomePageBloc>().add(
                            JurorHomePageJoinContest(
                              token: tokenController.text.trim(),
                            ),
                          );
                    }
                  },
                  child: Text('Proceed'),
                ),
              ],
            );
          },
        ),
      );
    },
  );
}

// void _showVoteAsSimpleJurorDialog({
//   required BuildContext context,
//   required String profileId,
// }) {
//   final jurorHomePageBloc = context.read<JurorHomePageBloc>();
//   final votingAccessFormKey = GlobalKey<FormState>();
//   final fullNameController = TextEditingController();
//   final tokenController = TextEditingController();
//   final fullNameFocusNode = FocusNode();
//   final tokenFocusNode = FocusNode();
//
//   showDialog(
//     context: context,
//     builder: (context) {
//       return BlocProvider.value(
//         value: jurorHomePageBloc,
//         child: BlocConsumer<JurorHomePageBloc, JurorHomePageState>(
//           listener: (context, state) {
//             if (state.status.isSuccess && state.sourceEvent is JurorHomePageVoteAsSimpleJuror) {
//               final simpleJurorAndVotingSessionBundle = state.simpleJurorAndVotingSessionBundle!;
//               final simpleJurorId = simpleJurorAndVotingSessionBundle.simpleJuror.id;
//               final votingSessionId = simpleJurorAndVotingSessionBundle.votingSession.id;
//               context.router.pop();
//               context.router.push(SimpleJurorVotingProcedureRoute(
//                   simpleJurorId: simpleJurorId, votingSessionId: votingSessionId));
//             }
//           },
//           builder: (context, state) {
//             return AlertDialog(
//               title: Text('Vote as simple juror'),
//               content: Form(
//                 key: votingAccessFormKey,
//                 child: Column(
//                   mainAxisSize: MainAxisSize.min,
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     CustomTextFormField(
//                       borderType: InputBorderType.underlined,
//                       controller: fullNameController,
//                       focusNode: fullNameFocusNode,
//                       label: 'Full name',
//                       validator: (value) => noEmptyValidator(value?.trim()),
//                     ),
//                     CustomTextFormField(
//                       borderType: InputBorderType.underlined,
//                       controller: tokenController,
//                       focusNode: tokenFocusNode,
//                       label: 'Token',
//                       validator: (value) => noEmptyValidator(value?.trim()),
//                     ),
//                   ],
//                 ),
//               ),
//               actions: [
//                 TextButton(
//                   onPressed: () {
//                     context.router.pop();
//                   },
//                   child: Text('Cancel'),
//                 ),
//                 TextButton(
//                   onPressed: () {
//                     if (votingAccessFormKey.currentState?.validate() ?? false) {
//                       context.read<JurorHomePageBloc>().add(
//                             JurorHomePageVoteAsSimpleJuror(
//                               fullName: fullNameController.text.trim(),
//                               token: tokenController.text.trim(),
//                             ),
//                           );
//                     }
//                   },
//                   child: Text('Proceed'),
//                 ),
//               ],
//             );
//           },
//         ),
//       );
//     },
//   );
// }
