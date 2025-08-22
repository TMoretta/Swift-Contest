import 'package:auto_route/auto_route.dart';
import 'package:dartx/dartx.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:swift_contest/model/database/entities/profile.dart';
import 'package:swift_contest/model/database/types/contest_role.dart';
import 'package:swift_contest/model/local/types/app_theme.dart';
import 'package:swift_contest/utils/functions/now.dart';
import 'package:swift_contest/utils/router/app_router.gr.dart';
import 'package:swift_contest/utils/themes/color_scheme_x.dart';
import 'package:swift_contest/view/widgets/custom_app_bar.dart';
import 'package:swift_contest/view/widgets/overlay_loader.dart';
import 'package:swift_contest/view/widgets/privacy_policy_dialog.dart';
import 'package:swift_contest/view/widgets/show_snack_bar.dart';
import 'package:swift_contest/view/widgets/terms_of_service_dialog.dart';
import 'package:swift_contest/view/widgets/void_widget.dart';
import 'package:swift_contest/viewmodel/blocs/auth_bloc/auth_bloc.dart';
import 'package:swift_contest/viewmodel/blocs/inbox_bloc/inbox_bloc.dart';
import 'package:swift_contest/viewmodel/blocs/theme_bloc/theme_bloc.dart';
import 'package:swift_contest/viewmodel/types/bloc_status.dart';

@RoutePage()
class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _AuthState();
}

class _AuthState extends State<SettingsPage> {
  @override
  void dispose() {
    context.hideLoader();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        BlocListener<AuthBloc, AuthState>(
          listener: (context, state) {
            if (state.message != null) {
              showSnackBar(context: context, text: state.message!);
            }
            if (state.blocStatus.isLoading) {
              context.showLoader();
            } else {
              context.hideLoader();
            }
            if (state.blocStatus.isSuccess && state.sourceEvent is AuthSignOut) {
              context.read<InboxBloc>().add(InboxClear());
              context.router.replaceAll([RootRoute()]);
            }
          },
        ),
        BlocListener<ThemeBloc, ThemeState>(
          listener: (context, state) {
            if (state.message != null) {
              showSnackBar(context: context, text: state.message!);
            }
            if (state.status.isLoading) {
              context.showLoader();
            } else {
              context.hideLoader();
            }
          },
        ),
      ],
      child: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, state) {
          return Scaffold(
            appBar: CustomAppBar(title: 'Settings'),
            body: Builder(
              builder: (context) {
                if (!state.isInitialized) {
                  if (state.blocStatus.isFailure) {
                    return Center(
                      child: FilledButton(
                        onPressed: () => context.read<AuthBloc>().add(AuthFetch()),
                        child: Text('Retry'),
                      ),
                    );
                  }
                  return VoidWidget();
                }

                final profile = state.profile ??
                    Profile(
                      id: '',
                      fullName: '',
                      prefRole: ContestRole.organizer,
                      createdAt: now(),
                    );
                return RefreshIndicator.adaptive(
                  onRefresh: () async => context.read<AuthBloc>().add(AuthFetch()),
                  child: ListView(
                    children: [
                      //* Account option
                      ListTile(
                        onTap: () {
                          context.router.push(AccountRoute());
                        },
                        leading: Icon(
                          Icons.person,
                          size: 28,
                        ),
                        title: Text(
                          'Account',
                        ),
                        titleTextStyle: Theme.of(context).textTheme.titleMedium,
                      ),
                      //* Theme option
                      BlocBuilder<ThemeBloc, ThemeState>(
                        builder: (context, state) {
                          final theme = state.theme!;
                          return InkWell(
                            onTap: () {
                              _showEditThemeDialog(context: context, currentTheme: theme);
                            },
                            child: ListTile(
                              leading: Icon(
                                Icons.contrast,
                                size: 28,
                              ),
                              title: Text('Theme'),
                              titleTextStyle: Theme.of(context).textTheme.titleMedium,
                              subtitle: Text(theme.name.capitalize()),
                              subtitleTextStyle: Theme.of(context)
                                  .textTheme
                                  .labelMedium
                                  ?.copyWith(color: Theme.of(context).colorScheme.grey),
                            ),
                          );
                        },
                      ),
                      //* Preferred role option
                      ListTile(
                        onTap: () {
                          _showEditPrefRoleDialog(
                              context: context, currentPrefRole: profile.prefRole);
                        },
                        leading: Icon(
                          Icons.face,
                          size: 28,
                        ),
                        title: Text(
                          'Preferred role',
                        ),
                        titleTextStyle: Theme.of(context).textTheme.titleMedium,
                        subtitle: Text(profile.prefRole.name.capitalize()),
                        subtitleTextStyle: Theme.of(context)
                            .textTheme
                            .labelMedium
                            ?.copyWith(color: Theme.of(context).colorScheme.grey),
                      ),
                      //* Legal Documents
                      ListTile(
                        onTap: () {
                          showTermsOfServiceDialog(context);
                        },
                        leading: Icon(
                          Icons.gavel_outlined,
                          size: 28,
                        ),
                        title: Text(
                          'Terms of Service',
                        ),
                        titleTextStyle: Theme.of(context).textTheme.titleMedium,
                      ),
                      ListTile(
                        onTap: () {
                          showPrivacyPolicyDialog(context);
                        },
                        leading: Icon(
                          Icons.privacy_tip_outlined,
                          size: 28,
                        ),
                        title: Text('Privacy Policy'),
                        titleTextStyle: Theme.of(context).textTheme.titleMedium,
                      ),
                      //* Logout option
                      ListTile(
                        onTap: () => context.read<AuthBloc>().add(AuthSignOut()),
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
                    ],
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}

void _showEditThemeDialog({
  required BuildContext context,
  required AppTheme currentTheme,
}) {
  final themeBloc = context.read<ThemeBloc>();

  showDialog(
    context: context,
    builder: (context) {
      AppTheme selectedTheme = currentTheme;
      return StatefulBuilder(
        builder: (context, setState) {
          return BlocProvider.value(
            value: themeBloc,
            child: BlocConsumer<ThemeBloc, ThemeState>(
              listener: (context, state) {
                if (state.status.isSuccess && state.sourceEvent is SaveTheme) {
                  showSnackBar(context: context, text: 'Theme changed successfully');
                  context.router.pop();
                }
              },
              builder: (context, state) {
                return AlertDialog(
                  title: Text('Theme'),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      RadioGroup<AppTheme>(
                        onChanged: (value) {
                          setState(() => selectedTheme = value!);
                        },
                        groupValue: selectedTheme,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            RadioListTile(
                              value: AppTheme.system,
                              title: Text('System'),
                            ),
                            RadioListTile(
                              value: AppTheme.light,
                              title: Text('Light'),
                            ),
                            RadioListTile(
                              value: AppTheme.dark,
                              title: Text('Dark'),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => context.router.pop(),
                      child: Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: () {
                        context.read<ThemeBloc>().add(SaveTheme(theme: selectedTheme));
                      },
                      child: Text('Proceed'),
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

void _showEditPrefRoleDialog({
  required BuildContext context,
  required ContestRole currentPrefRole,
}) {
  final authBloc = context.read<AuthBloc>();

  showDialog(
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
                  context.router.pop();
                }
              },
              builder: (context, state) {
                return AlertDialog(
                  title: Text('Preferred role'),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
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
                      onPressed: () => context.router.pop(),
                      child: Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: () {
                        context.read<AuthBloc>().add(AuthEditPrefRole(prefRole: selectedRole));
                      },
                      child: Text('Proceed'),
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
