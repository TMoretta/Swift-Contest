import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:swift_contest/model/enums/contest_role.dart';
import 'package:swift_contest/utils/functions/show_snack_bar.dart';
import 'package:swift_contest/utils/router/go_router.dart';
import 'package:swift_contest/view/widgets/loader.dart';
import 'package:swift_contest/viewmodel/blocs/auth_bloc/auth_bloc.dart';
import 'package:swift_contest/viewmodel/enums/auth_status.dart';
import 'package:swift_contest/viewmodel/enums/bloc_status.dart';

class RootPage extends StatefulWidget {
  const RootPage({super.key});

  @override
  State<RootPage> createState() => _RootPageState();
}

class _RootPageState extends State<RootPage> {
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    context.read<AuthBloc>().add(AuthInit(delay: 0));
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        //* Show a message if there is one
        if (state.message != null) {
          showSnackBar(context: context, text: state.message!);
        }
        if (state.blocStatus.isSuccess) {
          if (state.authStatus.isAuthenticated) {
            //* If success and authenticated go to home page of the pref contest role
            switch (state.authBundle!.profile.prefContestRole) {
              case ContestRole.organizer:
                context.replaceNamed(AppRouter.organizerHome);
                break;
              case ContestRole.participant:
                context.replaceNamed(AppRouter.participantHome);
                break;
              case ContestRole.juror:
                context.replaceNamed(AppRouter.jurorHome);
                break;
            }
          } else if (state.authStatus.isUnauthenticated) {
            //* If success and not authenticated go to sign in page
            context.replaceNamed(AppRouter.signIn);
          }
        }
      },
      child: Scaffold(
        body: SafeArea(
          child: Center(
            child: BlocBuilder<AuthBloc, AuthState>(
              builder: (context, state) {
                switch (state.blocStatus) {
                  case BlocStatus.initial:
                    return SizedBox.shrink();
                  case BlocStatus.failure:
                    return Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        FilledButton(
                          onPressed: () {
                            context.read<AuthBloc>().add(AuthInit(delay: 0));
                          },
                          child: Text('Retry'),
                        ),
                      ],
                    );
                  case BlocStatus.loading:
                    return Loader();
                  case BlocStatus.success:
                    return SizedBox.shrink();
                }
              },
            ),
          ),
        ),
      ),
    );
  }
}
