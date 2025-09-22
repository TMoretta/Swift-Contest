import 'package:auto_route/auto_route.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:swift_contest/utils/router/app_router.gr.dart';
import 'package:swift_contest/utils/validators/validators.dart';
import 'package:swift_contest/view/widgets/custom_text_form_field.dart';
import 'package:swift_contest/view/widgets/overlay_loader.dart';
import 'package:swift_contest/view/widgets/privacy_policy_dialog.dart';
import 'package:swift_contest/view/widgets/show_snack_bar.dart';
import 'package:swift_contest/view/widgets/terms_of_service_dialog.dart';
import 'package:swift_contest/viewmodel/blocs/pages_blocs/sign_up_page_bloc/sign_up_page_bloc.dart';
import 'package:swift_contest/viewmodel/types/bloc_status.dart';

@RoutePage()
class SignUpPage extends StatefulWidget implements AutoRouteWrapper {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();

  @override
  Widget wrappedRoute(BuildContext context) {
    return BlocProvider<SignUpPageBloc>(
      create: (context) => SignUpPageBloc(
        authRepository: context.read(),
      ),
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

  // final TextEditingController _passwordController = TextEditingController();
  // final FocusNode _passwordFocusNode = FocusNode();
  // final TextEditingController _confirmPasswordController = TextEditingController();
  // final FocusNode _confirmPasswordFocusNode = FocusNode();
  bool _isPrivacyAccepted = false;

  @override
  void dispose() {
    context.hideLoader();
    _formKey.currentState?.dispose();
    _fullNameController.dispose();
    _fullNameFocusNode.dispose();
    _emailController.dispose();
    _emailFocusNode.dispose();
    // _passwordController.dispose();
    // _passwordFocusNode.dispose();
    // _confirmPasswordController.dispose();
    // _confirmPasswordFocusNode.dispose();
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
        if (state.status.isSuccess && state.sourceEvent is SignUpWithEmail) {
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
                    SizedBox(height: 24),
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
                                onEditingComplete: () => _emailFocusNode.requestFocus(),
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
                                // onEditingComplete: () => _passwordFocusNode.requestFocus(),
                                label: 'Email',
                                validator: emailValidator,
                                prefixIcon: Icon(Icons.email_outlined),
                              ),
                            ),
                            // SizedBox(height: 5),
                            // //* Password field
                            // ConstrainedBox(
                            //   constraints: BoxConstraints(maxWidth: 420),
                            //   child: CustomTextFormField(
                            //     borderType: InputBorderType.outlined,
                            //     controller: _passwordController,
                            //     focusNode: _passwordFocusNode,
                            //     onEditingComplete: () => _confirmPasswordFocusNode.requestFocus(),
                            //     validator: passwordValidator,
                            //     label: 'Password',
                            //     prefixIcon: Icon(Icons.lock),
                            //     obscureText: true,
                            //   ),
                            // ),
                            // SizedBox(height: 5),
                            // //* Confirm password field
                            // ConstrainedBox(
                            //   constraints: BoxConstraints(maxWidth: 420),
                            //   child: CustomTextFormField(
                            //     borderType: InputBorderType.outlined,
                            //     controller: _confirmPasswordController,
                            //     focusNode: _confirmPasswordFocusNode,
                            //     validator: (value) =>
                            //         confirmPasswordValidator(value, _passwordController.text),
                            //     label: 'Confirm password',
                            //     prefixIcon: Icon(Icons.check_circle_outline),
                            //     obscureText: true,
                            //   ),
                            // ),
                            SizedBox(height: 10),
                            ConstrainedBox(
                              constraints: BoxConstraints(
                                maxWidth: 420,
                              ),
                              child: CheckboxListTile(
                                value: _isPrivacyAccepted,
                                onChanged: (value) {
                                  setState(() {
                                    _isPrivacyAccepted = value ?? false;
                                  });
                                },
                                title: RichText(
                                  text: TextSpan(
                                    style: Theme.of(context).textTheme.bodySmall,
                                    children: [
                                      const TextSpan(text: 'I have read and agree to the '),
                                      TextSpan(
                                        text: 'Terms of Service',
                                        style: const TextStyle(
                                            color: Colors.blue,
                                            decoration: TextDecoration.underline),
                                        recognizer: TapGestureRecognizer()
                                          ..onTap = () {
                                            // Mostra la pagina dei Termini come un dialogo
                                            showTermsOfServiceDialog(context);
                                          },
                                      ),
                                      const TextSpan(text: ' and the '),
                                      TextSpan(
                                        text: 'Privacy Policy',
                                        style: const TextStyle(
                                            color: Colors.blue,
                                            decoration: TextDecoration.underline),
                                        recognizer: TapGestureRecognizer()
                                          ..onTap = () {
                                            // Mostra la pagina della Privacy come un dialog
                                            showPrivacyPolicyDialog(context);
                                          },
                                      ),
                                      const TextSpan(text: '.'),
                                    ],
                                  ),
                                ),
                                controlAffinity: ListTileControlAffinity.leading,
                                contentPadding: EdgeInsets.zero,
                              ),
                            ),
                            SizedBox(height: 12),
                            //* Sign up button
                            ConstrainedBox(
                              constraints: BoxConstraints(
                                maxWidth: 100,
                              ),
                              child: FilledButton(
                                onPressed: (_isPrivacyAccepted)
                                    ? () {
                                        if (_formKey.currentState?.validate() ?? false) {
                                          context.read<SignUpPageBloc>().add(SignUpWithEmail(
                                              email: _emailController.text.trim(),
                                              fullName: _fullNameController.text.trim()));
                                        }
                                      }
                                    : null,
                                child: Text('Sign up'),
                              ),
                            ),
                            SizedBox(height: 12),
                            //* Sign in instead button
                            Row(
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
                            SizedBox(height: 24),
                            // Download for Android if on web
                            if (kIsWeb)
                              FilledButton.tonalIcon(
                                onPressed: () {
                                  showSnackBar(
                                      context: context, text: 'Download started, please wait...');
                                  context.read<SignUpPageBloc>().add(SignUpPageDownloadLatestApk());
                                },
                                icon: Icon(Icons.android),
                                label: Text('Download for Android'),
                                style: FilledButton.styleFrom(
                                    backgroundColor: Colors.green.shade200,
                                    foregroundColor: Colors.grey.shade900),
                              ),
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

void _showVoteAsSimpleJurorDialog({required BuildContext context}) {
  final signInPageBloc = context.read<SignUpPageBloc>();
  final accessVotingFormKey = GlobalKey<FormState>();
  final fullNameController = TextEditingController();
  final fullNameFocusNode = FocusNode();
  bool isPrivacyAccepted = false;

  showDialog(
    context: context,
    builder: (context) {
      return StatefulBuilder(builder: (context, setState) {
        return BlocProvider.value(
          value: signInPageBloc,
          child: BlocConsumer<SignUpPageBloc, SignUpPageState>(
            listener: (context, state) async {
              if (state.status.isSuccess &&
                  state.sourceEvent is SignUpPageAuthenticateSimpleJuror) {
                context.router.pop();
                context.router.replaceAll([RootRoute()]);
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
                        validator: fullNameValidator,
                      ),
                      CheckboxListTile(
                        value: isPrivacyAccepted,
                        onChanged: (value) {
                          setState(() {
                            isPrivacyAccepted = value ?? false;
                          });
                        },
                        title: RichText(
                          text: TextSpan(
                            style: Theme.of(context).textTheme.bodySmall,
                            children: [
                              const TextSpan(text: 'I have read and agree to the '),
                              TextSpan(
                                text: 'Terms of Service',
                                style: const TextStyle(
                                    color: Colors.blue, decoration: TextDecoration.underline),
                                recognizer: TapGestureRecognizer()
                                  ..onTap = () {
                                    // Mostra la pagina dei Termini come un dialogo
                                    showTermsOfServiceDialog(context);
                                  },
                              ),
                              const TextSpan(text: ' and the '),
                              TextSpan(
                                text: 'Privacy Policy',
                                style: const TextStyle(
                                    color: Colors.blue, decoration: TextDecoration.underline),
                                recognizer: TapGestureRecognizer()
                                  ..onTap = () {
                                    // Mostra la pagina della Privacy come un dialogo
                                    showPrivacyPolicyDialog(context);
                                  },
                              ),
                              const TextSpan(text: '.'),
                            ],
                          ),
                        ),
                        controlAffinity: ListTileControlAffinity.leading,
                        contentPadding: EdgeInsets.zero,
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
                    onPressed: (isPrivacyAccepted)
                        ? () {
                            if (accessVotingFormKey.currentState?.validate() ?? false) {
                              context.read<SignUpPageBloc>().add(SignUpPageAuthenticateSimpleJuror(
                                  fullName: fullNameController.text.trim()));
                            }
                          }
                        : null,
                    child: Text('Confirm'),
                  ),
                ],
              );
            },
          ),
        );
      });
    },
  );
}
