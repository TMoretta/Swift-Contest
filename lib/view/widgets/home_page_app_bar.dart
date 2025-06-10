import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:swift_contest/model/enums/contest_role.dart';
import 'package:swift_contest/utils/router/go_router.dart';
import 'package:swift_contest/utils/themes/color_scheme_x.dart';

class HomePageAppBar extends StatefulWidget implements PreferredSizeWidget {
  final ContestRole contestRole;

  const HomePageAppBar({required this.contestRole, super.key});

  @override
  State<HomePageAppBar> createState() => _HomePageAppBarState();

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

class _HomePageAppBarState extends State<HomePageAppBar> {
  @override
  Widget build(BuildContext context) {
    final contestRole = widget.contestRole;
    return AppBar(
      title: FittedBox(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          spacing: 4,
          children: [
            Text(
              switch (contestRole) {
                ContestRole.organizer => 'Organizer',
                ContestRole.participant => 'Participant',
                ContestRole.juror => 'Juror',
              },
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w800,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            TextButton(
              onPressed: () => _showSwitchRoleDialog(context: context, currentRole: contestRole),
              style: ButtonStyle(
                padding: WidgetStatePropertyAll(EdgeInsets.symmetric(horizontal: 4)),
              ),
              child: Row(
                spacing: 2,
                children: [
                  Icon(
                    Icons.swap_horiz_rounded,
                    size: 24,
                    color: Theme.of(context).colorScheme.secondary,
                  ),
                  Text(
                    'Switch role',
                    style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Theme.of(context).colorScheme.secondary),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      actions: [
        FittedBox(
          child: Row(
            children: [
              IconButton(
                onPressed: () {
                  context.pushNamed(AppRouter.settings);
                },
                icon: Icon(Icons.more_vert),
                color: Theme.of(context).colorScheme.secondary,
              ),
            ],
          ),
        ),
      ],
      shadowColor: Theme.of(context).colorScheme.black,
      surfaceTintColor: Theme.of(context).colorScheme.surface,
      elevation: 0.8,
    );
  }
}

void _showSwitchRoleDialog({required BuildContext context, required ContestRole currentRole}) {
  ContestRole selectedRole = currentRole;

  showDialog(
    context: context,
    builder: (context) {
      return StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: const Text('Switch role'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                RadioListTile<ContestRole>(
                  title: const Text('Organizer'),
                  value: ContestRole.organizer,
                  groupValue: selectedRole,
                  contentPadding: EdgeInsets.all(1),
                  shape: OutlineInputBorder(
                    borderSide: BorderSide.none,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  onChanged: (value) {
                    setState(
                      () => selectedRole = value!,
                    );
                  },
                ),
                RadioListTile<ContestRole>(
                  title: const Text('Participant'),
                  value: ContestRole.participant,
                  groupValue: selectedRole,
                  contentPadding: EdgeInsets.all(1),
                  shape: OutlineInputBorder(
                    borderSide: BorderSide.none,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  onChanged: (value) {
                    setState(
                      () => selectedRole = value!,
                    );
                  },
                ),
                RadioListTile<ContestRole>(
                  title: const Text('Juror'),
                  value: ContestRole.juror,
                  groupValue: selectedRole,
                  contentPadding: EdgeInsets.all(1),
                  shape: OutlineInputBorder(
                    borderSide: BorderSide.none,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  onChanged: (value) {
                    setState(
                      () => selectedRole = value!,
                    );
                  },
                ),
              ],
            ),
            actions: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton(
                    onPressed: () {
                      context.pop();
                    },
                    child: const Text('Cancel'),
                  ),
                  TextButton(
                    onPressed: () {
                      switch (selectedRole) {
                        case ContestRole.organizer:
                          context.replaceNamed(AppRouter.organizerHome);
                          break;
                        case ContestRole.participant:
                          context.replaceNamed(AppRouter.participantHome);
                          break;
                        case ContestRole.juror:
                          context.replaceNamed(AppRouter.jurorHome);
                          break;
                      }
                      context.pop();
                    },
                    child: const Text('Confirm'),
                  ),
                ],
              ),
            ],
          );
        },
      );
    },
  );
}
