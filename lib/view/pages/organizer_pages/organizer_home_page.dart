import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:swift_contest/model/db/types/contest_role.dart';
import 'package:swift_contest/utils/labels/labels.dart';
import 'package:swift_contest/utils/router/app_router.gr.dart';
import 'package:swift_contest/view/widgets/contest_card.dart';
import 'package:swift_contest/view/widgets/custom_search_bar.dart';
import 'package:swift_contest/view/widgets/home_page_app_bar.dart';
import 'package:swift_contest/view/widgets/list_view_with_central_label.dart';
import 'package:swift_contest/view/widgets/overlay_loader.dart';
import 'package:swift_contest/view/widgets/show_snack_bar.dart';
import 'package:swift_contest/view/widgets/void_widget.dart';
import 'package:swift_contest/viewmodel/blocs/auth_bloc/auth_bloc.dart';
import 'package:swift_contest/viewmodel/blocs/pages_blocs/organizer_home_page_bloc/organizer_home_page_bloc.dart';
import 'package:swift_contest/viewmodel/enums/bloc_status.dart';

@RoutePage()
class OrganizerHomePage extends StatefulWidget implements AutoRouteWrapper {
  const OrganizerHomePage({super.key});

  @override
  State<OrganizerHomePage> createState() => _OrganizerHomePageState();

  @override
  Widget wrappedRoute(BuildContext context) {
    return BlocProvider(
      create: (context) => OrganizerHomePageBloc(
        organizerRepository: context.read(),
      ),
      child: this,
    );
  }
}

class _OrganizerHomePageState extends State<OrganizerHomePage> {
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
    context.read<OrganizerHomePageBloc>().add(OrganizerHomePageFetch());
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
    return BlocConsumer<OrganizerHomePageBloc, OrganizerHomePageState>(
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
              contestRole: ContestRole.organizer,
              onRefresh: () async =>
                  context.read<OrganizerHomePageBloc>().add(OrganizerHomePageFetch())),
          body: SafeArea(
            child: Padding(
              padding: const EdgeInsets.only(left: 16, right: 16, top: 16),
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
                          onRefresh: () async {
                            _searchController.clear();
                            _searchFocusNode.unfocus();
                            context.read<OrganizerHomePageBloc>().add(OrganizerHomePageFetch());
                          },
                          child: ListViewWithCentralLabel(label: Labels.anErrorOccurred),
                        );
                      } else {
                        continue successCase;
                      }
                    successCase:
                    case BlocStatus.success:
                      return Column(
                        children: [
                          CustomSearchBar(
                            controller: _searchController,
                            focusNode: _searchFocusNode,
                            onChanged: (value) {
                              context
                                  .read<OrganizerHomePageBloc>()
                                  .add(OrganizerHomePageFilterResults(query: value));
                            },
                          ),
                          SizedBox(height: 16),
                          Expanded(
                            child: RefreshIndicator.adaptive(
                              onRefresh: () async {
                                _searchController.clear();
                                _searchFocusNode.unfocus();
                                context.read<OrganizerHomePageBloc>().add(OrganizerHomePageFetch());
                              },
                              child: (state.filteredContestsBundles!.isNotEmpty)
                                  ? ListView.builder(
                                      itemCount: state.filteredContestsBundles!.length,
                                      itemBuilder: (context, index) {
                                        final homeContestBundle = state.filteredContestsBundles![index];
                                        return Column(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            ContestCard(
                                              homeContestBundle: homeContestBundle,
                                              onTap: () async {
                                                final bool? res = await context.router.push(
                                                    OrganizerContestDetailsRoute(
                                                        contestId: homeContestBundle
                                                            .contestBundle.contest.id!));
                                                if (res == true) {
                                                  if (context.mounted) {
                                                    context
                                                        .read<OrganizerHomePageBloc>()
                                                        .add(OrganizerHomePageFetch());
                                                  }
                                                }
                                              },
                                            ),
                                            (index == state.filteredContestsBundles!.length - 1)
                                                ? SizedBox(height: 72)
                                                : SizedBox(height: 8),
                                          ],
                                        );
                                      },
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
          floatingActionButton: (state.isInitialized)
              ? FilledButton(
                  onPressed: () async {
                    final bool? res = await context.router.push(OrganizerContestCreationRoute());
                    if (res == true) {
                      if (context.mounted) {
                        context.read<OrganizerHomePageBloc>().add(OrganizerHomePageFetch());
                      }
                    }
                  },
                  child: Text('Create contest'),
                )
              : VoidWidget(),
        );
      },
    );
  }
}
