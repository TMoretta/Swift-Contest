import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:swift_contest/utils/router/go_router.dart';
import 'package:swift_contest/utils/themes/material_theme.dart';
import 'package:swift_contest/viewmodel/blocs/global_blocs/auth_bloc/auth_bloc.dart';


class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    final goRouter = getGoRouter(authBloc: context.read<AuthBloc>());
    return MaterialApp.router(
      themeMode: ThemeMode.dark,
      theme: MaterialTheme.light(),
      darkTheme: MaterialTheme.dark(),
      highContrastTheme: MaterialTheme.lightHighContrast(),
      highContrastDarkTheme: MaterialTheme.darkHighContrast(),
      debugShowCheckedModeBanner: false,
      routerConfig: goRouter,
    );
  }
}
