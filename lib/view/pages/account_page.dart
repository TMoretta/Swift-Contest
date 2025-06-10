import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:swift_contest/utils/functions/show_snack_bar.dart';
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
    return Scaffold(
      appBar: CustomAppBar(title: 'Account'),
      body: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) {
          if(state.message != null) {
            showSnackBar(context: context, text: state.message!);
          }
        },
        builder: (context, state) {
          switch(state.blocStatus) {
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
                    title: Row(
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      spacing: 12,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Full name',
                              style:
                              TextStyle(fontSize: 14, color: Theme.of(context).colorScheme.grey8),
                            ),
                            Text(
                              profile.fullName,
                              style: TextStyle(
                                  fontSize: 16, color: Theme.of(context).colorScheme.onSurface),
                            ),
                          ],
                        ),
                        IconButton(
                          onPressed: () async {
                            _showEditFullNameDialog(context: context);
                          },
                          icon: Icon(Icons.edit),
                        ),
                      ],
                    ),
                  ),
                ],
              );
          }
        },
      ),
    );
  }
}

void _showEditFullNameDialog({required BuildContext context}) {
  final fullNameController = TextEditingController();
  final authBloc = context.read<AuthBloc>();

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
              context.pop();
            }
          },
          builder: (context, state) {
            return AbsorbPointer(
              absorbing: state.blocStatus.isLoading,
              child: AlertDialog(
                title: Text('Edit full name'),
                content: CustomTextFormFieldUnderlined(
                  controller: fullNameController,
                ),
                actions: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () {
                          context.pop();
                        },
                        child: Text('Cancel'),
                      ),
                      TextButton(
                        onPressed: () {
                          context.read<AuthBloc>().add(AuthEditFullName(
                              fullName: fullNameController.text.trim()));
                        },
                        child: Text('Edit'),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        ),
      );
    },
  );
}
