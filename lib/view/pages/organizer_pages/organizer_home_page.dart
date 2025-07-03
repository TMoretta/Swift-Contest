import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:swift_contest/model/data_models/profile.dart';
import 'package:swift_contest/model/enums/contest_role.dart';
import 'package:swift_contest/utils/labels/labels.dart';
import 'package:swift_contest/utils/router/go_router.dart';
import 'package:swift_contest/view/widgets/contest_card.dart';
import 'package:swift_contest/view/widgets/home_page_app_bar.dart';
import 'package:swift_contest/view/widgets/list_view_with_central_label.dart';
import 'package:swift_contest/view/widgets/overlay_loader.dart';
import 'package:swift_contest/view/widgets/show_snack_bar.dart';
import 'package:swift_contest/view/widgets/void_widget.dart';
import 'package:swift_contest/viewmodel/blocs/auth_bloc/auth_bloc.dart';
import 'package:swift_contest/viewmodel/blocs/pages_blocs/organizer_home_page_bloc/organizer_home_page_bloc.dart';
import 'package:swift_contest/viewmodel/enums/bloc_status.dart';

class OrganizerHomePage extends StatefulWidget {
  const OrganizerHomePage({super.key});

  @override
  State<OrganizerHomePage> createState() => _OrganizerHomePageState();
}

class _OrganizerHomePageState extends State<OrganizerHomePage> {

  late Profile profile;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    profile = context.read<AuthBloc>().state.profile!;
    context.read<OrganizerHomePageBloc>().add(OrganizerHomePageInit(organizerId: profile.id));
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<OrganizerHomePageBloc, OrganizerHomePageState>(
      listener: (context, state) {
        if (state.message != null) {
          showSnackBar(context: context, text: state.message!);
        }
        if(state.status.isLoading) {
          context.showLoader();
        } else {
          context.hideLoader();
        }
        if(state.status.isLoading) {
          context.showLoader();
        } else {
          context.hideLoader();
        }
      },
      child: Scaffold(
        appBar: HomePageAppBar(contestRole: ContestRole.organizer),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: BlocBuilder<OrganizerHomePageBloc, OrganizerHomePageState>(
              builder: (context, state) {
                switch (state.status) {
                  case BlocStatus.initial:
                    return VoidWidget();
                  case BlocStatus.loading:
                    if (state.sourceEvent is OrganizerHomePageInit) {
                      return VoidWidget();
                    } else {
                      continue successCase;
                    }
                  case BlocStatus.failure:
                    if (state.sourceEvent is OrganizerHomePageInit) {
                      return RefreshIndicator.adaptive(
                        onRefresh: () async => context
                            .read<OrganizerHomePageBloc>()
                            .add(OrganizerHomePageInit(organizerId: profile.id)),
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
                            .read<OrganizerHomePageBloc>()
                            .add(OrganizerHomePageRefresh(organizerId: profile.id));
                        context.read<AuthBloc>().add(AuthFetchProfileMessages());
                      },
                      child: (state.createdContestsBundles!.isNotEmpty)
                          ? ListView(
                              children: [
                                SizedBox(height: 16),
                                ...state.createdContestsBundles!.map((homeContestBundle) {
                                  return Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      ContestCard(
                                        homeContestBundle: homeContestBundle,
                                        onTap: () async {
                                          final bool? res = await context.pushNamed(
                                              AppRouter.organizerContestDetails,
                                              extra: homeContestBundle.contest.id);
                                          if (res == true) {
                                            if (context.mounted) {
                                              context.read<OrganizerHomePageBloc>().add(
                                                  OrganizerHomePageRefresh(
                                                      organizerId: profile.id));
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
                          : ListViewWithCentralLabel(label: 'No contest created yet'),
                    );
                }
              },
            ),
          ),
        ),
        floatingActionButton: FilledButton(
          onPressed: () async {
            final bool? res = await context.pushNamed(AppRouter.organizerContestCreation);
            if (res == true) {
              if (context.mounted) {
                context
                    .read<OrganizerHomePageBloc>()
                    .add(OrganizerHomePageRefresh(organizerId: profile.id));
              }
            }
          },
          child: Text('Create contest'),
        ),
      ),
    );
  }
}
