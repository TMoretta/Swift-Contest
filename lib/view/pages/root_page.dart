import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:swift_contest/model/enums/contest_role.dart';
import 'package:swift_contest/utils/functions/show_snack_bar.dart';
import 'package:swift_contest/utils/router/go_router.dart';
import 'package:swift_contest/view/widgets/loader.dart';
import 'package:swift_contest/view/widgets/pull_to_refresh_hint.dart';
import 'package:swift_contest/viewmodel/blocs/auth_bloc/auth_bloc.dart';
import 'package:swift_contest/viewmodel/enums/auth_status.dart';
import 'package:swift_contest/viewmodel/enums/bloc_status.dart';

class RootPage extends StatefulWidget {
  final int delay;
  const RootPage({this.delay = 0, super.key});

  @override
  State<RootPage> createState() => _RootPageState();
}

class _RootPageState extends State<RootPage> {

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    context.read<AuthBloc>().add(AuthInit(delay: widget.delay));
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
            switch (state.profile!.prefRole) {
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
          child: BlocBuilder<AuthBloc, AuthState>(
            builder: (context, state) {
              switch (state.blocStatus) {
                case BlocStatus.failure:
                  return LayoutBuilder(
                    builder: (context, constraints) {
                      return Stack(
                        alignment: Alignment.center,
                        fit: StackFit.expand,
                        children: [
                          if (state.blocStatus.isFailure)
                            Positioned(
                              top: 4,
                              child: PullToRefreshHint(),
                            ),
                          RefreshIndicator.adaptive(
                            onRefresh: () async => context.read<AuthBloc>().add(AuthInit(delay: 0)),
                            child: SingleChildScrollView(
                              physics: AlwaysScrollableScrollPhysics(),
                              child: SizedBox(
                                height: constraints.maxHeight,
                                child: Center(
                                  child: FittedBox(
                                    fit: BoxFit.scaleDown,
                                    child: Text(
                                      'Swift Contest',
                                      style: Theme.of(context)
                                          .textTheme
                                          .displayMedium!
                                          .copyWith(color: Theme.of(context).colorScheme.primary),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  );
                case BlocStatus.loading:
                  return Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            'Swift Contest',
                            style: Theme.of(context)
                                .textTheme
                                .displayMedium!
                                .copyWith(color: Theme.of(context).colorScheme.primary),
                          ),
                        ),
                        SizedBox(height: 32),
                        Loader(),
                      ],
                    ),
                  );
                case BlocStatus.initial:
                case BlocStatus.success:
                  return Center(
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        'Swift Contest',
                        style: Theme.of(context)
                            .textTheme
                            .displayMedium!
                            .copyWith(color: Theme.of(context).colorScheme.primary),
                      ),
                    ),
                  );
              }
            },
          ),
        ),
      ),
    );
  }
}
