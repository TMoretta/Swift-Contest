import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:swift_contest/utils/labels/labels.dart';
import 'package:swift_contest/utils/router/app_router.gr.dart';
import 'package:swift_contest/utils/validators/validators.dart';
import 'package:swift_contest/view/widgets/custom_text_form_field.dart';
import 'package:swift_contest/view/widgets/overlay_loader.dart';
import 'package:swift_contest/view/widgets/show_snack_bar.dart';
import 'package:swift_contest/viewmodel/blocs/pages_blocs/sign_up_page_bloc/sign_up_page_bloc.dart';
import 'package:swift_contest/viewmodel/enums/bloc_status.dart';

@RoutePage()
class SignUpPage extends StatefulWidget implements AutoRouteWrapper {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();

  @override
  Widget wrappedRoute(BuildContext context) {
    return BlocProvider<SignUpPageBloc>(
      create: (context) => SignUpPageBloc(authRepository: context.read(),),
      child: this,
    );
  }
}

class _SignUpPageState extends State<SignUpPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _fullNameController = TextEditingController();
  final FocusNode _fullNameFocusNode = FocusNode();
  final TextEditingController _emailController = TextEditingController();
  final FocusNode _emailFocusNode = FocusNode();
  final TextEditingController _passwordController = TextEditingController();
  final FocusNode _passwordFocusNode = FocusNode();
  final TextEditingController _confirmPasswordController = TextEditingController();
  final FocusNode _confirmPasswordFocusNode = FocusNode();

  @override
  void dispose() {
    context.hideLoader();
    _formKey.currentState?.dispose();
    _fullNameController.dispose();
    _fullNameFocusNode.dispose();
    _emailController.dispose();
    _emailFocusNode.dispose();
    _passwordController.dispose();
    _passwordFocusNode.dispose();
    _confirmPasswordController.dispose();
    _confirmPasswordFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<SignUpPageBloc, SignUpPageState>(
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
        //* Go to sign up verify page
        if (state.status.isSuccess && state.sourceEvent is SignUpWithEmailAndPassword) {
          final email = _emailController.text.trim();
          context.router.push(SignUpVerifyRoute(email: email));
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
                      child: Padding(
                        padding: EdgeInsets.all(16),
                        child: Column(
                          children: [
                            //* Full name field
                            ConstrainedBox(
                              constraints: BoxConstraints(maxWidth: 420),
                              child: CustomTextFormField(
                                borderType: InputBorderType.outlined,
                                controller: _fullNameController,
                                focusNode: _fullNameFocusNode,
                                label: 'Full name',
                                validator: fullNameValidator,
                                prefixIcon: Icon(Icons.person_outlined),
                              ),
                            ),
                            SizedBox(height: 5),
                            //* Email field
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
                            SizedBox(height: 5),
                            //* Password field
                            ConstrainedBox(
                              constraints: BoxConstraints(maxWidth: 420),
                              child: CustomTextFormField(
                                borderType: InputBorderType.outlined,
                                controller: _passwordController,
                                focusNode: _passwordFocusNode,
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
                              child: CustomTextFormField(
                                borderType: InputBorderType.outlined,
                                controller: _confirmPasswordController,
                                focusNode: _confirmPasswordFocusNode,
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
                                    context.read<SignUpPageBloc>().add(SignUpWithEmailAndPassword(
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
                                      context.router.replace(SignInRoute());
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
                                    bottom:
                                        BorderSide(color: Theme.of(context).colorScheme.primary),
                                  ),
                                ),
                                child: Text('Vote in a contest as a simple juror'),
                              ),
                            ),
                            SizedBox(height: 72),
                          ],
                        ),
                      ),
                    ),
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
