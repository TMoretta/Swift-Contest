import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:swift_contest/model/local/types/app_theme.dart';
import 'package:swift_contest/utils/router/app_router.dart';
import 'package:swift_contest/utils/themes/material_theme.dart';
import 'package:swift_contest/viewmodel/blocs/theme_bloc/theme_bloc.dart';

class App extends StatefulWidget {
  const App({super.key});

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  final AppRouter _appRouter = AppRouter();
  late final MaterialTheme _materialTheme;
  // final AppLinks _appLinks = AppLinks();
  // StreamSubscription<Uri>? _deepLinkSubscription;

  @override
  void initState() {
    super.initState();
    // Set theme
    TextTheme textTheme = Theme.of(context).textTheme;
    final TextTheme bodyTextTheme = GoogleFonts.getTextTheme('Roboto', textTheme);
    final TextTheme displayTextTheme = GoogleFonts.getTextTheme('Roboto', textTheme);
    textTheme = textTheme.copyWith(
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
    textTheme = textTheme.apply(fontSizeDelta: 1.2, fontFamilyFallback: ['sans-serif']);
    _materialTheme = MaterialTheme(textTheme: textTheme);

    // _initDeepLinks(context);
  }

  // Future<void> _initDeepLinks(BuildContext context) async {
  //   // Gestisce il link iniziale che ha aperto l'app (da terminata).
  //   final initialUri = await _appLinks.getInitialLink();
  //   if (initialUri != null) {
  //     if (context.mounted) {
  //       if (initialUri.scheme == 'https' && initialUri.host == 'www.swiftcontest.com') {
  //         Logger.info('Link iniziale ricevuto: $initialUri');
  //         context.read<DeepLinkBloc>().add(DeepLinkSetPending(initialUri));
  //       }
  //     }
  //   }
  //
  //   // Gestisce i link ricevuti mentre l'app è in primo piano.
  //   _deepLinkSubscription = _appLinks.uriLinkStream.listen((uri) {
  //     if (context.mounted) {
  //       if (uri.scheme == 'https' && uri.host == 'www.swiftcontest.com') {
  //         Logger.info('Link ricevuto con app aperta: $uri');
  //         context.read<DeepLinkBloc>().add(DeepLinkSetPending(uri));
  //         context.router.replaceAll([RootRoute(delay: 0)]);
  //       }
  //     }
  //   });
  // }

  // @override
  // void dispose() {
  //   _deepLinkSubscription?.cancel();
  //   super.dispose();
  // }

  @override
  Widget build(BuildContext context) {
    return BlocSelector<ThemeBloc, ThemeState, AppTheme>(
      selector: (state) => state.theme ?? AppTheme.system,
      builder: (context, appTheme) {
        return DecoratedBox(
          decoration: BoxDecoration(
            color: switch (appTheme) {
              AppTheme.system => (MediaQuery.of(context).platformBrightness == Brightness.light)
                  ? const Color(0xFFECECF2) // light background
                  : const Color(0xFF1F2128), // dark background
              AppTheme.light => const Color(0xFFECECF2),
              AppTheme.dark => const Color(0xFF1F2128),
            },
          ),
          child: Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: 1000),
              child: MaterialApp.router(
                routerConfig: _appRouter.config(),
                scrollBehavior: CustomScrollBehavior(),
                themeMode: ThemeMode.values.byName(appTheme.name),
                theme: _materialTheme.light(),
                darkTheme: _materialTheme.dark(),
                debugShowCheckedModeBanner: false,
                localizationsDelegates: const [
                  GlobalMaterialLocalizations.delegate,
                  GlobalWidgetsLocalizations.delegate,
                  GlobalCupertinoLocalizations.delegate,
                ],
                supportedLocales: const [
                  Locale('en'),
                  Locale('it'),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class CustomScrollBehavior extends MaterialScrollBehavior {
  @override
  Set<PointerDeviceKind> get dragDevices {
    return {
      PointerDeviceKind.touch,
      PointerDeviceKind.mouse,
    };
  }
}
