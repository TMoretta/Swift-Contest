import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:swift_contest/view/widgets/show_snack_bar.dart';
import 'package:swift_contest/utils/router/go_router.dart';
import 'package:swift_contest/utils/themes/color_scheme_x.dart';
import 'package:swift_contest/view/widgets/custom_app_bar.dart';
import 'package:swift_contest/view/widgets/custom_text_form_field.dart';
import 'package:swift_contest/view/widgets/loader.dart';
import 'package:swift_contest/viewmodel/blocs/auth_bloc/auth_bloc.dart';
import 'package:swift_contest/viewmodel/enums/bloc_status.dart';

class AccountPage extends StatefulWidget {
  const AccountPage({super.key});

  @override
  State<AccountPage> createState() => _AccountPageState();
}

class _AccountPageState extends State<AccountPage> {
  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state.message != null) {
          showSnackBar(context: context, text: state.message!);
        }
        if(state.blocStatus.isSuccess && state.sourceEvent is AuthDeleteUser) {
          context.goNamed(AppRouter.root);
        }
      },
      child: Scaffold(
        appBar: CustomAppBar(title: 'Account'),
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
                    ListTile(
                      title: Text('Full name'),
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
                        icon: Icon(Icons.edit),
                      ),
                    ),
                    ListTile(
                      onTap: () {
                        context.read<AuthBloc>().add(AuthDeleteUser());
                      },
                      title: Text('Delete account'),
                    )
                  ],
                );
            }
          },
        ),
      ),
    );
  }
}

void _showEditFullNameDialog({required BuildContext context}) {
  final authBloc = context.read<AuthBloc>();
  final fullNameController = TextEditingController(text: authBloc.state.profile!.fullName);

  showDialog(
    context: context,
    builder: (context) {
      return BlocProvider.value(
        value: authBloc,
        child: BlocConsumer<AuthBloc, AuthState>(
          listener: (context, state) {
            if (state.blocStatus.isSuccess) {
              showSnackBar(context: context, text: 'Full name updated successfully');
              context.read<AuthBloc>().add(AuthFetchProfile());
              context.pop(true);
            }
          },
          builder: (context, state) {
            return AlertDialog(
              title: Text('Edit full name'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  (state.blocStatus.isLoading)
                      ? Loader()
                      : ConstrainedBox(
                          constraints: BoxConstraints(maxWidth: 200),
                          child: CustomTextFormFieldUnderlined(
                            controller: fullNameController,
                          ),
                        ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: (!state.blocStatus.isLoading)
                      ? () {
                          context.pop();
                        }
                      : null,
                  child: Text('Cancel'),
                ),
                TextButton(
                  onPressed: (!state.blocStatus.isLoading)
                      ? () {
                          context
                              .read<AuthBloc>()
                              .add(AuthEditFullName(fullName: fullNameController.text.trim()));
                        }
                      : null,
                  child: Text('Edit'),
                ),
              ],
            );
          },
        ),
      );
    },
  );
}
