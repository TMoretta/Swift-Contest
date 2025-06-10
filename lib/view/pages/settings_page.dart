import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:swift_contest/model/enums/app_theme.dart';
import 'package:swift_contest/model/enums/contest_role.dart';
import 'package:swift_contest/utils/functions/show_snack_bar.dart';
import 'package:swift_contest/utils/router/go_router.dart';
import 'package:swift_contest/utils/themes/color_scheme_x.dart';
import 'package:swift_contest/view/widgets/custom_app_bar.dart';
import 'package:swift_contest/view/widgets/loader.dart';
import 'package:swift_contest/viewmodel/blocs/auth_bloc/auth_bloc.dart';
import 'package:swift_contest/viewmodel/enums/bloc_status.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _AuthState();
}

class _AuthState extends State<SettingsPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: 'Settings'),
      body: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state.message != null) {
            showSnackBar(context: context, text: state.message!);
          }
          if (state.blocStatus.isSuccess && state.sourceEvent is AuthSignOut) {
            context.goNamed(AppRouter.splash);
          }
        },
        builder: (context, state) {
          switch (state.blocStatus) {
            case BlocStatus.initial:
              return SizedBox.shrink();
            case BlocStatus.loading:
              return Loader();
            case BlocStatus.failure:
            case BlocStatus.success:
              final profile = state.profile!;
              return ListView(
                children: [
                  //* Account option
                  TextButton(
                    onPressed: () {
                      context.pushNamed(AppRouter.account);
                    },
                    style: ButtonStyle(
                      shape: WidgetStatePropertyAll(LinearBorder()),
                      padding: WidgetStatePropertyAll(
                          EdgeInsets.symmetric(horizontal: 16, vertical: 16)),
                    ),
                    child: Row(
                      spacing: 12,
                      children: [
                        Icon(
                          Icons.person,
                          size: 28,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Account',
                              style: TextStyle(
                                  fontSize: 16, color: Theme.of(context).colorScheme.onSurface),
                            ),
                            Text(
                              'Full name',
                              style: TextStyle(
                                  fontSize: 12, color: Theme.of(context).colorScheme.grey8),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  //* Theme option
                  TextButton(
                    onPressed: () async {
                      final bool? res = await _showEditThemeDialog(
                          context: context,
                          currentTheme: profile.prefTheme);
                      if (res == true) {
                        if (context.mounted) {
                          context.read<AuthBloc>().add(AuthFetchProfile());
                        }
                      }
                    },
                    style: ButtonStyle(
                      shape: WidgetStatePropertyAll(LinearBorder()),
                      padding: WidgetStatePropertyAll(
                          EdgeInsets.symmetric(horizontal: 16, vertical: 16)),
                    ),
                    child: Row(
                      spacing: 12,
                      children: [
                        Icon(
                          Icons.contrast,
                          size: 28,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Theme',
                              style: TextStyle(
                                  fontSize: 16, color: Theme.of(context).colorScheme.onSurface),
                            ),
                            Text(
                              profile.prefTheme.name,
                              style: TextStyle(
                                  fontSize: 12, color: Theme.of(context).colorScheme.grey8),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  //* Preferred role option
                  TextButton(
                    onPressed: () async {
                      final bool? res = await _showEditPrefRoleDialog(
                          context: context,
                          currentPrefRole: profile.prefContestRole);
                      if (res == true) {
                        if (context.mounted) {
                          context.read<AuthBloc>().add(AuthFetchProfile());
                        }
                      }
                    },
                    style: ButtonStyle(
                      shape: WidgetStatePropertyAll(LinearBorder()),
                      padding: WidgetStatePropertyAll(
                          EdgeInsets.symmetric(horizontal: 16, vertical: 16)),
                    ),
                    child: Row(
                      spacing: 12,
                      children: [
                        Icon(
                          Icons.face,
                          size: 28,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Preferred role',
                              style: TextStyle(
                                  fontSize: 16, color: Theme.of(context).colorScheme.onSurface),
                            ),
                            Text(
                              profile.prefContestRole.name,
                              style: TextStyle(
                                  fontSize: 12, color: Theme.of(context).colorScheme.grey8),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  //* Logout option
                  TextButton(
                    onPressed: () async {
                      context.read<AuthBloc>().add(AuthSignOut());
                    },
                    style: ButtonStyle(
                      shape: WidgetStatePropertyAll(LinearBorder()),
                      padding: WidgetStatePropertyAll(
                          EdgeInsets.symmetric(horizontal: 16, vertical: 16)),
                    ),
                    child: Row(
                      spacing: 12,
                      children: [
                        Icon(
                          Icons.logout,
                          size: 28,
                          color: Theme.of(context).colorScheme.statusRed,
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Logout',
                              style: TextStyle(
                                  fontSize: 16, color: Theme.of(context).colorScheme.statusRed),
                            ),
                          ],
                        ),
                      ],
                    ),
                  )
                ],
              );
          }
        },
      ),
    );
  }
}

Future<bool?> _showEditThemeDialog({
  required BuildContext context,
  required AppTheme currentTheme,
}) {
  final authBloc = context.read<AuthBloc>();

  return showDialog<bool?>(
    context: context,
    builder: (context) {
      AppTheme selectedTheme = currentTheme;
      return StatefulBuilder(
        builder: (context, setState) {
          return BlocProvider.value(
            value: authBloc,
            child: BlocConsumer<AuthBloc, AuthState>(
              listener: (context, state) {
                if (state.message != null) {
                  showSnackBar(context: context, text: state.message!);
                }
                if (state.blocStatus.isSuccess && state.sourceEvent is AuthEditPrefTheme) {
                  showSnackBar(context: context, text: 'Theme changed successfully');
                  context.pop(true);
                }
              },
              builder: (context, state) {
                return AbsorbPointer(
                  absorbing: state.blocStatus.isLoading,
                  child: AlertDialog(
                    title: Text('Theme'),
                    content: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        RadioListTile<AppTheme>(
                          title: Text('System'),
                          groupValue: selectedTheme,
                          value: AppTheme.system,
                          onChanged: (value) {
                            setState(
                              () => selectedTheme = value!,
                            );
                          },
                        ),
                        RadioListTile<AppTheme>(
                          title: Text('Light'),
                          groupValue: selectedTheme,
                          value: AppTheme.light,
                          onChanged: (value) {
                            setState(
                              () => selectedTheme = value!,
                            );
                          },
                        ),
                        RadioListTile<AppTheme>(
                          title: Text('Dark'),
                          groupValue: selectedTheme,
                          value: AppTheme.dark,
                          onChanged: (value) {
                            setState(
                              () => selectedTheme = value!,
                            );
                          },
                        ),
                      ],
                    ),
                    actions: [
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          TextButton(
                            onPressed: () => context.pop(),
                            child: Text('Cancel'),
                          ),
                          TextButton(
                            onPressed: () {
                              final profile = context.read<AuthBloc>().state.profile!;
                              context.read<AuthBloc>().add(AuthEditPrefTheme(
                                  profile: profile, prefTheme: selectedTheme));
                            },
                            child: Text('Ok'),
                          ),
                        ],
                      )
                    ],
                  ),
                );
              },
            ),
          );
        },
      );
    },
  );
}

Future<bool?> _showEditPrefRoleDialog({required BuildContext context, required ContestRole currentPrefRole}) async {
  final authBloc = context.read<AuthBloc>();

  return showDialog<bool?>(
    context: context,
    builder: (context) {
      ContestRole selectedRole = currentPrefRole;
      return StatefulBuilder(
        builder: (context, setState) {
          return BlocProvider.value(
            value: authBloc,
            child: BlocConsumer<AuthBloc, AuthState>(
              listener: (context, state) {
                if (state.message != null) {
                  showSnackBar(context: context, text: state.message!);
                }
                if (state.blocStatus.isSuccess && state.sourceEvent is AuthEditPrefRole) {
                  showSnackBar(context: context, text: 'Preferred role changed successfully');
                  context.pop(true);
                }
              },
              builder: (context, state) {
                return AbsorbPointer(
                  absorbing: state.blocStatus.isLoading,
                  child: AlertDialog(
                    title: Text('Theme'),
                    content: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        RadioListTile<ContestRole>(
                          title: Text('Organizer'),
                          groupValue: selectedRole,
                          value: ContestRole.organizer,
                          onChanged: (value) {
                            setState(
                                  () => selectedRole = value!,
                            );
                          },
                        ),
                        RadioListTile<ContestRole>(
                          title: Text('Participant'),
                          groupValue: selectedRole,
                          value: ContestRole.participant,
                          onChanged: (value) {
                            setState(
                                  () => selectedRole = value!,
                            );
                          },
                        ),
                        RadioListTile<ContestRole>(
                          title: Text('Juror'),
                          groupValue: selectedRole,
                          value: ContestRole.juror,
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
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          TextButton(
                            onPressed: () => context.pop(),
                            child: Text('Cancel'),
                          ),
                          TextButton(
                            onPressed: () {
                              final profile = context.read<AuthBloc>().state.profile!;
                              context.read<AuthBloc>().add(AuthEditPrefRole(
                                  profile: profile, prefRole: selectedRole));
                            },
                            child: Text('Ok'),
                          ),
                        ],
                      )
                    ],
                  ),
                );
              },
            ),
          );
        },
      );
    },
  );
}
