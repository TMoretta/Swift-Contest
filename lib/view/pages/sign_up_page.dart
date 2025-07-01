import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:swift_contest/view/widgets/obscured_loader.dart';
import 'package:swift_contest/view/widgets/show_snack_bar.dart';
import 'package:swift_contest/utils/router/go_router.dart';
import 'package:swift_contest/utils/validators/validators.dart';
import 'package:swift_contest/view/widgets/custom_text_form_field.dart';
import 'package:swift_contest/view/widgets/loader.dart';
import 'package:swift_contest/viewmodel/blocs/pages_blocs/sign_up_page_bloc/sign_up_page_bloc.dart';
import 'package:swift_contest/viewmodel/enums/bloc_status.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final _formKey = GlobalKey<FormState>();
  final _fullNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return BlocListener<SignUpPageBloc, SignUpPageState>(
      listener: (context, state) {
        //* Show a message if there is one
        if (state.message != null) {
          showSnackBar(context: context, text: state.message!);
        }
        //* Go to sign up verify page
        if (state.status.isSuccess && state.sourceEvent is SignUpWithEmailAndPassword) {
          final email = _emailController.text.trim();
          context.pushNamed(AppRouter.signUpVerify, extra: email);
        }
      },
      child: Stack(
        alignment: Alignment.center,
        children: [
          Scaffold(
            body: SafeArea(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: BlocBuilder<SignUpPageBloc, SignUpPageState>(
                  builder: (context, state) {
                    return Center(
                      child: ListView(
                        shrinkWrap: true,
                        children: [
                          //* Title
                          FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Text(
                              'Swift Contest',
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
                              'Welcome to your contest manager',
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
                            child: Padding(
                              padding: EdgeInsets.all(16),
                              child: Column(
                                children: [
                                  //* Full name field
                                  ConstrainedBox(
                                    constraints: BoxConstraints(maxWidth: 420),
                                    child: CustomTextFormFieldOutlined(
                                      controller: _fullNameController,
                                      label: 'Full name',
                                      validator: fullNameValidator,
                                      prefixIcon: Icon(Icons.person_outlined),
                                    ),
                                  ),
                                  SizedBox(height: 5),
                                  //* Email field
                                  ConstrainedBox(
                                    constraints: BoxConstraints(maxWidth: 420),
                                    child: CustomTextFormFieldOutlined(
                                      controller: _emailController,
                                      label: 'Email',
                                      validator: emailValidator,
                                      prefixIcon: Icon(Icons.email_outlined),
                                    ),
                                  ),
                                  SizedBox(height: 5),
                                  //* Password field
                                  ConstrainedBox(
                                    constraints: BoxConstraints(maxWidth: 420),
                                    child: CustomTextFormFieldOutlined(
                                      controller: _passwordController,
                                      validator: passwordValidator,
                                      label: 'Password',
                                      prefixIcon: Icon(Icons.lock),
                                      obscureText: true,
                                    ),
                                  ),
                                  SizedBox(height: 5),
                                  //* Password field
                                  ConstrainedBox(
                                    constraints: BoxConstraints(maxWidth: 420),
                                    child: CustomTextFormFieldOutlined(
                                      controller: _confirmPasswordController,
                                      validator: (value) =>
                                          confirmPasswordValidator(value, _passwordController.text),
                                      label: 'Confirm password',
                                      prefixIcon: Icon(Icons.check_circle_outline),
                                      obscureText: true,
                                    ),
                                  ),
                                  SizedBox(height: 10),
                                  //* Sign up button
                                  ConstrainedBox(
                                    constraints: BoxConstraints(
                                      maxWidth: 100,
                                    ),
                                    child: FilledButton(
                                      onPressed: () {
                                        if (_formKey.currentState?.validate() ?? false) {
                                          context.read<SignUpPageBloc>().add(
                                              SignUpWithEmailAndPassword(
                                                  email: _emailController.text.trim(),
                                                  fullName: _fullNameController.text.trim(),
                                                  password: _passwordController.text));
                                        }
                                      },
                                      child: Text('Sign up'),
                                    ),
                                  ),
                                  //* Sign in instead button
                                  Align(
                                    alignment: Alignment.center,
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text('Already have an account?'),
                                        TextButton(
                                          onPressed: () {
                                            context.replaceNamed(AppRouter.signIn);
                                          },
                                          style: ButtonStyle(),
                                          child: DecoratedBox(
                                            decoration: BoxDecoration(
                                              border: Border(
                                                bottom: BorderSide(
                                                  color: Theme.of(context).colorScheme.primary,
                                                ),
                                              ),
                                            ),
                                            child: Text('Sign in'),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  SizedBox(height: 24),
                                  //* Vote as a simple juror button
                                  TextButton(
                                    onPressed: () {},
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
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
          BlocBuilder<SignUpPageBloc, SignUpPageState>(
            builder: (context, state) {
              if (state.status.isLoading) {
                return ObscuredLoader();
              }
              return SizedBox.shrink();
            },
          ),
        ],
      ),
    );
  }
}
