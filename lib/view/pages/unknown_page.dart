import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:swift_contest/utils/router/app_router.gr.dart';
import 'package:swift_contest/view/widgets/custom_app_bar.dart';

@RoutePage()
class UnknownPage extends StatelessWidget {
  const UnknownPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: 'Error'),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 80, color: Theme.of(context).colorScheme.error),
              const SizedBox(height: 20),
              Text(
                '404 - Page Not Found',
                style: Theme.of(context).textTheme.headlineSmall,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),
              const Text('The page you were looking for does not exist.', textAlign: TextAlign.center),
              const SizedBox(height: 30),
              FilledButton(
                onPressed: () => context.router.replace(const RootRoute()),
                child: const Text('Go to Home'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}