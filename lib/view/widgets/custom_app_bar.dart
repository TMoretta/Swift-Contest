import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:swift_contest/utils/themes/color_scheme_x.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions;

  const CustomAppBar({required this.title, this.actions, super.key});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      // automaticallyImplyLeading: !kIsWeb,
      title: FittedBox(
        fit: BoxFit.scaleDown,
        child: Text(
          title,
          style: Theme.of(context)
              .textTheme
              .headlineSmall!
              .copyWith(color: Theme.of(context).colorScheme.primary),
        ),
      ),
      actions: actions,
      shadowColor: Theme.of(context).colorScheme.black,
      surfaceTintColor: Theme.of(context).colorScheme.surface,
      elevation: 0.8,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
