import 'package:auto_route/auto_route.dart';
import 'package:dartx/dartx.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:swift_contest/model/local/types/app_theme.dart';
import 'package:swift_contest/utils/router/app_router.gr.dart';
import 'package:swift_contest/utils/themes/color_scheme_x.dart';
import 'package:swift_contest/utils/validators/validators.dart';
import 'package:swift_contest/view/widgets/custom_app_bar.dart';
import 'package:swift_contest/view/widgets/custom_text_form_field.dart';
import 'package:swift_contest/view/widgets/overlay_loader.dart';
import 'package:swift_contest/view/widgets/privacy_policy_dialog.dart';
import 'package:swift_contest/view/widgets/show_snack_bar.dart';
import 'package:swift_contest/view/widgets/terms_of_service_dialog.dart';
import 'package:swift_contest/viewmodel/blocs/auth_bloc/auth_bloc.dart';
import 'package:swift_contest/viewmodel/blocs/pages_blocs/simple_juror_home_page_bloc/simple_juror_home_page_bloc.dart';
import 'package:swift_contest/viewmodel/blocs/theme_bloc/theme_bloc.dart';
import 'package:swift_contest/viewmodel/types/bloc_status.dart';

@RoutePage()
class SimpleJurorHomePage extends StatefulWidget implements AutoRouteWrapper {
  const SimpleJurorHomePage({super.key});

  @override
  State<SimpleJurorHomePage> createState() => _SimpleJurorHomePageState();

  @override
  Widget wrappedRoute(BuildContext context) {
    return BlocProvider<SimpleJurorHomePageBloc>(
      create: (context) => SimpleJurorHomePageBloc(
        authRepository: context.read(),
        jurorRepository: context.read(),
      ),
      child: this,
    );
  }
}

