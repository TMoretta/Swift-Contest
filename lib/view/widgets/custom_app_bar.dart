import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:swift_contest/utils/themes/color_scheme_extension.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;

  const CustomAppBar({required this.title, super.key});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: FittedBox(
        child: Text(
          title,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w800,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
      ),
      actions: [
        // IconButton(
        //   onPressed: () {
        //     context.go('/notifications');
        //   },
        //   icon: Icon(Icons.notifications),
        //   color: Theme.of(context).colorScheme.secondary,
        // ),
        IconButton(
          onPressed: () {
            context.go('/settings');
          },
          icon: Icon(Icons.more_vert),
          color: Theme.of(context).colorScheme.secondary,
        ),
      ],
      shadowColor: Theme.of(context).colorScheme.black,
      surfaceTintColor: Theme.of(context).colorScheme.surface,
      elevation: 0.8,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
