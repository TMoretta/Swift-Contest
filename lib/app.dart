import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
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

    final TextTheme baseTextTheme = Theme.of(context).textTheme;
    final TextTheme bodyTextTheme = GoogleFonts.getTextTheme('Roboto', baseTextTheme);
    final TextTheme displayTextTheme = GoogleFonts.getTextTheme('Roboto', baseTextTheme);
    final TextTheme textTheme = baseTextTheme.copyWith(
      displayLarge: displayTextTheme.displayLarge,
      displayMedium: displayTextTheme.displayMedium,
      displaySmall: displayTextTheme.displaySmall,
      headlineLarge: displayTextTheme.headlineLarge,
      headlineMedium: displayTextTheme.headlineMedium,
      headlineSmall: displayTextTheme.headlineSmall,
      titleLarge: displayTextTheme.titleLarge,
      titleMedium: displayTextTheme.titleMedium,
      titleSmall: displayTextTheme.titleSmall,
      bodyLarge: bodyTextTheme.bodyLarge,
      bodyMedium: bodyTextTheme.bodyMedium,
      bodySmall: bodyTextTheme.bodySmall,
      labelLarge: bodyTextTheme.labelLarge,
      labelMedium: bodyTextTheme.labelMedium,
      labelSmall: bodyTextTheme.labelSmall,
    );
    // final TextTheme textTheme = baseTextTheme.copyWith(
    //   displayLarge: displayTextTheme.displayLarge?.copyWith(fontSize: 46, fontWeight: FontWeight.bold),
    //   displayMedium: displayTextTheme.displayMedium?.copyWith(fontSize: 40, fontWeight: FontWeight.bold),
    //   displaySmall: displayTextTheme.displaySmall?.copyWith(fontSize: 34, fontWeight: FontWeight.bold),
    //   headlineLarge: displayTextTheme.headlineLarge?.copyWith(fontSize: 30, fontWeight: FontWeight.w600),
    //   headlineMedium: displayTextTheme.headlineMedium?.copyWith(fontSize: 26, fontWeight: FontWeight.w600),
    //   headlineSmall: displayTextTheme.headlineSmall?.copyWith(fontSize: 24, fontWeight: FontWeight.w600),
    //   titleLarge: displayTextTheme.titleLarge?.copyWith(fontSize: 22, fontWeight: FontWeight.w600),
    //   titleMedium: displayTextTheme.titleMedium?.copyWith(fontSize: 20, fontWeight: FontWeight.w600),
    //   titleSmall: displayTextTheme.titleSmall?.copyWith(fontSize: 18, fontWeight: FontWeight.w600),
    //   bodyLarge: bodyTextTheme.bodyLarge?.copyWith(fontSize: 18, fontWeight: FontWeight.normal),
    //   bodyMedium: bodyTextTheme.bodyMedium?.copyWith(fontSize: 16, fontWeight: FontWeight.normal),
    //   bodySmall: bodyTextTheme.bodySmall?.copyWith(fontSize: 14, fontWeight: FontWeight.normal),
    //   labelLarge: bodyTextTheme.labelLarge?.copyWith(fontSize: 14, fontWeight: FontWeight.w500),
    //   labelMedium: bodyTextTheme.labelMedium?.copyWith(fontSize: 12, fontWeight: FontWeight.w500),
    //   labelSmall: bodyTextTheme.labelSmall?.copyWith(fontSize: 11, fontWeight: FontWeight.w500),
    // );

    final materialTheme = MaterialTheme(textTheme: textTheme);
    return BlocBuilder<AuthBloc, AuthState>(
      //* Rebuild only when the pref theme changes
      buildWhen: (previous, current) => current.authBundle?.profile.prefTheme != previous.authBundle?.profile.prefTheme,
      builder: (context, state) {
        //* Change dynamically the theme mode based on user pref theme
        final appTheme = context.read<AuthBloc>().state.authBundle?.profile.prefTheme ?? AppTheme.system;
        themeMode = ThemeMode.values.byName(appTheme.name);
        return MaterialApp.router(
          themeMode: themeMode,
          theme: materialTheme.light(),
          darkTheme: materialTheme.dark(),
          // highContrastTheme: materialTheme.lightHighContrast(),
          // highContrastDarkTheme: materialTheme.darkHighContrast(),
          debugShowCheckedModeBanner: false,
          routerConfig: goRouter,
        );
      },
    );
  }
}
