import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:swift_contest/model/enums/contest_role.dart';
import 'package:swift_contest/utils/functions/show_snack_bar.dart';
import 'package:swift_contest/utils/router/go_router.dart';
import 'package:swift_contest/viewmodel/blocs/global_blocs/auth_bloc/auth_bloc.dart';
import 'package:swift_contest/viewmodel/enums/auth_status.dart';
import 'package:swift_contest/viewmodel/enums/bloc_status.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    //* Check the state of the authetication and set a delay to show the logo meanwhile
    context.read<AuthBloc>().add(AuthInitWithDelay(delay: 3));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SizedBox(
              width: constraints.maxWidth,
              height: constraints.maxHeight,
              child: BlocConsumer<AuthBloc, AuthState>(
                listener: (context, state) {
                  //* Show message if there is one
                  if (state.message != null) {
                    showSnackBar(context: context, text: state.message!);
                  }
                  //* If not authenticated go to sign in
                  if(state.authStatus.isUnauthenticated) {
                    context.goNamed(AppRouter.signIn);
                  }
                  //* Go to home if authenticated
                  if (state.blocStatus.isSuccess && state.authStatus.isAuthenticated) {
                    switch(state.profile!.prefContestRole) {
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
                },
                builder: (context, state) {
                  //* Failed to retrieve the profile but the user is authenticated, so retry
                  if (state.blocStatus.isFailure && state.authStatus.isAuthenticated) {
                    return Center(
                      child: FilledButton(
                        onPressed: () {
                          context.read<AuthBloc>().add(AuthInit());
                        },
                        child: Text('Retry'),
                      ),
                    );
                  }
                  //* Show the logo meanwhile
                  return Center(
                    child: FlutterLogo(size: 100),
                  );
                },
              ),
            );
          },
        ),
      ),
    );
  }
}
