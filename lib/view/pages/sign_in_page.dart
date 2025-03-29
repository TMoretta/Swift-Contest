import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:swift_contest/utils/di/di.dart';
import 'package:swift_contest/utils/router/go_router.dart';
import 'package:swift_contest/view/widgets/auth_form_field.dart';
import 'package:swift_contest/view/widgets/loader.dart';
import 'package:swift_contest/view/widgets/show_snack_bar.dart';
import 'package:swift_contest/viewmodel/blocs/pages_blocs/sign_in_page_bloc/sign_in_page_bloc.dart';

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
                      BlocProvider<SignInPageBloc>(
                        create: (context) => getIt<SignInPageBloc>(),
                        child: BlocConsumer<SignInPageBloc, SignInPageState>(
                          //* AuthBloc listener
                          listener: (context, state) {
                            if (state is SignInPageFailure) {
                              showSnackBar(context: context, text: state.message);
                            }
                            // if (state is SignInPageSuccess) {
                            //   context.go('/home');
                            // }
                          },
                          //* AuthBloc builder
                          builder: (context, state) {
                            if (state is SignInPageLoading) {
                              return const Loader();
                            }
                            //* Form
                            return Form(
                              key: _formKey,
                              child: Padding(
                                padding: EdgeInsets.all(16),
                                child: Column(
                                  children: [
                                    //* Email field
                                    AuthFormField(
                                      controller: _emailController,
                                      label: 'Email',
                                      validator: _emailValidator,
                                      prefixIcon: Icon(Icons.email_outlined),
                                    ),
                                    SizedBox(height: 12),
                                    //* Password field
                                    AuthFormField(
                                      controller: _passwordController,
                                      label: 'Password',
                                      validator: _passwordValidator,
                                      prefixIcon: Icon(Icons.lock_outlined),
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
                                              color: Theme.of(context).colorScheme.secondary),
                                        ),
                                      ),
                                    ),
                                    //* Sign in button
                                    SizedBox(
                                      width: double.infinity,
                                      child: ElevatedButton(
                                        onPressed: () {
                                          if (_formKey.currentState?.validate() ?? false) {
                                            _handleSignInPage(context);
                                          }
                                        },
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Theme.of(context).colorScheme.primary,
                                          foregroundColor: Colors.white,
                                        ),
                                        child: const Text(
                                          'Sign in',
                                          style: TextStyle(
                                            fontSize: 16.0,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ),
                                    ),
                                    //* Sign up instead button
                                    Align(
                                      alignment: Alignment.center,
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Text(
                                            'Don\'t have an account?',
                                            style: TextStyle(
                                              color: Theme.of(context).colorScheme.onSurface,
                                            ),
                                          ),
                                          TextButton(
                                            onPressed: () {
                                              context.goNamed(AppRouter.signUp);
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
                                              child: Text(
                                                'Sign up',
                                                style: TextStyle(
                                                  color: Theme.of(context).colorScheme.primary,
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
                                                color: Theme.of(context).colorScheme.secondary),
                                          ),
                                        ),
                                        child: Text(
                                          'Vote in a contest as a guest',
                                          style: TextStyle(
                                            color: Theme.of(context).colorScheme.secondary,
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

  //* Function (handle sign in)
  void _handleSignInPage(BuildContext context) {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    context.read<SignInPageBloc>().add(SignInPageSignInWithEmailAndPassword(email: email, password: password));
  }

  //* Function (email validator)
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

  //* Function (Password validator)
  String? _passwordValidator(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your password';
    }
    return null;
  }
}
