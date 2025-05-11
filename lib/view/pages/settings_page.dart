import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:swift_contest/model/data_models/profile.dart';
import 'package:swift_contest/model/data_models/user.dart';
import 'package:swift_contest/utils/functions/show_snack_bar.dart';
import 'package:swift_contest/utils/themes/color_scheme_extension.dart';
import 'package:swift_contest/view/widgets/loader.dart';
import 'package:swift_contest/viewmodel/blocs/bloc_status.dart';
import 'package:swift_contest/viewmodel/blocs/global_blocs/auth_bloc/auth_bloc.dart';
import 'package:swift_contest/viewmodel/blocs/global_blocs/contest_role_bloc/contest_role_bloc.dart';
import 'package:swift_contest/viewmodel/blocs/global_blocs/juror_joined_contests_bloc/juror_joined_contests_bloc.dart';
import 'package:swift_contest/viewmodel/blocs/global_blocs/organizer_created_contests_bloc/organizer_created_contests_bloc.dart';
import 'package:swift_contest/viewmodel/blocs/global_blocs/participant_joined_contests_bloc/participant_joined_contests_bloc.dart';
import 'package:swift_contest/viewmodel/blocs/pages_blocs/settings_page_bloc/settings_page_bloc.dart';
import 'package:swift_contest/viewmodel/repositories/profile_repository.dart';
import 'package:swift_contest/viewmodel/repositories/user_repository.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  late User user;
  late Profile profile;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    user = context.read<AuthBloc>().state.user!;
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<SettingsPageBloc>(
      create: (context) => SettingsPageBloc(
        userRepository: context.read<UserRepository>(),
        profileRepository: context.read<ProfileRepository>(),
      )..add(SettingsPageGetProfile(userId: user.id)),
      child: Scaffold(
          appBar: AppBar(title: Text('Settings')),
          body: BlocConsumer<SettingsPageBloc, SettingsPageState>(
            listener: (context, state) {
              if (state.status.isFailure) {
                showSnackBar(context: context, text: state.message!);
              }
            },
            builder: (context, state) {
              if (state.status.isLoading) {
                return Loader();
              }
              if (state.status.isSuccess) {
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
                      onPressed: () => context.go('/settings/account'),
                      style: ButtonStyle(
                        shape: WidgetStatePropertyAll(LinearBorder()),
                        padding: WidgetStatePropertyAll(
                            EdgeInsets.symmetric(horizontal: 16, vertical: 24)),
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
                                'Full name, email, password',
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
                      onPressed: () {},
                      style: ButtonStyle(
                        shape: WidgetStatePropertyAll(LinearBorder()),
                        padding: WidgetStatePropertyAll(
                            EdgeInsets.symmetric(horizontal: 16, vertical: 24)),
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
                    //* Default role option
                    TextButton(
                      onPressed: () {},
                      style: ButtonStyle(
                        shape: WidgetStatePropertyAll(LinearBorder()),
                        padding: WidgetStatePropertyAll(
                            EdgeInsets.symmetric(horizontal: 16, vertical: 24)),
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
                                'Default role',
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
                    BlocProvider<SettingsPageBloc>(
                      create: (context) => SettingsPageBloc(
                        userRepository: context.read<UserRepository>(),
                        profileRepository: context.read<ProfileRepository>(),
                      ),
                      child: BlocConsumer<SettingsPageBloc, SettingsPageState>(
                        listener: (context, state) async {
                          if (state.status.isFailure) {
                            showSnackBar(context: context, text: state.message!);
                          }
                          if (state.status.isSuccess) {
                            context.read<ContestRoleBloc>().add(ContestRoleClear());
                            context.read<OrganizerCreatedContestsBloc>().add(OrganizerCreatedContestsClear());
                            context.read<ParticipantJoinedContestsBloc>().add(ParticipantJoinedContestsClear());
                            context.read<JurorJoinedContestsBloc>().add(JurorJoinedContestsClear());
                            context.read<AuthBloc>().add(AuthUnauthenticate());
                          }
                        },
                        builder: (context, state) {
                          return TextButton(
                            onPressed: () async {
                              context.read<SettingsPageBloc>().add(SettingsPageSignOut());
                            },
                            style: ButtonStyle(
                              shape: WidgetStatePropertyAll(LinearBorder()),
                              padding: WidgetStatePropertyAll(
                                  EdgeInsets.symmetric(horizontal: 16, vertical: 24)),
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
                                          fontSize: 16,
                                          color: Theme.of(context).colorScheme.statusRed),
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
              }
              return RefreshIndicator.adaptive(
                onRefresh: () async {
                  context.read<SettingsPageBloc>().add(SettingsPageGetProfile(userId: user.id));
                },
                child: ListView(),
              );
            },
          )),
    );
  }
}
