import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:swift_contest/model/database/types/contest_role.dart';
import 'package:swift_contest/utils/router/app_router.gr.dart';
import 'package:swift_contest/view/widgets/show_snack_bar.dart';
import 'package:swift_contest/view/widgets/void_widget.dart';
import 'package:swift_contest/viewmodel/blocs/auth_bloc/auth_bloc.dart';
import 'package:swift_contest/viewmodel/types/auth_status.dart';
import 'package:swift_contest/viewmodel/types/bloc_status.dart';

@RoutePage()
class RootPage extends StatefulWidget {
  const RootPage({super.key});

  @override
  State<RootPage> createState() => _RootPageState();
}

class _RootPageState extends State<RootPage> {
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    context.read<AuthBloc>().add(AuthFetch());
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthBloc, AuthState>(
      listener: (context, state) {
        //* Show a message if there is one
        if (state.blocStatus.isSuccess || state.blocStatus.isFailure) {
          FlutterNativeSplash.remove();
        }
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
                if (state.blocStatus.isFailure) {
                  return Center(
                    child: FilledButton(
                      onPressed: () async => context.read<AuthBloc>().add(AuthFetch()),
                      child: Text('Retry'),
                    ),
                  );
                }
                return VoidWidget();
              },
            ),
          ),
        );
      },
    );
    // return MultiBlocListener(
    //   listeners: [
    //     BlocListener<AuthBloc, AuthState>(
    //       listener: (context, state) {
    //         if (state.message != null) {
    //           showSnackBar(context: context, text: state.message!);
    //         }
    //         if (state.blocStatus.isSuccess) {
    //           if (state.authStatus.isAuthenticated) {
    //             context.read<DeepLinkBloc>().add(DeepLinkHandlePending());
    //           } else if (state.authStatus.isUnauthenticated) {
    //             //* If success and not authenticated go to sign in page
    //             context.router.replace(SignInRoute());
    //           }
    //         }
    //       },
    //     ),
    //     BlocListener<DeepLinkBloc, DeepLinkState>(
    //       listener: (context, state) {
    //         if (state.message != null) {
    //           showSnackBar(context: context, text: state.message!);
    //         }
    //         if(state.status.)
    //         if (state.status.isSuccess) {
    //           if (state.sourceEvent is DeepLinkHandleParticipantInvite) {
    //             context.router.push(ParticipantHomeRoute());
    //           }
    //
    //           final prefRole = context.read<AuthBloc>().state.profile!.prefRole;
    //           switch (prefRole) {
    //             case ContestRole.organizer:
    //               context.router.replace(OrganizerHomeRoute());
    //               break;
    //             case ContestRole.participant:
    //               context.router.replace(ParticipantHomeRoute());
    //               break;
    //             case ContestRole.juror:
    //               context.router.replace(JurorHomeRoute());
    //               break;
    //           }
    //         }
    //       },
    //     ),
    //   ],
    //   child: BlocBuilder<AuthBloc, AuthState>(
    //     builder: (context, state) {
    //       return Scaffold(
    //         body: SafeArea(
    //           child: Builder(
    //             builder: (context) {
    //               if (state.blocStatus.isFailure) {
    //                 return Center(
    //                   child: Column(
    //                     mainAxisSize: MainAxisSize.min,
    //                     children: [
    //                       MyLogo(),
    //                       SizedBox(height: 32),
    //                       FilledButton(
    //                         onPressed: () async => context.read<AuthBloc>().add(AuthFetch()),
    //                         child: Text('Retry'),
    //                       ),
    //                     ],
    //                   ),
    //                 );
    //               }
    //               return Center(
    //                 child: MyLogo(),
    //               );
    //             },
    //           ),
    //         ),
    //       );
    //     },
    //   ),
    // );
  }
}
