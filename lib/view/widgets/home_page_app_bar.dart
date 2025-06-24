import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:swift_contest/model/enums/contest_role.dart';
import 'package:swift_contest/utils/router/go_router.dart';
import 'package:swift_contest/utils/themes/color_scheme_x.dart';
import 'package:swift_contest/viewmodel/blocs/auth_bloc/auth_bloc.dart';
import 'package:swift_contest/viewmodel/enums/bloc_status.dart';

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
        fit: BoxFit.scaleDown,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Text(
              switch (contestRole) {
                ContestRole.organizer => 'Organizer',
                ContestRole.participant => 'Participant',
                ContestRole.juror => 'Juror',
              },
              style: Theme.of(context)
                  .textTheme
                  .headlineSmall!
                  .copyWith(color: Theme.of(context).colorScheme.primary),
            ),
            SizedBox(width: 4),
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
                    'Switch role',
                    style: Theme.of(context)
                        .textTheme
                        .bodyMedium!
                        .copyWith(color: Theme.of(context).colorScheme.secondary),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      actions: [
        BlocBuilder<AuthBloc, AuthState>(builder: (context, state) {
          switch (state.blocStatus) {
            case BlocStatus.initial:
            case BlocStatus.loading:
              return IconButton(
                onPressed: null,
                icon: Icon(Icons.notifications),
              );
            case BlocStatus.failure:
              if (state.sourceEvent is AuthInit) {
                return IconButton(
                  onPressed: null,
                  icon: Icon(Icons.notifications),
                );
              } else {
                continue successCase;
              }
            successCase:
            case BlocStatus.success:
              final messagesCount = state.messages!.where((e) => !e.isRead).length;
              return IconButton(
                onPressed: () {
                  context.pushNamed(AppRouter.inbox);
                },
                icon: Badge.count(
                  count: messagesCount,
                  isLabelVisible: (messagesCount != 0),
                  backgroundColor: Theme.of(context).colorScheme.error,
                  child: Icon(Icons.notifications),
                ),
              );
          }
        }),
        IconButton(
          onPressed: () {
            context.pushNamed(AppRouter.settings);
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
                  onChanged: (value) {
                    setState(
                      () => selectedRole = value!,
                    );
                  },
                ),
              ],
            ),
            actions: [
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
          );
        },
      );
    },
  );
}
