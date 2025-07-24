import 'package:auto_route/auto_route.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:swift_contest/utils/themes/color_scheme_x.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions;
  final void Function()? onRefresh;

  const CustomAppBar({
    required this.title,
    this.actions,
    this.onRefresh,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      leadingWidth: (kIsWeb) ? 112 : null,
      automaticallyImplyLeading: (!kIsWeb),
      leading: (kIsWeb)
          ? Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (context.router.canPop())
                  IconButton(
                    onPressed: () {
                      context.router.pop();
                    },
                    icon: Icon(Icons.arrow_back),
                  ),
                if (onRefresh != null)
                  IconButton(
                    onPressed: onRefresh,
                    icon: Icon(Icons.refresh),
                  ),

              ],
            )
          : null,
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
