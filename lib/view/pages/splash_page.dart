import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:swift_contest/model/enums/contest_role.dart';
import 'package:swift_contest/utils/functions/show_snack_bar.dart';
import 'package:swift_contest/utils/router/go_router.dart';
import 'package:swift_contest/viewmodel/blocs/auth_bloc/auth_bloc.dart';
import 'package:swift_contest/viewmodel/enums/auth_status.dart';
import 'package:swift_contest/viewmodel/enums/bloc_status.dart';

class SplashPage extends StatefulWidget {
  final int delay;

  const SplashPage({required this.delay, super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    //* Check the state of the authentication and set a delay to show the logo meanwhile
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AuthBloc>().add(AuthInitWithDelay(delay: widget.delay));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: BlocConsumer<AuthBloc, AuthState>(
          listener: (context, state) {
            //* Show a message if there is one
            if (state.message != null) {
              showSnackBar(context: context, text: state.message!);
            }
            if (state.blocStatus.isSuccess) {
              if (state.authStatus.isAuthenticated) {
                //* If success and authenticated go to home page of the pref contest role
                switch (state.profile!.prefContestRole) {
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
          builder: (context, state) {
            switch (state.blocStatus) {
              case BlocStatus.initial:
              case BlocStatus.loading:
              case BlocStatus.success:
                return Center(
                  child: FittedBox(
                    child: Text(
                      'Swift Contest',
                      style: TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.w800,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  ),
                );
              case BlocStatus.failure:
                //* In case of failure show a retry button
                return Center(
                  child: FittedBox(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Swift Contest',
                          style: TextStyle(
                            fontSize: 36,
                            fontWeight: FontWeight.w800,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                        FilledButton(
                          onPressed: () {
                            context.read<AuthBloc>().add(AuthInit());
                          },
                          child: Text('Retry'),
                        ),
                      ],
                    ),
                  ),
                );
            }
          },
        ),
      ),
    );
  }
}
