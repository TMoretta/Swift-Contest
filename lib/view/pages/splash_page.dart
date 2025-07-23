import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:swift_contest/model/enums/contest_role.dart';
import 'package:swift_contest/utils/router/app_router.gr.dart';
import 'package:swift_contest/view/widgets/list_view_with_central_widget.dart';
import 'package:swift_contest/view/widgets/my_logo.dart';
import 'package:swift_contest/view/widgets/show_snack_bar.dart';
import 'package:swift_contest/viewmodel/blocs/auth_bloc/auth_bloc.dart';
import 'package:swift_contest/viewmodel/enums/auth_status.dart';
import 'package:swift_contest/viewmodel/enums/bloc_status.dart';

@RoutePage()
class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    context.read<AuthBloc>().add(AuthFetch(delay: 1));
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthBloc, AuthState>(
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
                context.router.replace(OrganizerHomeRoute());
                break;
              case ContestRole.participant:
                context.router.replace(ParticipantHomeRoute());
                break;
              case ContestRole.juror:
                context.router.replace(JurorHomeRoute());
                break;
            }
          } else if (state.authStatus.isUnauthenticated) {
            //* If success and not authenticated go to sign in page
            context.router.replace(SignInRoute());
          }
        }
      },
      builder: (context, state) {
        return Scaffold(
          body: SafeArea(
            child: Builder(
              builder: (context) {
                switch (state.blocStatus) {
                  case BlocStatus.failure:
                    return RefreshIndicator(
                      onRefresh: () async => context.read<AuthBloc>().add(AuthFetch()),
                      child: LayoutBuilder(
                        builder: (context, constraints) {
                          return ListViewWithCentralWidget(
                            centralWidget: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                MyLogo(),
                                SizedBox(height: 32),
                                Text(
                                  'An error occurred',
                                  style: Theme.of(context).textTheme.bodyLarge,
                                )
                              ],
                            ),
                          );
                        },
                      ),
                    );
                  case BlocStatus.initial:
                  case BlocStatus.loading:
                  case BlocStatus.success:
                    return Center(
                      child: MyLogo(),
                    );
                }
              },
            ),
          ),
        );
      },
    );
  }
}
