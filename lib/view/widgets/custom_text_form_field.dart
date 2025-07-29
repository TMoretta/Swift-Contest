import 'package:flutter/material.dart';

enum InputBorderType { outlined, underlined }

class CustomTextFormField extends StatelessWidget {
  final InputBorderType borderType;
  final TextEditingController? controller;
  final FocusNode? focusNode;
  final String? label;
  final bool? readOnly;
  final FloatingLabelBehavior? floatingLabelBehavior;
  final Function(String)? onChanged;
  final String? Function(String?)? validator;
  final String? initialValue;
  final AutovalidateMode? autovalidateMode;
  final bool? isFilled;
  final Color? fillColor;
  final Widget? externalIcon;
  final Color? externalIconColor;
  final Widget? prefixIcon;
  final Color? prefixIconColor;
  final Widget? suffixIcon;
  final Color? suffixIconColor;
  final Widget? prefix;
  final TextStyle? prefixStyle;
  final Widget? suffix;
  final TextStyle? suffixStyle;
  final bool? enabled;
  final bool? obscureText;
  final TextInputType? keyboardType;
  final int? minLines;
  final int? maxLines;
  final bool? autofocus;

  const CustomTextFormField({
    required this.borderType,
    this.controller,
    this.focusNode,
    this.readOnly,
    this.label,
    this.floatingLabelBehavior,
    this.onChanged,
    this.validator,
    this.initialValue,
    this.autovalidateMode,
    this.isFilled,
    this.fillColor,
    this.externalIcon,
    this.externalIconColor,
    this.prefixIcon,
    this.prefixIconColor,
    this.suffixIcon,
    this.suffixIconColor,
    this.prefix,
    this.prefixStyle,
    this.suffix,
    this.suffixStyle,
    this.enabled,
    this.obscureText,
    this.keyboardType,
    this.minLines,
    this.maxLines,
    this.autofocus,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    InputBorder getBorder({
      required Color color,
      bool isFocused = false,
    }) {
      switch (borderType) {
        case InputBorderType.outlined:
          return OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: color, width: isFocused ? 2.0 : 1.0),
          );
        case InputBorderType.underlined:
          return UnderlineInputBorder(
            borderSide: BorderSide(color: color, width: isFocused ? 2.0 : 1.0),
          );
      }
    }
    return TextFormField(
      controller: controller,
      focusNode: focusNode,
      validator: validator,
      initialValue: initialValue,
      readOnly: readOnly ?? false,
      enabled: enabled,
      minLines: minLines ?? 1,
      maxLines: maxLines ?? 1,
      autofocus: autofocus ?? false,
      onTapOutside: (event) => focusNode?.unfocus(),
      onChanged: onChanged,
      obscureText: obscureText ?? false,
      autovalidateMode: autovalidateMode,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        label: Text(label ?? ''),
        floatingLabelBehavior: floatingLabelBehavior,
        filled: isFilled,
        fillColor: fillColor,
        icon: externalIcon,
        iconColor: externalIconColor,
        prefixIcon: prefixIcon,
        prefixIconColor: prefixIconColor,
        suffixIcon: suffixIcon,
        suffixIconColor: suffixIconColor,
        prefix: prefix,
        prefixStyle: prefixStyle,
        suffix: suffix,
        suffixStyle: suffixStyle,
        helperText: '',
        helperStyle: const TextStyle(height: 1),
        errorStyle: const TextStyle(height: 1),
        border: getBorder(color: Theme.of(context).colorScheme.outline),
        enabledBorder: getBorder(
          color: Theme.of(context).colorScheme.inversePrimary,
        ),
        errorBorder: getBorder(
          color: Theme.of(context).colorScheme.errorContainer,
        ),
        focusedBorder: getBorder(color: Theme.of(context).colorScheme.primary, isFocused: true),
        focusedErrorBorder: getBorder(color: Theme.of(context).colorScheme.error, isFocused: true),
      ),
    );
  }
}
