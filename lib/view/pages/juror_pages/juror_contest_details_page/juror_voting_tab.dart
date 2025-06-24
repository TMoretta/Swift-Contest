import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:swift_contest/model/data_models/user.dart';
import 'package:swift_contest/utils/functions/show_snack_bar.dart';
import 'package:swift_contest/utils/router/go_router.dart';
import 'package:swift_contest/view/widgets/loader.dart';
import 'package:swift_contest/viewmodel/blocs/auth_bloc/auth_bloc.dart';
import 'package:swift_contest/viewmodel/blocs/pages_blocs/juror_contest_details_page_bloc/juror_contest_details_page_bloc.dart';
import 'package:swift_contest/viewmodel/enums/bloc_status.dart';

class JurorVotingTab extends StatefulWidget {
  final String contestId;

  const JurorVotingTab({required this.contestId, super.key});

  @override
  State<JurorVotingTab> createState() => _JurorVotingTabState();
}

class _JurorVotingTabState extends State<JurorVotingTab> {
  late String contestId;

  @override
  void initState() {
    super.initState();
    contestId = widget.contestId;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final state = context.read<JurorContestDetailsPageBloc>().state;
    if (state.status.isInitial) {
      context
          .read<JurorContestDetailsPageBloc>()
          .add(JurorContestDetailsPageInit(contestId: contestId));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocBuilder<JurorContestDetailsPageBloc, JurorContestDetailsPageState>(
        builder: (context, state) {
          switch (state.status) {
            case BlocStatus.initial:
              return SizedBox.shrink();
            case BlocStatus.loading:
              return Loader();
            case BlocStatus.failure:
              if (state.sourceEvent is JurorContestDetailsPageInit) {
                return RefreshIndicator.adaptive(
                  onRefresh: () async => context
                      .read<JurorContestDetailsPageBloc>()
                      .add(JurorContestDetailsPageRefresh(contestId: contestId)),
                  child: ListView(),
                );
              } else {
                continue successCase;
              }
            successCase:
            case BlocStatus.success:
              return LayoutBuilder(
                builder: (context, constraints) {
                  return RefreshIndicator.adaptive(
                    onRefresh: () async => context
                        .read<JurorContestDetailsPageBloc>()
                        .add(JurorContestDetailsPageRefresh(contestId: contestId)),
                    child: (state.contestDetailsBundle!.liveVotingSession == null)
                        ? ListView(
                            children: [
                              SizedBox(
                                height: constraints.maxHeight,
                                child: Center(
                                  child: Text('No voting session live'),
                                ),
                              ),
                            ],
                          )
                        : ListView(),
                  );
                },
              );
          }
        },
      ),
      floatingActionButton: BlocBuilder<JurorContestDetailsPageBloc, JurorContestDetailsPageState>(
        builder: (context, state) {
          return FilledButton(
            onPressed: (state.contestDetailsBundle!.liveVotingSession != null)
                ? () {
                    context.pushNamed(AppRouter.jurorVotingProcedure,
                        extra: state.contestDetailsBundle!.liveVotingSession!.id);
                  }
                : null,
            child: Text('Vote'),
          );
        },
      ),
    );

    return BlocConsumer<JurorContestDetailsPageBloc, JurorContestDetailsPageState>(
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
          case (BlocStatus.failure || BlocStatus.success):
            if (state.contestDetailsBundle == null) {
              return RefreshIndicator.adaptive(
                onRefresh: () async {
                  context
                      .read<JurorContestDetailsPageBloc>()
                      .add(JurorContestDetailsPageInit(contestId: contestId));
                },
                child: ListView(),
              );
            } else {
              return RefreshIndicator.adaptive(
                onRefresh: () async {
                  context.read<JurorContestDetailsPageBloc>().add(JurorContestDetailsPageInit(
                        contestId: state.contestDetailsBundle!.contest.id,
                      ));
                },
                child: ListView(
                  children: [
                    switch (state.contestDetailsBundle!.liveVotingSession != null) {
                      true => Column(
                          children: [
                            Text('Voting session is live'),
                            FilledButton(
                              onPressed: () {
                                context.pushNamed(AppRouter.jurorVotingProcedure,
                                    extra: state.contestDetailsBundle!.toJson());
                              },
                              child: Text('Vote'),
                            ),
                          ],
                        ),
                      false => Column(
                          children: [
                            Text('No voting session is live'),
                            FilledButton(
                              onPressed: null,
                              child: Text('Vote'),
                            ),
                          ],
                        ),
                    }
                  ],
                ),
              );
            }
        }
      },
    );
  }
}
