import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:swift_contest/model/enums/app_theme.dart';
import 'package:swift_contest/utils/router/go_router.dart';
import 'package:swift_contest/utils/themes/material_theme.dart';

import 'viewmodel/blocs/auth_bloc/auth_bloc.dart';

class App extends StatefulWidget {
  const App({super.key});

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  late GoRouter goRouter;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    //* Get goRouter instance and passing AuthBloc to allow redirect base on auth state
    goRouter = getGoRouter(authBloc: context.read<AuthBloc>());
  }

  @override
  Widget build(BuildContext context) {
    late ThemeMode themeMode;
    return BlocBuilder<AuthBloc, AuthState>(
      //* Rebuild only when the pref theme changes
      buildWhen: (previous, current) => current.profile?.prefTheme != previous.profile?.prefTheme,
      builder: (context, state) {
        //* Change dynamically the theme mode based on user pref theme
        final appTheme = context.read<AuthBloc>().state.profile?.prefTheme ?? AppTheme.system;
        themeMode = ThemeMode.values.byName(appTheme.name);
        return MaterialApp.router(
          themeMode: themeMode,
          theme: MaterialTheme.light(),
          darkTheme: MaterialTheme.dark(),
          highContrastTheme: MaterialTheme.lightHighContrast(),
          highContrastDarkTheme: MaterialTheme.darkHighContrast(),
          debugShowCheckedModeBanner: false,
          routerConfig: goRouter,
        );
      },
    );
  }
}
