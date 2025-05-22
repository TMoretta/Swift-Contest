import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:swift_contest/model/enums/contest_role.dart';
import 'package:swift_contest/utils/functions/show_snack_bar.dart';
import 'package:swift_contest/utils/router/go_router.dart';
import 'package:swift_contest/view/widgets/custom_text_form_field.dart';
import 'package:swift_contest/view/widgets/loader.dart';
import 'package:swift_contest/viewmodel/blocs/global_blocs/auth_bloc/auth_bloc.dart';
import 'package:swift_contest/viewmodel/enums/bloc_status.dart';

class SignUpVerifyPage extends StatefulWidget {
  final String email;
  const SignUpVerifyPage({required this.email, super.key});

  @override
  State<SignUpVerifyPage> createState() => _SignUpVerifyPageState();
}

class _SignUpVerifyPageState extends State<SignUpVerifyPage> {
  final _formKey = GlobalKey<FormState>();
  final _otpController = TextEditingController();

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
                      BlocConsumer<AuthBloc, AuthState>(
                        listener: (context, state) {
                          //* Show a message if there is one
                          if (state.blocStatus.isFailure) {
                            showSnackBar(context: context, text: state.message!);
                          }
                          //* Show a message to verify email and go to 'sign in' in case of success
                          if (state.blocStatus.isSuccess) {
                            switch(state.profile!.prefContestRole) {
                              case ContestRole.organizer:
                                context.goNamed(AppRouter.organizerHome);
                                break;
                              case ContestRole.participant:
                                context.goNamed(AppRouter.participantHome);
                                break;
                              case ContestRole.juror:
                                context.goNamed(AppRouter.jurorHome);
                                break;
                            }
                            // showDialog(
                            //   context: context,
                            //   builder: (context) => AlertDialog(
                            //     title: const Text('Verify email'),
                            //     content: Text(
                            //       'We have sent a verification link to your email address. '
                            //       'Please check your inbox and verify your account.',
                            //     ),
                            //     actions: [
                            //       TextButton(
                            //         onPressed: () {
                            //           context.pop();
                            //           context.goNamed(AppRouter.signIn);
                            //         },
                            //         child: const Text('OK'),
                            //       ),
                            //     ],
                            //   ),
                            // );
                          }
                        },
                        builder: (context, state) {
                          if (state.blocStatus.isLoading) {
                            return const Loader();
                          }
                          return Form(
                            key: _formKey,
                            child: Padding(
                              padding: EdgeInsets.all(16),
                              child: Column(
                                children: [
                                  //* Otp field
                                  CustomTextFormFieldOutlined(
                                    controller: _otpController,
                                    label: 'OTP',
                                    prefixIcon: Icon(Icons.lock),
                                  ),
                                  SizedBox(height: 10),
                                  //* Verify button
                                  SizedBox(
                                    width: double.infinity,
                                    child: ElevatedButton(
                                      onPressed: () {
                                        if (_formKey.currentState?.validate() ?? false) {
                                          context
                                              .read<AuthBloc>()
                                              .add(AuthSignUpVerifyOtp(email: widget.email, otp: _otpController.text.trim()));
                                        }
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Theme.of(context).colorScheme.primary,
                                        foregroundColor: Colors.white,
                                      ),
                                      child: const Text(
                                        'Verify',
                                        style: TextStyle(
                                          fontSize: 16.0,
                                          fontWeight: FontWeight.w500,
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
}
