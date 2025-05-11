import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:swift_contest/utils/functions/show_snack_bar.dart';
import 'package:swift_contest/utils/router/go_router.dart';
import 'package:swift_contest/view/widgets/custom_text_form_field.dart';
import 'package:swift_contest/view/widgets/loader.dart';
import 'package:swift_contest/viewmodel/blocs/bloc_status.dart';
import 'package:swift_contest/viewmodel/blocs/pages_blocs/sign_up_page_bloc/sign_up_page_bloc.dart';
import 'package:swift_contest/viewmodel/repositories/user_repository.dart';

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
    return Scaffold(
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SizedBox(
              width: constraints.maxWidth,
              height: constraints.maxHeight,
              child: Center(
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      //* Title
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            'Swift Contest',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.primary,
                              fontSize: 48,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          Text(
                            'Welcome to your contest manager',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.onSurface,
                              fontSize: 20,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(
                        height: 12,
                      ),
                      //* Form
                      BlocProvider<SignUpPageBloc>(
                        create: (context) => SignUpPageBloc(
                            userRepository: context.read<UserRepository>()),
                        child: BlocConsumer<SignUpPageBloc, SignUpPageState>(
                          //* SignUpPageBloc listener
                          listener: (context, state) {
                            if (state.status.isFailure) {
                              showSnackBar(
                                  context: context, text: state.message!);
                            }
                            if (state.status.isSuccess) {
                              showDialog(
                                context: context,
                                builder: (context) => AlertDialog(
                                  title: const Text('Verify email'),
                                  content: Text(
                                    'We have sent a verification link to your email address. '
                                    'Please check your inbox and verify your account.',
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () {
                                        context.pop();
                                        context.goNamed(AppRouter.signIn);
                                      },
                                      child: const Text('OK'),
                                    ),
                                  ],
                                ),
                              );
                            }
                          },
                          //* SignUpPageBloc builder
                          builder: (context, state) {
                            if (state.status.isLoading) {
                              return const Loader();
                            }
                            return Form(
                              key: _formKey,
                              child: Padding(
                                padding: EdgeInsets.all(16),
                                child: Column(
                                  children: [
                                    //* Full name field
                                    CustomTextFormFieldOutlined(
                                      controller: _fullNameController,
                                      label: 'Full name',
                                      validator: (value) =>
                                          _fullNameValidator(value?.trim()),
                                      prefixIcon: Icon(Icons.person_outlined),
                                    ),
                                    SizedBox(height: 12),
                                    //* Email field
                                    CustomTextFormFieldOutlined(
                                      controller: _emailController,
                                      label: 'Email',
                                      validator: (value) =>
                                          _emailValidator(value?.trim()),
                                      prefixIcon: Icon(Icons.email_outlined),
                                    ),
                                    SizedBox(height: 12),
                                    //* Password field
                                    CustomTextFormFieldOutlined(
                                      controller: _passwordController,
                                      label: 'Password',
                                      validator: (value) =>
                                          _passwordValidator(value?.trim()),
                                      prefixIcon: Icon(Icons.lock_outlined),
                                    ),
                                    SizedBox(height: 12),
                                    //* Confirm password field
                                    CustomTextFormFieldOutlined(
                                      controller: _confirmPasswordController,
                                      label: 'Confirm password',
                                      validator: (value) =>
                                          _confirmPasswordValidator(value?.trim(), _confirmPasswordController.text.trim()),
                                      prefixIcon:
                                          Icon(Icons.check_circle_outlined),
                                    ),
                                    SizedBox(height: 2),
                                    //* Forgot password button
                                    Align(
                                      alignment: Alignment.centerRight,
                                      child: TextButton(
                                        onPressed: () {},
                                        // onPressed: () => _showForgotPasswordDialog(context),
                                        child: Text(
                                          'Forgot password?',
                                          style: TextStyle(
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .secondary),
                                        ),
                                      ),
                                    ),
                                    //* Sign up button
                                    SizedBox(
                                      width: double.infinity,
                                      child: ElevatedButton(
                                        onPressed: () {
                                          if (_formKey.currentState
                                                  ?.validate() ??
                                              false) {
                                            _handleSignUpPage(context);
                                          }
                                        },
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Theme.of(context)
                                              .colorScheme
                                              .primary,
                                          foregroundColor: Colors.white,
                                        ),
                                        child: const Text(
                                          'Sign up',
                                          style: TextStyle(
                                            fontSize: 16.0,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ),
                                    ),
                                    //* Sign in instead button
                                    Align(
                                      alignment: Alignment.center,
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Text(
                                            'Already have an account?',
                                            style: TextStyle(
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .onSurface,
                                            ),
                                          ),
                                          TextButton(
                                            onPressed: () {
                                              context.goNamed(AppRouter.signIn);
                                            },
                                            style: ButtonStyle(),
                                            child: DecoratedBox(
                                              decoration: BoxDecoration(
                                                border: Border(
                                                  bottom: BorderSide(
                                                    color: Theme.of(context)
                                                        .colorScheme
                                                        .primary,
                                                  ),
                                                ),
                                              ),
                                              child: Text(
                                                'Sign in',
                                                style: TextStyle(
                                                  color: Theme.of(context)
                                                      .colorScheme
                                                      .primary,
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    SizedBox(height: 24),
                                    //* Vote as a guest button
                                    TextButton(
                                      onPressed: () {},
                                      child: DecoratedBox(
                                        decoration: BoxDecoration(
                                          border: Border(
                                            bottom: BorderSide(
                                                color: Theme.of(context)
                                                    .colorScheme
                                                    .secondary),
                                          ),
                                        ),
                                        child: Text(
                                          'Vote in a contest as a guest',
                                          style: TextStyle(
                                            color: Theme.of(context)
                                                .colorScheme
                                                .secondary,
                                            fontSize: 16,
                                            fontWeight: FontWeight.w500,
                                            // color: Theme.of(context).colorScheme.surface,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  //* Handle sign up
  void _handleSignUpPage(BuildContext context) {
    context.read<SignUpPageBloc>().add(SignUpPageSignUpWithEmailAndPassword(
          fullName: _fullNameController.text.trim(),
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        ));
  }

  //* Full name validator
  String? _fullNameValidator(String? value) {
    String? valueTrm = value?.trim();

    if (valueTrm == null || valueTrm.isEmpty) {
      return 'Please enter your name';
    }
    if (valueTrm.length < 3) {
      return 'At least 2 characters long';
    }
    if (!RegExp(r'^[a-zA-Z]+$').hasMatch(valueTrm)) {
      return 'Can only contain letters';
    }
    return null;
  }

  //* Email validator
  String? _emailValidator(String? value) {
    String? valueTrm = value?.trim();
    if (valueTrm == null || valueTrm.isEmpty) {
      return 'Please enter your email';
    }
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    if (!emailRegex.hasMatch(valueTrm)) {
      return 'Please enter a valid email';
    }
    return null;
  }

  //* Password validator
  String? _passwordValidator(String? value) {
    String? valueTrm = value?.trim();
    if (valueTrm == null || valueTrm.isEmpty) {
      return 'Please enter your password';
    }
    if (valueTrm.length < 8) {
      return 'At least 8 characters';
    }
    if (!RegExp(r'[A-Z]').hasMatch(valueTrm)) {
      return 'At least one uppercase letter';
    }
    if (!RegExp(r'[a-z]').hasMatch(valueTrm)) {
      return 'At least one lowercase letter';
    }
    if (!RegExp(r'\d').hasMatch(valueTrm)) {
      return 'At least one number';
    }
    if (!RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(valueTrm)) {
      return 'At least one special character';
    }
    return null;
  }

  //* Confirm password validator
  String? _confirmPasswordValidator(String? value, String password) {
    String? valueTrm = value?.trim();
    if (valueTrm == null || valueTrm.isEmpty) {
      return 'Please confirm your password';
    }
    if (valueTrm != password.trim()) {
      return 'Passwords do not match';
    }
    return null;
  }
}