class _SimpleJurorHomePageState extends State<SimpleJurorHomePage> {
  @override
  Widget build(BuildContext context) {
    return BlocListener<SimpleJurorHomePageBloc, SimpleJurorHomePageState>(
      listener: (context, state) {
        if (state.message != null) {
          showSnackBar(context: context, text: state.message!);
        }
        if (state.status.isLoading) {
          context.showLoader();
        } else {
          context.hideLoader();
        }
        if (state.status.isSuccess && state.sourceEvent is SimpleJurorHomePageSignOut) {
          context.read<ThemeBloc>().add(ClearTheme());
          context.router.replaceAll([const RootRoute()]);
        }
      },
      child: Scaffold(
        appBar: const CustomAppBar(title: 'Simple Juror'),
        body: Padding(
          padding: const EdgeInsets.only(top: 16, left:16, right: 16),
          child: ListView(
            children: [
              Text('Actions', style: Theme.of(context).textTheme.titleMedium,),
              ListTile(
                onTap: () => context.router.push(const JurorVotingQrScannerRoute()),
                leading: const Icon(
                  Icons.qr_code_2,
                  size: 28,
                ),
                title: const Text('Scan jury QR token'),
              ),
              ListTile(
                onTap: () => _showInsertJuryTokenDialog(context),
                leading: const Icon(
                  Icons.abc,
                  size: 28,
                ),
                title: const Text('Insert jury token manually'),
              ),
              const SizedBox(height: 16),
              Text(
                'Settings',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              BlocBuilder<AuthBloc, AuthState>(
                  builder: (context, state) {
                    return ListTile(
                      onTap: () {},
                      title: Text(
                        state.profile?.fullName ?? 'Unknown',
                      ),
                      leading: const Icon(
                        Icons.person,
                        size: 28,
                      ),
                    );
                  }
              ),
              BlocConsumer<ThemeBloc, ThemeState>(
                listener: (context, state) {
                  if(state.message!=null) {
                    showSnackBar(context: context, text: state.message!);
                  }
                  if(state.status.isLoading) {
                    context.showLoader();
                  } else {
                    context.hideLoader();
                  }
                  if(state.status.isSuccess && state.sourceEvent is SaveTheme) {
                    showSnackBar(context: context, text: 'Theme changed successfully');
                  }
                },
                builder: (context, state) {
                  final theme = state.theme!;
                  return InkWell(
                    onTap: () {
                      _showEditThemeDialog(context: context, currentTheme: theme);
                    },
                    child: ListTile(
                      leading: const Icon(
                        Icons.contrast,
                        size: 28,
                      ),
                      title: const Text('Theme'),
                      subtitle: Text(theme.name.capitalize()),
                      subtitleTextStyle: Theme.of(context)
                          .textTheme
                          .labelMedium
                          ?.copyWith(color: Theme.of(context).colorScheme.grey),
                    ),
                  );
                },
              ),
              //* Legal Documents
              ListTile(
                onTap: () {
                  showTermsOfServiceDialog(context);
                },
                leading: const Icon(
                  Icons.gavel_outlined,
                  size: 28,
                ),
                title: const Text(
                  'Terms of Service',
                ),
                titleTextStyle: Theme.of(context).textTheme.titleMedium,
              ),
              ListTile(
                onTap: () {
                  showPrivacyPolicyDialog(context);
                },
                leading: const Icon(
                  Icons.privacy_tip_outlined,
                  size: 28,
                ),
                title: const Text('Privacy Policy'),
                titleTextStyle: Theme.of(context).textTheme.titleMedium,
              ),
              ListTile(
                onTap: () async {
                  final bool res = await showDialog<bool?>(
                        context: context,
                        builder: (_) {
                          return AlertDialog(
                            title: const Text('Logout'),
                            content: const Text('Are you sure you want to logout?'),
                            actions: [
                              TextButton(
                                onPressed: () {
                                  context.router.pop(false);
                                },
                                child: const Text('Cancel'),
                              ),
                              TextButton(
                                onPressed: () {
                                  context.router.pop(true);
                                },
                                child: const Text('Logout'),
                              ),
                            ],
                          );
                        },
                      ) ??
                      false;
                  if (!context.mounted || !res) {
                    return;
                  }
                  context.read<SimpleJurorHomePageBloc>().add(SimpleJurorHomePageSignOut());
                },
                leading: Icon(
                  Icons.logout,
                  color: Theme.of(context).colorScheme.error,
                  size: 28,
                ),
                title: Text(
                  'Logout',
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium
                      ?.copyWith(color: Theme.of(context).colorScheme.error),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<bool?> _showInsertJuryTokenDialog(BuildContext context) async {
    final simpleJurorHomePageBloc = context.read<SimpleJurorHomePageBloc>();
    final tokenController = TextEditingController();
    final tokenFocusNode = FocusNode();

    return await showDialog<bool?>(
      context: context,
      builder: (dialogContext) {
        return BlocProvider.value(
          value: simpleJurorHomePageBloc,
          child: BlocListener<SimpleJurorHomePageBloc, SimpleJurorHomePageState>(
            listener: (context, state) {
              if (state.status.isSuccess && state.sourceEvent is SimpleJurorHomePageAccessVoting) {
                dialogContext.pop(true);
                context.router
                    .push(JurorVotingProcedureRoute(votingSessionId: state.votingSession!.id!));
              }
            },
            child: AlertDialog(
              title: const Text('Insert Jury Token'),
              content: CustomTextFormField(
                borderType: InputBorderType.outlined,
                controller: tokenController,
                focusNode: tokenFocusNode,
                validator: noEmptyValidator,
                label: 'Token',
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    dialogContext.pop(false);
                  },
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: () {
                    context
                        .read<SimpleJurorHomePageBloc>()
                        .add(SimpleJurorHomePageAccessVoting(token: tokenController.text));
                  },
                  child: const Text('Confirm'),
                ),
              ],
            ),
          ),
        );
      },
    );
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
                    title: const Text('Theme'),
                    content: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        RadioGroup<AppTheme>(
                          onChanged: (value) {
                            setState(() => selectedTheme = value!);
                          },
                          groupValue: selectedTheme,
                          child: const Column(
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
                        child: const Text('Cancel'),
                      ),
                      TextButton(
                        onPressed: () {
                          context.read<ThemeBloc>().add(SaveTheme(theme: selectedTheme));
                        },
                        child: const Text('Proceed'),
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
}
