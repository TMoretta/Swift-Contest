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
    //   displayLarge: displayTextTheme.displayLarge?.copyWith(fontSize: 57),
    //   displayMedium: displayTextTheme.displayMedium?.copyWith(fontSize: 45),
    //   displaySmall: displayTextTheme.displaySmall?.copyWith(fontSize: 36),
    //   headlineLarge: displayTextTheme.headlineLarge?.copyWith(fontSize: 32),
    //   headlineMedium: displayTextTheme.headlineMedium?.copyWith(fontSize: 28),
    //   headlineSmall: displayTextTheme.headlineSmall?.copyWith(fontSize: 24),
    //   titleLarge: displayTextTheme.titleLarge?.copyWith(fontSize: 22),
    //   titleMedium: displayTextTheme.titleMedium?.copyWith(fontSize: 18),
    //   titleSmall: displayTextTheme.titleSmall?.copyWith(fontSize: 16),
    //   bodyLarge: bodyTextTheme.bodyLarge?.copyWith(fontSize: 18),
    //   bodyMedium: bodyTextTheme.bodyMedium?.copyWith(fontSize: 16),
    //   bodySmall: bodyTextTheme.bodySmall?.copyWith(fontSize: 14),
    //   labelLarge: bodyTextTheme.labelLarge?.copyWith(fontSize: 14),
    //   labelMedium: bodyTextTheme.labelMedium?.copyWith(fontSize: 12),
    //   labelSmall: bodyTextTheme.labelSmall?.copyWith(fontSize: 11),
    // );

    final materialTheme = MaterialTheme(textTheme: textTheme);
    return BlocBuilder<AuthBloc, AuthState>(
      //* Rebuild only when the pref theme changes
      buildWhen: (previous, current) => current.profile?.prefTheme != previous.profile?.prefTheme,
      builder: (context, state) {
        //* Change dynamically the theme mode based on user pref theme
        final appTheme = context.read<AuthBloc>().state.profile?.prefTheme ?? AppTheme.system;
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
