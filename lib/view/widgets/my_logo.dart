import 'package:flutter/material.dart';

class MyLogo extends StatelessWidget {
  const MyLogo({super.key});

  @override
  Widget build(BuildContext context) {
    return FittedBox(
      fit: BoxFit.scaleDown,
      child: Text(
        'Swift Contest',
        style: Theme.of(context)
            .textTheme
            .displayMedium!
            .copyWith(color: Theme.of(context).colorScheme.primary),
      ),
    );
  }
}
