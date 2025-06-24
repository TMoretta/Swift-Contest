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
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state.message != null) {
          showSnackBar(context: context, text: state.message!);
        }
        if (state.blocStatus.isSuccess && state.sourceEvent is AuthSignOut) {
          context.goNamed(AppRouter.root);
        }
      },
      child: Scaffold(
        appBar: CustomAppBar(title: 'Settings'),
        body: BlocBuilder<AuthBloc, AuthState>(
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
                    InkWell(
                      onTap: () {
                        context.pushNamed(AppRouter.account);
                      },
                      child: ListTile(
                        leading: Icon(
                          Icons.person,
                          size: 28,
                        ),
                        title: Text(
                          'Account',
                        ),
                        titleTextStyle: Theme.of(context).textTheme.titleMedium,
                        subtitle: Text(
                          'Full name',
                        ),
                        subtitleTextStyle: Theme.of(context)
                            .textTheme
                            .labelMedium
                            ?.copyWith(color: Theme.of(context).colorScheme.grey),
                      ),
                    ),
                    //* Theme option
                    InkWell(
                      onTap: () async {
                        final bool? res = await _showEditThemeDialog(
                            context: context, currentTheme: profile.prefTheme);
                        if (res == true) {
                          if (context.mounted) {
                            context.read<AuthBloc>().add(AuthFetchProfile());
                          }
                        }
                      },
                      child: ListTile(
                        leading: Icon(
                          Icons.contrast,
                          size: 28,
                        ),
                        title: Text(
                          'Theme',
                        ),
                        titleTextStyle: Theme.of(context).textTheme.titleMedium,
                        subtitle: Text(
                          '${profile.prefTheme.name[0].toUpperCase()}${profile.prefTheme.name.substring(1).toLowerCase()}',
                        ),
                        subtitleTextStyle: Theme.of(context)
                            .textTheme
                            .labelMedium
                            ?.copyWith(color: Theme.of(context).colorScheme.grey),
                      ),
                    ),
                    //* Preferred role option
                    InkWell(
                      onTap: () async {
                        final bool? res = await _showEditPrefRoleDialog(
                            context: context, currentPrefRole: profile.prefRole);
                        if (res == true) {
                          if (context.mounted) {
                            context.read<AuthBloc>().add(AuthFetchProfile());
                          }
                        }
                      },
                      child: ListTile(
                        leading: Icon(
                          Icons.face,
                          size: 28,
                        ),
                        title: Text(
                          'Preferred role',
                        ),
                        titleTextStyle: Theme.of(context).textTheme.titleMedium,
                        subtitle: Text(
                          '${profile.prefRole.name[0].toUpperCase()}'
                          '${profile.prefRole.name.substring(1).toLowerCase()}',
                        ),
                        subtitleTextStyle: Theme.of(context)
                            .textTheme
                            .labelMedium
                            ?.copyWith(color: Theme.of(context).colorScheme.grey),
                      ),
                    ),
                    //* Logout option
                    InkWell(
                      onTap: () async {
                        context.read<AuthBloc>().add(AuthSignOut());
                      },
                      child: ListTile(
                        leading: Icon(
                          Icons.logout,
                          size: 28,
                          color: Theme.of(context).colorScheme.error,
                        ),
                        iconColor: Theme.of(context).colorScheme.error,
                        title: Text(
                          'Logout',
                        ),
                        titleTextStyle: Theme.of(context)
                            .textTheme
                            .titleMedium
                            ?.copyWith(color: Theme.of(context).colorScheme.error),
                      ),
                    ),
                  ],
                );
            }
          },
        ),
      ),
    );
  }
}

Future<bool?> _showEditThemeDialog({
  required BuildContext context,
  required AppTheme currentTheme,
})async {
  final authBloc = context.read<AuthBloc>();

  return  await showDialog<bool?>(
    context: context,
    builder: (context) {
      AppTheme selectedTheme = currentTheme;
      return StatefulBuilder(
        builder: (context, setState) {
          return BlocProvider.value(
            value: authBloc,
            child: BlocConsumer<AuthBloc, AuthState>(
              listener: (context, state) {
                if (state.blocStatus.isSuccess && state.sourceEvent is AuthEditPrefTheme) {
                  showSnackBar(context: context, text: 'Theme changed successfully');
                  context.pop(true);
                }
              },
              builder: (context, state) {
                return AlertDialog(
                  title: Text('Theme'),
                  content: (state.blocStatus.isLoading)
                      ? Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Loader(),
                          ],
                        )
                      : Column(
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
                    TextButton(
                      onPressed: (!state.blocStatus.isLoading) ? () => context.pop() : null,
                      child: Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: (!state.blocStatus.isLoading)
                          ? () {
                              context
                                  .read<AuthBloc>()
                                  .add(AuthEditPrefTheme(prefTheme: selectedTheme));
                            }
                          : null,
                      child: Text('Ok'),
                    ),
                  ],
                );
              },
            ),
          );
        },
      );
    },
  );
}

Future<bool?> _showEditPrefRoleDialog(
    {required BuildContext context, required ContestRole currentPrefRole,}) async {
  final authBloc = context.read<AuthBloc>();

  return await showDialog<bool?>(
    context: context,
    builder: (context) {
      ContestRole selectedRole = currentPrefRole;
      return StatefulBuilder(
        builder: (context, setState) {
          return BlocProvider.value(
            value: authBloc,
            child: BlocConsumer<AuthBloc, AuthState>(
              listener: (context, state) {
                if (state.blocStatus.isSuccess && state.sourceEvent is AuthEditPrefRole) {
                  showSnackBar(context: context, text: 'Preferred role changed successfully');
                  context.pop(true);
                }
              },
              builder: (context, state) {
                return AlertDialog(
                  title: Text('Theme'),
                  content: (state.blocStatus.isLoading)
                      ? Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Loader(),
                          ],
                        )
                      : Column(
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
                    TextButton(
                      onPressed: (!state.blocStatus.isLoading) ? () => context.pop() : null,
                      child: Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: (!state.blocStatus.isLoading)
                          ? () {
                              context
                                  .read<AuthBloc>()
                                  .add(AuthEditPrefRole(prefRole: selectedRole));
                            }
                          : null,
                      child: Text('Ok'),
                    ),
                  ],
                );
              },
            ),
          );
        },
      );
    },
  );
}
