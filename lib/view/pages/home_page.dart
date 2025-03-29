import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:swift_contest/model/data_models/profile/contest_role.dart';
import 'package:swift_contest/utils/router/go_router.dart';
import 'package:swift_contest/view/widgets/loader.dart';
import 'package:swift_contest/view/widgets/show_snack_bar.dart';
import 'package:swift_contest/viewmodel/blocs/app_contest_role_bloc/app_contest_role_bloc.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    super.initState();
    final appContestRoleState = context.read<AppContestRoleBloc>().state;
    if (appContestRoleState is AppContestRoleInitial) {
      context.read<AppContestRoleBloc>().add(AppContestRoleInitRole());
    } else {
      context.read<AppContestRoleBloc>().add(AppContestRoleTriggerListener());
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AppContestRoleBloc, AppContestRoleState>(
      listener: (context, state) {
        if (state is AppContestRoleSuccess) {
          final appContestRole = state.appContestRole;
          switch (appContestRole) {
            case ContestRole.organizer:
              context.goNamed(AppRouter.organizerHome);
              break;
            case ContestRole.participant:
              context.goNamed(AppRouter.participantHome);
              break;
            case ContestRole.juror:
              context.goNamed(AppRouter.jurorHome);
              break;
          }
        }
        if (state is AppContestRoleFailure) {
          showSnackBar(context: context, text: state.message);
          context.goNamed(AppRouter.organizerHome);
        }
      },
      builder: (context, state) {
        return Loader();
      },
    );
  }
}
