import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:swift_contest/model/data_models/profile.dart';
import 'package:swift_contest/model/data_models/user.dart';
import 'package:swift_contest/model/enums/app_theme.dart';
import 'package:swift_contest/utils/functions/show_snack_bar.dart';
import 'package:swift_contest/utils/router/go_router.dart';
import 'package:swift_contest/utils/themes/color_scheme_x.dart';
import 'package:swift_contest/view/widgets/loader.dart';
import 'package:swift_contest/viewmodel/blocs/global_blocs/auth_bloc/auth_bloc.dart';
import 'package:swift_contest/viewmodel/blocs/global_blocs/juror_joined_contests_bloc/juror_joined_contests_bloc.dart';
import 'package:swift_contest/viewmodel/blocs/global_blocs/organizer_created_contests_bloc/organizer_created_contests_bloc.dart';
import 'package:swift_contest/viewmodel/blocs/global_blocs/participant_joined_contests_bloc/participant_joined_contests_bloc.dart';
import 'package:swift_contest/viewmodel/blocs/pages_blocs/settings_page_bloc/settings_page_bloc.dart';
import 'package:swift_contest/viewmodel/enums/bloc_status.dart';
import 'package:swift_contest/viewmodel/repositories/profile_repository.dart';
import 'package:swift_contest/viewmodel/repositories/user_repository.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _AuthState();
}

class _AuthState extends State<SettingsPage> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Settings')),
      body: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state.message != null) {
            showSnackBar(context: context, text: state.message!);
          }
        },
        builder: (context, state) {
          if(state.blocStatus.isLoading) {
            return Loader();
          }
          final user = state.user!;
          final profile = state.profile!;
          return ListView(
            children: [
              // Divider(
              //   color: Theme.of(context).colorScheme.greyA,
              //   thickness: 0.7,
              // ),
              // //* Account option
              // InkWell(
              //   onTap: (){},
              //   child: Padding(
              //     padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              //     child: Row(
              //       mainAxisAlignment: MainAxisAlignment.start,
              //       crossAxisAlignment: CrossAxisAlignment.center,
              //       spacing: 16,
              //       children: [
              //         SizedBox(
              //           width: 60,
              //           height: 60,
              //           child: CircleAvatar(
              //             backgroundImage: AssetImage('assets/images/image.jpeg'),
              //             // backgroundColor: Colors.transparent,
              //           ),
              //         ),
              //         Column(
              //           mainAxisAlignment: MainAxisAlignment.center,
              //           crossAxisAlignment: CrossAxisAlignment.start,
              //           children: [
              //             Text(
              //               'Mario',
              //               style: TextStyle(
              //                 fontSize: 16,
              //                 fontWeight: FontWeight.w600,
              //               ),
              //             ),
              //             Text(
              //               'Rossi',
              //               style: TextStyle(
              //                 fontSize: 14,
              //                 fontWeight: FontWeight.w500,
              //                 color: Theme.of(context).colorScheme.grey8,
              //               ),
              //             ),
              //           ],
              //         ),
              //       ],
              //     ),
              //   ),
              // ),
              // Divider(
              //   color: Theme.of(context).colorScheme.greyA,
              //   thickness: 0.7,
              // ),
              //* Account option
              TextButton(
                onPressed: () => context.pushNamed(AppRouter.account),
                style: ButtonStyle(
                  shape: WidgetStatePropertyAll(LinearBorder()),
                  padding:
                      WidgetStatePropertyAll(EdgeInsets.symmetric(horizontal: 16, vertical: 16)),
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
                          style:
                              TextStyle(fontSize: 12, color: Theme.of(context).colorScheme.grey8),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              //* Theme option
              TextButton(
                onPressed: () {
                  _showEditThemeDialog(context: context, currentTheme: profile.prefTheme);
                },
                style: ButtonStyle(
                  shape: WidgetStatePropertyAll(LinearBorder()),
                  padding:
                      WidgetStatePropertyAll(EdgeInsets.symmetric(horizontal: 16, vertical: 16)),
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
                          style:
                              TextStyle(fontSize: 12, color: Theme.of(context).colorScheme.grey8),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              //* Preferred role option
              TextButton(
                onPressed: () {},
                style: ButtonStyle(
                  shape: WidgetStatePropertyAll(LinearBorder()),
                  padding:
                      WidgetStatePropertyAll(EdgeInsets.symmetric(horizontal: 16, vertical: 16)),
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
                          style:
                              TextStyle(fontSize: 12, color: Theme.of(context).colorScheme.grey8),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              //* Logout option
              BlocProvider<AuthBloc>(
                create: (context) => AuthBloc(
                  userRepository: context.read<UserRepository>(),
                  profileRepository: context.read<ProfileRepository>(),
                ),
                child: BlocConsumer<AuthBloc, AuthState>(
                  listener: (context, state) async {
                    if (state.message!=null) {
                      showSnackBar(context: context, text: state.message!);
                    }
                    if (state.blocStatus.isSuccess) {
                      context.goNamed(AppRouter.signIn);
                    }
                  },
                  builder: (context, state) {
                    return TextButton(
                      onPressed: () async {
                        context
                            .read<OrganizerCreatedContestsBloc>()
                            .add(OrganizerCreatedContestsClear());
                        context
                            .read<ParticipantJoinedContestsBloc>()
                            .add(ParticipantJoinedContestsClear());
                        context.read<JurorJoinedContestsBloc>().add(JurorJoinedContestsClear());
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
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

void _showEditThemeDialog({required BuildContext context, required AppTheme currentTheme}) {
  showDialog(
    context: context,
    builder: (context) {
      return StatefulBuilder(
        builder: (context, setState) {
          AppTheme selectedTheme = currentTheme;
          return BlocConsumer<AuthBloc, AuthState>(
            listener: (context, state) {
              if (state.message != null) {
                showSnackBar(context: context, text: state.message!);
              }
              if (state.blocStatus.isSuccess) {
                showSnackBar(context: context, text: 'Theme changed successfully');
              }
            },
            builder: (context, state) {
              return AbsorbPointer(
                absorbing: state.blocStatus.isLoading,
                child: AlertDialog(
                  title: Text('Theme'),
                  content: Column(
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
                            context.read<AuthBloc>().add(AuthEditPrefTheme(prefTheme: selectedTheme));
                          },
                          child: Text('Ok'),
                        ),
                      ],
                    )
                  ],
                ),
              );
            },
          );
        },
      );
    },
  );
}
