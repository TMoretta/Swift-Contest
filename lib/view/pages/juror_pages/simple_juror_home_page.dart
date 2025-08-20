import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:swift_contest/utils/router/app_router.gr.dart';
import 'package:swift_contest/utils/validators/validators.dart';
import 'package:swift_contest/view/widgets/custom_app_bar.dart';
import 'package:swift_contest/view/widgets/custom_text_form_field.dart';
import 'package:swift_contest/view/widgets/overlay_loader.dart';
import 'package:swift_contest/view/widgets/show_snack_bar.dart';
import 'package:swift_contest/viewmodel/blocs/auth_bloc/auth_bloc.dart';
import 'package:swift_contest/viewmodel/blocs/pages_blocs/simple_juror_home_page_bloc/simple_juror_home_page_bloc.dart';
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
  late final String fullName;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    fullName = context.read<AuthBloc>().state.profile?.fullName ?? '';
  }

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
          context.router.replaceAll([RootRoute()]);
        }
      },
      child: Scaffold(
        appBar: CustomAppBar(title: 'Simple Juror'),
        body: ListView(
          children: [
            ListTile(
              title: Text(
                fullName,
                style: Theme.of(context)
                    .textTheme
                    .titleMedium
                    ?.copyWith(color: Theme.of(context).colorScheme.secondary),
              ),
              leading: Icon(
                Icons.person,
                color: Theme.of(context).colorScheme.secondary,
                size: 28,
              ),
            ),
            ListTile(
              onTap: () => context.router.push(JurorVotingQrScannerRoute()),
              leading: Icon(
                Icons.qr_code_2,
                size: 28,
              ),
              title: Text('Scan jury QR token'),
            ),
            ListTile(
              onTap: () => _showInsertJuryTokenDialog(context),
              leading: Icon(
                Icons.abc,
                size: 28,
              ),
              title: Text('Insert jury token manually'),
            ),
            ListTile(
              onTap: () async {
                final bool res = await showDialog<bool?>(
                      context: context,
                      builder: (_) {
                        return AlertDialog(
                          title: Text('Logout'),
                          content: Text('Are you sure you want to logout?'),
                          actions: [
                            TextButton(
                              onPressed: () {
                                context.router.pop(false);
                              },
                              child: Text('Cancel'),
                            ),
                            TextButton(
                              onPressed: () {
                                context.router.pop(true);
                              },
                              child: Text('Logout'),
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
              if(state.status.isSuccess && state.sourceEvent is SimpleJurorHomePageAccessVoting) {
                dialogContext.pop(true);
                context.router.push(JurorVotingProcedureRoute(votingSessionId: state.votingSession!.id!));
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
                    context.read<SimpleJurorHomePageBloc>().add(SimpleJurorHomePageAccessVoting(token: tokenController.text));
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
}
