import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:swift_contest/utils/labels/labels.dart';
import 'package:swift_contest/utils/router/go_router.dart';
import 'package:swift_contest/view/widgets/custom_text_form_field.dart';
import 'package:swift_contest/view/widgets/overlay_loader.dart';
import 'package:swift_contest/view/widgets/show_snack_bar.dart';
import 'package:swift_contest/viewmodel/blocs/pages_blocs/sign_in_verify_page_bloc/sign_in_verify_page_bloc.dart';
import 'package:swift_contest/viewmodel/enums/bloc_status.dart';

class SignInVerifyPage extends StatefulWidget {
  final String email;

  const SignInVerifyPage({required this.email, super.key});

  @override
  State<SignInVerifyPage> createState() => _SignInVerifyPageState();
}

class _SignInVerifyPageState extends State<SignInVerifyPage> {
  final _formKey = GlobalKey<FormState>();
  final _otpController = TextEditingController();

  @override
  void dispose() {
    context.hideLoader();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<SignInVerifyPageBloc, SignInVerifyPageState>(
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
        //* Show a message to verify email and go to 'sign in' in case of success
        if (state.status.isSuccess && state.sourceEvent is SignInVerifyOtp) {
          context.goNamed(AppRouter.root, extra: 0);
        }
      },
      builder: (context, state) {
        return Scaffold(
          body: SafeArea(
            child: Center(
              child: ListView(
                shrinkWrap: true,
                children: [
                  //* Title
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        Labels.appTitle,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.primary,
                          fontSize: 48,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      Text(
                        Labels.appSubtitle,
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
                  Form(
                    key: _formKey,
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: Column(
                        children: [
                          //* Otp field
                          CustomTextFormField(
                            borderType: InputBorderType.outlined,
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
                                  context.read<SignInVerifyPageBloc>().add(SignInVerifyOtp(
                                      email: widget.email, otp: _otpController.text.trim()));
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
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
