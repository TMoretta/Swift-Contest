import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:pinput/pinput.dart';
import 'package:swift_contest/view/widgets/obscured_loader.dart';
import 'package:swift_contest/view/widgets/show_snack_bar.dart';
import 'package:swift_contest/utils/router/go_router.dart';
import 'package:swift_contest/utils/validators/validators.dart';
import 'package:swift_contest/view/widgets/custom_app_bar.dart';
import 'package:swift_contest/view/widgets/loader.dart';
import 'package:swift_contest/view/widgets/otp_field.dart';
import 'package:swift_contest/view/widgets/void_widget.dart';
import 'package:swift_contest/viewmodel/blocs/pages_blocs/sign_up_verify_page_bloc/sign_up_verify_page_bloc.dart';
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
  void initState() {
    super.initState();
    if (kIsWeb) {
      BrowserContextMenu.disableContextMenu();
    }
  }

  @override
  void dispose() {
    if (kIsWeb) {
      BrowserContextMenu.enableContextMenu();
    }
    _otpController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<SignUpVerifyPageBloc, SignUpVerifyPageState>(
      listener: (context, state) {
        //* Show a message if there is one
        if (state.message != null) {
          showSnackBar(context: context, text: state.message!);
        }
        if (state.status.isSuccess && state.sourceEvent is SignUpVerifyOtp) {
          context.goNamed(AppRouter.root, extra: 0);
        }
      },
      child: Stack(
        alignment: Alignment.center,
        children: [
          Scaffold(
            appBar: CustomAppBar(title: 'Verify account'),
            body: SafeArea(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: BlocBuilder<SignUpVerifyPageBloc, SignUpVerifyPageState>(
                  builder: (context, state) {
                    return Center(
                      child: ListView(
                        shrinkWrap: true,
                        children: [
                          Text(
                            'A code has been sent to your email. Please check your inbox and verify your account.',
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.bodyLarge,
                          ),
                          SizedBox(height: 32),
                          Form(
                            key: _formKey,
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                FormField(
                                  validator: (value) => otpValidator(_otpController.text, 6),
                                  builder: (field) {
                                    return Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        OtpField(
                                          length: 6,
                                          controller: _otpController,
                                        ),
                                        if (field.hasError)
                                          SizedBox(height: 8),
                                        if (field.hasError)
                                          Text(
                                            'Enter a valid OTP',
                                            style: Theme.of(context).textTheme.labelLarge?.copyWith(
                                                color: Theme.of(context).colorScheme.error),
                                          ),
                                      ],
                                    );
                                  },
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
            floatingActionButton: FloatingActionButton.extended(
              onPressed: () {
                if (_formKey.currentState?.validate() ?? false) {
                  final otp = _otpController.text;
                  context
                      .read<SignUpVerifyPageBloc>()
                      .add(SignUpVerifyOtp(email: widget.email, otp: otp));
                }
              },
              label: const Text('Verify'),
            ),
          ),
          BlocBuilder<SignUpVerifyPageBloc, SignUpVerifyPageState>(
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
