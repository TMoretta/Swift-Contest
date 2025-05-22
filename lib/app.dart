import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:swift_contest/model/enums/app_theme.dart';
import 'package:swift_contest/utils/router/go_router.dart';
import 'package:swift_contest/utils/themes/material_theme.dart';
import 'package:swift_contest/viewmodel/blocs/global_blocs/auth_bloc/auth_bloc.dart';


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
    goRouter = getGoRouter(authBloc: context.read<AuthBloc>());
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc,AuthState>(
      builder:(context, state) {
        late ThemeMode themeMode;
        switch(state.profile?.prefTheme) {
          case null:
            themeMode = ThemeMode.system;
            break;
          case AppTheme.system:
            themeMode = ThemeMode.system;
            break;
          case AppTheme.light:
            themeMode = ThemeMode.light;
            break;
          case AppTheme.dark:
            themeMode = ThemeMode.dark;
            break;
        }
        return MaterialApp.router(
          themeMode: themeMode,
          theme: MaterialTheme.light(),
          darkTheme: MaterialTheme.dark(),
          highContrastTheme: MaterialTheme.lightHighContrast(),
          highContrastDarkTheme: MaterialTheme.darkHighContrast(),
          debugShowCheckedModeBanner: false,
          routerConfig: goRouter,
        );
      }
    );
  }
}
