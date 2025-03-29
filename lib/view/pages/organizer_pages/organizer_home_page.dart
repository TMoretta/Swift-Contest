import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:swift_contest/model/data_models/profile/contest_role.dart';
import 'package:swift_contest/model/data_models/user/user.dart';
import 'package:swift_contest/utils/router/go_router.dart';
import 'package:swift_contest/view/widgets/contest_card.dart';
import 'package:swift_contest/view/widgets/home_page_app_bar.dart';
import 'package:swift_contest/view/widgets/loader.dart';
import 'package:swift_contest/view/widgets/show_snack_bar.dart';
import 'package:swift_contest/viewmodel/blocs/app_auth_bloc/app_auth_bloc.dart';
import 'package:swift_contest/viewmodel/blocs/organizer_pages_blocs/organizer_home_page_bloc/organizer_home_page_bloc.dart';

class OrganizerHomePage extends StatefulWidget {
  const OrganizerHomePage({super.key});

  @override
  State<OrganizerHomePage> createState() => _OrganizerHomePageState();
}

class _OrganizerHomePageState extends State<OrganizerHomePage> {
  late User user;

  @override
  void initState() {
    super.initState();
    final appAuthState = context.read<AppAuthBloc>().state;
    user = (appAuthState as AppAuthAuthenticated).user;
    final organizerHomePageBloc = context.read<OrganizerHomePageBloc>();
    final organizerHomePageState = organizerHomePageBloc.state;
    if (organizerHomePageState is! OrganizerHomePageSuccess) {
      organizerHomePageBloc.add(OrganizerHomePageGetCreatedContestsExtended(organizerId: user.id));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: HomePageAppBar(contestRole: ContestRole.organizer),
      body: BlocConsumer<OrganizerHomePageBloc, OrganizerHomePageState>(
        listener: (context, state) {
          if (state is OrganizerHomePageFailure) {
            showSnackBar(context: context, text: state.message);
          }
        },
        builder: (context, state) {
          return SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                return SizedBox(
                  width: constraints.maxWidth,
                  height: constraints.maxHeight,
                  child: switch (state) {
                    OrganizerHomePageInitial() => Loader(),
                    OrganizerHomePageLoading() => Loader(),
                    OrganizerHomePageSuccess() => RefreshIndicator.adaptive(
                        onRefresh: () async {
                          context.read<OrganizerHomePageBloc>().add(
                              OrganizerHomePageGetCreatedContestsExtended(organizerId: user.id));
                        },
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: ListView.builder(
                            itemCount: state.contests.length,
                            itemBuilder: (context, index) {
                              final contest = state.contests[index];
                              final organizer = state.organizers[index];
                              final participations = state.participations[index];
                              final jurations = state.jurations[index];
                              return Column(
                                children: [
                                  SizedBox(height: (index == 0) ? 16 : 0),
                                  ContestCard(
                                    contest: state.contests[index],
                                    organizer: organizer,
                                    participations: participations,
                                    jurations: jurations,
                                    onTap: () {
                                      context.pushNamed(AppRouter.organizerContestDetails,
                                          extra: contest.id);
                                    },
                                  ),
                                  SizedBox(height: (index == state.contests.length - 1) ? 80 : 8),
                                ],
                              );
                            },
                          ),
                        ),
                      ),
                    OrganizerHomePageFailure() => RefreshIndicator.adaptive(
                        onRefresh: () async {
                          context.read<OrganizerHomePageBloc>().add(
                              OrganizerHomePageGetCreatedContestsExtended(organizerId: user.id));
                        },
                        child: ListView(),
                      ),
                  },
                );
              },
            ),
          );
        },
      ),
      floatingActionButton: FilledButton(
        onPressed: () async {
          final result = await context.pushNamed(AppRouter.organizerContestCreation);
          if (result == true) {
            if (context.mounted) {
              context
                  .read<OrganizerHomePageBloc>()
                  .add(OrganizerHomePageGetCreatedContestsExtended(organizerId: user.id));
            }
          }
        },
        child: Text('Create a contest'),
      ),
    );
  }
}
