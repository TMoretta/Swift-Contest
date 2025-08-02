import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:swift_contest/model/database/types/contest_role.dart';
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
import 'package:swift_contest/viewmodel/blocs/pages_blocs/participant_home_page_bloc/participant_home_page_bloc.dart';
import 'package:swift_contest/viewmodel/enums/bloc_status.dart';

@RoutePage()
class ParticipantHomePage extends StatefulWidget implements AutoRouteWrapper {
  const ParticipantHomePage({super.key});

  @override
  State<ParticipantHomePage> createState() => _ParticipantHomePageState();

  @override
  Widget wrappedRoute(BuildContext context) {
    return BlocProvider<ParticipantHomePageBloc>(
      create: (context) => ParticipantHomePageBloc(
        participantRepository: context.read(),
      ),
      child: this,
    );
  }
}

class _ParticipantHomePageState extends State<ParticipantHomePage> {
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
    context.read<ParticipantHomePageBloc>().add(ParticipantHomePageFetch());
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
    return BlocConsumer<ParticipantHomePageBloc, ParticipantHomePageState>(
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
            contestRole: ContestRole.participant
          ),
          body: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Builder(
                builder: (context) {
                  if (!state.isInitialized) {
                    if (state.status.isFailure) {
                      return Center(
                        child: FilledButton(
                          onPressed: () async => context.read<ParticipantHomePageBloc>().add(ParticipantHomePageFetch()),
                          child: Text('Retry'),
                        ),
                      );
                    }
                    return VoidWidget();
                  }
                  return Column(
                    children: [
                      SizedBox(height: 16),
                      CustomSearchBar(
                        controller: _searchController,
                        focusNode: _searchFocusNode,
                        onChanged: (value) {
                          context
                              .read<ParticipantHomePageBloc>()
                              .add(ParticipantHomePageFilterResults(query: value));
                        },
                      ),
                      Expanded(
                        child: RefreshIndicator.adaptive(
                          onRefresh: () async {
                            context
                                .read<ParticipantHomePageBloc>()
                                .add(ParticipantHomePageFetch());
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
                                            ParticipantContestDetailsRoute(
                                                contestId: homeContestBundle.contestBundle.contest.id!));
                                        if (res == true) {
                                          if (context.mounted) {
                                            context.read<ParticipantHomePageBloc>().add(
                                                ParticipantHomePageFetch(
                                                ));
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
                },
              ),
            ),
          ),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () {
              _showJoinContestDialog(context: context);
            },
            icon: Icon(Icons.login),
            label: Text('Join a contest'),
          ),
        );
      },
    );
  }
}

void _showJoinContestDialog({
  required BuildContext context
}) {
  final participantHomePageBloc = context.read<ParticipantHomePageBloc>();
  final joinContestFormKey = GlobalKey<FormState>();
  final tokenController = TextEditingController();
  final tokenFocusNode = FocusNode();

  showDialog(
    context: context,
    builder: (context) {
      return BlocProvider.value(
        value: participantHomePageBloc,
        child: BlocConsumer<ParticipantHomePageBloc, ParticipantHomePageState>(
          listener: (context, state) {
            if (state.status.isSuccess && state.sourceEvent is ParticipantHomePageJoinContest) {
              showSnackBar(context: context, text: 'Joined contest successfully');
              context
                  .read<ParticipantHomePageBloc>()
                  .add(ParticipantHomePageFetch());
              context.router.pop();
            }
          },
          builder: (context, state) {
            return AlertDialog(
              title: Text('Join as participant'),
              content: Form(
                key: joinContestFormKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
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
                      context.read<ParticipantHomePageBloc>().add(
                            ParticipantHomePageJoinContest(
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
