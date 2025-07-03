import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:swift_contest/model/enums/app_theme.dart';
import 'package:swift_contest/model/enums/contest_role.dart';
import 'package:swift_contest/utils/labels/labels.dart';
import 'package:swift_contest/utils/router/go_router.dart';
import 'package:swift_contest/utils/themes/color_scheme_x.dart';
import 'package:swift_contest/view/widgets/custom_app_bar.dart';
import 'package:swift_contest/view/widgets/list_view_with_central_label.dart';
import 'package:swift_contest/view/widgets/overlay_loader.dart';
import 'package:swift_contest/view/widgets/show_snack_bar.dart';
import 'package:swift_contest/view/widgets/void_widget.dart';
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
        if(state.blocStatus.isLoading) {
          context.showLoader();
        } else {
          context.hideLoader();
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
                return VoidWidget();
              case BlocStatus.loading:
                if (state.sourceEvent is AuthInit) {
                  return VoidWidget();
                } else {
                  continue successCase;
                }
              case BlocStatus.failure:
                if (state.sourceEvent is AuthInit) {
                  return RefreshIndicator.adaptive(
                    onRefresh: () async => context.read<AuthBloc>().add(AuthInit(delay: 0)),
                    child: ListViewWithCentralLabel(label: Labels.anErrorOccurred),
                  );
                } else {
                  continue successCase;
                }
              successCase:
              case BlocStatus.success:
                final profile = state.profile!;
                return RefreshIndicator.adaptive(
                  onRefresh: () async => context.read<AuthBloc>().add(AuthRefresh()),
                  child: ListView(
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
                        onTap: () {
                          _showEditThemeDialog(
                              context: context, currentTheme: profile.prefTheme);
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
                        onTap: () {
                          _showEditPrefRoleDialog(
                              context: context, currentPrefRole: profile.prefRole);
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
                        onTap: () {
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
                  ),
                );
            }
          },
        ),
      ),
    );
  }
}

void _showEditThemeDialog({
  required BuildContext context,
  required AppTheme currentTheme,
}) {
  final authBloc = context.read<AuthBloc>();

  showDialog<bool?>(
    context: context,
    builder: (context) {
      AppTheme selectedTheme = currentTheme;
      return StatefulBuilder(
        builder: (context, setState) {
          return BlocProvider.value(
            value: authBloc,
            child: BlocListener<AuthBloc, AuthState>(
              listener: (context, state) {
                if (state.blocStatus.isSuccess && state.sourceEvent is AuthEditPrefTheme) {
                  showSnackBar(context: context, text: 'Theme changed successfully');
                  authBloc.add(AuthFetchProfile());
                  context.pop();
                }
              },
              child: AlertDialog(
                title: Text('Theme'),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
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
                    onPressed: () => context.pop(),
                    child: Text('Cancel'),
                  ),
                  TextButton(
                    onPressed: () {
                      authBloc.add(AuthEditPrefTheme(prefTheme: selectedTheme));
                    },
                    child: Text('Proceed'),
                  ),
                ],
              ),
            ),
          );
        },
      );
    },
  );
}

void _showEditPrefRoleDialog({
  required BuildContext context,
  required ContestRole currentPrefRole,
}) {
  final authBloc = context.read<AuthBloc>();

  showDialog<bool?>(
    context: context,
    builder: (context) {
      ContestRole selectedRole = currentPrefRole;
      return StatefulBuilder(
        builder: (context, setState) {
          return BlocProvider.value(
            value: authBloc,
            child: BlocListener<AuthBloc, AuthState>(
              listener: (context, state) {
                if (state.blocStatus.isSuccess && state.sourceEvent is AuthEditPrefRole) {
                  showSnackBar(context: context, text: 'Preferred role changed successfully');
                  authBloc.add(AuthFetchProfile());
                  context.pop();
                }
              },
              child: AlertDialog(
                title: Text('Preferred role'),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
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
                    onPressed: () => context.pop(),
                    child: Text('Cancel'),
                  ),
                  TextButton(
                    onPressed: () {
                      authBloc.add(AuthEditPrefRole(prefRole: selectedRole));
                    },
                    child: Text('Proceed'),
                  ),
                ],
              ),
            ),
          );
        },
      );
    },
  );
}
