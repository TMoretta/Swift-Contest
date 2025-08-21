import 'package:auto_route/auto_route.dart';
import 'package:dartx/dartx.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:swift_contest/model/database/types/contest_role.dart';
import 'package:swift_contest/utils/router/app_router.gr.dart';
import 'package:swift_contest/view/widgets/custom_app_bar.dart';
import 'package:swift_contest/viewmodel/blocs/auth_bloc/auth_bloc.dart';

class HomePageAppBar extends StatefulWidget implements PreferredSizeWidget {
  final ContestRole contestRole;

  const HomePageAppBar({required this.contestRole, super.key});

  @override
  State<HomePageAppBar> createState() => _HomePageAppBarState();

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

class _HomePageAppBarState extends State<HomePageAppBar> {
  late final ContestRole contestRole;

  @override
  void initState() {
    super.initState();
    contestRole = widget.contestRole;
  }

  @override
  Widget build(BuildContext context) {
    return CustomAppBar(
        title: contestRole.name.capitalize(),
      actions: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextButton(
              onPressed: () => _showSwitchRoleDialog(context: context, currentRole: contestRole),
              child: Row(
                children: [
                  Icon(
                    Icons.swap_horiz_rounded,
                    size: 24,
                    color: Theme.of(context).colorScheme.secondary,
                  ),
                  SizedBox(width: 2),
                  Text(
                    'Switch',
                    style: Theme.of(context)
                        .textTheme
                        .bodyMedium!
                        .copyWith(color: Theme.of(context).colorScheme.secondary),
                  ),
                ],
              ),
            ),
            BlocBuilder<AuthBloc, AuthState>(
              builder: (context, state) {
                final messagesCount = state.messages?.where((e) => !e.isRead).length;
                return IconButton(
                  onPressed: () {
                    context.router.push(InboxRoute());
                  },
                  icon: Badge.count(
                    count: messagesCount ?? -1,
                    isLabelVisible: (messagesCount != 0),
                    backgroundColor: Theme.of(context).colorScheme.tertiary,
                    child: Icon(
                      Icons.notifications,
                      color: Theme.of(context).colorScheme.secondary,
                    ),
                  ),
                );
              },
            ),
            IconButton(
              onPressed: () {
                context.router.push(SettingsRoute());
              },
              icon: Icon(Icons.more_vert),
              color: Theme.of(context).colorScheme.secondary,
            ),
          ],
        )
      ],
    );
  }
}

void _showSwitchRoleDialog({required BuildContext context, required ContestRole currentRole}) {
  ContestRole selectedRole = currentRole;

  showDialog(
    context: context,
    builder: (dialogContext) {
      return StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: const Text('Switch role'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                RadioGroup<ContestRole>(
                  onChanged: (value) {
                    setState(() => selectedRole = value!);
                  },
                  groupValue: selectedRole,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      RadioListTile(
                        value: ContestRole.organizer,
                        title: Text('Organizer'),
                      ),
                      RadioListTile(
                        value: ContestRole.participant,
                        title: Text('Participant'),
                      ),
                      RadioListTile(
                        value: ContestRole.juror,
                        title: Text('Juror'),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  context.router.pop();
                },
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () {
                  switch (selectedRole) {
                    case ContestRole.organizer:
                      context.router.replaceAll([OrganizerHomeRoute()]);
                      break;
                    case ContestRole.participant:
                      context.router.replaceAll([ParticipantHomeRoute()]);
                      break;
                    case ContestRole.juror:
                      context.router.replaceAll([JurorHomeRoute()]);
                      break;
                  }
                  context.router.pop();
                },
                child: const Text('Switch'),
              ),
            ],
          );
        },
      );
    },
  );
}
