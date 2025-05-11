import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:swift_contest/model/data_models/user.dart';
import 'package:swift_contest/utils/router/go_router.dart';
import 'package:swift_contest/view/widgets/loader.dart';
import 'package:swift_contest/viewmodel/blocs/bloc_status.dart';
import 'package:swift_contest/viewmodel/blocs/global_blocs/auth_bloc/auth_bloc.dart';
import 'package:swift_contest/viewmodel/blocs/pages_blocs/juror_contest_details_page_bloc/juror_contest_details_page_bloc.dart';

class JurorVotingTab extends StatefulWidget {
  final String contestId;

  const JurorVotingTab({required this.contestId, super.key});

  @override
  State<JurorVotingTab> createState() => _JurorVotingTabState();
}

class _JurorVotingTabState extends State<JurorVotingTab> {
  late User user;

  @override
  void initState() {
    super.initState();
    context
        .read<JurorContestDetailsPageBloc>()
        .add(JurorContestDetailsPageGetVotingTabInfo(contestId: widget.contestId));
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    user = context.read<AuthBloc>().state.user!;
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<JurorContestDetailsPageBloc, JurorContestDetailsPageState>(
      listener: (context, state) {},
      builder: (context, state) {
        if (state.status.isLoading) {
          return Loader();
        }
        if (state.status.isSuccess) {
          return RefreshIndicator.adaptive(
            onRefresh: () async {
              context
                  .read<JurorContestDetailsPageBloc>()
                  .add(JurorContestDetailsPageGetVotingTabInfo(
                    contestId: widget.contestId,
                  ));
            },
            child: ListView(
              children: [
                switch (state.isVotingSessionProcedureLive) {
                  true => Column(
                      children: [
                        Text('Voting session is live'),
                        FilledButton(
                          onPressed: () {
                            context.pushNamed(AppRouter.jurorVotingProcedure, extra: widget.contestId);
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
        return RefreshIndicator.adaptive(
          onRefresh: () async {
            context.read<JurorContestDetailsPageBloc>().add(JurorContestDetailsPageGetVotingTabInfo(
                  contestId: widget.contestId,
                ));
          },
          child: ListView(),
        );
      },
    );
  }
}
