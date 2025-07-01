import 'package:flutter/material.dart';
import 'package:pinput/pinput.dart';

class OtpField extends StatelessWidget {
  final int length;
  final TextEditingController? controller;
  final FocusNode? focusNode;
  final String? Function(String?)? validator;

  const OtpField({
    required this.length,
    this.controller,
    this.focusNode,
    this.validator,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Pinput(
      length: length,
      controller: controller,
      focusNode: focusNode,
      validator: validator,
      pinputAutovalidateMode: PinputAutovalidateMode.onSubmit,
      cursor: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Container(
            margin: const EdgeInsets.only(bottom: 8),
            width: 22,
            height: 1,
            color: Theme.of(context).colorScheme.primary,
          ),
        ],
      ),
      defaultPinTheme: PinTheme(
        width: 56,
        height: 56,
        textStyle: Theme.of(context).textTheme.bodyLarge,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: Theme.of(context).colorScheme.outline),
        ),
      ),
      focusedPinTheme: PinTheme(
        width: 56,
        height: 56,
        textStyle: Theme.of(context).textTheme.bodyLarge,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: Theme.of(context).colorScheme.primary),
        ),
      ),
      errorPinTheme: PinTheme(
        width: 56,
        height: 56,
        textStyle: Theme.of(context).textTheme.bodyLarge,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: Theme.of(context).colorScheme.error),
        ),
      ),
    );
  }
}
