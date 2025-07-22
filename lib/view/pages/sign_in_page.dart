import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:swift_contest/utils/labels/labels.dart';
import 'package:swift_contest/utils/router/app_router.gr.dart';
import 'package:swift_contest/utils/validators/validators.dart';
import 'package:swift_contest/view/widgets/custom_text_form_field.dart';
import 'package:swift_contest/view/widgets/overlay_loader.dart';
import 'package:swift_contest/view/widgets/show_snack_bar.dart';
import 'package:swift_contest/viewmodel/blocs/pages_blocs/sign_in_page_bloc/sign_in_page_bloc.dart';
import 'package:swift_contest/viewmodel/enums/bloc_status.dart';

@RoutePage()
class SignInPage extends StatefulWidget implements AutoRouteWrapper {
  const SignInPage({super.key});

  @override
  State<SignInPage> createState() => _SignInPageState();

  @override
  Widget wrappedRoute(BuildContext context) {
    return BlocProvider<SignInPageBloc>(
      create: (context) => SignInPageBloc(authRepository: context.read(), jurorRepository: context.read(),),
      child: this,
    );
  }
}

class _SignInPageState extends State<SignInPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final FocusNode _emailFocusNode = FocusNode();
  final TextEditingController _passwordController = TextEditingController();
  final FocusNode _passwordFocusNode = FocusNode();

  @override
  void dispose() {
    context.hideLoader();
    _formKey.currentState?.dispose();
    _emailController.dispose();
    _emailFocusNode.dispose();
    _passwordController.dispose();
    _passwordFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<SignInPageBloc, SignInPageState>(
      listener: (context, state) {
        //* Show a message if there is one
        if (state.message != null) {
          showSnackBar(context: context, text: state.message!);
        }
        if (state.status.isLoading) {
          context.showLoader();
        } else {
          context.hideLoader();
        }
        //* Go to root page
        if (state.status.isSuccess && state.sourceEvent is SignInWithEmailAndPassword) {
          context.router.replaceAll([RootRoute()]);
        }
      },
      builder: (context, state) {
        return Scaffold(
          body: SafeArea(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Center(
                child: ListView(
                  shrinkWrap: true,
                  children: [
                    SizedBox(height: 72),
                    //* Title
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        Labels.appTitle,
                        textAlign: TextAlign.center,
                        style: Theme.of(context)
                            .textTheme
                            .displayMedium!
                            .copyWith(color: Theme.of(context).colorScheme.primary),
                      ),
                    ),
                    //* Subtitle
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        Labels.appSubtitle,
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                    ),
                    SizedBox(
                      height: 12,
                    ),
                    //* Form
                    Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          //* Email text field
                          ConstrainedBox(
                            constraints: BoxConstraints(maxWidth: 420),
                            child: CustomTextFormField(
                              borderType: InputBorderType.outlined,
                              controller: _emailController,
                              focusNode: _emailFocusNode,
                              label: 'Email',
                              validator: emailValidator,
                              prefixIcon: Icon(Icons.email_outlined),
                            ),
                          ),
                          //* Password text field
                          ConstrainedBox(
                            constraints: BoxConstraints(maxWidth: 420),
                            child: CustomTextFormField(
                              borderType: InputBorderType.outlined,
                              controller: _passwordController,
                              focusNode: _passwordFocusNode,
                              label: 'Password',
                              prefixIcon: Icon(Icons.lock),
                              obscureText: true,
                              validator: noEmptyValidator,
                            ),
                          ),
                          //* Sign in button
                          ConstrainedBox(
                            constraints: BoxConstraints(
                              maxWidth: 100,
                            ),
                            child: FilledButton(
                              onPressed: () {
                                if (_formKey.currentState?.validate() ?? false) {
                                  context.read<SignInPageBloc>().add(SignInWithEmailAndPassword(
                                      email: _emailController.text.trim(),
                                      password: _passwordController.text.trim()));
                                }
                              },
                              child: Text('Sign in'),
                            ),
                          ),
                          // TextButton(
                          //   onPressed: () {
                          //
                          //   },
                          //   child: DecoratedBox(
                          //     decoration: BoxDecoration(
                          //       border: Border(
                          //         bottom: BorderSide(
                          //           color: Theme.of(context).colorScheme.primary,
                          //         ),
                          //       ),
                          //     ),
                          //     child: Text('Forgot password?',style: Theme.of(context).textTheme.bodyMedium,),
                          //   ),
                          // ),
                          //* Sign up instead button
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                'Don\'t have an account?',
                              ),
                              TextButton(
                                onPressed: () {
                                  context.router.replace(SignUpRoute());
                                },
                                child: DecoratedBox(
                                  decoration: BoxDecoration(
                                    border: Border(
                                      bottom: BorderSide(
                                        color: Theme.of(context).colorScheme.primary,
                                      ),
                                    ),
                                  ),
                                  child: Text('Sign up'),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 24),
                          //* Vote as a simple juror
                          TextButton(
                            onPressed: () {
                              _showVoteAsSimpleJurorDialog(context: context);
                            },
                            child: DecoratedBox(
                              decoration: BoxDecoration(
                                border: Border(
                                  bottom:
                                      BorderSide(color: Theme.of(context).colorScheme.primary),
                                ),
                              ),
                              child: Text('Vote in a contest as a simple juror'),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 72),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

void _showVoteAsSimpleJurorDialog({required BuildContext context}) {
  final signInPageBloc = context.read<SignInPageBloc>();
  final accessVotingFormKey = GlobalKey<FormState>();
  final fullNameController = TextEditingController();
  final fullNameFocusNode = FocusNode();
  final tokenController = TextEditingController();
  final tokenFocusNode = FocusNode();
  showDialog(
    context: context,
    builder: (context) {
      return BlocProvider.value(
        value: signInPageBloc,
        child: BlocConsumer<SignInPageBloc, SignInPageState>(
          listener: (context, state) {
            if (state.status.isSuccess && state.sourceEvent is SignInPageVoteAsSimpleJuror) {
              final simpleJurorAndVotingSessionBundle = state.simpleJurorAndVotingSessionBundle!;
              final simpleJurorId = simpleJurorAndVotingSessionBundle.simpleJuror.id;
              final votingSessionId = simpleJurorAndVotingSessionBundle.votingSession.id;
              context.router.pop();
              context.router.replace(SimpleJurorVotingProcedureRoute(
                  simpleJurorId: simpleJurorId, votingSessionId: votingSessionId));
            }
          },
          builder: (context, state) {
            return AlertDialog(
              title: Text('Vote as simple juror'),
              content: Form(
                key: accessVotingFormKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CustomTextFormField(
                      borderType: InputBorderType.underlined,
                      controller: fullNameController,
                      focusNode: fullNameFocusNode,
                      label: 'Full name',
                      validator: (value) => noEmptyValidator(value?.trim()),
                    ),
                    CustomTextFormField(
                      borderType: InputBorderType.underlined,
                      controller: tokenController,
                      focusNode: tokenFocusNode,
                      label: 'Token',
                      validator: (value) => noEmptyValidator(value?.trim()),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    context.router.pop();
                  },
                  child: Text('Cancel'),
                ),
                TextButton(
                  onPressed: () {
                    if (accessVotingFormKey.currentState?.validate() ?? false) {
                      context.read<SignInPageBloc>().add(
                            SignInPageVoteAsSimpleJuror(
                              fullName: fullNameController.text.trim(),
                              token: tokenController.text.trim(),
                            ),
                          );
                    }
                  },
                  child: Text('Ok'),
                ),
              ],
            );
          },
        ),
      );
    },
  );
}
