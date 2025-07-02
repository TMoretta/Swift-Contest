import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:swift_contest/utils/labels/labels.dart';
import 'package:swift_contest/utils/router/go_router.dart';
import 'package:swift_contest/utils/validators/validators.dart';
import 'package:swift_contest/view/widgets/custom_text_form_field.dart';
import 'package:swift_contest/view/widgets/obscured_loader.dart';
import 'package:swift_contest/view/widgets/show_snack_bar.dart';
import 'package:swift_contest/viewmodel/blocs/pages_blocs/sign_in_page_bloc/sign_in_page_bloc.dart';
import 'package:swift_contest/viewmodel/enums/bloc_status.dart';
import 'package:swift_contest/view/widgets/void_widget.dart';

class SignInPage extends StatefulWidget {
  const SignInPage({super.key});

  @override
  State<SignInPage> createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return BlocListener<SignInPageBloc, SignInPageState>(
      listener: (context, state) {
        //* Show a message if there is one
        if (state.message != null) {
          showSnackBar(context: context, text: state.message!);
        }
        //* Go to root page
        if (state.status.isSuccess && state.sourceEvent is SignInWithEmailAndPassword) {
          context.goNamed(AppRouter.root, extra: 0);
        }
      },
      child: Stack(
        alignment: Alignment.center,
        children: [
          Scaffold(
            body: SafeArea(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: BlocBuilder<SignInPageBloc, SignInPageState>(
                  builder: (context, state) {
                    return Center(
                      child: ListView(
                        shrinkWrap: true,
                        children: [
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
                                  child: CustomTextFormFieldOutlined(
                                    controller: _emailController,
                                    label: 'Email',
                                    validator: emailValidator,
                                    prefixIcon: Icon(Icons.email_outlined),
                                  ),
                                ),
                                //* Password text field
                                ConstrainedBox(
                                  constraints: BoxConstraints(maxWidth: 420),
                                  child: CustomTextFormFieldOutlined(
                                    controller: _passwordController,
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
                                        context.read<SignInPageBloc>().add(
                                            SignInWithEmailAndPassword(
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
                                        context.replaceNamed(AppRouter.signUp);
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
                                        bottom: BorderSide(
                                            color: Theme.of(context).colorScheme.primary),
                                      ),
                                    ),
                                    child: Text('Vote in a contest as a simple juror'),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
          BlocBuilder<SignInPageBloc, SignInPageState>(
            builder: (context, state) {
              if (state.status.isLoading) {
                return ObscuredLoader();
              }
              return VoidWidget();
            },
          ),
        ],
      ),
    );
  }
}

void _showVoteAsSimpleJurorDialog({required BuildContext context}) {
  final signInPageBloc = context.read<SignInPageBloc>();
  showDialog(
    context: context,
    builder: (context) {
      final accessVotingFormKey = GlobalKey<FormState>();
      final fullNameController = TextEditingController();
      final tokenController = TextEditingController();
      return BlocProvider.value(
        value: signInPageBloc,
        child: BlocListener<SignInPageBloc, SignInPageState>(
          listener: (context, state) {
            if (state.status.isSuccess && state.sourceEvent is SignInPageVoteAsSimpleJuror) {
              context.pop();
              context.replaceNamed(AppRouter.simpleJurorVotingProcedure,
                  extra: state.simpleJurorAndVotingSessionBundle!.toJson());
            }
          },
          child: Stack(
            children: [
              AlertDialog(
                title: Text('Vote as simple juror'),
                content: Form(
                  key: accessVotingFormKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CustomTextFormFieldUnderlined(
                        controller: fullNameController,
                        label: 'Full name',
                        validator: (value) => noEmptyValidator(value?.trim()),
                      ),
                      CustomTextFormFieldUnderlined(
                        controller: tokenController,
                        label: 'Token',
                        validator: (value) => noEmptyValidator(value?.trim()),
                      ),
                    ],
                  ),
                ),
                actions: [
                  TextButton(
                    onPressed: () {
                      context.pop();
                    },
                    child: Text('Cancel'),
                  ),
                  TextButton(
                    onPressed: () {
                      if (accessVotingFormKey.currentState?.validate() ?? false) {
                        signInPageBloc.add(
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
              ),
              BlocBuilder<SignInPageBloc, SignInPageState>(
                builder: (context, state) {
                  if (state.status.isLoading) {
                    return ObscuredLoader();
                  }
                  return VoidWidget();
                },
              ),
            ],
          ),
        ),
      );
    },
  );
}
