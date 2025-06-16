import 'package:flutter/material.dart';
import 'package:pinput/pinput.dart';

class OtpField extends StatefulWidget {
  final int length;
  final TextEditingController? controller;
  final FocusNode? focusNode;
  final String? Function(String?)? validator;

  const OtpField(
      {required this.length, this.controller, this.focusNode, this.validator, super.key});

  @override
  State<OtpField> createState() => _OtpFieldState();
}

class _OtpFieldState extends State<OtpField> {
  @override
  Widget build(BuildContext context) {
    return Pinput(
      length: widget.length,
      controller: widget.controller,
      focusNode: widget.focusNode,
      validator: widget.validator,
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
