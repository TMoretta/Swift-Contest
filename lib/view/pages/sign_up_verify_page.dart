import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:pinput/pinput.dart';
import 'package:swift_contest/view/widgets/show_snack_bar.dart';
import 'package:swift_contest/utils/router/go_router.dart';
import 'package:swift_contest/utils/validators/validators.dart';
import 'package:swift_contest/view/widgets/custom_app_bar.dart';
import 'package:swift_contest/view/widgets/loader.dart';
import 'package:swift_contest/view/widgets/otp_field.dart';
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
  late final FocusNode focusNode = FocusNode();

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
    focusNode.dispose();
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
      child: Scaffold(
        appBar: CustomAppBar(title: 'Verify account'),
        body: SafeArea(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Center(
              child: BlocBuilder<SignUpVerifyPageBloc, SignUpVerifyPageState>(
                builder: (context, state) {
                  switch (state.status) {
                    case BlocStatus.loading:
                      return Loader();
                    case BlocStatus.initial:
                    case BlocStatus.failure:
                    case BlocStatus.success:
                      return Form(
                        key: _formKey,
                        child: ListView(
                          shrinkWrap: true,
                          children: [
                            Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                OtpField(
                                  length: 6,
                                  controller: _otpController,
                                  validator: (value) => otpValidator(value, 6),
                                  focusNode: focusNode,
                                ),
                                SizedBox(height: 20),
                                ConstrainedBox(
                                  constraints: BoxConstraints(maxWidth: 100),
                                  child: FilledButton(
                                    onPressed: () {
                                      if (_formKey.currentState?.validate() ?? false) {
                                        context.read<SignUpVerifyPageBloc>().add(SignUpVerifyOtp(
                                            email: widget.email, otp: _otpController.text.trim()));
                                      }
                                    },
                                    child: const Text('Verify'),
                                  ),
                                ),
                              ],
                            )
                          ],
                        ),
                      );

                    // return Form(
                    //   key: _formKey,
                    //   child: Padding(
                    //     padding: EdgeInsets.all(16),
                    //     child: Column(
                    //       children: [
                    //         //* Otp field
                    //         CustomTextFormFieldOutlined(
                    //           controller: _otpController,
                    //           label: 'OTP',
                    //           prefixIcon: Icon(Icons.lock),
                    //         ),
                    //         SizedBox(height: 10),
                    //         //* Verify button
                    //         SizedBox(
                    //           width: double.infinity,
                    //           child: ElevatedButton(
                    //             onPressed: () {
                    //               if (_formKey.currentState?.validate() ?? false) {
                    //                 context.read<SignUpVerifyPageBloc>().add(SignUpVerifyOtp(
                    //                     email: widget.email,
                    //                     otp: _otpController.text.trim()));
                    //               }
                    //             },
                    //             style: ElevatedButton.styleFrom(
                    //               backgroundColor: Theme.of(context).colorScheme.primary,
                    //               foregroundColor: Colors.white,
                    //             ),
                    //             child: const Text(
                    //               'Verify',
                    //               style: TextStyle(
                    //                 fontSize: 16.0,
                    //                 fontWeight: FontWeight.w500,
                    //               ),
                    //             ),
                    //           ),
                    //         ),
                    //       ],
                    //     ),
                    //   ),
                    // );
                  }
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}
