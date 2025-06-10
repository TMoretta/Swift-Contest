import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:swift_contest/model/data_models/user.dart';
import 'package:swift_contest/model/enums/contest_role.dart';
import 'package:swift_contest/utils/functions/show_snack_bar.dart';
import 'package:swift_contest/utils/router/go_router.dart';
import 'package:swift_contest/view/widgets/contest_card.dart';
import 'package:swift_contest/view/widgets/home_page_app_bar.dart';
import 'package:swift_contest/view/widgets/loader.dart';
import 'package:swift_contest/viewmodel/blocs/auth_bloc/auth_bloc.dart';
import 'package:swift_contest/viewmodel/blocs/pages_blocs/organizer_home_page_bloc/organizer_home_page_bloc.dart';
import 'package:swift_contest/viewmodel/enums/bloc_status.dart';

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
    user = context.read<AuthBloc>().state.user!;
    context
        .read<OrganizerHomePageBloc>()
        .add(OrganizerHomePageGetCreatedContests(organizerId: user.id));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: HomePageAppBar(contestRole: ContestRole.organizer),
      body: SafeArea(
        child: BlocConsumer<OrganizerHomePageBloc, OrganizerHomePageState>(
          listener: (context, state) {
            if (state.message != null) {
              showSnackBar(context: context, text: state.message!);
            }
          },
          builder: (context, state) {
            switch (state.status) {
              case BlocStatus.initial:
                return SizedBox.shrink();
              case BlocStatus.loading:
                return Loader();
              case BlocStatus.failure:
                if (state.status.isFailure &&
                    state.sourceEvent is OrganizerHomePageGetCreatedContests) {
                  return RefreshIndicator.adaptive(
                    onRefresh: () async => context
                        .read<OrganizerHomePageBloc>()
                        .add(OrganizerHomePageGetCreatedContests(organizerId: user.id)),
                    child: ListView(
                      physics: AlwaysScrollableScrollPhysics(),
                    ),
                  );
                } else {
                  continue successCase;
                }
              successCase:
              case BlocStatus.success:
                return RefreshIndicator.adaptive(
                  onRefresh: () async => context
                      .read<OrganizerHomePageBloc>()
                      .add(OrganizerHomePageGetCreatedContests(organizerId: user.id)),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: ListView.builder(
                      physics: AlwaysScrollableScrollPhysics(),
                      itemCount: state.createdContestsBundles!.length,
                      itemBuilder: (context, index) {
                        final contestCardBundle = state.createdContestsBundles![index];
                        return Column(
                          children: [
                            SizedBox(height: (index == 0) ? 16 : 0),
                            ContestCard(
                              contestCardBundle: contestCardBundle,
                              onTap: () {
                                context.pushNamed(AppRouter.organizerContestDetails,
                                    extra: contestCardBundle.contest.id);
                              },
                            ),
                            SizedBox(
                                height:
                                    (index == state.createdContestsBundles!.length - 1) ? 80 : 8),
                          ],
                        );
                      },
                    ),
                  ),
                );
            }
          },
        ),
      ),
      floatingActionButton: FilledButton(
        onPressed: () async {
          final res = await context.pushNamed(AppRouter.organizerContestCreation);
          if (res == true) {
            if (context.mounted) {
              context
                  .read<OrganizerHomePageBloc>()
                  .add(OrganizerHomePageGetCreatedContests(organizerId: user.id));
            }
          }
        },
        child: Text('Create a contest'),
      ),
    );
  }
}
