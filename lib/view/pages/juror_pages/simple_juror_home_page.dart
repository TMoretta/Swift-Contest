// import 'package:auto_route/auto_route.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:swift_contest/viewmodel/blocs/pages_blocs/simple_juror_home_page_bloc/simple_juror_home_page_bloc.dart';
//
// class SimpleJurorHomePage extends StatefulWidget implements AutoRouteWrapper {
//   const SimpleJurorHomePage({super.key});
//
//   @override
//   State<SimpleJurorHomePage> createState() => _SimpleJurorHomePageState();
//
//   @override
//   Widget wrappedRoute(BuildContext context) {
//     return BlocProvider<SimpleJurorHomePageBloc>(
//       create: (context) => SimpleJurorHomePageBloc(jurorRepository: context.read(),),
//       child: this,
//     );
//   }
// }
//
// class _SimpleJurorHomePageState extends State<SimpleJurorHomePage> {
//   @override
//   Widget build(BuildContext context) {
//     return const Placeholder();
//   }
// }
