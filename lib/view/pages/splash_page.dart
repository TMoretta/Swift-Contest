import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:swift_contest/utils/router/go_router.dart';
import 'package:swift_contest/view/widgets/loader.dart';
import 'package:swift_contest/viewmodel/blocs/app_auth_bloc/app_auth_bloc.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  @override
  void initState() {
    super.initState();
    context.read<AppAuthBloc>().add(AppAuthSplashPageDelay());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SizedBox(
              width: constraints.maxWidth,
              height: constraints.maxHeight,
              child: BlocConsumer<AppAuthBloc, AppAuthState>(
                listener: (context, state) {
                  if (state is AppAuthAuthenticated) {
                    context.goNamed(AppRouter.home);
                  }
                  if (state is AppAuthUnauthenticated) {
                    context.goNamed(AppRouter.signIn);
                  }
                },
                builder: (context, state) {
                  return Loader();
                },
              ),
            );
          },
        ),
      ),
    );
  }
}
