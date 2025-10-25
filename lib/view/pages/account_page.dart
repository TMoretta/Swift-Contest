import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:swift_contest/utils/router/app_router.gr.dart';
import 'package:swift_contest/utils/themes/color_scheme_x.dart';
import 'package:swift_contest/view/widgets/custom_app_bar.dart';
import 'package:swift_contest/view/widgets/custom_text_form_field.dart';
import 'package:swift_contest/view/widgets/overlay_loader.dart';
import 'package:swift_contest/view/widgets/show_snack_bar.dart';
import 'package:swift_contest/view/widgets/void_widget.dart';
import 'package:swift_contest/viewmodel/blocs/auth_bloc/auth_bloc.dart';
import 'package:swift_contest/viewmodel/types/bloc_status.dart';

@RoutePage()
class AccountPage extends StatefulWidget {
  const AccountPage({super.key});

  @override
  State<AccountPage> createState() => _AccountPageState();
}

class _AccountPageState extends State<AccountPage> {
  @override
  void dispose() {
    context.hideLoader();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state.message != null) {
          showSnackBar(context: context, text: state.message!);
        }
        if (state.blocStatus.isLoading) {
          context.showLoader();
        } else {
          context.hideLoader();
        }
        if (state.blocStatus.isSuccess && state.sourceEvent is AuthDeleteAccount) {
          showSnackBar(context: context, text: 'Account deleted successfully');
          context.router.replaceAll([const RootRoute()]);
        }
      },
      builder: (context, state) {
        return Scaffold(
          appBar: const CustomAppBar(title: 'Account'),
          body: Builder(
            builder: (context) {
              if (!state.isInitialized) {
                if (state.blocStatus.isFailure) {
                  return Center(
                    child: FilledButton(
                      onPressed: () async => context.read<AuthBloc>().add(AuthFetch()),
                      child: const Text('Retry'),
                    ),
                  );
                }
                return const VoidWidget();
              }
              final account = state.account!;
              final profile = state.profile!;
              return RefreshIndicator.adaptive(
                onRefresh: () async => context.read<AuthBloc>().add(AuthFetch()),
                child: ListView(
                  children: [
                    ListTile(
                      title: const Text('Email'),
                      titleTextStyle: Theme.of(context)
                          .textTheme
                          .labelLarge
                          ?.copyWith(color: Theme.of(context).colorScheme.grey),
                      subtitle: Text(account.email),
                      subtitleTextStyle: Theme.of(context).textTheme.bodyLarge,
                    ),
                    ListTile(
                      title: const Text('Full name'),
                      titleTextStyle: Theme.of(context)
                          .textTheme
                          .labelLarge
                          ?.copyWith(color: Theme.of(context).colorScheme.grey),
                      subtitle: Text(profile.fullName),
                      subtitleTextStyle: Theme.of(context).textTheme.bodyLarge,
                      trailing: IconButton(
                        onPressed: () {
                          _showEditFullNameDialog(context: context);
                        },
                        icon: const Icon(Icons.edit),
                      ),
                    ),
                    ListTile(
                      onTap: () async {
                        final bool? res = await showDialog(
                          context: context,
                          builder: (context) {
                            return AlertDialog(
                              title: const Text('Delete account'),
                              content: const Text(
                                  'Are you sure you want to delete your account? This action is irreversible'),
                              actions: [
                                TextButton(
                                  onPressed: () => context.router.pop(),
                                  child: const Text('Cancel'),
                                ),
                                TextButton(
                                  onPressed: () => context.router.pop(true),
                                  child: const Text('Proceed'),
                                ),
                              ],
                            );
                          },
                        );
                        if (res == true) {
                          if (context.mounted) {
                            context.read<AuthBloc>().add(AuthDeleteAccount());
                          }
                        }
                      },
                      title: Text(
                        'Delete account',
                        style: Theme.of(context)
                            .textTheme
                            .titleMedium
                            ?.copyWith(color: Theme.of(context).colorScheme.error),
                      ),
                      leading: Icon(
                        Icons.delete,
                        color: Theme.of(context).colorScheme.error,
                      ),
                    )
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }
}

void _showEditFullNameDialog({required BuildContext context}) {
  final authBloc = context.read<AuthBloc>();
  final fullNameController = TextEditingController();
  final fullNameFocusNode = FocusNode();

  showDialog(
    context: context,
    builder: (context) {
      return BlocProvider.value(
        value: authBloc,
        child: BlocConsumer<AuthBloc, AuthState>(
          listener: (context, state) {
            if (state.blocStatus.isSuccess && state.sourceEvent is AuthEditFullName) {
              showSnackBar(context: context, text: 'Full name updated successfully');
              context.router.pop();
            }
          },
          builder: (context, state) {
            return AlertDialog(
              title: const Text('Edit full name'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CustomTextFormField(
                    borderType: InputBorderType.underlined,
                    label: 'Full name',
                    controller: fullNameController,
                    focusNode: fullNameFocusNode,
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
                    context
                        .read<AuthBloc>()
                        .add(AuthEditFullName(fullName: fullNameController.text.trim()));
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
}
