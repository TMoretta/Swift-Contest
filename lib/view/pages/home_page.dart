// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:go_router/go_router.dart';
// import 'package:swift_contest/model/enums/contest_role.dart';
// import 'package:swift_contest/utils/functions/show_snack_bar.dart';
// import 'package:swift_contest/utils/router/go_router.dart';
// import 'package:swift_contest/view/widgets/loader.dart';
// import 'package:swift_contest/viewmodel/blocs/global_blocs/auth_bloc/auth_bloc.dart';
// import 'package:swift_contest/viewmodel/enums/bloc_status.dart';
// import 'package:swift_contest/viewmodel/blocs/global_blocs/contest_role_bloc/contest_role_bloc.dart';
//
// class HomePage extends StatefulWidget {
//   const HomePage({super.key});
//
//   @override
//   State<HomePage> createState() => _HomePageState();
// }
//
// class _HomePageState extends State<HomePage> {
//   late ContestRole prefContestRole;
//
//   @override
//   void didChangeDependencies() {
//     super.didChangeDependencies();
//     prefContestRole = context.read<AuthBloc>().state.profile!.prefContestRole;
//     if(context.read<ContestRoleBloc>().state.status == BlocStatus.initial) {
//       context.read<ContestRoleBloc>().add(ContestRoleChangeRole(contestRole: prefContestRole));
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return BlocConsumer<ContestRoleBloc, ContestRoleState>(
//       listener: (context, state) {
//         if (state.status.isSuccess) {
//           final contestRole = state.contestRole!;
//           switch (contestRole) {
//             case ContestRole.organizer:
//               context.goNamed(AppRouter.organizerHome);
//               break;
//             case ContestRole.participant:
//               context.goNamed(AppRouter.participantHome);
//               break;
//             case ContestRole.juror:
//               context.goNamed(AppRouter.jurorHome);
//               break;
//           }
//         }
//         if (state.status.isFailure) {
//           showSnackBar(context: context, text: state.message!);
//           context.goNamed(AppRouter.organizerHome);
//         }
//       },
//       builder: (context, state) {
//         if (state.status.isLoading) {
//           return Loader();
//         }
//         return Container();
//       },
//     );
//   }
// }
