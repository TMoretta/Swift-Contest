import 'package:auto_route/auto_route.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:swift_contest/utils/router/app_router.gr.dart';
import 'package:swift_contest/utils/validators/validators.dart';
import 'package:swift_contest/view/widgets/custom_app_bar.dart';
import 'package:swift_contest/view/widgets/otp_field.dart';
import 'package:swift_contest/view/widgets/overlay_loader.dart';
import 'package:swift_contest/view/widgets/show_snack_bar.dart';
import 'package:swift_contest/viewmodel/blocs/pages_blocs/sign_up_verify_page_bloc/sign_up_verify_page_bloc.dart';
import 'package:swift_contest/viewmodel/types/bloc_status.dart';

@RoutePage()
class SignUpVerifyPage extends StatefulWidget implements AutoRouteWrapper {
  final String email;

  const SignUpVerifyPage({
    @PathParam('email') required this.email,
    super.key,
  });

  @override
  State<SignUpVerifyPage> createState() => _SignUpVerifyPageState();

  @override
  Widget wrappedRoute(BuildContext context) {
    return BlocProvider<SignUpVerifyPageBloc>(
      create: (context) => SignUpVerifyPageBloc(
        authRepository: context.read(),
      ),
      child: this,
    );
  }
}

class _SignUpVerifyPageState extends State<SignUpVerifyPage> {
  final _formKey = GlobalKey<FormState>();
  final _otpController = TextEditingController();
  final _otpFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    if (kIsWeb) {
      BrowserContextMenu.disableContextMenu();
    }
  }

  @override
  void dispose() {
    context.hideLoader();
    if (kIsWeb) {
      BrowserContextMenu.enableContextMenu();
    }
    _otpController.dispose();
    _otpFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<SignUpVerifyPageBloc, SignUpVerifyPageState>(
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
        if (state.status.isSuccess && state.sourceEvent is SignUpVerifyOtp) {
          context.router.replaceAll([RootRoute()]);
        }
      },
      builder: (context, state) {
        return Scaffold(
          appBar: CustomAppBar(title: 'Verify account'),
          body: SafeArea(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Center(
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
                          OtpField(
                            length: 6,
                            controller: _otpController,
                            focusNode: _otpFocusNode,
                            validator: (value) => otpValidator(value, 6),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 72),
                  ],
                ),
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
        );
      },
    );
  }
}
