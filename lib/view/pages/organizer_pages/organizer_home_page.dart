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
import 'package:swift_contest/viewmodel/blocs/bloc_status.dart';
import 'package:swift_contest/viewmodel/blocs/global_blocs/auth_bloc/auth_bloc.dart';
import 'package:swift_contest/viewmodel/blocs/global_blocs/organizer_created_contests_bloc/organizer_created_contests_bloc.dart';

class OrganizerHomePage extends StatefulWidget {
  const OrganizerHomePage({super.key});

  @override
  State<OrganizerHomePage> createState() => _OrganizerHomePageState();
}

class _OrganizerHomePageState extends State<OrganizerHomePage> {
  late User user;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final authState = context.read<AuthBloc>().state;
    user = (authState as AuthAuthenticated).user;
    if (!context.read<OrganizerCreatedContestsBloc>().state.status.isSuccess) {
      context
          .read<OrganizerCreatedContestsBloc>()
          .add(OrganizerCreatedContestsGetCreatedContests(organizerId: user.id));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: HomePageAppBar(contestRole: ContestRole.organizer),
      body: BlocConsumer<OrganizerCreatedContestsBloc, OrganizerCreatedContestsState>(
        listener: (context, state) {
          if (state.status.isFailure) {
            showSnackBar(context: context, text: state.message!);
          }
        },
        builder: (context, state) {
          return SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                return SizedBox(
                  width: constraints.maxWidth,
                  height: constraints.maxHeight,
                  child: switch (state.status) {
                    BlocStatus.initial => Container(),
                    BlocStatus.loading => Loader(),
                    BlocStatus.success => RefreshIndicator.adaptive(
                        onRefresh: () async {
                          context.read<OrganizerCreatedContestsBloc>().add(
                              OrganizerCreatedContestsGetCreatedContests(organizerId: user.id));
                        },
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: ListView.builder(
                            itemCount: state.contests!.length,
                            itemBuilder: (context, index) {
                              final contest = state.contests![index];
                              final organizer = state.organizers![index];
                              final participations = state.participations![index];
                              final jurations = state.jurations![index];
                              return Column(
                                children: [
                                  SizedBox(height: (index == 0) ? 16 : 0),
                                  ContestCard(
                                    contest: contest,
                                    organizer: organizer,
                                    participations: participations,
                                    jurations: jurations,
                                    onTap: () {
                                      context.pushNamed(AppRouter.organizerContestDetails,
                                          extra: contest.id);
                                    },
                                  ),
                                  SizedBox(height: (index == state.contests!.length - 1) ? 80 : 8),
                                ],
                              );
                            },
                          ),
                        ),
                      ),
                    BlocStatus.failure => RefreshIndicator.adaptive(
                        onRefresh: () async {
                          context.read<OrganizerCreatedContestsBloc>().add(
                              OrganizerCreatedContestsGetCreatedContests(organizerId: user.id));
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
                  .read<OrganizerCreatedContestsBloc>()
                  .add(OrganizerCreatedContestsGetCreatedContests(organizerId: user.id));
            }
          }
        },
        child: Text('Create a contest'),
      ),
    );
  }
}
