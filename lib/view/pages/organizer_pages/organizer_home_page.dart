import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:swift_contest/model/data_models/profile.dart';
import 'package:swift_contest/model/enums/contest_role.dart';
import 'package:swift_contest/view/widgets/show_snack_bar.dart';
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
  late Profile profile;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    profile = context.read<AuthBloc>().state.profile!;
    context.read<OrganizerHomePageBloc>().add(OrganizerHomePageInit(userId: profile.id));
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<OrganizerHomePageBloc, OrganizerHomePageState>(
      listener: (context, state) {
        if (state.message != null) {
          showSnackBar(context: context, text: state.message!);
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
                    return SizedBox.shrink();
                  case BlocStatus.loading:
                    return Loader();
                  case BlocStatus.failure:
                    if (state.sourceEvent is OrganizerHomePageInit) {
                      return RefreshIndicator.adaptive(
                        onRefresh: () async => context
                            .read<OrganizerHomePageBloc>()
                            .add(OrganizerHomePageInit(userId: profile.id)),
                        child: ListView(),
                      );
                    } else {
                      continue successCase;
                    }
                  successCase:
                  case BlocStatus.success:
                    // if (state.createdContestsBundles!.isEmpty) {
                    //   return LayoutBuilder(builder: (context, constraints) {
                    //     return RefreshIndicator.adaptive(
                    //       onRefresh: () async => context
                    //           .read<OrganizerHomePageBloc>()
                    //           .add(OrganizerHomePageRefresh(userId: user.id)),
                    //       child: ListView(
                    //         children: [
                    //           SizedBox(
                    //             height: constraints.maxHeight,
                    //             child: Center(
                    //               child: Text(
                    //                 'No contest created yet',
                    //                 style: Theme.of(context).textTheme.bodyLarge,
                    //               ),
                    //             ),
                    //           ),
                    //         ],
                    //       ),
                    //     );
                    //   },);
                    // }
                    return LayoutBuilder(
                      builder: (context, constraints) {
                        return RefreshIndicator.adaptive(
                          onRefresh: () async => context
                              .read<OrganizerHomePageBloc>()
                              .add(OrganizerHomePageRefresh(userId: profile.id)),
                          child: (state.createdContestsBundles!.isNotEmpty)
                              ? ListView.builder(
                                  itemCount: state.createdContestsBundles!.length,
                                  itemBuilder: (context, index) {
                                    final contestCardBundle = state.createdContestsBundles![index];
                                    return Column(
                                      children: [
                                        SizedBox(height: (index == 0) ? 16 : 0),
                                        ContestCard(
                                          contestCardBundle: contestCardBundle,
                                          onTap: () async {
                                            final bool? res = await context.pushNamed(AppRouter.organizerContestDetails,
                                                extra: contestCardBundle.contest.id);
                                            if(res==true) {
                                              if(context.mounted) {
                                                context.read<OrganizerHomePageBloc>().add(OrganizerHomePageRefresh(userId: profile.id));
                                              }
                                            }
                                          },
                                        ),
                                        SizedBox(
                                            height: (index == state.createdContestsBundles!.length - 1)
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
                                          'No contest created yet',
                                          style: Theme.of(context).textTheme.bodyLarge,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                        );
                      }
                    );
                }
              },
            ),
          ),
        ),
        floatingActionButton: BlocBuilder<OrganizerHomePageBloc, OrganizerHomePageState>(
          builder: (context, state) {
            switch (state.status) {
              case BlocStatus.initial:
              case BlocStatus.loading:
                return SizedBox.shrink();
              case BlocStatus.failure:
              case BlocStatus.success:
                return FilledButton(
                  onPressed: () async {
                    final bool? res = await context.pushNamed(AppRouter.organizerContestCreation);
                    if (res == true) {
                      if (context.mounted) {
                        context
                            .read<OrganizerHomePageBloc>()
                            .add(OrganizerHomePageRefresh(userId: profile.id));
                      }
                    }
                  },
                  child: Text('Create a contest'),
                );
            }
          },
        ),
      ),
    );
  }
}
