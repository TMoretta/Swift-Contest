import 'package:flutter/material.dart';
import 'package:swift_contest/utils/router/go_router.dart';
import 'package:swift_contest/utils/themes/material_theme.dart';


class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
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
